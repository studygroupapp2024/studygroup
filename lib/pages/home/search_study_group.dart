import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/components/containers/filter_chip.dart';
import 'package:study_buddy/components/containers/study_group_container.dart';
import 'package:study_buddy/pages/chat/chat_page.dart';
import 'package:study_buddy/services/group/courses.dart';
import 'package:study_buddy/services/group/group_services.dart';

class FindStudyGroup extends StatefulWidget {
  const FindStudyGroup({super.key});

  @override
  State<FindStudyGroup> createState() => _FindStudyGroupState();
}

class _FindStudyGroupState extends State<FindStudyGroup> {
  late String groupChatId;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GroupService _groupService = GroupService();
  final Courses _courses = Courses();

  // Current Courses
  late final Stream<QuerySnapshot<Object?>> _userCourses =
      getUserCoursesFunc(_firebaseAuth.currentUser!.uid);

  Stream<QuerySnapshot<Object?>> getUserCoursesFunc(String userId) {
    return _courses.getCurrentUserCourses(userId);
  }

  // Study Groups
  late final Stream<QuerySnapshot<Object?>> _studyGroups = getStudyGroups();

  Stream<QuerySnapshot<Object?>> getStudyGroups() {
    return _groupService.getStudyGroups();
  }

  late List<Map<String, dynamic>> _filteredList = [];

  void filteredList() {
    _studyGroups.listen((QuerySnapshot<Object?> snapshot) {
      List<Map<String, dynamic>> contents = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> studentIds = data['membersId'] ?? [];
        if (!studentIds.contains(_firebaseAuth.currentUser!.uid)) {
          print(data);
          contents.add({'id': doc.id, 'data': data});
        }
      }
      _filteredList = contents;
    });
    print("EXECUTED AGAIN");
  }

  void joinGroupChat(String chatId, groupTitle) async {
    print("Joining group chat with chatId: $chatId");
    await _groupService.checkAndAddUserEmail(
      _firebaseAuth.currentUser!.email.toString(),
      _firebaseAuth.currentUser!.uid,
      chatId,
      groupTitle,
    );
  }

  final List<String> _selectedFilters = [];

  _selectFilter(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
      print("COntents: $_selectedFilters");
    });
  }

  @override
  Widget build(BuildContext context) {
    filteredList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Study Groups",
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: .4,
                  maxChildSize: .9,
                  minChildSize: .2,
                  builder: (context, scrollController) => SingleChildScrollView(
                    controller: scrollController,
                    child: SizedBox(
                      height: 400,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.close),
                                Expanded(
                                  child: Text(
                                    "Courses",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
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
                                    var data = snapshot.data!.docs;

                                    var courseCodes = <String>[];
                                    for (var doc in data) {
                                      var courseCode = doc['courseCode'];
                                      courseCodes.add(courseCode);
                                    }

                                    return Wrap(
                                      children: courseCodes.map((code) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5),
                                          child: MyFilterChip(
                                              label: code,
                                              selected: _selectedFilters
                                                  .contains(code),
                                              onChanged: (selected) {
                                                _selectFilter(code);
                                              }),
                                        );
                                      }).toList(),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _studyGroups,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Expanded(
                    child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final tempList = _filteredList;
                final filterStudyGroupList = tempList.where((studygroups) {
                  return _selectedFilters.isEmpty ||
                      _selectedFilters
                          .contains(studygroups['data']['studyGrpCourseName']);
                }).toList();

                return Expanded(
                  child: ListView.builder(
                    itemCount: filterStudyGroupList.length,
                    itemBuilder: (context, index) {
                      var doc = filterStudyGroupList[index];
                      var documentId = doc['id'];
                      return Column(children: [
                        StudyGroupContainer(
                            title: doc['data']["studyGrppTitle"] ?? "No Title",
                            desc: doc['data']["studyGrpDescription"] ??
                                "No Description",
                            members: (doc['data']["members"]?.length ?? 0)
                                .toString(),
                            onTap: () {
                              joinGroupChat(
                                documentId,
                                doc['data']["studyGrppTitle"],
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    groupChatId: documentId,
                                    chatName: doc['data']["studyGrppTitle"],
                                  ),
                                ),
                              );
                            }),
                      ]);
                    },
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
