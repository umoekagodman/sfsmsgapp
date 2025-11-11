// chat_composer.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

import '../../../common/themes.dart';
import '../../../states/system_state.dart';
import '../../../utilities/functions.dart';
import '../../../utilities/image_uploader.dart';
import '../../../utilities/voice_recorder.dart';
import '../../../widgets/snackbars.dart';
import '../../../widgets/timer.dart';

class ChatComposer extends ConsumerStatefulWidget {
  final String? conversationId;
  final Map<String, dynamic>? conversation;
  final Map<String, dynamic>? user;
  final List<dynamic>? selectedContacts;
  final Function(Map<String, dynamic>)? onSendMessage;
  final Function(Map<String, dynamic>)? onNewMessage;

  const ChatComposer({
    super.key,
    this.conversationId,
    this.conversation,
    this.user,
    this.selectedContacts,
    this.onSendMessage,
    this.onNewMessage,
  });

  @override
  ConsumerState<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends ConsumerState<ChatComposer> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _typingTimer;
  bool _isTyping = false;
  String _imageUrl = '';
  bool _uploadingImage = false;
  String _voiceNoteUrl = '';
  bool _isRecording = false;
  bool _showEmojiPicker = false;
  bool _showCaptionField = false;
  String _caption = '';

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final wasTyping = _isTyping;
    _isTyping = _textController.text.trim().isNotEmpty;
    if (_isTyping != wasTyping) {
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(milliseconds: 300), () {
        _updateTypingStatus(_isTyping);
      });
    }
    setState(() {}); // rebuild to toggle send/mic
  }

  Future<void> _updateTypingStatus(bool typing) async {
    final $system = ref.read(systemProvider);
    if (!isTrue($system['chat_typing_enabled'])) return;
    if (widget.conversation == null || widget.conversation!.isEmpty) return;

    await sendAPIRequest(
      'chat/reactions/typing',
      method: 'POST',
      body: {
        'is_typing': typing,
        'conversation_id': widget.conversation!['conversation_id'],
      },
    );
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _imageUrl.isEmpty && _voiceNoteUrl.isEmpty) return;

    // Keep behavior identical to your existing API usage
    final response = await sendAPIRequest(
      'chat/message',
      method: 'POST',
      body: {
        if (text.isNotEmpty) 'message': text,
        if (_imageUrl.isNotEmpty) 'photo': _imageUrl,
        if (_voiceNoteUrl.isNotEmpty) 'voice_note': _voiceNoteUrl,
        if (_caption.isNotEmpty) 'caption': _caption,
        if (widget.conversation != null && widget.conversation!.isNotEmpty)
          'conversation_id': widget.conversation!['conversation_id'],
        if ((widget.conversation == null || widget.conversation!.isEmpty) && widget.user != null)
          'recipients': [widget.user!['user_id']].toString(),
        if (widget.selectedContacts != null && widget.selectedContacts!.isNotEmpty)
          'recipients': widget.selectedContacts!.map((e) => e['user_id']).toList().toString(),
      },
    );

    if (response['statusCode'] == 200 && response['body']['data'] is Map) {
      widget.onNewMessage?.call(response['body']['data']);
      widget.onSendMessage?.call(response['body']['data']);
      _resetInput();
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(snackBarWarning(response['body']['message'] ?? tr("There is something that went wrong!")));
    }
  }

  void _resetInput() {
    setState(() {
      _textController.clear();
      _isTyping = false;
      _imageUrl = '';
      _uploadingImage = false;
      _voiceNoteUrl = '';
      _isRecording = false;
      _showEmojiPicker = false;
      _showCaptionField = false;
      _caption = '';
    });
  }

  Future<void> _deleteImage() async {
    final src = _imageUrl;
    setState(() => _imageUrl = '');
    await sendAPIRequest('data/delete', method: 'POST', body: {'src': src});
  }

  Future<void> _pickImage() async {
    setState(() => _uploadingImage = true);
    final url = await showImageUploadOptions(
      context: context,
      setUploadingState: (uploading) => setState(() => _uploadingImage = uploading),
    );
    if (url != null) {
      // show local preview (we have the uploaded URL from API). Telegram shows local preview but for compatibility we show preview and wait for send.
      setState(() {
        _imageUrl = url;
        _showCaptionField = true;
      });
    } else {
      setState(() {
        _uploadingImage = false;
      });
    }
  }

  Future<void> _startOrStopRecording() async {
    if (!_isRecording) {
      await VoiceRecorder().startRecording(
        context: context,
        setRecordingState: (recording) => setState(() => _isRecording = recording),
      );
    } else {
      final url = await VoiceRecorder().stopRecording(
        context: context,
        setRecordingState: (recording) => setState(() => _isRecording = recording),
      );
      if (url != null) {
        setState(() => _voiceNoteUrl = url);
        await _sendMessage();
      }
    }
  }

  Future<void> _showClipboardPicker() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text ?? '';
    // Best-effort clipboard picker - Flutter does not expose full clipboard history
    if (text.isEmpty) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(snackBarWarning(tr('Clipboard is empty')));
      return;
    }
    final pasted = await showModalBottomSheet<String?>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tr('Clipboard'), style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SingleChildScrollView(child: Text(text)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, null),
                        child: Text(tr('Cancel')),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, text),
                        child: Text(tr('Paste')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (pasted != null) {
      final newText = (_textController.text.isEmpty) ? pasted : '${_textController.text}$pasted';
      _textController.text = newText;
      _textController.selection = TextSelection.fromPosition(TextPosition(offset: newText.length));
      setState(() => _showEmojiPicker = false);
    }
  }

  // Small emoji grid
  Widget _emojiPicker() {
    const emojis = [
      '😀','😂','😍','🤔','👍','👎','🙏','🔥','🎉','🙌','😢','😁',
      '😎','😉','🤷','😅','🤩','😇','🤝','👏'
    ];
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: GridView.count(
        crossAxisCount: 8,
        padding: const EdgeInsets.all(10),
        children: emojis.map((e) {
          return GestureDetector(
            onTap: () {
              final current = _textController.text;
              final selection = _textController.selection;
              final newText = current.replaceRange(selection.start, selection.end, e);
              _textController.text = newText;
              final pos = selection.start + e.length;
              _textController.selection = TextSelection.fromPosition(TextPosition(offset: pos));
              setState(() => _showEmojiPicker = false);
              _focusNode.requestFocus();
            },
            child: Center(child: Text(e, style: const TextStyle(fontSize: 20))),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    VoiceRecorder().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final $system = ref.read(systemProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Telegram style: flat rounded white bar (or dark variant)
    final inputBg = isDark ? const Color(0xFF222222) : Colors.white;
    final hintColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final screenWidth = MediaQuery.of(context).size.width;

    Widget composer = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [

        // Expanded input + image preview
Expanded(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Inline image preview + caption
      if (_imageUrl.isNotEmpty)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "${$system['system_uploads']}/$_imageUrl",
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.error),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: TextEditingController(text: _caption),
                      onChanged: (v) => _caption = v,
                      decoration: InputDecoration(
                        hintText: tr('Add a caption...'),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      maxLines: 3,
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 20, color: Colors.red),
                        onPressed: _deleteImage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

      // Telegram-style flat input bar (all buttons inside, full width)
      Container(
        color: inputBg,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            // Emoji button
            IconButton(
              onPressed: () {
                setState(() {
                  _showEmojiPicker = !_showEmojiPicker;
                  if (_showEmojiPicker) {
                    _focusNode.unfocus();
                  } else {
                    _focusNode.requestFocus();
                  }
                });
              },
              icon: Icon(
                _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions_outlined,
                color: xPrimaryColor,
              ),
              splashRadius: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),

            // Attachment button
            IconButton(
              onPressed: _pickImage,
              icon: SvgPicture.asset(
                "assets/images/icons/chat/attach.svg",
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  isDark ? Colors.white70 : Colors.black54,
                  BlendMode.srcIn,
                ),
              ),
              splashRadius: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),

            // Text field
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 1,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: tr('Speak your mind...'),
                  hintStyle: TextStyle(color: hintColor, fontSize: 16),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                contextMenuBuilder: (context, editableTextState) {
                  final List<ContextMenuButtonItem> buttonItems = editableTextState.contextMenuButtonItems;
                  return AdaptiveTextSelectionToolbar.buttonItems(
                    anchors: editableTextState.contextMenuAnchors,
                    buttonItems: [
                      ...buttonItems,
                      ContextMenuButtonItem(
                        label: tr('Clipboard'),
                        onPressed: () {
                          editableTextState.hideToolbar();
                          _showClipboardPicker();
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            // Mic / Send
            IconButton(
              icon: Icon(
                _isTyping || _imageUrl.isNotEmpty || _voiceNoteUrl.isNotEmpty
                    ? Icons.send
                    : (_isRecording ? Icons.stop : Icons.mic),
                color: xPrimaryColor,
              ),
              onPressed: _isTyping || _imageUrl.isNotEmpty || _voiceNoteUrl.isNotEmpty
                  ? _sendMessage
                  : _startOrStopRecording,
              splashRadius: 20,
            ),
          ],
        ),
      ),
    ],
  ),
),

      // Mic / Send button
      if (_isTyping || _imageUrl.isNotEmpty || _voiceNoteUrl.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.send, color: xPrimaryColor),
          onPressed: _sendMessage,
          splashRadius: 20,
        )
      else
        IconButton(
          icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: xPrimaryColor),
          onPressed: _startOrStopRecording,
          splashRadius: 20,
        ),
    ],
  ),
),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Right: mic or send depending on typing or other attachments
        if (_isTyping || _imageUrl.isNotEmpty || _voiceNoteUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: xPrimaryColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: _isRecording ? Colors.red : xPrimaryColor,
              child: IconButton(
                icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white),
                onPressed: _startOrStopRecording,
              ),
            ),
          ),
      ],
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            composer,
            // emoji picker area
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _showEmojiPicker ? _emojiPicker() : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
