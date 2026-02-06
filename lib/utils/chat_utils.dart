import 'dart:async';
import 'package:TunisiaBook/models/chat_message.dart';
import 'package:TunisiaBook/services/api_chatbot.dart';

/// Get assistant response from API only
Future<ChatMessage> getAssistantResponse(
    String userMessage,
    ChatService chatService,
    ) async {
  try {
    final response = await chatService.sendMessage(userMessage);

    final responseText = response['response'] ??
        'Désolé, je n\'ai pas compris.';

    return ChatMessage(
      text: responseText,
      isUser: false,
      timestamp: DateTime.now(),
      isMarkdown: true,
    );
  } catch (e) {
    return ChatMessage(
      text: '⚠ Une erreur s\'est produite: ${e.toString()}',
      isUser: false,
      timestamp: DateTime.now(),
      isMarkdown: false,
    );
  }
}

/// Alternative: Get response with retry logic
Future<ChatMessage> getAssistantResponseWithRetry(
    String userMessage,
    ChatService chatService, {
      int maxRetries = 2,
    }) async {
  int retryCount = 0;

  while (retryCount <= maxRetries) {
    try {
      final response = await chatService.sendMessage(userMessage);
      final responseText = response['response'] ??
          'Désolé, je n\'ai pas compris.';

      return ChatMessage(
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
        isMarkdown: true,
      );
    } catch (e) {
      retryCount++;

      if (retryCount > maxRetries) {
        String errorMessage;
        if (e.toString().contains('Timeout') ||
            e.toString().contains('Délai')) {
          errorMessage = 'Le serveur prend trop de temps à répondre. Veuillez réessayer.';
        } else if (e.toString().contains('Connection') ||
            e.toString().contains('connexion')) {
          errorMessage = 'Problème de connexion. Vérifiez votre Internet.';
        } else {
          errorMessage = 'Une erreur s\'est produite. Veuillez réessayer.';
        }

        return ChatMessage(
          text: '⚠ $errorMessage',
          isUser: false,
          timestamp: DateTime.now(),
          isMarkdown: false,
        );
      }

      await Future.delayed(Duration(seconds: retryCount * 2));
    }
  }

  return ChatMessage(
    text: '⚠ Une erreur inattendue s\'est produite.',
    isUser: false,
    timestamp: DateTime.now(),
    isMarkdown: false,
  );
}