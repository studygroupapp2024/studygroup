import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/components/buttons/rounded_button.dart';
import 'package:study_buddy/components/textfields/rounded_textfield_title.dart';
import 'package:study_buddy/services/group/courses.dart';
import 'package:study_buddy/services/group/group_services.dart';

class CreateStudyGroup extends StatefulWidget {
  const CreateStudyGroup({super.key});

  @override
  State<CreateStudyGroup> createState() => _CreateStudyGroupState();
}

class _CreateStudyGroupState extends State<CreateStudyGroup> {
  final TextEditingController _grpNameController = TextEditingController();

  final TextEditingController _grpDescController = TextEditingController();

  final GroupService _groupService = GroupService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final Courses _courses = Courses();

  // Current Courses
  late final Stream<QuerySnapshot<Object?>> _userCourses =
      getUserCoursesFunc(_firebaseAuth.currentUser!.uid);

  Stream<QuerySnapshot<Object?>> getUserCoursesFunc(String userId) {
    return _courses.getCurrentUserCourses(userId);
  }

  void create() async {
    FocusScope.of(context).unfocus();
    if (_grpNameController.text.isNotEmpty &&
        _grpDescController.text.isNotEmpty &&
        _selectedCourse.isNotEmpty) {
      print("OUTPUT: ${_grpNameController.text}");
      print("OUTPUT: ${_grpDescController.text}");
      print("OUTPUT: $_selectedCourse");
      print("OUTPUT: $_selectedCourseId");
      await _groupService.sendGroupChatInfo(_grpNameController.text,
          _grpDescController.text, _selectedCourse, _selectedCourseId);
      _grpNameController.clear();
      _grpDescController.clear();
      _selectedCourse = '';
      _selectedCourseId = '';
    }
  }

  late String _selectedCourse = '';
  late String _selectedCourseId = '';
  @override
  Widget build(BuildContext context) {
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
                    title: "Name",
                    controller: _grpNameController,
                    hinttext: "What is the name of the study group?",
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 25,
                      bottom: 10,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Courses",
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      StreamBuilder(
                        stream: _userCourses,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text("ERROR");
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            var data = snapshot.data!.docs;

                            var courseCodes = <Map<String, dynamic>>[];
                            for (var doc in data) {
                              var courseCode =
                                  doc.data() as Map<String, dynamic>;
                              courseCodes.add(courseCode);
                            }
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  children: courseCodes.map((code) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: FilterChip(
                                        label: Text(code['courseCode']),
                                        selected: _selectedCourse ==
                                            code['courseCode'],
                                        onSelected: (bool selected) {
                                          setState(() {
                                            _selectedCourse = selected
                                                ? code['courseCode']
                                                : '';
                                            _selectedCourseId = selected
                                                ? code['courseId']
                                                : '';
                                          });
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  RoundedTextFieldTitle(
                    title: "Description",
                    controller: _grpDescController,
                    hinttext:
                        "Let other students know about the purpose of the study group.",
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  RoundedButton(
                    text: "Create Study Group",
                    onTap: create,
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    textcolor: Theme.of(context).colorScheme.primary,
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
