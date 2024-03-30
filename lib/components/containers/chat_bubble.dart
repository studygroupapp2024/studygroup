import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final Alignment alignment;
  final Color backgroundColor;
  final Color textColor;
  final BorderRadiusGeometry? borderRadius;
  final TextAlign? textAlign;
  final double? fontSize;
  final void Function()? onTap;

  final String senderMessage;
  const ChatBubble({
    super.key,
    required this.alignment,
    required this.senderMessage,
    required this.backgroundColor,
    required this.textColor,
    required this.borderRadius,
    required this.textAlign,
    required this.fontSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          constraints: const BoxConstraints(maxWidth: 250),
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
            textWidthBasis: TextWidthBasis.parent,
            textAlign: textAlign,
            senderMessage,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}
