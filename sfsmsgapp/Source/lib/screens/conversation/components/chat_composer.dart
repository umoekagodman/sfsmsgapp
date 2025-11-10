import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:easy_localization/easy_localization.dart';

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
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _typingTimer;
  bool _isTyping = false;
  String _imageUrl = '';
  bool _uploadingImage = false;
  String _voiceNoteUrl = '';
  bool _isRecording = false;
  bool _showEmoji = false;

  // Send message
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _imageUrl.isEmpty && _voiceNoteUrl.isEmpty) return;

    final response = await sendAPIRequest(
      'chat/message',
      method: 'POST',
      body: {
        if (text.isNotEmpty) 'message': text,
        if (_imageUrl.isNotEmpty) 'photo': _imageUrl,
        if (_voiceNoteUrl.isNotEmpty) 'voice_note': _voiceNoteUrl,
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
      _showEmoji = false;
    });
  }

  // Typing indicator
  void _handleTyping(String value) {
    final wasTyping = _isTyping;
    _isTyping = value.trim().isNotEmpty;

    if (_isTyping != wasTyping) {
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(milliseconds: 500), () {
        _updateTypingStatus(_isTyping);
      });
    }
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

  // Delete uploaded image
  Future<void> _deleteImage() async {
    final src = _imageUrl;
    setState(() => _imageUrl = '');
    await sendAPIRequest('data/delete', method: 'POST', body: {'src': src});
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final $system = ref.read(systemProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final hintColor = isDark ? Colors.grey[400] : Colors.grey[600];
    // FIX: Provide non-null default colors
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

    final bool hasText = _textController.text.trim().isNotEmpty;
    final bool showSendButton = hasText || _imageUrl.isNotEmpty || _voiceNoteUrl.isNotEmpty;

    return Column(
      children: [
        // Image Preview
        if (_imageUrl.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      "${$system['system_uploads']}/$_imageUrl",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: -8,
                  right: -8,
                  child: IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                    onPressed: _deleteImage,
                  ),
                ),
              ],
            ),
          ),

        // Main Input Row
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Attachment Button (Always visible like WhatsApp)
                if (isTrue($system['chat_photos_enabled']))
                  Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    child: IconButton(
                      onPressed: () async {
                        setState(() => _uploadingImage = true);
                        final url = await showImageUploadOptions(
                          context: context,
                          setUploadingState: (uploading) => setState(() => _uploadingImage = uploading),
                        );
                        if (url != null) setState(() => _imageUrl = url);
                      },
                      icon: Icon(Icons.attach_file, color: xPrimaryColor, size: 24),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ),

                // Emoji/GIF Button
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: IconButton(
                    onPressed: () {
                      // TODO: Implement emoji picker
                      // For now, toggle between emoji and GIF
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: Icon(
                      _showEmoji ? Icons.emoji_emotions : Icons.gif,
                      color: xPrimaryColor,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                ),

                // Text Input (Expandable like WhatsApp/Telegram)
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 120, // 6 lines maximum
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      minLines: 1,
                      maxLines: null, // Allows auto-expansion
                      decoration: InputDecoration(
                        hintText: tr('Type a message...'),
                        hintStyle: TextStyle(color: hintColor, fontSize: 16),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                      onChanged: _handleTyping,
                      onSubmitted: (_) {
                        if (showSendButton) _sendMessage();
                      },
                    ),
                  ),
                ),

                // Send/Voice Button
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 8),
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    child: showSendButton
                        ? IconButton(
                            key: ValueKey('send'),
                            onPressed: _sendMessage,
                            icon: Container(
                              decoration: BoxDecoration(
                                color: xPrimaryColor,
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.send, color: Colors.white, size: 20),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                          )
                        : isTrue($system['voice_notes_chat_enabled'])
                            ? Row(
                                key: ValueKey('voice'),
                                children: [
                                  if (_isRecording) ...[
                                    TimerWidget(),
                                    SizedBox(width: 8),
                                  ],
                                  IconButton(
                                    onPressed: () async {
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
                                    },
                                    icon: Container(
                                      decoration: BoxDecoration(
                                        color: _isRecording ? Colors.red : xPrimaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        _isRecording ? Icons.stop : Icons.mic,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                                  ),
                                ],
                              )
                            : SizedBox(width: 40), // Placeholder for consistent spacing
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
