import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logic/edu_logic.dart';
import '../models/models.dart';

const String _storageKey = 'edu_manager_data_v1';

String todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

String currentMonthKey() => DateFormat('yyyy-MM').format(DateTime.now());

String monthLabel(String monthKey) {
  final parts = monthKey.split('-');
  final year = int.tryParse(parts[0]) ?? DateTime.now().year;
  final month = int.tryParse(parts[1]) ?? DateTime.now().month;
  return DateFormat('MMMM yyyy').format(DateTime(year, month));
}

class EduState extends ChangeNotifier {
  EduState();

  bool loaded = false;
  List<SchoolClass> classes = [];
  List<Student> students = [];
  List<FeePayment> fees = [];
  List<Notice> notices = [];
  List<ExamResult> results = [];
  List<TimetableEntry> timetable = [];

  /// date key (yyyy-MM-dd) -> student id -> present?
  Map<String, Map<String, bool>> attendance = {};

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      _seed();
    } else {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        classes = (data['classes'] as List)
            .map((e) => SchoolClass.fromJson(e as Map<String, dynamic>))
            .toList();
        students = (data['students'] as List)
            .map((e) => Student.fromJson(e as Map<String, dynamic>))
            .toList();
        fees = (data['fees'] as List)
            .map((e) => FeePayment.fromJson(e as Map<String, dynamic>))
            .toList();
        notices = (data['notices'] as List)
            .map((e) => Notice.fromJson(e as Map<String, dynamic>))
            .toList();
        // Results and timetable were added in v1.1.0, so older saved
        // data may not have them yet.
        results = ((data['results'] as List?) ?? [])
            .map((e) => ExamResult.fromJson(e as Map<String, dynamic>))
            .toList();
        timetable = ((data['timetable'] as List?) ?? [])
            .map((e) => TimetableEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        final att = data['attendance'] as Map<String, dynamic>;
        attendance = att.map(
          (date, day) => MapEntry(
            date,
            (day as Map<String, dynamic>).map(
              (id, value) => MapEntry(id, value as bool),
            ),
          ),
        );
      } catch (_) {
        _seed();
      }
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(toJson()));
  }

  Map<String, dynamic> toJson() => {
        'classes': classes.map((c) => c.toJson()).toList(),
        'students': students.map((s) => s.toJson()).toList(),
        'fees': fees.map((f) => f.toJson()).toList(),
        'notices': notices.map((n) => n.toJson()).toList(),
        'results': results.map((r) => r.toJson()).toList(),
        'timetable': timetable.map((t) => t.toJson()).toList(),
        'attendance': attendance,
      };

  String _newId() =>
      DateTime.now().millisecondsSinceEpoch.toString() +
      students.length.toString() +
      notices.length.toString();

  void _seed() {
    classes = [
      SchoolClass(id: 'c1', name: 'Class 8', section: 'A', room: 'Room 201'),
      SchoolClass(id: 'c2', name: 'Class 9', section: 'B', room: 'Room 305'),
    ];
    students = [
      Student(id: 's01', name: 'Arif Hossain', classId: 'c1', section: 'A', guardianPhone: '01711-234501', monthlyFee: 1500),
      Student(id: 's02', name: 'Nusrat Jahan', classId: 'c1', section: 'A', guardianPhone: '01822-345602', monthlyFee: 1500),
      Student(id: 's03', name: 'Tanvir Ahmed', classId: 'c1', section: 'A', guardianPhone: '01933-456703', monthlyFee: 1500),
      Student(id: 's04', name: 'Mim Akter', classId: 'c1', section: 'A', guardianPhone: '01644-567804', monthlyFee: 1500),
      Student(id: 's05', name: 'Sakib Rahman', classId: 'c1', section: 'A', guardianPhone: '01555-678905', monthlyFee: 1500),
      Student(id: 's06', name: 'Lamiya Sultana', classId: 'c1', section: 'A', guardianPhone: '01766-789006', monthlyFee: 1500),
      Student(id: 's07', name: 'Rafi Chowdhury', classId: 'c2', section: 'B', guardianPhone: '01877-890107', monthlyFee: 2000),
      Student(id: 's08', name: 'Anika Tabassum', classId: 'c2', section: 'B', guardianPhone: '01988-901208', monthlyFee: 2000),
      Student(id: 's09', name: 'Hasan Mahmud', classId: 'c2', section: 'B', guardianPhone: '01699-012309', monthlyFee: 2000),
      Student(id: 's10', name: 'Priya Das', classId: 'c2', section: 'B', guardianPhone: '01510-123410', monthlyFee: 2000),
      Student(id: 's11', name: 'Mehedi Hasan', classId: 'c2', section: 'B', guardianPhone: '01721-234511', monthlyFee: 2000),
      Student(id: 's12', name: 'Sadia Afrin', classId: 'c2', section: 'B', guardianPhone: '01832-345612', monthlyFee: 2000),
    ];
    final month = currentMonthKey();
    fees = students.map((s) {
      // Seed a realistic mix: about half the students already paid.
      final paid = ['s01', 's03', 's06', 's07', 's09', 's12'].contains(s.id);
      return FeePayment(
        studentId: s.id,
        month: month,
        amount: s.monthlyFee,
        paid: paid,
        paidOn: paid ? month : null,
      );
    }).toList();
    notices = [
      Notice(
        id: 'n1',
        title: 'Monthly exam starts Sunday',
        body:
            'The monthly exam for all classes starts this Sunday at 9:00 AM. Students must bring their admit card and arrive 15 minutes early.',
        date: todayKey(),
      ),
      Notice(
        id: 'n2',
        title: 'Fees due by the 10th',
        body:
            'Please clear this month fees by the 10th to avoid a late fine of 100 taka. Pay at the office or through bKash.',
        date: todayKey(),
      ),
    ];
    attendance = {};
    // Seed yesterday so the history is not empty.
    final yesterday =
        DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));
    attendance[yesterday] = {
      for (final s in students) s.id: s.id != 's04' && s.id != 's10',
    };
    // Seed Monthly Exam results: four subjects, each out of 100.
    const seedMarks = <String, List<double>>{
      's01': [78, 82, 88, 75],
      's02': [85, 79, 91, 84],
      's03': [62, 58, 71, 66],
      's04': [45, 52, 48, 55],
      's05': [90, 86, 93, 89],
      's06': [74, 81, 69, 77],
      's07': [68, 72, 80, 64],
      's08': [88, 91, 84, 90],
      's09': [55, 49, 61, 58],
      's10': [92, 88, 95, 91],
      's11': [38, 44, 41, 47],
      's12': [79, 83, 76, 82],
    };
    const seedSubjects = ['Bangla', 'English', 'Mathematics', 'Science'];
    results = [
      for (final entry in seedMarks.entries)
        for (var i = 0; i < seedSubjects.length; i++)
          ExamResult(
            id: 'r-${entry.key}-$i',
            studentId: entry.key,
            examName: 'Monthly Exam',
            subject: seedSubjects[i],
            marks: entry.value[i],
            totalMarks: 100,
          ),
    ];
    // Seed a weekly timetable: five periods, Monday to Friday.
    const daySubjects = <List<String>>[
      ['Bangla', 'English', 'Mathematics', 'Science', 'ICT'],
      ['Mathematics', 'Bangla', 'English', 'Science', 'Social Science'],
      ['English', 'Mathematics', 'Science', 'Bangla', 'ICT'],
      ['Science', 'Mathematics', 'English', 'Bangla', 'Religion'],
      ['Mathematics', 'Science', 'Bangla', 'English', 'Physical Education'],
    ];
    const subjectTeachers = <String, String>{
      'Bangla': 'Mr. Rahman',
      'English': 'Ms. Akter',
      'Mathematics': 'Mr. Hossain',
      'Science': 'Ms. Jahan',
      'ICT': 'Mr. Karim',
      'Social Science': 'Ms. Begum',
      'Religion': 'Mr. Ali',
      'Physical Education': 'Mr. Das',
    };
    timetable = [
      for (final schoolClass in classes)
        for (var day = 0; day < daySubjects.length; day++)
          for (var period = 0; period < daySubjects[day].length; period++)
            TimetableEntry(
              id: 't-${schoolClass.id}-${day + 1}-${period + 1}',
              classId: schoolClass.id,
              weekday: day + 1,
              period: period + 1,
              subject: daySubjects[day][period],
              teacher: subjectTeachers[daySubjects[day][period]] ?? '',
            ),
    ];
  }

  String classLabel(String classId) {
    final found = classes.where((c) => c.id == classId);
    if (found.isEmpty) return 'Unknown class';
    return found.first.label;
  }

  List<Student> studentsInClass(String classId) =>
      students.where((s) => s.classId == classId).toList();

  Future<void> addStudent({
    required String name,
    required String classId,
    required String section,
    required String guardianPhone,
    required double monthlyFee,
  }) async {
    students.add(Student(
      id: _newId(),
      name: name,
      classId: classId,
      section: section,
      guardianPhone: guardianPhone,
      monthlyFee: monthlyFee,
    ));
    await _save();
    notifyListeners();
  }

  Future<void> removeStudent(String id) async {
    students.removeWhere((s) => s.id == id);
    fees.removeWhere((f) => f.studentId == id);
    results.removeWhere((r) => r.studentId == id);
    for (final day in attendance.values) {
      day.remove(id);
    }
    await _save();
    notifyListeners();
  }

  Future<void> addClass({
    required String name,
    required String section,
    required String room,
  }) async {
    classes.add(SchoolClass(
      id: _newId(),
      name: name,
      section: section,
      room: room,
    ));
    await _save();
    notifyListeners();
  }

  Future<void> setAttendance(String date, String studentId, bool present) async {
    attendance.putIfAbsent(date, () => {})[studentId] = present;
    await _save();
    notifyListeners();
  }

  Future<void> markAllPresent(String date, List<Student> group) async {
    final day = attendance.putIfAbsent(date, () => {});
    for (final s in group) {
      day[s.id] = true;
    }
    await _save();
    notifyListeners();
  }

  Future<void> markFeePaid(String studentId, String month) async {
    final index = fees.indexWhere(
      (f) => f.studentId == studentId && f.month == month,
    );
    if (index >= 0) {
      fees[index] = fees[index].copyWith(paid: true, paidOn: todayKey());
    } else {
      final student = students.firstWhere((s) => s.id == studentId);
      fees.add(FeePayment(
        studentId: studentId,
        month: month,
        amount: student.monthlyFee,
        paid: true,
        paidOn: todayKey(),
      ));
    }
    await _save();
    notifyListeners();
  }

  Future<void> markFeeUnpaid(String studentId, String month) async {
    final index = fees.indexWhere(
      (f) => f.studentId == studentId && f.month == month,
    );
    if (index >= 0) {
      fees[index] = fees[index].copyWith(paid: false, paidOn: null);
    }
    await _save();
    notifyListeners();
  }

  Future<void> addNotice(String title, String body) async {
    notices.insert(
      0,
      Notice(id: _newId(), title: title, body: body, date: todayKey()),
    );
    await _save();
    notifyListeners();
  }

  Future<void> addResult({
    required String studentId,
    required String examName,
    required String subject,
    required double marks,
    required double totalMarks,
  }) async {
    // One mark per student, exam and subject: replace an old entry.
    results.removeWhere(
      (r) =>
          r.studentId == studentId &&
          r.examName == examName &&
          r.subject == subject,
    );
    results.add(ExamResult(
      id: _newId(),
      studentId: studentId,
      examName: examName,
      subject: subject,
      marks: marks,
      totalMarks: totalMarks,
    ));
    await _save();
    notifyListeners();
  }

  Future<void> removeResult(String id) async {
    results.removeWhere((r) => r.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> addTimetableEntry({
    required String classId,
    required int weekday,
    required int period,
    required String subject,
    required String teacher,
  }) async {
    // One lesson per class, weekday and period: replace an old entry.
    timetable.removeWhere(
      (t) =>
          t.classId == classId &&
          t.weekday == weekday &&
          t.period == period,
    );
    timetable.add(TimetableEntry(
      id: _newId(),
      classId: classId,
      weekday: weekday,
      period: period,
      subject: subject,
      teacher: teacher,
    ));
    await _save();
    notifyListeners();
  }

  Future<void> removeTimetableEntry(String id) async {
    timetable.removeWhere((t) => t.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> removeNotice(String id) async {
    notices.removeWhere((n) => n.id == id);
    await _save();
    notifyListeners();
  }

  /// Removes every class, student, fee, notice, result, timetable
  /// entry and attendance record. Nothing is reseeded, so the app
  /// starts clean.
  Future<void> clearAll() async {
    classes = [];
    students = [];
    fees = [];
    notices = [];
    results = [];
    timetable = [];
    attendance = {};
    await _save();
    notifyListeners();
  }

  /// Clears everything, then seeds the original demo classes and students.
  Future<void> resetDemoData() async {
    _seed();
    await _save();
    notifyListeners();
  }

  // Dashboard helpers.
  int get totalStudents => students.length;
  int get totalClasses => classes.length;
  int get feesDueThisMonth => feesDueCount(fees, currentMonthKey());
  double get feesDueAmount => totalFeesDue(
        fees.where((f) => f.month == currentMonthKey()).toList(),
      );
  Notice? get latestNotice => notices.isEmpty ? null : notices.first;
}
