import 'package:flutter/material.dart';
import '../../models/subject.dart';
import '../../models/lecture.dart';
import '../../models/content.dart';
import '../../screens/lecture_screen.dart';
import '../../screens/study_screen.dart';

/// Navigation helper class providing static methods for app navigation
class NavigationHelper {
  /// Opens the LectureScreen for the given subject
  static Future<void> openLectureScreen(BuildContext context, Subject subject) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LectureScreen(subject: subject),
      ),
    );
  }

  /// Opens the StudyScreen for the given lecture and contents
  static Future<void> openStudyScreen(
    BuildContext context,
    Lecture lecture,
    List<Content> contents,
  ) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudyScreen(
          lecture: lecture,
          contents: contents,
        ),
      ),
    );
  }
}
