import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:study_buddy/models/chat_info_model.dart';

class ChatInfo extends ConsumerWidget {
  const ChatInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Settings"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Member Request",
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final memberRequestModel = ref.watch(memberRequestProvider);
                return memberRequestModel.when(
                  data: (memberRequests) {
                    if (memberRequests.isEmpty) {
                      return const Center(
                          child: Text('No member requests found.'));
                    }
                    return ListView.builder(
                      itemCount: memberRequests.length,
                      itemBuilder: (context, index) {
                        final memberRequest = memberRequests[index];
                        return ListTile(
                          title: Text(memberRequest['courseCode']),
                          subtitle: Text(memberRequest['courseTitle']),
                          trailing: Text(memberRequest['courseId']),
                        );
                      },
                    );
                  },
                  error: (error, stackTrace) {
                    return Center(
                      child: Text('Error: $error'),
                    );
                  },
                  loading: () {
                    return const Center(child: CircularProgressIndicator());
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
