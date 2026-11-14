import '../models/models.dart';

/// Pure logic for fees and attendance. Kept free of Flutter so it is
/// easy to unit test.

/// Total monthly fee amount due across all unpaid fee records.
double totalFeesDue(List<FeePayment> fees) =>
    fees.where((f) => !f.paid).fold(0.0, (sum, f) => sum + f.amount);

/// Total amount collected (paid) across all fee records.
double totalFeesCollected(List<FeePayment> fees) =>
    fees.where((f) => f.paid).fold(0.0, (sum, f) => sum + f.amount);

/// Number of students who still owe fees for the given month.
int feesDueCount(List<FeePayment> fees, String month) => fees
    .where((f) => f.month == month && !f.paid)
    .map((f) => f.studentId)
    .toSet()
    .length;

/// Fee records for one month, one per student, in student order.
List<FeePayment> feesForMonth(
  List<Student> students,
  List<FeePayment> fees,
  String month,
) {
  return students.map((s) {
    final existing = fees.where(
      (f) => f.studentId == s.id && f.month == month,
    );
    if (existing.isNotEmpty) return existing.first;
    return FeePayment(
      studentId: s.id,
      month: month,
      amount: s.monthlyFee,
      paid: false,
    );
  }).toList();
}

/// Count present and absent students in one day's attendance map.
/// A missing entry counts as not yet marked, not as absent.
({int present, int absent, int unmarked}) countAttendance(
  List<Student> students,
  Map<String, bool> dayAttendance,
) {
  var present = 0;
  var absent = 0;
  var unmarked = 0;
  for (final student in students) {
    final value = dayAttendance[student.id];
    if (value == null) {
      unmarked++;
    } else if (value) {
      present++;
    } else {
      absent++;
    }
  }
  return (present: present, absent: absent, unmarked: unmarked);
}

/// Attendance percentage for one student across many days.
/// Days with no entry for the student are ignored.
double attendancePercentage(
  String studentId,
  Map<String, Map<String, bool>> allDays,
) {
  var present = 0;
  var marked = 0;
  for (final day in allDays.values) {
    final value = day[studentId];
    if (value == null) continue;
    marked++;
    if (value) present++;
  }
  if (marked == 0) return 0;
  return present / marked * 100;
}

// ---------------------------------------------------------------------------
// Exam results and grades
// ---------------------------------------------------------------------------

/// Grade bands used by most Bangladesh school boards.
/// The pass mark is 33.
String gradeForPercentage(double percentage) {
  if (percentage >= 80) return 'A+';
  if (percentage >= 70) return 'A';
  if (percentage >= 60) return 'A-';
  if (percentage >= 50) return 'B';
  if (percentage >= 40) return 'C';
  if (percentage >= 33) return 'D';
  return 'F';
}

/// Grade point for a percentage, on the 5.0 scale.
double gradePointForPercentage(double percentage) {
  if (percentage >= 80) return 5.0;
  if (percentage >= 70) return 4.0;
  if (percentage >= 60) return 3.5;
  if (percentage >= 50) return 3.0;
  if (percentage >= 40) return 2.0;
  if (percentage >= 33) return 1.0;
  return 0.0;
}

/// Summary of one student's results in one exam.
({double obtained, double total, double percentage, String grade, double gpa, bool passed})
resultSummary(List<ExamResult> results) {
  var obtained = 0.0;
  var total = 0.0;
  var points = 0.0;
  var passed = true;
  for (final result in results) {
    obtained += result.marks;
    total += result.totalMarks;
    points += gradePointForPercentage(result.percentage);
    if (result.percentage < 33) passed = false;
  }
  final percentage = total <= 0 ? 0.0 : obtained / total * 100;
  final gpa = results.isEmpty ? 0.0 : points / results.length;
  return (
    obtained: obtained,
    total: total,
    percentage: percentage,
    grade: gradeForPercentage(percentage),
    gpa: gpa,
    passed: passed && results.isNotEmpty,
  );
}

