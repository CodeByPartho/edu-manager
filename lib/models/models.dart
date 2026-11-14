class Student {
  Student({
    required this.id,
    required this.name,
    required this.classId,
    required this.section,
    required this.guardianPhone,
    required this.monthlyFee,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'] as String,
        name: json['name'] as String,
        classId: json['classId'] as String,
        section: json['section'] as String,
        guardianPhone: json['guardianPhone'] as String,
        monthlyFee: (json['monthlyFee'] as num).toDouble(),
      );

  final String id;
  final String name;
  final String classId;
  final String section;
  final String guardianPhone;
  final double monthlyFee;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'classId': classId,
        'section': section,
        'guardianPhone': guardianPhone,
        'monthlyFee': monthlyFee,
      };
}

class SchoolClass {
  SchoolClass({
    required this.id,
    required this.name,
    required this.section,
    required this.room,
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) => SchoolClass(
        id: json['id'] as String,
        name: json['name'] as String,
        section: json['section'] as String,
        room: json['room'] as String,
      );

  final String id;
  final String name;
  final String section;
  final String room;

  String get label => '$name - Section $section';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'section': section,
        'room': room,
      };
}

class FeePayment {
  FeePayment({
    required this.studentId,
    required this.month,
    required this.amount,
    required this.paid,
    this.paidOn,
  });

  factory FeePayment.fromJson(Map<String, dynamic> json) => FeePayment(
        studentId: json['studentId'] as String,
        month: json['month'] as String,
        amount: (json['amount'] as num).toDouble(),
        paid: json['paid'] as bool,
        paidOn: json['paidOn'] as String?,
      );

  final String studentId;
  final String month;
  final double amount;
  final bool paid;
  final String? paidOn;

  FeePayment copyWith({bool? paid, String? paidOn}) => FeePayment(
        studentId: studentId,
        month: month,
        amount: amount,
        paid: paid ?? this.paid,
        paidOn: paidOn ?? this.paidOn,
      );

  Map<String, dynamic> toJson() => {
        'studentId': studentId,
        'month': month,
        'amount': amount,
        'paid': paid,
        'paidOn': paidOn,
      };
}

class Notice {
  Notice({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
  });

  factory Notice.fromJson(Map<String, dynamic> json) => Notice(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        date: json['date'] as String,
      );

  final String id;
  final String title;
  final String body;
  final String date;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'date': date,
      };
}

/// One subject mark for one student in one exam.
/// [marks] is the score out of [totalMarks].
class ExamResult {
  ExamResult({
    required this.id,
    required this.studentId,
    required this.examName,
    required this.subject,
    required this.marks,
    required this.totalMarks,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) => ExamResult(
        id: json['id'] as String,
        studentId: json['studentId'] as String,
        examName: json['examName'] as String,
        subject: json['subject'] as String,
        marks: (json['marks'] as num).toDouble(),
        totalMarks: (json['totalMarks'] as num).toDouble(),
      );

  final String id;
  final String studentId;
  final String examName;
  final String subject;
  final double marks;
  final double totalMarks;

  double get percentage => totalMarks <= 0 ? 0 : marks / totalMarks * 100;

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'examName': examName,
        'subject': subject,
        'marks': marks,
        'totalMarks': totalMarks,
      };
}

/// One weekly timetable slot for a class.
/// [weekday] is 1 for Monday through 5 for Friday.
/// [period] is the period number within the day, starting at 1.
class TimetableEntry {
  TimetableEntry({
    required this.id,
    required this.classId,
    required this.weekday,
    required this.period,
    required this.subject,
    required this.teacher,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) =>
      TimetableEntry(
        id: json['id'] as String,
        classId: json['classId'] as String,
        weekday: json['weekday'] as int,
        period: json['period'] as int,
        subject: json['subject'] as String,
        teacher: json['teacher'] as String,
      );

  final String id;
  final String classId;
  final int weekday;
  final int period;
  final String subject;
  final String teacher;

  Map<String, dynamic> toJson() => {
        'id': id,
        'classId': classId,
        'weekday': weekday,
        'period': period,
        'subject': subject,
        'teacher': teacher,
      };
}
