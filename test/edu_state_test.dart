import 'package:edu_manager/state/edu_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('reset data', () {
    test('clearAll empties classes, students, fees, notices and attendance',
        () async {
      final state = EduState();
      await state.resetDemoData();
      expect(state.classes.length, 2);
      expect(state.students.length, 12);
      // 12 students x 4 subjects in the Monthly Exam.
      expect(state.results.length, 48);
      // 2 classes x 5 days x 5 periods.
      expect(state.timetable.length, 50);

      await state.clearAll();

      expect(state.classes, isEmpty);
      expect(state.students, isEmpty);
      expect(state.fees, isEmpty);
      expect(state.notices, isEmpty);
      expect(state.results, isEmpty);
      expect(state.timetable, isEmpty);
      expect(state.attendance, isEmpty);
    });

    test('resetDemoData reseeds the original demo classes and students',
        () async {
      final state = EduState();
      await state.clearAll();
      expect(state.students, isEmpty);

      await state.resetDemoData();

      expect(state.classes.length, 2);
      expect(state.students.length, 12);
      expect(state.fees.length, 12);
      expect(state.notices.length, 2);
      expect(state.results.length, 48);
      expect(state.timetable.length, 50);
      expect(state.attendance, isNotEmpty);
    });

    test('resetDemoData persists results and timetable too', () async {
      final state = EduState();
      await state.clearAll();
      await state.resetDemoData();

      final reloaded = EduState();
      await reloaded.load();

      expect(reloaded.results.length, 48);
      expect(reloaded.timetable.length, 50);
    });

    test('clearAll persists, so a fresh load does not reseed', () async {
      final state = EduState();
      await state.resetDemoData();
      await state.clearAll();

      final reloaded = EduState();
      await reloaded.load();

      expect(reloaded.classes, isEmpty);
      expect(reloaded.students, isEmpty);
      expect(reloaded.fees, isEmpty);
      expect(reloaded.notices, isEmpty);
      expect(reloaded.attendance, isEmpty);
    });

    test('resetDemoData persists, so a fresh load sees the demo data',
        () async {
      final state = EduState();
      await state.clearAll();
      await state.resetDemoData();

      final reloaded = EduState();
      await reloaded.load();

      expect(reloaded.classes.length, 2);
      expect(reloaded.students.length, 12);
    });
  });
}
