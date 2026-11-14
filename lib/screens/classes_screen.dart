import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/edu_logic.dart';
import '../models/models.dart';
import '../state/edu_state.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Classes'),
              Tab(text: 'Timetable'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _ClassList(),
                TimetableTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassList extends StatelessWidget {
  const _ClassList();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EduState>();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.classes.length,
      itemBuilder: (context, index) {
        final schoolClass = state.classes[index];
        final students = state.studentsInClass(schoolClass.id);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: const Icon(Icons.school),
            title: Text(schoolClass.label),
            subtitle: Text('${schoolClass.room} - ${students.length} students'),
            children: students
                .map(
                  (s) => ListTile(
                    leading: CircleAvatar(child: Text(s.name[0])),
                    title: Text(s.name),
                    subtitle: Text('Guardian ${s.guardianPhone}'),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class TimetableTab extends StatefulWidget {
  const TimetableTab({super.key});

  @override
  State<TimetableTab> createState() => _TimetableTabState();
}

class _TimetableTabState extends State<TimetableTab> {
  String? _classId;
  int _weekday = 1;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EduState>();
    _classId ??= state.classes.isEmpty ? null : state.classes.first.id;
    final day = _classId == null
        ? <TimetableEntry>[]
        : timetableForDay(state.timetable, _classId!, _weekday);
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
              Expanded(
                child: DropdownButtonFormField<int>(
                  key: ValueKey(_weekday),
                  initialValue: _weekday,
                  decoration: const InputDecoration(labelText: 'Day'),
                  items: [
                    for (var i = 0; i < weekdayNames.length; i++)
                      DropdownMenuItem(
                        value: i + 1,
                        child: Text(weekdayNames[i]),
                      ),
                  ],
                  onChanged: (v) => setState(() => _weekday = v ?? 1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: day.isEmpty
              ? const Center(child: Text('No lessons on this day yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: day.length,
                  itemBuilder: (context, index) {
                    final entry = day[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${entry.period}'),
                        ),
                        title: Text(entry.subject),
                        subtitle: Text(entry.teacher),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          tooltip: 'Delete lesson',
                          onPressed: () =>
                              state.removeTimetableEntry(entry.id),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _classId == null
                ? null
                : () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => AddTimetableSheet(
                        classId: _classId!,
                        weekday: _weekday,
                      ),
                    ),
            icon: const Icon(Icons.add),
            label: const Text('Add lesson'),
          ),
        ),
      ],
    );
  }
}

class AddTimetableSheet extends StatefulWidget {
  const AddTimetableSheet({
    super.key,
    required this.classId,
    required this.weekday,
  });

  final String classId;
  final int weekday;

  @override
  State<AddTimetableSheet> createState() => _AddTimetableSheetState();
}

class _AddTimetableSheetState extends State<AddTimetableSheet> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _teacher = TextEditingController();
  int _period = 1;

  @override
  void dispose() {
    _subject.dispose();
    _teacher.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<EduState>();
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add lesson - ${weekdayNames[widget.weekday - 1]}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _period,
                decoration: const InputDecoration(labelText: 'Period'),
                items: [
                  for (var i = 1; i <= 8; i++)
                    DropdownMenuItem(value: i, child: Text('Period $i')),
                ],
                onChanged: (v) => setState(() => _period = v ?? 1),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subject,
                decoration: const InputDecoration(labelText: 'Subject'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Subject is required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _teacher,
                decoration: const InputDecoration(labelText: 'Teacher'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Teacher is required' : null,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  if (hasTimetableConflict(
                    state.timetable,
                    widget.classId,
                    widget.weekday,
                    _period,
                  )) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'That period already has a lesson. Delete it first to replace it.',
                        ),
                      ),
                    );
                    return;
                  }
                  await state.addTimetableEntry(
                    classId: widget.classId,
                    weekday: widget.weekday,
                    period: _period,
                    subject: _subject.text.trim(),
                    teacher: _teacher.text.trim(),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save lesson'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddClassSheet extends StatefulWidget {
  const AddClassSheet({super.key});

  @override
  State<AddClassSheet> createState() => _AddClassSheetState();
}

class _AddClassSheetState extends State<AddClassSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _section = TextEditingController(text: 'A');
  final _room = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _section.dispose();
    _room.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<EduState>();
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add class', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Class name (e.g. Class 10)'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Class name is required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _section,
                decoration: const InputDecoration(labelText: 'Section'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _room,
                decoration: const InputDecoration(labelText: 'Room'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Room is required' : null,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  await state.addClass(
                    name: _name.text.trim(),
                    section: _section.text.trim().isEmpty
                        ? 'A'
                        : _section.text.trim(),
                    room: _room.text.trim(),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save class'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
