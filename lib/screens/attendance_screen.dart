import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/edu_logic.dart';
import '../state/edu_state.dart';
import 'message_dialog.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? _classId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EduState>();
    _classId ??= state.classes.isEmpty ? null : state.classes.first.id;
    final group = _classId == null
        ? state.students
        : state.studentsInClass(_classId!);
    final date = todayKey();
    final day = state.attendance[date] ?? {};
    final counts = countAttendance(group, day);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey(_classId),
                  initialValue: _classId,
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: state.classes
                      .map((c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _classId = v),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () =>
                    state.markAllPresent(date, group),
                child: const Text('All present'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CountChip(label: 'Present', count: counts.present, color: Colors.green),
              _CountChip(label: 'Absent', count: counts.absent, color: Colors.red),
              _CountChip(label: 'Not marked', count: counts.unmarked, color: Colors.grey),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: group.length,
            itemBuilder: (context, index) {
              final student = group[index];
              final value = day[student.id];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(child: Text(student.name[0])),
                  title: Text(student.name),
                  subtitle: Text(state.classLabel(student.classId)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChoiceChip(
                        label: const Text('Present'),
                        selected: value == true,
                        selectedColor: Colors.green.withValues(alpha: 0.3),
                        onSelected: (_) =>
                            state.setAttendance(date, student.id, true),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Absent'),
                        selected: value == false,
                        selectedColor: Colors.red.withValues(alpha: 0.3),
                        onSelected: (_) =>
                            state.setAttendance(date, student.id, false),
                      ),
                      if (value == false)
                        IconButton(
                          icon: const Icon(Icons.message, size: 20),
                          tooltip: 'Absence notice for guardian',
                          onPressed: () => showCopyableMessage(
                            context,
                            title: 'Absence notice',
                            text: absenceNoticeText(
                              student: student,
                              date: date,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Attendance is saved per date and stored on this device. '
            'Tap Present or Absent for each student.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: color),
        ),
        Text(label),
      ],
    );
  }
}
