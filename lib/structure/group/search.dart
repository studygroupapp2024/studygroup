import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/structure/group/courses.dart';

class CustomSearch extends SearchDelegate {
  final Courses _courses = Courses();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late final Stream<QuerySnapshot<Object?>> courses = getCourses();

  Stream<QuerySnapshot<Object?>> getCourses() {
    return _courses.getCourses();
  }

  late List<Map<String, dynamic>> _filteredList = [];

  void filteredList() {
    courses.listen((QuerySnapshot<Object?> snapshot) {
      List<Map<String, dynamic>> contents = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> studentIds = data['studentId'] ?? [];
        if (!studentIds.contains(_firebaseAuth.currentUser!.uid)) {
          print(data);
          contents.add({'id': doc.id, 'data': data});
        }
      }
      _filteredList = contents;
    });
  }

  void joinCourse(String courseCode, courseTitle, courseId) async {
    await _courses.addCourse(courseCode, courseTitle, courseId);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(
          Icons.clear,
        ),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(
        Icons.arrow_back,
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    filteredList();
    return StreamBuilder<QuerySnapshot>(
      stream: courses,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Has Error");
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return ListView.builder(
            itemCount: _filteredList.length,
            itemBuilder: (context, index) {
              var doc = _filteredList[index];

              var documentId = doc['id'];
              var icon = (doc['data']['studentId'] as List<dynamic>)
                      .contains(_firebaseAuth.currentUser!.uid)
                  ? const Icon(Icons.check)
                  : const Icon(Icons.add_circle_outline_outlined);
              var onTap = (doc['data']['studentId'] as List<dynamic>)
                      .contains(_firebaseAuth.currentUser!.uid)
                  ? () => null
                  : () => joinCourse(
                        doc['data']["subject_code"],
                        doc['data']["subject_title"],
                        documentId,
                      );
              if (doc['data']["subject_title"]
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  doc['data']["subject_code"]
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase())) {
                return ListTile(
                  title: Text(doc['data']["subject_code"]),
                  subtitle: Text(doc['data']["subject_title"]),
                  trailing: IconButton(icon: icon, onPressed: onTap),
                );
              }
              return Container();
            },
          );
        }
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    filteredList();
    return StreamBuilder<QuerySnapshot>(
      stream: courses,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Has Error");
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return ListView.builder(
            itemCount: _filteredList.length,
            itemBuilder: (context, index) {
              var doc = _filteredList[index];

              var documentId = doc['id'];
              var icon = (doc['data']['studentId'] as List<dynamic>)
                      .contains(_firebaseAuth.currentUser!.uid)
                  ? const Icon(Icons.check)
                  : const Icon(Icons.add_circle_outline_outlined);
              var onTap = (doc['data']['studentId'] as List<dynamic>)
                      .contains(_firebaseAuth.currentUser!.uid)
                  ? () => null
                  : () => joinCourse(
                        doc['data']["subject_code"],
                        doc['data']["subject_title"],
                        documentId,
                      );
              if (doc['data']["subject_title"]
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  doc['data']["subject_code"]
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase())) {
                return ListTile(
                  title: Text(doc['data']["subject_code"]),
                  subtitle: Text(doc['data']["subject_title"]),
                  trailing: IconButton(icon: icon, onPressed: onTap),
                );
              }
              return Container();
            },
          );
        }
      },
    );
  }
}
