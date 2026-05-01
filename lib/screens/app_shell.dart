import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'study_overview_screen.dart';
import 'progress_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'Subjects',
    'Study',
    'Progress',
  ];

  static const List<Widget> _pages = [
    HomeScreen(),
    StudyOverviewScreen(),
    ProgressScreen(),
  ];

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Study'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Progress'),
        ],
      ),
    );
  }
}
