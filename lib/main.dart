import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/app_shell.dart';
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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.zero,
        ),
      ),
      home: const AppShell(),
    );
  }
}
