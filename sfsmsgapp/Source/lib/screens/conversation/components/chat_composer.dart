import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
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
  bool _uploading = false;
  String _voiceUrl = '';
  bool _recording = false;
  bool _locked = false; // WhatsApp “slide to cancel” lock

  @override
  void dispose() {
    _typingTimer?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _textController.clear();
      _isTyping = false;
      _imageUrl = '';
      _uploading = false;
      _voiceUrl = '';
      _recording = false;
      _locked = false;
    });
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _imageUrl.isEmpty && _voiceUrl.isEmpty) return;

    final body = {
      if (text.isNotEmpty) 'message': text,
      if (_imageUrl.isNotEmpty) 'photo': _imageUrl,
      if (_voiceUrl.isNotEmpty) 'voice_note': _voiceUrl,
      if (widget.conversation != null) 'conversation_id': widget.conversation!['conversation_id'],
      if (widget.user != null) 'recipients': [widget.user!['user_id']].toString(),
      if (widget.selectedContacts != null)
        'recipients': widget.selectedContacts!.map((e) => e['user_id']).toList().toString(),
    };

    final resp = await sendAPIRequest('chat/message', method: 'POST', body: body);
    if (resp['statusCode'] == 200) {
      widget.onNewMessage?.call(resp['body']['data']);
      widget.onSendMessage?.call(resp['body']['data']);
      _reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(snackBarWarning(resp['body']['message'] ?? tr("Error")));
    }
  }

  void _onTyping(String v) {
    final typing = v.trim().isNotEmpty;
    if (typing == _isTyping) return;
    _isTyping = typing;
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 800), () => _updateTyping(typing));
  }

  Future<void> _updateTyping(bool typing) async {
    if (widget.conversation == null) return;
    await sendAPIRequest('chat/reactions/typing', method: 'POST', body: {
      'is_typing': typing,
      'conversation_id': widget.conversation!['conversation_id'],
    });
  }

  Future<void> _pickImage() async {
    setState(() => _uploading = true);
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xFile == null) {
      setState(() => _uploading = false);
      return;
    }
    final url = await uploadImage(File(xFile.path), onProgress: (p) => setState(() {}));
    if (url != null) _imageUrl = url;
    setState(() => _uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    final $system = ref.read(systemProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF202020) : const Color(0xFFF1F3F4);
    final inputBg = dark ? const Color(0xFF2C2C2C) : Colors.white;

    return Container(
      color: bg,
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
        top: 8,
      ),
      child: Row(
        children: [
          // Emoji button (Telegram style)
          IconButton(
            icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey[600]),
            onPressed: () {},
          ),

          // Image preview OR attach button
          if (_imageUrl.isNotEmpty)
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage("${$system['system_uploads']}/$_imageUrl"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: -8,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red, size: 22),
                    onPressed: () => setState(() => _imageUrl = ''),
                  ),
                ),
              ],
            )
          else if (!_uploading)
            IconButton(
              icon: SvgPicture.asset(
                "assets/images/icons/chat/image.svg",
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(xPrimaryColor, BlendMode.srcIn),
              ),
              onPressed: _pickImage,
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SpinKitCircle(color: xPrimaryColor, size: 24),
            ),

          // Text field + voice button inside
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 140),
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(fontSize: 16, color: dark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: tr('Speak your mind...'),
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onChanged: _onTyping,
                    ),
                  ),

                  // Voice / Send button
                  GestureDetector(
                    onLongPressStart: (_) async {
                      if (_locked) return;
                      setState(() => _recording = true);
                      await VoiceRecorder().startRecording(
                        context: context,
                        setRecordingState: (r) => setState(() => _recording = r),
                      );
                    },
                    onLongPressEnd: (_) async {
                      if (_locked) return;
                      final url = await VoiceRecorder().stopRecording(context: context);
                      if (url != null) {
                        _voiceUrl = url;
                        _send();
                      }
                      setState(() => _recording = false);
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: _textController.text.isNotEmpty || _imageUrl.isNotEmpty ? xPrimaryColor : Colors.transparent,
                      child: Icon(
                        _textController.text.isNotEmpty || _imageUrl.isNotEmpty
                            ? Icons.send_rounded
                            : (_recording ? Icons.mic : Icons.mic_none),
                        color: _textController.text.isNotEmpty || _imageUrl.isNotEmpty ? Colors.white : Colors.grey[600],
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
