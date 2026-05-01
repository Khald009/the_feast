import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'adapters/subject_adapter.dart';
import 'adapters/lecture_adapter.dart';
import 'adapters/content_adapter.dart';
import 'adapters/mistake_adapter.dart';
import 'adapters/user_progress_adapter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SubjectAdapter());
  Hive.registerAdapter(LectureAdapter());
  Hive.registerAdapter(ContentAdapter());
  Hive.registerAdapter(MistakeAdapter());
  Hive.registerAdapter(UserProgressAdapter());
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Study App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
