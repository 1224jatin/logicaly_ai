import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  void Function(String status)? _onStatus;

  Future<bool> initialize() async {
    // The status listener is set during initialization in newer versions of the plugin
    return await _speech.initialize(
      onStatus: (status) => _onStatus?.call(status),
    );
  }

  void startListening({
    required void Function(String text) onResult,
    void Function(String status)? onStatus,
  }) {
    // We store the status callback to be used by the global listener
    _onStatus = onStatus;
    _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      // Note: onStatus is no longer a parameter of the listen method in 7.x
    );
  }

  void stopListening() {
    _speech.stop();
  }

  bool get isListening => _speech.isListening;
}
