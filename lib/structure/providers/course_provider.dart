// collect to all the document
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:study_buddy/structure/models/subject_model.dart';
import 'package:study_buddy/structure/models/user_courses.dart';
import 'package:study_buddy/structure/providers/university_provider.dart';
import 'package:study_buddy/structure/services/course_services.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

final multipleStudentCoursesInformationProvider =
    StreamProvider.family<List<StudentCoursesModel>, String>(
        (ref, userId) async* {
  final institutionId =
      await ref.watch(institutionIdProviderBasedOnUser).getUniversityBasedId();
  final getUserCourses = _firestore
      .collection("institution")
      .doc(institutionId)
      .collection('students')
      .doc(userId)
      .collection("courses")
      .snapshots()
      .map(
        (querySnapshot) => querySnapshot.docs
            .map(
              (snapshot) => StudentCoursesModel.fromSnapshot(snapshot),
            )
            .toList(),
      );
  yield* getUserCourses;
});

final currentStudentCoursesInformationProvider =
    StreamProvider.family<List<StudentCoursesModel>, String>(
        (ref, userId) async* {
  final institutionId =
      await ref.watch(institutionIdProviderBasedOnUser).getUniversityBasedId();

  final getCurrentUserCourses = _firestore
      .collection("institution")
      .doc(institutionId)
      .collection('students')
      .doc(userId)
      .collection("courses")
      .snapshots()
      .map(
        (querySnapshot) => querySnapshot.docs
            .map(
              (snapshot) => StudentCoursesModel.fromSnapshot(snapshot),
            )
            .where((course) => !course.isCompleted)
            .toList(),
      );
  yield* getCurrentUserCourses;
});

final completedStudentCoursesInformationProvider =
    StreamProvider.family<List<StudentCoursesModel>, String>(
        (ref, userId) async* {
  final institutionId =
      await ref.watch(institutionIdProviderBasedOnUser).getUniversityBasedId();

  final getCompletedUserCourses = _firestore
      .collection("institution")
      .doc(institutionId)
      .collection('students')
      .doc(userId)
      .collection("courses")
      .snapshots()
      .map(
        (querySnapshot) => querySnapshot.docs
            .map(
              (snapshot) => StudentCoursesModel.fromSnapshot(snapshot),
            )
            .where((course) => course.isCompleted)
            .toList(),
      );
  yield* getCompletedUserCourses;
});

// search course
final unenrolledCoursesProvider = StreamProvider.family
    .autoDispose<List<SubjectModel>, String>((ref, userId) async* {
  final searchQuery = ref.watch(courseSearchQueryProvider);
  print("UNENROLLED COURSE");
  final institutionId =
      await ref.watch(institutionIdProviderBasedOnUser).getUniversityBasedId();

  print("INSTITUTION ID: $institutionId");
  final getCourses = _firestore
      .collection("institution")
      .doc(institutionId)
      .collection("subjects")
      .snapshots()
      .map(
        (querySnapshot) => querySnapshot.docs
            .map((snapshot) => SubjectModel.fromSnapshot(snapshot))
            .where((group) =>
                !group.studentId.contains(userId) &&
                (group.subject_code
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    group.subject_title
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    searchQuery.isEmpty))
            .toList(),
      );

  yield* getCourses;
});

// ======================= STATE PROVIDERS =============================

final courseSearchQueryProvider = StateProvider<String>((ref) => '');

final courseProvider = StateProvider.autoDispose<Courses>((ref) {
  return Courses();
});
