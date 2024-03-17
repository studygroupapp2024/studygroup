import 'package:flutter/material.dart';
import 'package:study_buddy/components/buttons/rounded_button.dart';

class StudyGroupContainer extends StatelessWidget {
  final void Function()? onTap;
  final String title;
  final String desc;
  final String members;
  final String identifier;

  const StudyGroupContainer(
      {super.key,
      required this.onTap,
      required this.title,
      required this.desc,
      required this.members,
      required this.identifier});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        height: 175,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(2, 5),
                color: Colors.black.withOpacity(0.1),
              ),
            ]),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 45,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                desc,
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.account_box_outlined),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    members,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              RoundedButton(
                text: identifier,
                onTap: onTap,
                margin: const EdgeInsets.symmetric(horizontal: 15),
                color: Theme.of(context).colorScheme.tertiaryContainer,
                textcolor: Theme.of(context).colorScheme.background,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
