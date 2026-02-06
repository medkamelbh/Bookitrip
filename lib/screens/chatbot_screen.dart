import 'package:TunisiaBook/helpers/chatbot_helpers.dart';
import 'package:TunisiaBook/services/api_chatbot.dart';
import 'package:TunisiaBook/widgets/chatbot/ChatMessagesList.dart';
import 'package:TunisiaBook/widgets/chatbot/chat_appBar.dart';
import 'package:flutter/material.dart';
import 'package:TunisiaBook/constants/theme.dart';
import 'package:TunisiaBook/models/chat_message.dart';
import 'package:TunisiaBook/widgets/chatbot/chat_input_field.dart';
import 'package:TunisiaBook/screens/mainScreen_container.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ChatService _chatService = ChatService();

  bool _isTyping = false;
  bool _isInitialized = false;
  late AnimationController _typingController;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      await _chatService.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _messages.add(
            ChatMessage(
              text: 'chatbot.welcome'.tr(),
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Initialization error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || !_isInitialized) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    await ChatHelpers.sendMessage(
      message: userMessage,
      chatService: _chatService,
      onAddMessage: (message) {
        setState(() {
          _messages.add(message);
        });
      },
      onTypingChange: (isTyping) {
        setState(() {
          _isTyping = isTyping;
        });
      },
      onScrollToBottom: () => ChatHelpers.scrollToBottom(_scrollController),
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      },
    );
  }

  void _handleQuickChipTap(String label) {
    _messageController.text = ChatHelpers.handleQuickChipTap(label);
  }

  void _toggleDrawer() {
    final containerState = context
        .findAncestorStateOfType<MainScreenContainerState>();
    containerState?.toggleDrawer();
  }

  void _startNewConversation() {
    setState(() {
      _messages.clear();
      _messages.addAll(ChatHelpers.startNewConversation(_chatService));
    });
  }

  Future<void> _showConversationHistory() async {
    await ChatHelpers.showConversationHistory(
      context: context,
      chatService: _chatService,
      onLoadConversation: _loadConversation,
    );
  }

  Future<void> _loadConversation(String sessionId) async {
    final messages = await ChatHelpers.loadConversation(
      context: context,
      chatService: _chatService,
      sessionId: sessionId,
    );

    if (messages != null) {
      setState(() {
        _messages.clear();
        _messages.addAll(messages);
      });
      ChatHelpers.scrollToBottom(_scrollController);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: ChatAppBar(
        theme: theme,
        onBack: () => context.go('/home'),
        onMenuTap: _toggleDrawer,
      ),
      body: _isInitialized
          ? Column(
              children: [
                SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 2,
                  ),
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: _startNewConversation,
                        icon: Icon(Icons.add, color: theme.primary),
                        label: Text(
                          'chatbot.new_conversation'.tr(),
                          style: TextStyle(color: theme.primary),
                        ),
                      ),
                      const Spacer(),
                      /*TextButton.icon(
                        onPressed: _showConversationHistory,
                        icon: Icon(Icons.history, color: theme.primary),
                        label: Text(
                          'chatbot.history'.tr(),
                          style: TextStyle(color: theme.primary),
                        ),
                      ),*/
                    ],
                  ),

                ),
                Divider(
                    color: theme.text.withOpacity(0.1),
                    thickness: 1
                ),
                /*ChatQuickSuggestions(
                  theme: theme,
                  onChipTap: _handleQuickChipTap,
                ),*/
                ChatMessagesList(
                  scrollController: _scrollController,
                  messages: _messages,
                  isTyping: _isTyping,
                  typingController: _typingController,
                ),
                ChatInputField(
                  controller: _messageController,
                  onSend: _sendMessage,
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
