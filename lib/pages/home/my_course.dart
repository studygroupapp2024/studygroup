import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/components/containers/user_courses_container.dart';
import 'package:study_buddy/services/group/courses.dart';
import 'package:study_buddy/services/group/search.dart';

class FindCourses extends StatefulWidget {
  const FindCourses({super.key});

  @override
  State<FindCourses> createState() => _FindCoursesState();
}

final Courses _courses = Courses();
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class _FindCoursesState extends State<FindCourses> {
  // Current Courses
  late final Stream<QuerySnapshot<Object?>> _userCourses =
      getUserCoursesFunc(_firebaseAuth.currentUser!.uid);

  Stream<QuerySnapshot<Object?>> getUserCoursesFunc(String userId) {
    return _courses.getCurrentUserCourses(userId);
  }

  // Get Completed Courses
  late final Stream<QuerySnapshot<Object?>> _userCompletedCourses =
      getUserCompletedCoursesFunc(_firebaseAuth.currentUser!.uid);

  Stream<QuerySnapshot<Object?>> getUserCompletedCoursesFunc(String userId) {
    return _courses.getCompletedUserCourses(userId);
  }

  void markCompleted(String documentId) async {
    await _courses.markCompleted(documentId);
  }

  void deleteData(String documentId, courseId) async {
    await _courses.deleteCourse(documentId, courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Courses"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: CustomSearch());
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: ListView(
        children: [
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "My Courses",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 300,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _userCourses,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text("No Data");
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
                            height: 5,
                          );
                        },
                        itemBuilder: (context, index) {
                          var doc = snapshot.data!.docs[index];

                          var data = doc.data() as Map<String, dynamic>;
                          var documentId = doc.id;
                          var icon = (data["isCompleted"] == true
                              ? const Icon(Icons.delete)
                              : const Icon(Icons.check));
                          return MyCoursesContainer(
                            courseTitle: data["courseTitle"],
                            courseCode: data["courseCode"],
                            icon: icon,
                            onTap: () => markCompleted(documentId),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(
                  10,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Completed Courses",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 300,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _userCompletedCourses,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text("No Data");
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      print("Current Data: ${snapshot.data!.docs}");
                      return ListView.separated(
                        itemCount: snapshot.data!.docs.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 5,
                          );
                        },
                        itemBuilder: (context, index) {
                          var doc = snapshot.data!.docs[index];

                          var data = doc.data() as Map<String, dynamic>;
                          var documentId = doc.id;
                          var icon = (data["isCompleted"] == true
                              ? const Icon(Icons.delete)
                              : const Icon(Icons.check));
                          return MyCoursesContainer(
                            courseCode: data["courseTitle"],
                            courseTitle: data["courseCode"],
                            icon: icon,
                            onTap: () =>
                                deleteData(documentId, data["courseId"]),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
