import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/components/buttons/rounded_button.dart';
import 'package:study_buddy/components/containers/add_course_container.dart';
import 'package:study_buddy/components/textfields/rounded_textfield.dart';
import 'package:study_buddy/services/group/courses.dart';
import 'package:study_buddy/services/group/group_services.dart';

class CreateStudyGroup extends StatefulWidget {
  const CreateStudyGroup({super.key});

  @override
  State<CreateStudyGroup> createState() => _CreateStudyGroupState();
}

class _CreateStudyGroupState extends State<CreateStudyGroup> {
  bool isSubmitted = false;
  int selectedIndex = -1;
  String course = '';
  String courseId = '';
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
    if (_grpNameController.text.isNotEmpty &&
        _grpDescController.text.isNotEmpty &&
        course.isNotEmpty &&
        courseId.isNotEmpty) {
      await _groupService.sendGroupChatInfo(
        _grpNameController.text,
        _grpDescController.text,
        course,
        courseId,
      );
      _grpNameController.clear();
      _grpDescController.clear();
      course = '';
      courseId = '';
      selectedIndex = -1;
      setState(() {
        isSubmitted = true;
      });
    }
  }

  void add() {}
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Create Study Group"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
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
                textcolor: Theme.of(context).colorScheme.primary,
              ),
              const Padding(
                padding: EdgeInsets.only(
                  left: 25,
                  top: 10,
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
              Expanded(
                child: StreamBuilder(
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
                      return ListView.separated(
                        itemCount: snapshot.data!.docs.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 10,
                          );
                        },
                        itemBuilder: (context, index) {
                          var doc = snapshot.data!.docs[index];

                          var data = doc.data() as Map<String, dynamic>;
                          return isSubmitted
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                      course = data["courseTitle"];
                                      courseId = data["courseId"];
                                    });
                                  },
                                  child: SelectionCourse(
                                    courseTitle: data["courseTitle"],
                                    courseCode: data["courseCode"],
                                    color: selectedIndex == index
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .tertiaryContainer,
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                      course = data["courseTitle"];
                                      courseId = data["courseId"];
                                    });
                                  },
                                  child: SelectionCourse(
                                    courseTitle: data["courseTitle"],
                                    courseCode: data["courseCode"],
                                    color: selectedIndex == index
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .tertiaryContainer,
                                  ),
                                );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
