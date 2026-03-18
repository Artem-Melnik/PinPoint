import 'attendance.dart';
import 'event_location.dart';

/// Core Event model. The primary content unit of the application.
class Event {
  final String id;
  final String name;
  final String description;
  final EventLocation location;
  final DateTime startTime;
  final DateTime endTime;

  /// ID of the Organization that owns this event.
  final String organizationId;

  /// List of Tag IDs applied to this event.
  final List<String> tagIds;

  /// Ordered list of image URLs. First image is treated as the hero/thumbnail.
  final List<String> imageUrls;

  /// Optional explicit thumbnail override (defaults to imageUrls.first).
  final String? thumbnailUrl;

  /// When null, attendance tracking is disabled for this event.
  final AttendanceInfo? attendance;

  final EventStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// User ID of the person who created the event.
  final String createdByUserId;

  const Event({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.organizationId,
    this.tagIds = const [],
    this.imageUrls = const [],
    this.thumbnailUrl,
    this.attendance,
    this.status = EventStatus.draft,
    required this.createdAt,
    required this.updatedAt,
    required this.createdByUserId,
  });

  /// Resolves the best available thumbnail URL.
  String? get resolvedThumbnail =>
      thumbnailUrl ?? (imageUrls.isNotEmpty ? imageUrls.first : null);

  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isOngoing =>
      startTime.isBefore(DateTime.now()) && endTime.isAfter(DateTime.now());
  bool get isPast => endTime.isBefore(DateTime.now());

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        location:
            EventLocation.fromJson(json['location'] as Map<String, dynamic>),
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        organizationId: json['organizationId'] as String,
        tagIds: List<String>.from(json['tagIds'] as List? ?? []),
        imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
        thumbnailUrl: json['thumbnailUrl'] as String?,
        attendance: json['attendance'] != null
            ? AttendanceInfo.fromJson(
                json['attendance'] as Map<String, dynamic>)
            : null,
        status: EventStatus.values.byName(
            json['status'] as String? ?? EventStatus.draft.name),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        createdByUserId: json['createdByUserId'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'location': location.toJson(),
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'organizationId': organizationId,
        'tagIds': tagIds,
        'imageUrls': imageUrls,
        'thumbnailUrl': thumbnailUrl,
        'attendance': attendance?.toJson(),
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'createdByUserId': createdByUserId,
      };
}

enum EventStatus {
  /// Not yet visible to non-admin users.
  draft,

  /// Visible and open for RSVPs.
  published,

  /// Cancelled; still visible with a cancellation notice.
  cancelled,

  /// Event has ended.
  completed,
}
