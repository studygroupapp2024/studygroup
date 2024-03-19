import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final Alignment alignment;
  final Color backgroundColor;
  final Color textColor;
  final BorderRadiusGeometry? borderRadius;

  final String senderMessage;
  const ChatBubble({
    super.key,
    required this.alignment,
    required this.senderMessage,
    required this.backgroundColor,
    required this.textColor,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: IntrinsicWidth(
        child: Container(
          alignment: alignment,
          padding: const EdgeInsets.only(
            right: 15,
            left: 15,
            top: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
          ),
          child: Text(
            senderMessage,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
