/// Represents the physical or virtual location of an Event.
/// Supports both in-person venues and online meetings.
class EventLocation {
  final String name;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;

  /// Optional coordinates for map display.
  final double? latitude;
  final double? longitude;

  /// If true, the event takes place online.
  final bool isOnline;

  /// URL for virtual meeting (Zoom, Google Meet, etc.).
  final String? onlineUrl;

  const EventLocation({
    required this.name,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.latitude,
    this.longitude,
    this.isOnline = false,
    this.onlineUrl,
  });

  /// Convenience getter for a formatted single-line address.
  String get formattedAddress {
    if (isOnline) return onlineUrl ?? 'Online';
    final parts = [address, city, state, zipCode].whereType<String>();
    return parts.join(', ');
  }

  factory EventLocation.fromJson(Map<String, dynamic> json) => EventLocation(
        name: json['name'] as String,
        address: json['address'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        zipCode: json['zipCode'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        isOnline: json['isOnline'] as bool? ?? false,
        onlineUrl: json['onlineUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'latitude': latitude,
        'longitude': longitude,
        'isOnline': isOnline,
        'onlineUrl': onlineUrl,
      };
}