/// Results for one student in one exam, in the order they were recorded.
List<ExamResult> resultsForStudent(
  List<ExamResult> results,
  String studentId,
  String examName,
) =>
    results
        .where((r) => r.studentId == studentId && r.examName == examName)
        .toList();

/// Exam names present in the results, in first-seen order.
List<String> examNames(List<ExamResult> results) {
  final names = <String>[];
  for (final result in results) {
    if (!names.contains(result.examName)) names.add(result.examName);
  }
  return names;
}

/// Rank of one student within a class for one exam, by total marks.
/// Students with equal totals share a rank. Returns 0 when the student
/// has no results in the exam.
int rankInClassForExam(
  List<ExamResult> results,
  List<Student> classStudents,
  String studentId,
  String examName,
) {
  final totals = <String, double>{};
  for (final student in classStudents) {
    final mine = resultsForStudent(results, student.id, examName);
    if (mine.isEmpty) continue;
    totals[student.id] =
        mine.fold(0.0, (sum, r) => sum + r.marks);
  }
  final myTotal = totals[studentId];
  if (myTotal == null) return 0;
  var rank = 1;
  for (final total in totals.values) {
    if (total > myTotal) rank++;
  }
  return rank;
}

// ---------------------------------------------------------------------------
// Timetable
// ---------------------------------------------------------------------------

const List<String> weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
];

/// Entries for one class on one weekday, in period order.
List<TimetableEntry> timetableForDay(
  List<TimetableEntry> entries,
  String classId,
  int weekday,
) {
  final day = entries
      .where((e) => e.classId == classId && e.weekday == weekday)
      .toList();
  day.sort((a, b) => a.period.compareTo(b.period));
  return day;
}

/// True when the class already has a lesson in this weekday and period.
bool hasTimetableConflict(
  List<TimetableEntry> entries,
  String classId,
  int weekday,
  int period,
) =>
    entries.any(
      (e) =>
          e.classId == classId &&
          e.weekday == weekday &&
          e.period == period,
    );

// ---------------------------------------------------------------------------
// Fee receipts and guardian messages
// ---------------------------------------------------------------------------

String receiptNumber(String studentId, String month) => 'EM-$month-$studentId';

/// Plain text fee receipt, ready to copy or share with a guardian.
String feeReceiptText({
  required Student student,
  required String classLabel,
  required String month,
  required double amount,
  required String? paidOn,
}) {
  final buffer = StringBuffer();
  buffer.writeln('EduManager - Fee Receipt');
  buffer.writeln('Receipt no: ${receiptNumber(student.id, month)}');
  buffer.writeln('Student: ${student.name}');
  buffer.writeln('Class: $classLabel');
  buffer.writeln('Month: $month');
  buffer.writeln('Amount paid: ৳${amount.toStringAsFixed(0)}');
  buffer.writeln('Paid on: ${paidOn ?? month}');
  buffer.writeln('Thank you for your payment.');
  return buffer.toString();
}

/// Copyable fee reminder for a guardian. This is message text only,
/// the app does not send messages itself.
String feeReminderText({
  required Student student,
  required String month,
  required double amount,
}) =>
    'Dear guardian of ${student.name}, the monthly fee of '
    '৳${amount.toStringAsFixed(0)} for $month is still due. '
    'Please pay at the office to avoid a late fine. Thank you, EduManager.';

/// Copyable absence notice for a guardian.
String absenceNoticeText({
  required Student student,
  required String date,
}) =>
    'Dear guardian of ${student.name}, your child was absent on $date. '
    'Please inform the office if there is a reason for the absence. '
    'Thank you, EduManager.';

/// Copyable result summary for a guardian.
String resultShareText({
  required Student student,
  required String examName,
  required double obtained,
  required double total,
  required double percentage,
  required String grade,
  required int rank,
  required int classSize,
}) =>
    'Dear guardian of ${student.name}, here is the $examName result: '
    '${obtained.toStringAsFixed(0)} out of ${total.toStringAsFixed(0)} '
    'marks (${percentage.toStringAsFixed(1)}%, grade $grade)'
    '${rank > 0 ? ', rank $rank of $classSize in class' : ''}. '
    'Thank you, EduManager.';
