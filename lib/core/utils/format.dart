String fmtNum(num n) {
  final s = n.round().abs().toString();
  final b = StringBuffer(n < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

String _trim(String v) => v.contains('.') ? v.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '') : v;

String fmtPrice(num p, bool ar) {
  if (p >= 1000000) {
    final v = p / 1000000;
    final s = _trim(v.toStringAsFixed(v >= 10 ? 1 : 2));
    return ar ? '$s مليون ج.م' : 'EGP ${s}M';
  }
  if (p >= 1000) {
    final v = p / 1000;
    final s = _trim(v.toStringAsFixed(v >= 100 ? 0 : 1));
    return ar ? '$s ألف ج.م' : 'EGP ${s}K';
  }
  return fmtFull(p, ar);
}

String fmtShort(num p) {
  if (p >= 1000000) return '${_trim((p / 1000000).toStringAsFixed(p >= 10000000 ? 1 : 2))}M';
  if (p >= 1000) return '${_trim((p / 1000).toStringAsFixed(0))}K';
  return p.round().toString();
}

String fmtFull(num p, bool ar) => ar ? '${fmtNum(p)} ج.م' : 'EGP ${fmtNum(p)}';

const _arDays = ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
const _enDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _arMonths = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
const _enMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String dayName(DateTime d, bool ar) => (ar ? _arDays : _enDays)[d.weekday - 1];
String monthName(DateTime d, bool ar) => (ar ? _arMonths : _enMonths)[d.month - 1];
String fmtDate(DateTime d, bool ar) => ar ? '${d.day} ${monthName(d, ar)} ${d.year}' : '${monthName(d, ar)} ${d.day}, ${d.year}';

String timeAgo(DateTime d, bool ar) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return ar ? 'الآن' : 'just now';
  if (diff.inHours < 1) return ar ? 'منذ ${diff.inMinutes} دقيقة' : '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return ar ? 'منذ ${diff.inHours} ساعة' : '${diff.inHours}h ago';
  if (diff.inDays == 1) return ar ? 'منذ يوم' : '1 day ago';
  return ar ? 'منذ ${diff.inDays} أيام' : '${diff.inDays} days ago';
}

bool isEgyptianMobile(String v) => RegExp(r'^01[0125][0-9]{8}$').hasMatch(v.replaceAll(' ', ''));
