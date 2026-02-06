import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart'; // Optional but recommended
import 'package:TunisiaBook/constants/theme.dart';
import 'package:provider/provider.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isSpeechEnabled = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  /// Initialize the SpeechToText instance
  void _initSpeech() async {
    // Optionally request permission explicitly if needed,
    // though initialize() usually handles it.
    await Permission.microphone.request();

    _isSpeechEnabled = await _speech.initialize(
      onStatus: (status) {
        // If the system stops listening (e.g., silence timeout), update UI
        if (status == 'notListening' || status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (errorNotification) {
        setState(() => _isListening = false);
        debugPrint('Speech Error: ${errorNotification.errorMsg}');
      },
    );
    setState(() {});
  }

  /// Start listening with a 3-second silence timeout
  void _startListening() async {
    if (!_isSpeechEnabled) {
      // Try initializing again if it failed previously
      _initSpeech();
      return;
    }

    setState(() => _isListening = true);

    await _speech.listen(
      onResult: (result) {
        setState(() {
          // Update the text field in real-time
          widget.controller.text = result.recognizedWords;
        });

        // AUTO-SEND LOGIC:
        // If the result is final (user stopped speaking and processing is done),
        // send the message automatically.
        if (result.finalResult) {
          setState(() => _isListening = false);
          if (widget.controller.text.trim().isNotEmpty) {
            widget.onSend();
            // Optional: Clear controller here if your onSend doesn't do it
            // widget.controller.clear();
          }
        }
      },
      // This is the key parameter for the "3 seconds of silence" requirement
      pauseFor: const Duration(seconds: 3),
      // Optional: stop if user doesn't speak at all for 10s
      listenFor: const Duration(seconds: 10),
      localeId: "fr_FR", // Set your preferred locale (e.g., French)
      cancelOnError: true,
      listenMode: stt.ListenMode.dictation,
    );
  }

  /// Manually stop listening (if user taps the mic button again)
  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    // Highlight border when listening
                    color: _isListening
                        ? theme.primary
                        : theme.text.withOpacity(0.1),
                    width: _isListening ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        style: TextStyle(
                          color: theme.text,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: _isListening
                              ? 'Écoute en cours...'
                              : 'Posez une question...',
                          hintStyle: TextStyle(
                            color: _isListening
                                ? theme.primary
                                : theme.text.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => widget.onSend(),
                      ),
                    ),
                    // Mic Button
                    IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic_off : Icons.mic,
                        // Change color to indicate active state
                        color: _isListening
                            ? theme.primary
                            : theme.text.withOpacity(0.6),
                      ),
                      onPressed: _isListening ? _stopListening : _startListening,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primary,
                    theme.primary.withOpacity(0.8),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: widget.onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}