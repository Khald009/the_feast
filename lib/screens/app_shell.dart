import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subject_provider.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'study_dashboard_screen.dart';
import 'progress_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'Subjects',
    'Dashboard',
    'Progress',
  ];

  static const List<Widget> _pages = [
    HomeScreen(),
    StudyDashboardScreen(),
    ProgressScreen(),
  ];

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectProvider);
    if (subjects.isEmpty) {
      return const OnboardingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined), label: 'Study'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined), label: 'Progress'),
        ],
      ),
    );
  }
}
