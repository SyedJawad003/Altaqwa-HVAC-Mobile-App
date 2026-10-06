class JobProgress {
  static const requested = 'requested';
  static const assigned = 'assigned';
  static const accepted = 'accepted';
  static const onTheWay = 'on_the_way';
  static const arrived = 'arrived';
  static const workStarted = 'work_started';
  static const completed = 'completed';
  static const verified = 'verified';

  static const stages = <String>[
    requested,
    assigned,
    accepted,
    onTheWay,
    arrived,
    workStarted,
    completed,
    verified,
  ];

  static const labels = <String, String>{
    requested: 'Requested',
    assigned: 'Assigned',
    accepted: 'Accepted',
    onTheWay: 'On the Way',
    arrived: 'Arrived',
    workStarted: 'Work Started',
    completed: 'Completed',
    verified: 'Verified',
  };

  static String labelFor(String stage) =>
      labels[stage] ?? (stage.isEmpty ? 'Requested' : stage);

  static String fromLegacyStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'new':
        return requested;
      case 'assigned':
        return assigned;
      case 'confirmed':
        return accepted;
      case 'on_the_way':
        return onTheWay;
      case 'arrived':
        return arrived;
      case 'in_progress':
      case 'work_started':
        return workStarted;
      case 'completed':
        return completed;
      case 'verified':
        return verified;
      default:
        return requested;
    }
  }

  static int indexOf(String stage) {
    final index = stages.indexOf(stage);
    return index < 0 ? 0 : index;
  }
}

DateTime? parseJobDate(String date, [String time = '']) {
  final raw = date.trim();
  if (raw.isEmpty) return null;
  final parsed = DateTime.tryParse(raw);
  if (parsed != null) {
    return _withTime(parsed, time);
  }
  for (final separator in ['/', '-', '.']) {
    final parts = raw.split(separator);
    if (parts.length == 3) {
      final first = int.tryParse(parts[0]);
      final second = int.tryParse(parts[1]);
      final third = int.tryParse(parts[2]);
      if (first == null || second == null || third == null) continue;
      try {
        final value = first > 31
            ? DateTime(first, second, third)
            : DateTime(third, second, first);
        return _withTime(value, time);
      } catch (_) {}
    }
  }
  return null;
}

DateTime _withTime(DateTime date, String time) {
  final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(time);
  if (match == null) return DateTime(date.year, date.month, date.day);
  return DateTime(
    date.year,
    date.month,
    date.day,
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
  );
}

bool isSameDay(DateTime left, DateTime right) =>
    left.year == right.year && left.month == right.month && left.day == right.day;

class JobIssue {
  const JobIssue({
    required this.id,
    required this.requestId,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    this.technicianName = '',
    this.customerName = '',
    this.serviceName = '',
    this.createdByName = '',
    this.createdByEmail = '',
    this.createdByRole = 'supervisor',
    this.createdAt,
  });

  final String id;
  final String requestId;
  final String type;
  final String title;
  final String description;
  final String status;
  final String technicianName;
  final String customerName;
  final String serviceName;
  final String createdByName;
  final String createdByEmail;
  final String createdByRole;
  final DateTime? createdAt;

  String get typeLabel => type.replaceAll('_', ' ');

  bool get isOpen => status.toLowerCase() != 'resolved';
}
