class Hospital {
  const Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.travelMinutes,
    this.specialties = const <String>[],
    this.phone,
    this.imageUrl,
    this.hasEmergency = false,
    this.isOpenNow = true,
  });

  final String id;
  final String name;
  final String address;
  final double distanceKm;
  final int travelMinutes;
  final List<String> specialties;
  final String? phone;
  final String? imageUrl;
  final bool hasEmergency;
  final bool isOpenNow;

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
      travelMinutes: (json['travel_minutes'] as num?)?.round() ?? 0,
      specialties:
          ((json['specialties'] as List<dynamic>?) ?? const <dynamic>[])
              .map((dynamic e) => e.toString())
              .toList(growable: false),
      phone: json['phone'] as String?,
      imageUrl: json['image_url'] as String?,
      hasEmergency: json['has_emergency'] as bool? ?? false,
      isOpenNow: json['is_open_now'] as bool? ?? true,
    );
  }
}
