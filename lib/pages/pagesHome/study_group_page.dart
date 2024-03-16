import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/components/containers/study_group_container.dart';
import 'package:study_buddy/pages/chat/chat_page.dart';
import 'package:study_buddy/structure/group/group_services.dart';

class FindStudyGroup extends StatefulWidget {
  const FindStudyGroup({super.key});

  @override
  State<FindStudyGroup> createState() => _FindStudyGroupState();
}

class _FindStudyGroupState extends State<FindStudyGroup> {
  // List Document IDs
  late List<Map<String, dynamic>> studyGroupList = [];

  late String groupChatId;

  late Future<void> _future;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GroupService _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    _future = getDocId();
  }

  void joinGroupChat(String chatId, groupTitle) async {
    print("Joining group chat with chatId: $chatId");
    await _groupService.checkAndAddUserEmail(
      _firebaseAuth.currentUser!.email.toString(),
      _firebaseAuth.currentUser!.uid,
      chatId,
      groupTitle,
    );
    await getDocId();
  }

  // get Data from database
  Future<void> getDocId() async {
    List<Map<String, dynamic>> tempList = [];
    await FirebaseFirestore.instance
        .collection('study_groups')
        .orderBy('createdAt', descending: true)
        .get()
        .then(
          (snapshot) => snapshot.docs.forEach((document) {
            List<dynamic> memberId = document.data()['membersId'] ?? [];

            if (!memberId.contains(_firebaseAuth.currentUser!.uid)) {
              tempList.add({
                'id': document.id,
                'data': document.data(),
              });
            }
          }),
        );

    setState(() {
      studyGroupList = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Study Groups",
        ),
        centerTitle: true,
        actions: const [
          IconButton(
            onPressed: null,
            icon: Icon(
              Icons.search,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Expanded(
                    child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: studyGroupList.length,
                    itemBuilder: (context, index) {
                      String docId = studyGroupList[index]['id'];
                      Map<String, dynamic> docData =
                          studyGroupList[index]['data'];
                      return StudyGroupContainer(
                          title: docData["studyGrppTitle"] ?? "No Title",
                          desc: docData["studyGrpDescription"] ??
                              "No Description",
                          members: (docData["members"]?.length ?? 0).toString(),
                          onTap: () {
                            joinGroupChat(
                              docId,
                              docData["studyGrppTitle"],
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                      groupChatId: docId,
                                      chatName: docData["studyGrppTitle"])),
                            );
                          });
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
