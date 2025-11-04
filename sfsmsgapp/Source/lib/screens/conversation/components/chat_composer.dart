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
    final inputBg = isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100;
    final hintColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attach Photo
            if (isTrue($system['chat_photos_enabled']) && _imageUrl.isEmpty && !_uploadingImage)
              IconButton(
                onPressed: () async {
                  setState(() => _uploadingImage = true);
                  final url = await showImageUploadOptions(
                    context: context,
                    setUploadingState: (uploading) => setState(() => _uploadingImage = uploading),
                  );
                  if (url != null) setState(() => _imageUrl = url);
                },
                icon: SvgPicture.asset(
                  "assets/images/icons/chat/image.svg",
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(xPrimaryColor, BlendMode.srcIn),
                ),
              ),

            // Uploading Spinner
            if (_uploadingImage)
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: const SpinKitCircle(color: xPrimaryColor, size: 20),
              ),

            // Image Preview
            if (_imageUrl.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: xPrimaryColor, width: 1.5),
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
                      top: -6,
                      right: -6,
                      child: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                        onPressed: _deleteImage,
                      ),
                    ),
                  ],
                ),
              ),

            // Text Input (Expandable)
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 1,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: tr('Speak your mind...'),
                    hintStyle: TextStyle(color: hintColor, fontSize: 16),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                  onChanged: _handleTyping,
                  onSubmitted: (_) => _sendMessage(), // Done = send
                ),
              ),
            ),

            // Send Button
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
              ),

            // Voice Button
            if (isTrue($system['voice_notes_chat_enabled']) && !_isTyping && _imageUrl.isEmpty && _voiceNoteUrl.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    if (_isRecording) ...[
                      const TimerWidget(),
                      const SizedBox(width: 8),
                    ],
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: _isRecording ? Colors.red : xPrimaryColor,
                      child: IconButton(
                        icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white),
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
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
