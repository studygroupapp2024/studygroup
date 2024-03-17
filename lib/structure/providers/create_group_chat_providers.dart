import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef CourseCode = String;
typedef ChatName = String;
typedef ChatNameDescription = String;
typedef CourseId = String;

final selectedCourseProvider = StateProvider<CourseCode?>((ref) => '');
final chatNameProvider = StateProvider<ChatName?>((ref) => '');
final chatDescriptionProvider =
    StateProvider<ChatNameDescription?>((ref) => '');
final selectedcourseIdProvider = StateProvider<CourseId?>((ref) => '');

final buttonColorProvider = StateProvider<bool>((ref) {
  final selectedCourse = ref.watch(selectedCourseProvider);
  final chatName = ref.watch(chatNameProvider);
  final chatDescription = ref.watch(chatDescriptionProvider);
//selectedCourse!.isNotEmpty &&
  return (chatName!.isNotEmpty &&
      chatDescription!.isNotEmpty &&
      selectedCourse!.isNotEmpty);
});
