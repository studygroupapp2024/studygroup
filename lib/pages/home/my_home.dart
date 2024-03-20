import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:study_buddy/pages/home/my_profile.dart';
import 'package:study_buddy/structure/providers/groupchat_provider.dart';

class HomePage extends ConsumerWidget {
  HomePage({super.key});

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //   getCategories();
    final checkMemberRequest = ref.watch(userHasStudyGroupRequest);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 10,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 16,
                backgroundImage: _firebaseAuth.currentUser?.photoURL != null
                    ? NetworkImage(_firebaseAuth.currentUser!.photoURL!)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Good day,",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _firebaseAuth.currentUser?.displayName?.isNotEmpty == true
                    ? _firebaseAuth.currentUser!.displayName!.toString()
                    : _firebaseAuth.currentUser!.email!.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 30),
            child: Text(
              "Connect with study partners and tutors easily.",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Category",
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.background,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      return checkMemberRequest.when(
                        data: (value) {
                          print("The array is NOT EMPTY?: $value");
                          print(
                              "The array is NOT EMPTY?: ${_firebaseAuth.currentUser!.uid}");
                          return value
                              ? const Text('User has a study group request')
                              : const Text('User has no study group request');
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

                  // child: GridView.builder(
                  //   itemCount: categories.length,
                  //   gridDelegate:
                  //       const SliverGridDelegateWithFixedCrossAxisCount(
                  //           crossAxisCount: 2),
                  //   itemBuilder: (context, index) {
                  //     return Category(
                  //       text: categories[index].name,
                  //       iconPath: categories[index].iconPath,
                  //       onTap: categories[index].onTap,
                  //       caption: categories[index].caption,
                  //       request: 'Empty',
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// List<CategoryModel> categories = [];

  // void _getCategories() {
  //   categories = CategoryModel.getCategories(context);
  // }

  // @override
  // void initState() {
  //   _getCategories();
  //   super.initState();
  // }