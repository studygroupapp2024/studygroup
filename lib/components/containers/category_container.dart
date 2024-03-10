import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Category extends StatelessWidget {
  final String text;
  final String iconPath;
  final void Function()? onTap;

  const Category(
      {super.key,
      required this.text,
      required this.iconPath,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 140,
          width: 140,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 80,
                  alignment: Alignment.center,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      iconPath,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  text,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
