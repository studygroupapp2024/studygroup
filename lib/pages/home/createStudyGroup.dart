import 'package:flutter/material.dart';
import 'package:study_buddy/components/buttons/rounded_button.dart';
import 'package:study_buddy/components/textfields/rounded_textfield.dart';
import 'package:study_buddy/services/group/group_services.dart';

class CreateStudyGroup extends StatelessWidget {
  final TextEditingController _grpNameController = TextEditingController();
  final TextEditingController _grpDescController = TextEditingController();
  final GroupService _groupService = GroupService();

  CreateStudyGroup({super.key});

  void create() async {
    if (_grpNameController.text.isNotEmpty &&
        _grpDescController.text.isNotEmpty) {
      await _groupService.sendGroupChatInfo(
          _grpNameController.text, _grpDescController.text);
      _grpNameController.clear();
      _grpDescController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Study Group"),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 25,
          ),
          RoundedTextField(
              hintText: "Group Name",
              obscureText: false,
              controller: _grpNameController),
          const SizedBox(
            height: 25,
          ),
          RoundedTextField(
              hintText: "Group Description",
              obscureText: false,
              controller: _grpDescController),
          const SizedBox(
            height: 25,
          ),
          RoundedButton(
              text: "Create Study Group",
              onTap: create,
              margin: const EdgeInsets.symmetric(horizontal: 25),
              color: Theme.of(context).colorScheme.tertiaryContainer,
              textcolor: Theme.of(context).colorScheme.primary)
        ],
      ),
    );
  }
}
