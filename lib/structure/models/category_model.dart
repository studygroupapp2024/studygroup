import 'package:flutter/material.dart';
import 'package:study_buddy/pages/home/create_study_group.dart';
import 'package:study_buddy/pages/home/my_chat.dart';
import 'package:study_buddy/pages/home/my_course.dart';
import 'package:study_buddy/pages/home/search_study_group.dart';

class CategoryModel {
  String name;
  String iconPath;
  Color backgroundColor;
  VoidCallback? onTap;

  CategoryModel({
    required this.name,
    required this.iconPath,
    required this.backgroundColor,
    required this.onTap,
  });

  static List<CategoryModel> getCategories(BuildContext context) {
    List<CategoryModel> categories = [];

    categories.add(
      CategoryModel(
        name: "My Courses",
        iconPath: 'assets/icons/study-student_svgrepo.com.svg',
        backgroundColor: const Color.fromARGB(255, 222, 159, 172),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FindCourses(),
            ),
          );
        },
      ),
    );

    categories.add(
      CategoryModel(
        name: "My Study Groups",
        iconPath: 'assets/icons/users-group_svgrepo.com.svg',
        backgroundColor: const Color.fromARGB(255, 222, 159, 172),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FindPage(),
            ),
          );
        },
      ),
    );

    categories.add(
      CategoryModel(
        name: "Add Study Group",
        iconPath:
            'assets/icons/book-shelf-books-education-learning-school-study_svgrepo.com.svg',
        backgroundColor: const Color.fromARGB(255, 222, 159, 172),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateStudyGroup(),
            ),
          );
        },
      ),
    );

    categories.add(
      CategoryModel(
        name: "Find Study Group",
        iconPath: 'assets/icons/search-phone_svgrepo.com.svg',
        backgroundColor: const Color.fromARGB(255, 222, 159, 172),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FindStudyGroup(),
            ),
          );
        },
      ),
    );

    return categories;
  }
}
