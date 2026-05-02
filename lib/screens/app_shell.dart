import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subject_provider.dart';
import 'study_workspace_screen.dart';
import 'onboarding_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'Study',
    'Progress',
  ];

  static const List<Widget> _pages = [
    StudyWorkspaceScreen(),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school),
            label: 'Study',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}