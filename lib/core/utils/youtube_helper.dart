class YoutubeHelper {
  /// Regular expressions matching various YouTube link patterns
  static final RegExp _regExp = RegExp(
    r'^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*',
    caseSensitive: false,
    multiLine: false,
  );

  /// Extract 11-character YouTube video ID from URL or return the trimmed raw ID if already valid
  static String? extractVideoId(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // Check if it's already an 11-char YouTube ID (letters, numbers, underscore, hyphen)
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(trimmed)) {
      return trimmed;
    }

    final match = _regExp.firstMatch(trimmed);
    if (match != null && match.groupCount >= 1) {
      final id = match.group(1);
      if (id != null && id.length == 11) {
        return id;
      }
    }

    return null;
  }

  /// Get thumbnail image URL from video ID
  static String getThumbnailUrl(String videoId, {bool highQuality = true}) {
    if (highQuality) {
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }
    return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
  }

  /// Clean user-provided title or generate sensible default
  static String formatTitle(String rawTitle, String videoId) {
    if (rawTitle.trim().isNotEmpty) {
      return rawTitle.trim();
    }
    return 'Video ($videoId)';
  }
}
