import 'dart:convert';

/// Represents a parent-curated video stored locally
class CuratedVideo {
  final String id;
  final String youtubeId;
  final String title;
  final String category;
  final String durationText;
  final DateTime addedAt;

  CuratedVideo({
    required this.id,
    required this.youtubeId,
    required this.title,
    this.category = 'General',
    this.durationText = '',
    required this.addedAt,
  });

  /// High quality thumbnail URL from YouTube CDN
  String get thumbnailUrl => 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';

  /// Max resolution thumbnail URL fallback
  String get maxResThumbnailUrl => 'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg';

  CuratedVideo copyWith({
    String? id,
    String? youtubeId,
    String? title,
    String? category,
    String? durationText,
    DateTime? addedAt,
  }) {
    return CuratedVideo(
      id: id ?? this.id,
      youtubeId: youtubeId ?? this.youtubeId,
      title: title ?? this.title,
      category: category ?? this.category,
      durationText: durationText ?? this.durationText,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'youtubeId': youtubeId,
      'title': title,
      'category': category,
      'durationText': durationText,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory CuratedVideo.fromMap(Map<String, dynamic> map) {
    return CuratedVideo(
      id: map['id'] ?? '',
      youtubeId: map['youtubeId'] ?? '',
      title: map['title'] ?? 'Kids Video',
      category: map['category'] ?? 'General',
      durationText: map['durationText'] ?? '',
      addedAt: map['addedAt'] != null 
          ? DateTime.tryParse(map['addedAt']) ?? DateTime.now() 
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory CuratedVideo.fromJson(String source) => 
      CuratedVideo.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CuratedVideo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          youtubeId == other.youtubeId;

  @override
  int get hashCode => id.hashCode ^ youtubeId.hashCode;
}
