/// Represents a reusable label that can be applied to both Events and Organizations.
/// Tags are scoped by category to help with filtering and discovery.
class Tag {
  final String id;
  final String name;

  /// Hex color string (e.g. '#FF5733') for UI display.
  final String? color;
  final TagCategory category;

  const Tag({
    required this.id,
    required this.name,
    this.color,
    required this.category,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json['id'] as String,
        name: json['name'] as String,
        color: json['color'] as String?,
        category: TagCategory.values.byName(json['category'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'category': category.name,
      };
}

enum TagCategory {
  academic,
  social,
  sports,
  arts,
  technology,
  volunteer,
  career,
  health,
  cultural,
  other,
}
