import 'package:firstflutterapp/theme.dart';
import 'package:flutter/material.dart';

class ConfirmPopup extends StatelessWidget {
  final String? headerMessage;
  final String? contentMessage;

  const ConfirmPopup({
    super.key,
    this.headerMessage,
    this.contentMessage,
  });

  void showPopup(BuildContext context, headerMessage, contentMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(headerMessage),
          content: Text(contentMessage),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showPopup(context, headerMessage, contentMessage);
      },
      icon: Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.darkColor,
            width: 1,
          ),
          color: Colors.transparent,
        ),
        child: Icon(
          Icons.question_mark_outlined,
          color: AppTheme.darkColor,
          size: 12,
        ),
      ),
    );
  }
}
