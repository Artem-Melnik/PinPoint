/// Tracks a single user's RSVP/check-in state for an Event.
class AttendanceRecord {
  final String userId;
  final RSVPStatus status;
  final DateTime rsvpAt;

  /// Whether the user physically checked in on the day.
  final bool checkedIn;
  final DateTime? checkedInAt;

  const AttendanceRecord({
    required this.userId,
    required this.status,
    required this.rsvpAt,
    this.checkedIn = false,
    this.checkedInAt,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        userId: json['userId'] as String,
        status: RSVPStatus.values.byName(json['status'] as String),
        rsvpAt: DateTime.parse(json['rsvpAt'] as String),
        checkedIn: json['checkedIn'] as bool? ?? false,
        checkedInAt: json['checkedInAt'] != null
            ? DateTime.parse(json['checkedInAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'status': status.name,
        'rsvpAt': rsvpAt.toIso8601String(),
        'checkedIn': checkedIn,
        'checkedInAt': checkedInAt?.toIso8601String(),
      };
}

enum RSVPStatus { going, maybe, notGoing }

/// Optional attendance configuration embedded within an Event.
/// When null on an Event, attendance tracking is disabled for that event.
class AttendanceInfo {
  /// Whether users must RSVP to attend.
  final bool requiresRSVP;

  /// Maximum number of attendees allowed. Null means unlimited.
  final int? maxCapacity;

  /// Deadline after which RSVPs are no longer accepted.
  final DateTime? rsvpDeadline;

  /// All RSVP/check-in records for the event.
  final List<AttendanceRecord> records;

  const AttendanceInfo({
    this.requiresRSVP = false,
    this.maxCapacity,
    this.rsvpDeadline,
    this.records = const [],
  });

  /// Convenience getters for quick stats.
  int get goingCount =>
      records.where((r) => r.status == RSVPStatus.going).length;
  int get maybeCount =>
      records.where((r) => r.status == RSVPStatus.maybe).length;
  int get checkedInCount => records.where((r) => r.checkedIn).length;
  bool get isFull => maxCapacity != null && goingCount >= maxCapacity!;

  factory AttendanceInfo.fromJson(Map<String, dynamic> json) => AttendanceInfo(
        requiresRSVP: json['requiresRSVP'] as bool? ?? false,
        maxCapacity: json['maxCapacity'] as int?,
        rsvpDeadline: json['rsvpDeadline'] != null
            ? DateTime.parse(json['rsvpDeadline'] as String)
            : null,
        records: (json['records'] as List<dynamic>? ?? [])
            .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'requiresRSVP': requiresRSVP,
        'maxCapacity': maxCapacity,
        'rsvpDeadline': rsvpDeadline?.toIso8601String(),
        'records': records.map((r) => r.toJson()).toList(),
      };
}
