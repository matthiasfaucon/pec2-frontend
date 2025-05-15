import 'package:flutter/material.dart';
import 'package:firstflutterapp/components/message/conversation_item.dart';

class ConversationList extends StatelessWidget {
  final List<PrivateMessage> conversations;
  final Function(PrivateMessage) onConversationTap;

  const ConversationList ({
    Key? key,
    required this.conversations,
    required this.onConversationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) {
      return const Center(
        child: Text(
          'Aucun message pour le moment',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      itemCount: conversations.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final message = conversations[index];
        return ConversationItem(
          message: message,
          onTap: () => onConversationTap(message),
        );
      },
    );
  }
}
