import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/edu_logic.dart';
import '../state/edu_state.dart';
import 'message_dialog.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String? _examName;
  String? _classId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EduState>();
    final exams = examNames(state.results);
    _examName ??= exams.isEmpty ? null : exams.first;
    final exam = _examName;
    final group = _classId == null
        ? state.students
        : state.studentsInClass(_classId!);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey('exam-$exam'),
                  initialValue: exam,
                  decoration: const InputDecoration(labelText: 'Exam'),
                  items: exams
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _examName = v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey('class-$_classId'),
                  initialValue: _classId,
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All classes'),
                    ),
                    ...state.classes.map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.label)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _classId = v),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: exam == null
              ? const Center(
                  child: Text('No results yet. Add the first marks.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: group.length,
                  itemBuilder: (context, index) {
                    final student = group[index];
                    final mine =
                        resultsForStudent(state.results, student.id, exam);
                    if (mine.isEmpty) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(child: Text(student.name[0])),
                          title: Text(student.name),
                          subtitle: Text(
                            '${state.classLabel(student.classId)} - No marks yet',
                          ),
                        ),
                      );
                    }
                    final summary = resultSummary(mine);
                    final classStudents =
                        state.studentsInClass(student.classId);
                    final rank = rankInClassForExam(
                      state.results,
                      classStudents,
                      student.id,
                      exam,
                    );
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ExpansionTile(
                        leading: CircleAvatar(child: Text(student.name[0])),
                        title: Text(student.name),
                        subtitle: Text(
                          '${summary.obtained.toStringAsFixed(0)} of '
                          '${summary.total.toStringAsFixed(0)} - '
                          '${summary.percentage.toStringAsFixed(1)}% - '
                          'GPA ${summary.gpa.toStringAsFixed(2)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(summary.grade),
                              backgroundColor: summary.passed
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            IconButton(
                              icon: const Icon(Icons.share, size: 20),
                              tooltip: 'Share result with guardian',
                              onPressed: () => showCopyableMessage(
                                context,
                                title: 'Result for ${student.name}',
                                text: resultShareText(
                                  student: student,
                                  examName: exam,
                                  obtained: summary.obtained,
                                  total: summary.total,
                                  percentage: summary.percentage,
                                  grade: summary.grade,
                                  rank: rank,
                                  classSize: classStudents.length,
                                ),
                              ),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  rank > 0
                                      ? 'Rank $rank of ${classStudents.length} in class'
                                      : 'Not ranked yet',
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  summary.passed ? 'Passed' : 'Failed',
                                  style: TextStyle(
                                    color: summary.passed
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...mine.map(
                            (result) => ListTile(
                              title: Text(result.subject),
                              subtitle: Text(
                                '${result.marks.toStringAsFixed(0)} of '
                                '${result.totalMarks.toStringAsFixed(0)} - '
                                'Grade ${gradeForPercentage(result.percentage)}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                tooltip: 'Delete mark',
                                onPressed: () =>
                                    state.removeResult(result.id),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Grades use the usual board scale: A+ 80 and above, A 70, '
            'A- 60, B 50, C 40, D 33, F below 33. Share copies the result '
            'as text for the guardian.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class AddResultSheet extends StatefulWidget {
  const AddResultSheet({super.key});

  @override
  State<AddResultSheet> createState() => _AddResultSheetState();
}

class _AddResultSheetState extends State<AddResultSheet> {
  final _formKey = GlobalKey<FormState>();
  final _exam = TextEditingController(text: 'Monthly Exam');
  final _subject = TextEditingController();
  final _marks = TextEditingController();
  final _total = TextEditingController(text: '100');
  String? _studentId;

  @override
  void dispose() {
    _exam.dispose();
    _subject.dispose();
    _marks.dispose();
    _total.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EduState>();
    _studentId ??= state.students.isEmpty ? null : state.students.first.id;
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
              Text('Add marks', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(_studentId),
                initialValue: _studentId,
                decoration: const InputDecoration(labelText: 'Student'),
                items: state.students
                    .map(
                      (s) => DropdownMenuItem(
                        value: s.id,
                        child: Text('${s.name} (${state.classLabel(s.classId)})'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _studentId = v),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _exam,
                decoration: const InputDecoration(labelText: 'Exam name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Exam name is required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subject,
                decoration:
                    const InputDecoration(labelText: 'Subject'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Subject is required' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _marks,
                      decoration:
                          const InputDecoration(labelText: 'Marks obtained'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final parsed = double.tryParse(v ?? '');
                        if (parsed == null || parsed < 0) {
                          return 'Enter marks of 0 or more';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _total,
                      decoration:
                          const InputDecoration(labelText: 'Total marks'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final parsed = double.tryParse(v ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a total above zero';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate() ||
                      _studentId == null) {
                    return;
                  }
                  final marks = double.parse(_marks.text.trim());
                  final total = double.parse(_total.text.trim());
                  if (marks > total) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Marks cannot be more than the total'),
                      ),
                    );
                    return;
                  }
                  await state.addResult(
                    studentId: _studentId!,
                    examName: _exam.text.trim(),
                    subject: _subject.text.trim(),
                    marks: marks,
                    totalMarks: total,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save marks'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
