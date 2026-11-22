import 'package:skillswap/core/utils/format_utils.dart';

String clock(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Aujourd'hui : l'heure. Sinon : la date.
String listTime(DateTime d) {
  final now = DateTime.now();
  final sameDay =
      d.year == now.year && d.month == now.month && d.day == now.day;
  return sameDay ? clock(d) : DateFmt.date(d);
}