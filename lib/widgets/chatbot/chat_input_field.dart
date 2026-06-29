import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:BookiTrip/constants/theme.dart';
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

  void _initSpeech() async {
    await Permission.microphone.request();

    _isSpeechEnabled = await _speech.initialize(
      onStatus: (status) {
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

  void _startListening() async {
    if (!_isSpeechEnabled) {
      _initSpeech();
      return;
    }

    setState(() => _isListening = true);

    await _speech.listen(
      onResult: (result) {
        setState(() {
          widget.controller.text = result.recognizedWords;
        });

        if (result.finalResult) {
          setState(() => _isListening = false);
          if (widget.controller.text.trim().isNotEmpty) {
            widget.onSend();
          }
        }
      },
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(seconds: 10),
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
      ),
      localeId: "fr_FR",
    );
  }

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
            color: Colors.black.withValues(alpha: 0.05),
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
                    color: _isListening
                        ? theme.primary
                        : theme.text.withValues(alpha: 0.1),
                    width: _isListening ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        style: TextStyle(color: theme.text, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: _isListening
                              ? 'Écoute en cours...'
                              : 'Posez une question...',
                          hintStyle: TextStyle(
                            color: _isListening
                                ? theme.primary
                                : theme.text.withValues(alpha: 0.5),
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => widget.onSend(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic_off : Icons.mic,
                        color: _isListening
                            ? theme.primary
                            : theme.text.withValues(alpha: 0.6),
                      ),
                      onPressed: _isListening
                          ? _stopListening
                          : _startListening,
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
                  colors: [theme.primary, theme.primary.withValues(alpha: 0.8)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.3),
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
