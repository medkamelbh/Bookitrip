import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TunisiaBook/models/chat_message.dart';

class ChatService {
  final String chatBaseUrl = 'https://backend.tunisiabook.com';

  String? _sessionId;
  String? _userId;

  static const Duration requestTimeout = Duration(seconds: 80);
  static const String _userIdKey = 'tunisiabook_user_id';

  Future<void> initialize() async {
    _userId = await _getOrCreateUserId();
    print('Initialized with user ID: $_userId');
    _sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<String> _getOrCreateUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String? existingUserId = prefs.getString(_userIdKey);

      if (existingUserId != null && existingUserId.isNotEmpty) {
        print('Using existing user ID: $existingUserId');
        return existingUserId;
      } else {
        final newUserId = 'user_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';

        await prefs.setString(_userIdKey, newUserId);
        print('Created new user ID: $newUserId');

        return newUserId;
      }
    } catch (e) {
      print('Error managing user ID: $e');
      return 'user_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Get the current user ID
  Future<String?> getCurrentUserId() async {
    if (_userId != null) return _userId;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Clear user ID
  Future<void> clearUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      _userId = null;
      print('User ID cleared');
    } catch (e) {
      print('Error clearing user ID: $e');
    }
  }

  Future<Map<String, dynamic>> sendMessage(String message) async {
    if (_userId == null) {
      await initialize();
    }

    try {
      final response = await http
          .post(
        Uri.parse('$chatBaseUrl/utilisateur/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'session_id': _sessionId,
          'user_id': _userId,
        }),
      )
          .timeout(
        requestTimeout,
        onTimeout: () {
          throw TimeoutException(
            'La connexion a pris trop de temps. Veuillez réessayer.',
          );
        },
      );

      if (response.statusCode == 200) {
        print('RAW RESPONSE: ${response.body}');
        return jsonDecode(response.body) as Map<String, dynamic>;

      } else if (response.statusCode == 408) {
        throw TimeoutException('Le serveur a mis trop de temps à répondre.');
      } else if (response.statusCode >= 500) {
        throw Exception('Erreur du serveur. Veuillez réessayer plus tard.');
      } else {
        throw Exception('Erreur Innatendu. Veuillez réessayer...');
      }
    } on TimeoutException catch (e) {
      throw Exception('Délai d\'attente dépassé');
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion! Vérifiez votre connexion Internet.');
    } on FormatException catch (e) {
      throw Exception('Réponse invalide du serveur');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  // Start a new conversation (new session, same user)
  void startNewConversation() {
    _sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Get conversation history
  Future<List<Map<String, dynamic>>> getConversationHistory() async {
    if (_userId == null) {
      await initialize();
    }

    try {
      final response = await http
          .post(
        Uri.parse('$chatBaseUrl/utilisateur/conversations/history'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': _userId,
        }),
      )
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['conversations'] ?? []);
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Timeout loading conversation history');
    } on http.ClientException catch (e) {
      throw Exception('Connection error loading history: ${e.message}');
    } catch (e) {
      throw Exception('Error loading history: $e');
    }
  }

  /// Load a specific conversation
  Future<Map<String, dynamic>> loadConversation(String sessionId) async {
    if (_userId == null) {
      await initialize();
    }

    try {
      final response = await http
          .post(
        Uri.parse('$chatBaseUrl/utilisateur/conversations/load'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'session_id': sessionId,
          'user_id': _userId,
        }),
      )
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        _sessionId = sessionId;

        return data;
      } else {
        throw Exception('Failed to load conversation: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Timeout loading conversation');
    } on http.ClientException catch (e) {
      throw Exception('Connection error: ${e.message}');
    } catch (e) {
      throw Exception('Error loading conversation: $e');
    }
  }

  /// Delete a conversation
  Future<void> deleteConversation(String sessionId) async {
    if (_userId == null) {
      await initialize();
    }

    try {
      final response = await http
          .post(
        Uri.parse('$chatBaseUrl/utilisateur/conversations/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'session_id': sessionId,
          'user_id': _userId,
        }),
      )
          .timeout(requestTimeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete conversation: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Timeout deleting conversation');
    } on http.ClientException catch (e) {
      throw Exception('Connection error: ${e.message}');
    } catch (e) {
      throw Exception('Error deleting conversation: $e');
    }
  }

  /// Convert conversation data to ChatMessage list
  List<ChatMessage> conversationToMessages(Map<String, dynamic> conversation) {
    final messages = <ChatMessage>[];

    try {
      print('Converting conversation: ${conversation.keys}');

      if (conversation.containsKey('history')) {
        final messageList = conversation['history'] as List;
        print('Found ${messageList.length} messages in history');

        for (var msg in messageList) {
          try {
            final bool isUser;
            if (msg.containsKey('role')) {
              isUser = msg['role'] == 'user';
            } else {
              isUser = msg['is_user'] ?? false;
            }

            final text = msg['content'] ?? msg['text'] ?? '';

            if (text.isNotEmpty) {
              messages.add(
                ChatMessage(
                  text: text,
                  isUser: isUser,
                  timestamp: msg.containsKey('timestamp')
                      ? _parseTimestamp(msg['timestamp'])
                      : DateTime.now(),
                  isMarkdown: !isUser,
                ),
              );
            }
          } catch (e) {
            print('Error parsing individual message: $e');
          }
        }
      }
      else if (conversation.containsKey('messages')) {
        final messageList = conversation['messages'] as List;
        print('Found ${messageList.length} messages in messages array');

        for (var msg in messageList) {
          try {
            final bool isUser;
            if (msg.containsKey('role')) {
              isUser = msg['role'] == 'user';
            } else {
              isUser = msg['is_user'] ?? false;
            }

            final text = msg['content'] ?? msg['text'] ?? '';

            // Only add non-empty messages
            if (text.isNotEmpty) {
              messages.add(
                ChatMessage(
                  text: text,
                  isUser: isUser,
                  timestamp: msg.containsKey('timestamp')
                      ? _parseTimestamp(msg['timestamp'])
                      : DateTime.now(),
                  isMarkdown: !isUser,
                ),
              );
            }
          } catch (e) {
            print('Error parsing individual message: $e');
          }
        }
      }
    } catch (e) {
      print('Error parsing conversation messages: $e');
      print('Conversation structure: $conversation');
    }

    print('Converted ${messages.length} messages total');
    return messages;
  }

  /// Parse timestamp from various formats
  DateTime _parseTimestamp(dynamic timestamp) {
    try {
      if (timestamp is String) {
        return DateTime.parse(timestamp);
      } else if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } catch (e) {
      print('Error parsing timestamp: $e for value: $timestamp');
    }
    return DateTime.now();
  }

  String? get currentSessionId => _sessionId;
  String? get currentUserId => _userId;
}