# EduManager

Education management mini app for schools and coaching centres. Built with Flutter and Material 3. Part of a one app per day reference build series by Partho Sarothi Paik.

## What it does

- Dashboard: total students, classes, fees due count and amount, present today, and the latest notice
- Students: searchable list with guardian phone and monthly fee, add a student (name, class, section, guardian phone, monthly fee), long press to remove
- Classes: class list with room and student count, expandable student roster, add a class
- Attendance: mark present or absent per class for today, with present, absent and not marked counts, plus an All present button. Saved per date on the device
- Fees: monthly fee list per student with paid and due status, mark paid and undo, collected and due totals for the current month
- Notices: notice board to post and delete notices

## Data

Everything is stored locally with shared_preferences as JSON. No account, no server, no network calls. The first launch seeds demo data: 2 classes (Class 8 Section A, Class 9 Section B) and 12 students, with about half of the current month fees already paid and one day of attendance history.

## Tech

- Flutter 3.47.9, Material 3 dark theme, accent #39FF88
- State: provider
- Dates: intl
- Storage: shared_preferences

## Run

```sh
flutter pub get
flutter run
```

## Test

```sh
flutter analyze
flutter test
flutter build web --release
```

Unit tests cover fee totals (due, collected, due count, missing month fill) and attendance counting (present, absent, unmarked, percentage ignoring unmarked days).

## Project structure

- `lib/main.dart` app entry and dark theme
- `lib/models/models.dart` Student, SchoolClass, FeePayment, Notice
- `lib/logic/edu_logic.dart` pure fee and attendance logic
- `lib/state/edu_state.dart` state, persistence and demo seed
- `lib/screens/` dashboard, students, classes, attendance, fees, notices, main shell
- `lib/utils/format.dart` taka and date formatting
- `test/edu_logic_test.dart` unit tests
