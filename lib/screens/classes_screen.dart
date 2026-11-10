import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/edu_state.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

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
