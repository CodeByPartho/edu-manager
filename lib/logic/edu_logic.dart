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
