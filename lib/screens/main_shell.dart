import 'package:flutter/material.dart';

import 'attendance_screen.dart';
import 'classes_screen.dart';
import 'dashboard_screen.dart';
import 'fees_screen.dart';
import 'notices_screen.dart';
import 'students_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = [
    'Dashboard',
    'Students',
    'Classes',
    'Attendance',
    'Fees',
    'Notices',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: IndexedStack(
        index: _index,
        children: const [
          DashboardScreen(),
          StudentsScreen(),
          ClassesScreen(),
          AttendanceScreen(),
          FeesScreen(),
          NoticesScreen(),
        ],
      ),
      floatingActionButton: _fabFor(context, _index),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Students'),
          NavigationDestination(icon: Icon(Icons.school), label: 'Classes'),
          NavigationDestination(
            icon: Icon(Icons.fact_check),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Fees',
          ),
          NavigationDestination(icon: Icon(Icons.campaign), label: 'Notices'),
        ],
      ),
    );
  }

  Widget? _fabFor(BuildContext context, int index) {
    switch (index) {
      case 1:
        return FloatingActionButton(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddStudentSheet(),
          ),
          tooltip: 'Add student',
          child: const Icon(Icons.person_add),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddClassSheet(),
          ),
          tooltip: 'Add class',
          child: const Icon(Icons.add),
        );
      case 5:
        return FloatingActionButton(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddNoticeSheet(),
          ),
          tooltip: 'Add notice',
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }
}
