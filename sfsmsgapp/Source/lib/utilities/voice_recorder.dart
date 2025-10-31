import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:easy_localization/easy_localization.dart';

// Import App Files
import '../widgets/snackbars.dart';
import 'functions.dart';

class VoiceRecorder {
  static final VoiceRecorder _instance = VoiceRecorder._internal();
  factory VoiceRecorder() => _instance;
  VoiceRecorder._internal();

  final AudioRecorder _recorder = AudioRecorder();
  String? _fileName;
  String? _recordPath;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  Future<void> startRecording({
    required BuildContext context,
    required Function(bool isRecording) setRecordingState,
  }) async {
    if (_isRecording) return;
    if (await requestMicPermission()) {
      if (await _recorder.hasPermission()) {
        try {
          final directory = await getTemporaryDirectory();
          _fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
          _recordPath = '${directory.path}/$_fileName';
          _isRecording = true;
          setRecordingState(true);
          await _recorder.start(const RecordConfig(), path: _recordPath!);
        } catch (e) {
          _isRecording = false;
          setRecordingState(false);
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              snackBarError(tr('Failed to start recording')),
            );
        }
      }
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          snackBarError(tr('Microphone permission not granted')),
        );
    }
  }

  Future<String?> stopRecording({
    required BuildContext context,
    required Function(bool isRecording) setRecordingState,
  }) async {
    if (!_isRecording || _recordPath == null) return null;
    try {
      await _recorder.stop();
      _isRecording = false;
      setRecordingState(false);
      final response = await sendAPIRequest(
        'data/upload',
        method: 'UPLOAD',
        body: <String, String>{
          'type': 'audio',
          'handle': 'voice_notes',
          'multiple': 'false',
          'name': _fileName!,
          'guid': getGUID(),
        },
        files: [_recordPath!],
      );
      if (response['statusCode'] == 200) {
        return response['body']['data'];
      } else {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            snackBarError(response['body']['message']),
          );
      }
    } catch (e) {
      _isRecording = false;
      setRecordingState(false);
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          snackBarError(tr('Failed to stop recording')),
        );
    }
    return null;
  }

  Future<void> dispose() async {
    if (_isRecording) {
      await _recorder.stop();
      _isRecording = false;
    }
    await _recorder.dispose();
  }
}
