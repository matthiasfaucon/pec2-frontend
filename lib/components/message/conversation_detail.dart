import 'package:flutter/material.dart';
import 'package:firstflutterapp/components/message/conversation_item.dart';
import 'package:firstflutterapp/components/message/message_bubble.dart';
import 'package:firstflutterapp/components/message/message_input.dart';

class ConversationDetail extends StatelessWidget {
  final List<PrivateMessage> messages;
  final TextEditingController messageController;
  final Function(String) onSendMessage;
  final String otherPersonName;

  const ConversationDetail({
    Key? key,
    required this.messages,
    required this.messageController,
    required this.onSendMessage,
    required this.otherPersonName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child:
              messages.isEmpty
                  ? const Center(
                    child: Text(
                      'Commencez à discuter',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(message: messages[index]);
                    },
                  ),
        ),
        MessageInput(
          controller: messageController,
          onSend: onSendMessage,
          receiverName: otherPersonName,
        ),
      ],
    );
  }
}
