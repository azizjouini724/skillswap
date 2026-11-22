String initialsOf(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

class DateFmt {
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String date(DateTime d) {
    final year = d.year == DateTime.now().year ? '' : ' ${d.year}';
    return '${_days[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}$year';
  }

  static String time(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

  static String dateTime(DateTime d) => '${date(d)}, ${time(d)}';
}