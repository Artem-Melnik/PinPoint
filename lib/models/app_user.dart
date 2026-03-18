/// Represents an authenticated application user.
/// Authentication details (e.g. Firebase Auth) are managed separately;
/// this model covers only the app-level profile data.
class AppUser {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String? bio;

  /// IDs of Organizations the user has chosen to follow (but is not a member of).
  final List<String> followedOrganizationIds;

  /// IDs of Events the user has bookmarked/saved for later.
  final List<String> savedEventIds;

  /// IDs of Organizations where this user holds a membership (any role).
  final List<String> memberOrganizationIds;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// App-level role. Most users are [AppRole.user].
  final AppRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.bio,
    this.followedOrganizationIds = const [],
    this.savedEventIds = const [],
    this.memberOrganizationIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.role = AppRole.user,
  });

  bool get isPlatformAdmin => role == AppRole.platformAdmin;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        profileImageUrl: json['profileImageUrl'] as String?,
        bio: json['bio'] as String?,
        followedOrganizationIds: List<String>.from(
            json['followedOrganizationIds'] as List? ?? []),
        savedEventIds:
            List<String>.from(json['savedEventIds'] as List? ?? []),
        memberOrganizationIds: List<String>.from(
            json['memberOrganizationIds'] as List? ?? []),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        role: AppRole.values.byName(
            json['role'] as String? ?? AppRole.user.name),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'profileImageUrl': profileImageUrl,
        'bio': bio,
        'followedOrganizationIds': followedOrganizationIds,
        'savedEventIds': savedEventIds,
        'memberOrganizationIds': memberOrganizationIds,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'role': role.name,
      };
}

enum AppRole {
  /// Standard user with no special privileges.
  user,

  /// Can verify organizations and moderate content.
  platformAdmin,
}
