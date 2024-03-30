import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:study_buddy/components/containers/study_group_container.dart';
import 'package:study_buddy/components/no_data_holder.dart';
import 'package:study_buddy/pages/home/create_study_group.dart';
import 'package:study_buddy/structure/providers/groupchat_provider.dart';
import 'package:study_buddy/structure/providers/university_provider.dart';

class FindStudyGroup extends ConsumerWidget {
  FindStudyGroup({super.key});

  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // void requestToJoin(String chatId, groupTitle) async {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Find Study Groups",
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).update((state) => value);
              },
              obscureText: false,
              controller: _controller,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  fillColor: Theme.of(context).colorScheme.secondary,
                  filled: true,
                  hintText: "Search",
                  hintStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final multipleGroupChatProvider = ref.watch(
                  selectedGroupChatInformationProvider(_auth.currentUser!.uid),
                );
                return multipleGroupChatProvider.when(
                  data: (groupchats) {
                    if (groupchats.isEmpty) {
                      return NoContent(
                          icon:
                              'assets/icons/book-shelf-books-education-learning-school-study_svgrepo.com.svg',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateStudyGroup(),
                              ),
                            );
                          },
                          description:
                              "There is no study group available for now. Do you want to lead one?",
                          buttonText: "Create Study Group");
                    } else {
                      return ListView.builder(
                        itemCount: groupchats.length,
                        itemBuilder: (context, index) {
                          final groupChats = groupchats[index];
                          final membersRequestList = groupChats.membersRequestId
                              .map((e) => e as String)
                              .toList();

                          return StudyGroupContainer(
                            onTap: () async {
                              ref
                                  .read(groupChatMemberRequestProvider)
                                  .requestToJoin(
                                    groupChats.docID.toString(),
                                    groupChats.creatorId,
                                    groupChats.studyGroupTitle,
                                    _auth.currentUser!.displayName.toString(),
                                    await ref
                                        .watch(institutionIdProviderBasedOnUser)
                                        .getUniversityBasedId(),
                                  );
                            },
                            title: groupChats.studyGroupTitle,
                            desc: groupChats.studyGroupDescription,
                            members: groupChats.membersId.length.toString(),
                            identifier: membersRequestList
                                    .contains(_auth.currentUser!.uid)
                                ? "Pending Application"
                                : "Join",
                          );
                        },
                      );
                    }
                  },
                  error: (error, stackTrace) {
                    return Center(
                      child: Text('Error: $error'),
                    );
                  },
                  loading: () {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
