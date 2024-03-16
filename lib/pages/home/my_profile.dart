import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/structure/auth/auth_service.dart';

class ProfilePage extends StatelessWidget {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final AuthService _auth = AuthService();
  ProfilePage({super.key});

  void logout(BuildContext context) {
    _auth.signOut();
    Navigator.pop(context);
  }

  void view() async {
    print("view");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Profile",
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: Center(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 60,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _firebaseAuth.currentUser?.photoURL !=
                              null
                          ? NetworkImage(_firebaseAuth.currentUser!.photoURL!)
                          : null,
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    _firebaseAuth.currentUser?.displayName?.isNotEmpty == true
                        ? _firebaseAuth.currentUser!.displayName!.toString()
                        : _firebaseAuth.currentUser!.email!.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_city),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Location: Los Angeles",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Study",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            "My courses",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "2",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            "Study",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "Tutors:",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            "Chat",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Study Progress",
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.secondary,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: const Offset(
                            2,
                            3,
                          ),
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_box_sharp,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Expanded(
                          child: Text(
                            "Completed Courses:",
                          ),
                        ),
                        GestureDetector(
                          onTap: view,
                          child: const Text("View"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.secondary,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: const Offset(
                            2,
                            3,
                          ),
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.timelapse,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Expanded(
                          child: Text(
                            "Become a tutor",
                          ),
                        ),
                        GestureDetector(
                          onTap: view,
                          child: const Text("View"),
                        ),
                      ],
                    ),
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
