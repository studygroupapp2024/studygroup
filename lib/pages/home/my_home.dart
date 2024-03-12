import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/components/containers/category_container.dart';
import 'package:study_buddy/models/category_model.dart';
import 'package:study_buddy/pages/home/my_profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  List<CategoryModel> categories = [];

  void _getCategories() {
    categories = CategoryModel.getCategories(context);
  }

  @override
  void initState() {
    _getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _getCategories();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _firebaseAuth.currentUser?.displayName?.isNotEmpty == true
              ? _firebaseAuth.currentUser!.displayName!.toString()
              : _firebaseAuth.currentUser!.email!.toString(),
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
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
      body: GridView.builder(
        itemCount: categories.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (context, index) {
          return Category(
            text: categories[index].name,
            iconPath: categories[index].iconPath,
            onTap: categories[index].onTap,
          );
        },
      ),
    );
  }
}
