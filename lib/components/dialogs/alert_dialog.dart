import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final void Function()? confirm;
  final String content;

  const ConfirmationDialog({
    super.key,
    required this.confirm,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirmation"),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("No"),
        ),
        TextButton(
          onPressed: () {
            confirm?.call();
            Navigator.of(context).pop();
          },
          child: const Text("Yes"),
        ),
      ],
    );
  }
}
