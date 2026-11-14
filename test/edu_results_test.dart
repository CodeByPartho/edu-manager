import 'package:edu_manager/logic/edu_logic.dart';
import 'package:edu_manager/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final students = [
    Student(id: 's1', name: 'A', classId: 'c1', section: 'A', guardianPhone: '01700', monthlyFee: 1500),
    Student(id: 's2', name: 'B', classId: 'c1', section: 'A', guardianPhone: '01701', monthlyFee: 1500),
    Student(id: 's3', name: 'C', classId: 'c1', section: 'A', guardianPhone: '01702', monthlyFee: 1500),
  ];

  List<ExamResult> resultsFor(String exam) => [
        ExamResult(id: 'r1', studentId: 's1', examName: exam, subject: 'Bangla', marks: 85, totalMarks: 100),
        ExamResult(id: 'r2', studentId: 's1', examName: exam, subject: 'English', marks: 75, totalMarks: 100),
        ExamResult(id: 'r3', studentId: 's2', examName: exam, subject: 'Bangla', marks: 60, totalMarks: 100),
        ExamResult(id: 'r4', studentId: 's2', examName: exam, subject: 'English', marks: 60, totalMarks: 100),
        ExamResult(id: 'r5', studentId: 's3', examName: exam, subject: 'Bangla', marks: 30, totalMarks: 100),
        ExamResult(id: 'r6', studentId: 's3', examName: exam, subject: 'English', marks: 90, totalMarks: 100),
      ];

  group('grades', () {
    test('gradeForPercentage follows the board bands', () {
      expect(gradeForPercentage(100), 'A+');
      expect(gradeForPercentage(80), 'A+');
      expect(gradeForPercentage(79.9), 'A');
      expect(gradeForPercentage(70), 'A');
      expect(gradeForPercentage(60), 'A-');
      expect(gradeForPercentage(50), 'B');
      expect(gradeForPercentage(40), 'C');
      expect(gradeForPercentage(33), 'D');
      expect(gradeForPercentage(32.9), 'F');
      expect(gradeForPercentage(0), 'F');
    });

    test('gradePointForPercentage uses the 5.0 scale', () {
      expect(gradePointForPercentage(85), 5.0);
      expect(gradePointForPercentage(70), 4.0);
      expect(gradePointForPercentage(60), 3.5);
      expect(gradePointForPercentage(50), 3.0);
      expect(gradePointForPercentage(40), 2.0);
      expect(gradePointForPercentage(33), 1.0);
      expect(gradePointForPercentage(20), 0.0);
    });
  });

  group('result summary', () {
    test('totals, percentage, grade and GPA from subject marks', () {
      final mine = resultsForStudent(resultsFor('Monthly Exam'), 's1', 'Monthly Exam');
      final summary = resultSummary(mine);
      expect(summary.obtained, 160);
      expect(summary.total, 200);
      expect(summary.percentage, 80);
      expect(summary.grade, 'A+');
      expect(summary.gpa, 4.5);
      expect(summary.passed, isTrue);
    });

    test('one failed subject fails the whole exam', () {
      final mine = resultsForStudent(resultsFor('Monthly Exam'), 's3', 'Monthly Exam');
      final summary = resultSummary(mine);
      expect(summary.passed, isFalse);
      expect(summary.percentage, 60);
    });

    test('empty results are zero and not passed', () {
      final summary = resultSummary([]);
      expect(summary.obtained, 0);
      expect(summary.total, 0);
      expect(summary.percentage, 0);
      expect(summary.grade, 'F');
      expect(summary.gpa, 0);
      expect(summary.passed, isFalse);
    });

    test('examNames lists each exam once, in first-seen order', () {
      final all = [
        ...resultsFor('Monthly Exam'),
        ExamResult(id: 'r7', studentId: 's1', examName: 'Half Yearly', subject: 'Bangla', marks: 70, totalMarks: 100),
      ];
      expect(examNames(all), ['Monthly Exam', 'Half Yearly']);
    });
  });

  group('class rank', () {
    test('ranks by total marks, ties share a rank', () {
      final all = resultsFor('Monthly Exam');
      // s1 total 160, s2 total 120, s3 total 120.
      expect(rankInClassForExam(all, students, 's1', 'Monthly Exam'), 1);
      expect(rankInClassForExam(all, students, 's2', 'Monthly Exam'), 2);
      expect(rankInClassForExam(all, students, 's3', 'Monthly Exam'), 2);
    });

    test('rank is zero with no results in the exam', () {
      expect(rankInClassForExam([], students, 's1', 'Monthly Exam'), 0);
    });
  });

  group('timetable', () {
    final entries = [
      TimetableEntry(id: 't1', classId: 'c1', weekday: 1, period: 3, subject: 'Science', teacher: 'Ms. Jahan'),
      TimetableEntry(id: 't2', classId: 'c1', weekday: 1, period: 1, subject: 'Bangla', teacher: 'Mr. Rahman'),
      TimetableEntry(id: 't3', classId: 'c1', weekday: 2, period: 1, subject: 'English', teacher: 'Ms. Akter'),
    ];

    test('timetableForDay filters by class and day, in period order', () {
      final day = timetableForDay(entries, 'c1', 1);
      expect(day.map((e) => e.subject).toList(), ['Bangla', 'Science']);
    });

    test('hasTimetableConflict detects a taken slot only', () {
      expect(hasTimetableConflict(entries, 'c1', 1, 1), isTrue);
      expect(hasTimetableConflict(entries, 'c1', 1, 2), isFalse);
      expect(hasTimetableConflict(entries, 'c1', 2, 1), isTrue);
      expect(hasTimetableConflict(entries, 'c2', 1, 1), isFalse);
    });
  });

  group('fee receipts and guardian messages', () {
    final student = students.first;

    test('feeReceiptText carries receipt number, student, month and amount', () {
      final text = feeReceiptText(
        student: student,
        classLabel: 'Class 8 - Section A',
        month: '2026-11',
        amount: 1500,
        paidOn: '2026-11-05',
      );
      expect(text, contains('EM-2026-11-s1'));
      expect(text, contains('A'));
      expect(text, contains('2026-11'));
      expect(text, contains('1500'));
      expect(text, contains('2026-11-05'));
    });

    test('feeReminderText names the student, month and amount due', () {
      final text = feeReminderText(student: student, month: '2026-11', amount: 1500);
      expect(text, contains('A'));
      expect(text, contains('2026-11'));
      expect(text, contains('1500'));
    });

    test('absenceNoticeText names the student and the date', () {
      final text = absenceNoticeText(student: student, date: '2026-11-14');
      expect(text, contains('A'));
      expect(text, contains('2026-11-14'));
    });

    test('resultShareText carries marks, percentage, grade and rank', () {
      final text = resultShareText(
        student: student,
        examName: 'Monthly Exam',
        obtained: 160,
        total: 200,
        percentage: 80,
        grade: 'A+',
        rank: 1,
        classSize: 3,
      );
      expect(text, contains('Monthly Exam'));
      expect(text, contains('160'));
      expect(text, contains('80.0%'));
      expect(text, contains('A+'));
      expect(text, contains('rank 1 of 3'));
    });
  });
}
