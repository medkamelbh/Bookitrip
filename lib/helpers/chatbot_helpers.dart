import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:TunisiaBook/models/chat_message.dart';
import 'package:TunisiaBook/services/api_chatbot.dart';

class ChatHelpers {
  /// Scroll to the bottom of the chat
  static void scrollToBottom(ScrollController scrollController) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Handle quick chip tap
  static String handleQuickChipTap(String label) {
    return label.replaceAll(RegExp(r'[^\w\s]'), '');
  }

  /// Send a message and handle the response with retry logic
  static Future<void> sendMessage({
    required String message,
    required ChatService chatService,
    required Function(ChatMessage) onAddMessage,
    required Function(bool) onTypingChange,
    required VoidCallback onScrollToBottom,
    required Function(String) onError,
    int maxRetries = 2,
  }) async {
    final userMessage = ChatMessage(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
      isMarkdown: false,
    );
    onAddMessage(userMessage);
    onScrollToBottom();

    onTypingChange(true);

    int retryCount = 0;
    while (retryCount <= maxRetries) {
      try {
        final response = await chatService.sendMessage(message);

        onTypingChange(false);

        final String botResponse = response['response'] ??
            'Désolé, je n\'ai pas compris.';

        final botMessage = ChatMessage(
          text: botResponse,
          isUser: false,
          timestamp: DateTime.now(),
          isMarkdown: true,
        );
        onAddMessage(botMessage);
        onScrollToBottom();

        return;

      } catch (e) {
        retryCount++;

        if (retryCount > maxRetries) {
          onTypingChange(false);

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

          onError(errorMessage);

          // Add error message to chat
          final errorBotMessage = ChatMessage(
            text: '⚠ $errorMessage',
            isUser: false,
            timestamp: DateTime.now(),
            isMarkdown: false,
          );
          onAddMessage(errorBotMessage);
          onScrollToBottom();

          return;
        }

        // Wait before retrying
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
  }

  /// Start a new conversation
  static List<ChatMessage> startNewConversation(ChatService chatService) {
    chatService.startNewConversation();
    return [
      ChatMessage(
        text: "Bonjour ! Je suis votre assistant. Comment puis-je vous aider à explorer la Tunisie aujourd'hui ?",
        isUser: false,
        timestamp: DateTime.now(),
        isMarkdown: false,
      )
    ];
  }

  /// Show conversation history bottom sheet
  static Future<void> showConversationHistory({
    required BuildContext context,
    required ChatService chatService,
    required Function(String) onLoadConversation,
  }) async {
    try {
      final conversations = await chatService.getConversationHistory();

      if (!context.mounted) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.history, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Historique des Conversations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: conversations.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun historique de conversation',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conv = conversations[index];
                    final title = conv['title'] ?? 'Conversation';
                    final updatedAt = conv['updated_at'] ?? '';
                    final sessionId = conv['session_id'] ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.chat,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Mis à jour: ${_formatDate(updatedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red[400],
                          onPressed: () async {
                            // Show confirmation dialog
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Supprimer la conversation'),
                                content: const Text(
                                  'Êtes-vous sûr de vouloir supprimer cette conversation ?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              try {
                                await chatService.deleteConversation(sessionId);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  showConversationHistory(
                                    context: context,
                                    chatService: chatService,
                                    onLoadConversation: onLoadConversation,
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erreur de suppression: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          onLoadConversation(sessionId);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Load a specific conversation
  static Future<List<ChatMessage>?> loadConversation({
    required BuildContext context,
    required ChatService chatService,
    required String sessionId,
  }) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Chargement de la conversation...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final conversation = await chatService.loadConversation(sessionId);

      // Debug print to see what we received
      print('Loaded conversation data: $conversation');

      final messages = chatService.conversationToMessages(conversation);

      // Debug print to see parsed messages
      print('Parsed ${messages.length} messages');

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 16),
                Text('Conversation chargée avec succès'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      return messages;
    } catch (e) {
      print('Error loading conversation: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Text('Erreur: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return null;
    }
  }

  /// Format date string for display - handles HTTP date format
  static String _formatDate(String dateStr) {
    try {
      DateTime date;

      // Try parsing standard ISO format first
      try {
        date = DateTime.parse(dateStr);
      } catch (e) {
        // Parse HTTP date format: "Mon, 15 Dec 2025 08:53:51 GMT"
        date = DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en_US').parse(dateStr);
      }

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Aujourd\'hui ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Hier ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} jours';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      print('Date parsing error: $e for date: $dateStr');
      return dateStr.substring(0, dateStr.length > 20 ? 20 : dateStr.length);
    }
  }
}