import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/edu_logic.dart';
import '../state/edu_state.dart';
import '../utils/format.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EduState>();
    final today = state.attendance[todayKey()] ?? {};
    final todayCount = countAttendance(state.students, today);
    final notice = state.latestNotice;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Good morning',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          'EduManager overview',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _StatCard(
              icon: Icons.people,
              label: 'Total students',
              value: '${state.totalStudents}',
            ),
            _StatCard(
              icon: Icons.class_,
              label: 'Classes',
              value: '${state.totalClasses}',
            ),
            _StatCard(
              icon: Icons.receipt_long,
              label: 'Fees due',
              value:
                  '${state.feesDueThisMonth} students (${taka(state.feesDueAmount)})',
            ),
            _StatCard(
              icon: Icons.check_circle,
              label: 'Present today',
              value:
                  '${todayCount.present} of ${state.totalStudents} (${todayCount.unmarked} not marked)',
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Latest notice', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (notice == null)
          const Card(child: ListTile(title: Text('No notices yet.')))
        else
          Card(
            child: ListTile(
              leading: const Icon(Icons.campaign),
              title: Text(notice.title),
              subtitle: Text(
                notice.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(shortDate(notice.date)),
            ),
          ),
        const SizedBox(height: 20),
        Text('Classes at a glance', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...state.classes.map((c) {
          final count = state.studentsInClass(c.id).length;
          return Card(
            child: ListTile(
              leading: const Icon(Icons.school),
              title: Text(c.label),
              subtitle: Text('${c.room} - $count students'),
            ),
          );
        }),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF39FF88)),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
