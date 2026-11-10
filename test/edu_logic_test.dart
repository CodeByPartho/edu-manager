import 'package:edu_manager/logic/edu_logic.dart';
import 'package:edu_manager/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final students = [
    Student(id: 's1', name: 'A', classId: 'c1', section: 'A', guardianPhone: '01700', monthlyFee: 1500),
    Student(id: 's2', name: 'B', classId: 'c1', section: 'A', guardianPhone: '01701', monthlyFee: 2000),
    Student(id: 's3', name: 'C', classId: 'c2', section: 'B', guardianPhone: '01702', monthlyFee: 1500),
  ];

  List<FeePayment> feesFor(String month) => [
        FeePayment(studentId: 's1', month: month, amount: 1500, paid: true, paidOn: month),
        FeePayment(studentId: 's2', month: month, amount: 2000, paid: false),
        FeePayment(studentId: 's3', month: month, amount: 1500, paid: false),
      ];

  group('fee totals', () {
    test('totalFeesDue sums only unpaid records', () {
      expect(totalFeesDue(feesFor('2026-11')), 3500);
    });

    test('totalFeesCollected sums only paid records', () {
      expect(totalFeesCollected(feesFor('2026-11')), 1500);
    });

    test('feesDueCount counts one student once per month', () {
      expect(feesDueCount(feesFor('2026-11'), '2026-11'), 2);
      expect(feesDueCount(feesFor('2026-11'), '2026-10'), 0);
    });

    test('feesForMonth fills missing records from the student fee', () {
      final result = feesForMonth(students, [
        FeePayment(studentId: 's1', month: '2026-11', amount: 1500, paid: true),
      ], '2026-11');
      expect(result.length, 3);
      expect(result[1].amount, 2000);
      expect(result[1].paid, isFalse);
      expect(result[2].amount, 1500);
    });

    test('totals are zero with no fee records', () {
      expect(totalFeesDue([]), 0);
      expect(totalFeesCollected([]), 0);
      expect(feesDueCount([], '2026-11'), 0);
    });
  });

  group('attendance counting', () {
    test('counts present, absent and unmarked separately', () {
      final counts = countAttendance(students, {'s1': true, 's2': false});
      expect(counts.present, 1);
      expect(counts.absent, 1);
      expect(counts.unmarked, 1);
    });

    test('all unmarked when the day has no records', () {
      final counts = countAttendance(students, {});
      expect(counts.present, 0);
      expect(counts.absent, 0);
      expect(counts.unmarked, 3);
    });

    test('attendancePercentage ignores unmarked days', () {
      final allDays = {
        '2026-11-09': {'s1': true, 's2': true},
        '2026-11-10': {'s1': false},
      };
      expect(attendancePercentage('s1', allDays), 50);
      expect(attendancePercentage('s2', allDays), 100);
    });

    test('attendancePercentage is zero with no marked days', () {
      expect(attendancePercentage('s3', {}), 0);
      expect(
        attendancePercentage('s3', {'2026-11-09': {'s1': true}}),
        0,
      );
    });
  });
}
