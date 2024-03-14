import 'package:flutter/material.dart';

class RoundedTextFieldTitle extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String hinttext;
  const RoundedTextFieldTitle({
    super.key,
    required this.title,
    required this.controller,
    required this.hinttext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            obscureText: false,
            minLines: 1,
            maxLines: 3,
            controller: controller,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.tertiary),
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(20),
                ),
                fillColor: Theme.of(context).colorScheme.secondary,
                filled: true,
                hintText: hinttext,
                hintStyle:
                    TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }
}
