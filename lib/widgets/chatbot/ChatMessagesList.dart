import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:BookiTrip/models/chat_message.dart';
import 'package:BookiTrip/constants/theme.dart';
import 'package:provider/provider.dart';
import 'chat_data_cards.dart';

class ChatMessagesList extends StatelessWidget {
  final ScrollController scrollController;
  final List<ChatMessage> messages;
  final bool isTyping;
  final AnimationController typingController;

  const ChatMessagesList({
    super.key,
    required this.scrollController,
    required this.messages,
    required this.isTyping,
    required this.typingController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.background,
              theme.background.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: messages.length + (isTyping ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == messages.length) {
              return _buildTypingIndicator(theme);
            }

            final message = messages[index];
            final isFirstInGroup = index == 0 ||
                messages[index - 1].isUser != message.isUser;
            final isLastInGroup = index == messages.length - 1 ||
                messages[index + 1].isUser != message.isUser;

            return _buildMessageBubble(
              context,
              message,
              theme,
              isFirstInGroup,
              isLastInGroup,
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
      BuildContext context,
      ChatMessage message,
      AppTheme theme,
      bool isFirstInGroup,
      bool isLastInGroup,
      ) {
    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInGroup ? 8 : 2,
        bottom: isLastInGroup ? 8 : 2,
      ),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser && isLastInGroup) ...[
            _buildAvatar(theme, message.isUser),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: !message.isUser || message.isMarkdown
                  ? _buildMarkdownWithCards(context, message, theme)
                  : _buildSimpleMessage(context, message, theme, isFirstInGroup, isLastInGroup),
            ),
          ),
          if (message.isUser && isLastInGroup) ...[
            const SizedBox(width: 8),
            _buildAvatar(theme, message.isUser),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(AppTheme theme, bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? theme.CardBG! : theme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isUser ? theme.primary : theme.primary).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy_outlined,
        color: isUser ? theme.primary : Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildSimpleMessage(
      BuildContext context,
      ChatMessage message,
      AppTheme theme,
      bool isFirstInGroup,
      bool isLastInGroup,
      ) {
    final isError = message.text.startsWith('⚠') || message.text.startsWith('❌');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: message.isUser
            ? LinearGradient(
          colors: [theme.primary, theme.primary.withValues(alpha: 0.65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: message.isUser
            ? null
            : (isError
            ? Colors.red.shade50
            : theme.isDark? theme.background: Colors.white),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(message.isUser || !isFirstInGroup ? 20 : 4),
          topRight: Radius.circular(!message.isUser || !isFirstInGroup ? 20 : 4),
          bottomLeft: Radius.circular(message.isUser || !isLastInGroup ? 20 : 4),
          bottomRight: Radius.circular(!message.isUser || !isLastInGroup ? 20 : 4),
        ),
        boxShadow: [
          BoxShadow(
            color: message.isUser
                ? theme.text.withValues(alpha: 0.4)
                : theme.isDark? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: message.isUser ? Colors.white : theme.text,
          fontSize: 15,
          height: 1.4,
          fontWeight: message.isUser ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildMarkdownWithCards(
      BuildContext context,
      ChatMessage message,
      AppTheme theme,
      ) {
    final parsedContent = _parseMarkdownContent(message.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...parsedContent.map((content) {
          if (content['type'] == 'table') {
            return _buildTableAsCards(context, content['data'], theme);
          } else {
            return _buildMarkdownSection(context, content['data'], theme);
          }
        }),
        if (message.data != null) ...[
          const SizedBox(height: 8),
          ChatDataCards(data: message.data!, theme: theme),
        ]
      ],
    );
  }

  Widget _buildMarkdownSection(
      BuildContext context,
      String markdown,
      AppTheme theme,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.isDark ? theme.background : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: MarkdownBody(
        data: markdown,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            color: theme.text,
            fontSize: 15,
            height: 1.5,
          ),
          h1: TextStyle(
            color: theme.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
          h2: TextStyle(
            color: theme.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
          h3: TextStyle(
            color: theme.primary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
          listBullet: TextStyle(
            color: theme.primary,
            fontSize: 15,
          ),
          blockquote: TextStyle(
            color: theme.primary,
            fontStyle: FontStyle.italic,
            fontSize: 14,
          ),
          blockquoteDecoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: theme.primary,
                width: 3,
              ),
            ),
          ),
          code: TextStyle(
            color: theme.primary,
            backgroundColor: theme.primary.withValues(alpha: 0.1),
            fontSize: 14,
            fontFamily: 'monospace',
          ),
        ),
        selectable: true,
      ),
    );
  }

  Widget _buildTableAsCards(
      BuildContext context,
      List<Map<String, dynamic>> tableData,
      AppTheme theme,
      ) {
    return Column(
      children: tableData.asMap().entries.map((entry) {
        final index = entry.key;
        final row = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.CardBG!.withValues(alpha: 0.7),
                theme.primary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.primary.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: theme.primary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                // Card header with gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primary.withValues(alpha: 0.15),
                        theme.secondary.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                ),
                // Card content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: row.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: theme.primary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: Text(
                                entry.value.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.text,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _parseMarkdownContent(String markdown) {
    final List<Map<String, dynamic>> content = [];
    final lines = markdown.split('\n');

    List<String> currentSection = [];
    List<String> tableLines = [];
    bool inTable = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.contains('|') && !inTable) {
        if (currentSection.isNotEmpty) {
          content.add({
            'type': 'markdown',
            'data': currentSection.join('\n'),
          });
          currentSection = [];
        }
        inTable = true;
        tableLines.add(line);
      } else if (line.contains('|') && inTable) {
        tableLines.add(line);
      } else if (inTable && !line.contains('|')) {
        if (tableLines.length > 2) {
          final tableData = _parseTable(tableLines);
          if (tableData.isNotEmpty) {
            content.add({
              'type': 'table',
              'data': tableData,
            });
          }
        }
        tableLines = [];
        inTable = false;
        currentSection.add(line);
      } else {
        currentSection.add(line);
      }
    }

    if (inTable && tableLines.length > 2) {
      final tableData = _parseTable(tableLines);
      if (tableData.isNotEmpty) {
        content.add({
          'type': 'table',
          'data': tableData,
        });
      }
    } else if (currentSection.isNotEmpty) {
      content.add({
        'type': 'markdown',
        'data': currentSection.join('\n'),
      });
    }

    return content;
  }

  List<Map<String, dynamic>> _parseTable(List<String> tableLines) {
    if (tableLines.length < 2) return [];

    final headers = tableLines[0]
        .split('|')
        .map((h) => h.trim())
        .where((h) => h.isNotEmpty)
        .toList();

    final List<Map<String, dynamic>> rows = [];

    for (int i = 2; i < tableLines.length; i++) {
      final cells = tableLines[i]
          .split('|')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();

      if (cells.length == headers.length) {
        final Map<String, dynamic> row = {};
        for (int j = 0; j < headers.length; j++) {
          row[headers[j]] = cells[j];
        }
        rows.add(row);
      }
    }

    return rows;
  }

  Widget _buildTypingIndicator(AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAvatar(theme, false),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0, theme),
                const SizedBox(width: 6),
                _buildDot(1, theme),
                const SizedBox(width: 6),
                _buildDot(2, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, AppTheme theme) {
    return AnimatedBuilder(
      animation: typingController,
      builder: (context, child) {
        final value = (typingController.value + (index * 0.33)) % 1.0;
        final scale = 0.6 + (value * 0.4);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primary.withValues(alpha: 0.4 + (value * 0.6)),
                  theme.secondary.withValues(alpha: 0.4 + (value * 0.6)),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withValues(alpha: 0.3 * value),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}