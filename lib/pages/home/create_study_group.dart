import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:study_buddy/components/buttons/rounded_button.dart';
import 'package:study_buddy/components/dialogs/create_group.dart';
import 'package:study_buddy/components/no_data_holder.dart';
import 'package:study_buddy/components/textfields/rounded_textfield_title.dart';
import 'package:study_buddy/pages/home/my_courses.dart';
import 'package:study_buddy/structure/providers/course_provider.dart';
import 'package:study_buddy/structure/providers/create_group_chat_providers.dart';
import 'package:study_buddy/structure/providers/groupchat_provider.dart';

class CreateStudyGroup extends ConsumerWidget {
  CreateStudyGroup({super.key});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserCourse = ref.watch(
      currentStudentCoursesInformationProvider(_auth.currentUser!.uid),
    );
    final selectedCourse = ref.watch(selectedCourseProvider);
    final courseId = ref.watch(selectedcourseIdProvider);

    final buttonColor = ref.watch(buttonColorProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Create Study Group"),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  RoundedTextFieldTitle(
                    title: "What is the name of the study group?",
                    hinttext: "Name",
                    controller: _nameController,
                    onChange: (val) {
                      ref.read(chatNameProvider.notifier).state = val;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 25,
                      bottom: 10,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "What course is the study group for?",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: currentUserCourse.when(data: (currentCourses) {
                          if (currentCourses.isEmpty) {
                            return Center(
                              child: NoContent(
                                  icon:
                                      'assets/icons/study-student_svgrepo.com.svg',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FindCourses(),
                                      ),
                                    );
                                  },
                                  description: "You have no enrolled courses.",
                                  buttonText: "Enroll in a course"),
                            );
                          } else {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                children: currentCourses.map((completed) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: FilterChip(
                                      label: Text(completed.courseCode),
                                      selected: selectedCourse ==
                                          completed.courseCode,
                                      onSelected: (bool selected) {
                                        ref
                                            .read(
                                                selectedCourseProvider.notifier)
                                            .state = completed.courseCode;
                                        ref
                                            .read(selectedcourseIdProvider
                                                .notifier)
                                            .state = completed.courseId;
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          }
                        }, error: (error, stackTrace) {
                          return Center(
                            child: Text('Error: $error'),
                          );
                        }, loading: () {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  RoundedTextFieldTitle(
                    title: "What is the study group all about?",
                    controller: _descriptionController,
                    hinttext:
                        "Let other students know about the purpose of the study group.",
                    onChange: (val) {
                      ref.read(chatDescriptionProvider.notifier).state = val;
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  RoundedButton(
                    text: "Create Study Group",
                    onTap: () async {
                      final success =
                          await ref.read(groupChatProvider).addStudyGroup(
                                _nameController.text,
                                _descriptionController.text,
                                selectedCourse.toString(),
                                courseId.toString(),
                              );

                      if (success) {
                        _nameController.clear();
                        _descriptionController.clear();
                        ref.read(selectedCourseProvider.notifier).state = '';
                        ref.read(selectedcourseIdProvider.notifier).state = '';
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const CreateGroupChatDialog(
                              confirm: null,
                              content: "The group chat has been created",
                              title: "Success",
                              type: "Okay",
                            );
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const CreateGroupChatDialog(
                              confirm: null,
                              content:
                                  "There was an error creating the study group. Kindly try again.",
                              title: "Failed",
                              type: "Okay",
                            );
                          },
                        );
                      }
                    },
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    color: buttonColor
                        ? const Color(0xff9494ff)
                        : const Color(0xff939cc4),
                    textcolor: Theme.of(context).colorScheme.background,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
