import 'package:intl/intl.dart';

String taka(double amount) =>
    '৳${NumberFormat('#,##0').format(amount)}';

String shortDate(String isoDate) {
  final parsed = DateTime.tryParse(isoDate);
  if (parsed == null) return isoDate;
  return DateFormat('d MMM yyyy').format(parsed);
}
