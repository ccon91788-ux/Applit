import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'vi_VN');
  static final DateFormat monthYearFormat = DateFormat('MMMM yyyy', 'vi_VN');
  static final DateFormat timeFormat = DateFormat('HH:mm');

  static String formatDate(DateTime d) => dateFormat.format(d);
  static String formatMonthYear(DateTime d) => monthYearFormat.format(d);
  static String formatTime(String hhmm) => hhmm;

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime addMonths(DateTime date, int months) {
    var y = date.year;
    var m = date.month + months;
    while (m > 12) {
      m -= 12;
      y++;
    }
    while (m < 1) {
      m += 12;
      y--;
    }
    final lastDay = DateTime(y, m + 1, 0).day;
    final d = date.day > lastDay ? lastDay : date.day;
    return DateTime(y, m, d);
  }

  static DateTime nextOccurrence(DateTime from, String repeat) {
    switch (repeat) {
      case 'daily':
        return from.add(const Duration(days: 1));
      case 'weekly':
        return from.add(const Duration(days: 7));
      case 'monthly':
        return addMonths(from, 1);
      case 'yearly':
        return DateTime(from.year + 1, from.month, from.day);
      default:
        return from;
    }
  }
}
