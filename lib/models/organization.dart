/// Social media / contact link bundle for an Organization.
class SocialLinks {
  final String? website;
  final String? instagram;
  final String? twitter;
  final String? facebook;
  final String? linkedin;
  final String? discord;
  final String? youtube;

  const SocialLinks({
    this.website,
    this.instagram,
    this.twitter,
    this.facebook,
    this.linkedin,
    this.discord,
    this.youtube,
  });

  factory SocialLinks.fromJson(Map<String, dynamic> json) => SocialLinks(
        website: json['website'] as String?,
        instagram: json['instagram'] as String?,
        twitter: json['twitter'] as String?,
        facebook: json['facebook'] as String?,
        linkedin: json['linkedin'] as String?,
        discord: json['discord'] as String?,
        youtube: json['youtube'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'website': website,
        'instagram': instagram,
        'twitter': twitter,
        'facebook': facebook,
        'linkedin': linkedin,
        'discord': discord,
        'youtube': youtube,
      };
}

/// A single user's membership record within an Organization.
class OrgMembership {
  final String userId;
  final MemberRole role;
  final DateTime joinedAt;

  const OrgMembership({
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  factory OrgMembership.fromJson(Map<String, dynamic> json) => OrgMembership(
        userId: json['userId'] as String,
        role: MemberRole.values.byName(json['role'] as String),
        joinedAt: DateTime.parse(json['joinedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'role': role.name,
        'joinedAt': joinedAt.toIso8601String(),
      };
}

enum MemberRole {
  /// Full control — can delete the org, transfer ownership.
  owner,

  /// Can create/edit events and manage members.
  admin,

  /// Standard member; visible in the member list.
  member,
}

/// Represents a campus club, student org, or group that hosts Events.
class Organization {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final String? bannerImageUrl;

  /// Tag IDs that describe this organization's focus areas.
  final List<String> tagIds;

  /// IDs of all Events created by this organization.
  final List<String> eventIds;

  /// All current members with their roles.
  final List<OrgMembership> members;

  final String? contactEmail;
  final SocialLinks? socialLinks;

  /// Whether the organization has been verified by platform admins.
  final bool isVerified;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Organization({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    this.bannerImageUrl,
    this.tagIds = const [],
    this.eventIds = const [],
    this.members = const [],
    this.contactEmail,
    this.socialLinks,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns all members with the [MemberRole.admin] or [MemberRole.owner] role.
  List<OrgMembership> get admins => members
      .where((m) => m.role == MemberRole.admin || m.role == MemberRole.owner)
      .toList();

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        logoUrl: json['logoUrl'] as String?,
        bannerImageUrl: json['bannerImageUrl'] as String?,
        tagIds: List<String>.from(json['tagIds'] as List? ?? []),
        eventIds: List<String>.from(json['eventIds'] as List? ?? []),
        members: (json['members'] as List<dynamic>? ?? [])
            .map((e) => OrgMembership.fromJson(e as Map<String, dynamic>))
            .toList(),
        contactEmail: json['contactEmail'] as String?,
        socialLinks: json['socialLinks'] != null
            ? SocialLinks.fromJson(json['socialLinks'] as Map<String, dynamic>)
            : null,
        isVerified: json['isVerified'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'logoUrl': logoUrl,
        'bannerImageUrl': bannerImageUrl,
        'tagIds': tagIds,
        'eventIds': eventIds,
        'members': members.map((m) => m.toJson()).toList(),
        'contactEmail': contactEmail,
        'socialLinks': socialLinks?.toJson(),
        'isVerified': isVerified,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
