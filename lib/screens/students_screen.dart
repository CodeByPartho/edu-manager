import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/edu_state.dart';
import '../utils/format.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EduState>();
    final students = state.students
        .where((s) => s.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search students',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Expanded(
          child: students.isEmpty
              ? const Center(child: Text('No students found.'))
              : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(student.name[0]),
                        ),
                        title: Text(student.name),
                        subtitle: Text(
                          '${state.classLabel(student.classId)} - Guardian ${student.guardianPhone}',
                        ),
                        trailing: Text(taka(student.monthlyFee)),
                        onLongPress: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Remove student?'),
                              content: Text(
                                'Remove ${student.name} and their fees and attendance records?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Remove'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            await context
                                .read<EduState>()
                                .removeStudent(student.id);
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class AddStudentSheet extends StatefulWidget {
  const AddStudentSheet({super.key});

  @override
  State<AddStudentSheet> createState() => _AddStudentSheetState();
}

class _AddStudentSheetState extends State<AddStudentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _fee = TextEditingController();
  String? _classId;
  String _section = 'A';

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _fee.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EduState>();
    _classId ??= state.classes.isEmpty ? null : state.classes.first.id;
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
              Text('Add student', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey(_classId),
                initialValue: _classId,
                decoration: const InputDecoration(labelText: 'Class'),
                items: state.classes
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.label)))
                    .toList(),
                onChanged: (v) => setState(() => _classId = v),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _section,
                decoration: const InputDecoration(labelText: 'Section'),
                onChanged: (v) => _section = v,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phone,
                decoration:
                    const InputDecoration(labelText: 'Guardian phone'),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Guardian phone is required'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fee,
                decoration:
                    const InputDecoration(labelText: 'Monthly fee (taka)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final parsed = double.tryParse(v ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a fee above zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate() || _classId == null) {
                    return;
                  }
                  await state.addStudent(
                    name: _name.text.trim(),
                    classId: _classId!,
                    section: _section.trim().isEmpty ? 'A' : _section.trim(),
                    guardianPhone: _phone.text.trim(),
                    monthlyFee: double.parse(_fee.text.trim()),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save student'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
