class HealthGuide {
  const HealthGuide({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.readMinutes,
    required this.relatedBiomarker,
    required this.sections,
  });

  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final int readMinutes;

  final String? relatedBiomarker;
  final List<GuideSection> sections;

  factory HealthGuide.fromJson(Map<String, dynamic> json) {
    return HealthGuide(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      readMinutes: (json['read_minutes'] as num?)?.round() ?? 1,
      relatedBiomarker: json['related_biomarker'] as String?,
      sections: ((json['sections'] as List<dynamic>?) ?? const <dynamic>[])
          .map((dynamic e) => GuideSection.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class GuideSection {
  const GuideSection({
    required this.heading,
    required this.body,
    this.points = const <String>[],
  });

  final String heading;
  final String body;
  final List<String> points;

  factory GuideSection.fromJson(Map<String, dynamic> json) {
    return GuideSection(
      heading: json['heading'] as String? ?? '',
      body: json['body'] as String? ?? '',
      points: ((json['points'] as List<dynamic>?) ?? const <dynamic>[])
          .map((dynamic e) => e.toString())
          .toList(growable: false),
    );
  }
}
