import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/default_videos.dart';
import '../models/curated_video.dart';

class StorageService {
  static const String _keyVideos = 'kids_tube_curated_videos';
  static const String _keyParentPin = 'kids_tube_parent_pin';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  /// Load all curated videos from local storage, or initialize with defaults if empty
  Future<List<CuratedVideo>> loadVideos() async {
    final rawList = _prefs.getStringList(_keyVideos);
    if (rawList == null || rawList.isEmpty) {
      // Seed with initial safe videos
      await saveVideos(DefaultVideos.initialList);
      return DefaultVideos.initialList;
    }

    try {
      return rawList.map((str) => CuratedVideo.fromJson(str)).toList();
    } catch (e) {
      // In case of parsing error fallback to defaults
      return DefaultVideos.initialList;
    }
  }

  /// Save the entire list of curated videos
  Future<void> saveVideos(List<CuratedVideo> videos) async {
    final jsonList = videos.map((v) => v.toJson()).toList();
    await _prefs.setStringList(_keyVideos, jsonList);
  }

  /// Add a new video to the top of the curated list
  Future<List<CuratedVideo>> addVideo(CuratedVideo video) async {
    final current = await loadVideos();
    // Prevent duplicates of same YouTube video
    final updated = [
      video,
      ...current.where((v) => v.youtubeId != video.youtubeId),
    ];
    await saveVideos(updated);
    return updated;
  }

  /// Update an existing video
  Future<List<CuratedVideo>> updateVideo(CuratedVideo updatedVideo) async {
    final current = await loadVideos();
    final updated = current.map((v) {
      return v.id == updatedVideo.id ? updatedVideo : v;
    }).toList();
    await saveVideos(updated);
    return updated;
  }

  /// Delete a video by its ID
  Future<List<CuratedVideo>> deleteVideo(String id) async {
    final current = await loadVideos();
    final updated = current.where((v) => v.id != id).toList();
    await saveVideos(updated);
    return updated;
  }

  /// Reset to safe default playlist
  Future<List<CuratedVideo>> resetToDefaults() async {
    await saveVideos(DefaultVideos.initialList);
    return DefaultVideos.initialList;
  }

  /// Get currently stored parental PIN (defaults to '1234')
  String getParentPin() {
    return _prefs.getString(_keyParentPin) ?? DefaultVideos.defaultParentPin;
  }

  /// Change parental PIN
  Future<bool> setParentPin(String newPin) async {
    if (newPin.length == 4) {
      return await _prefs.setString(_keyParentPin, newPin);
    }
    return false;
  }

  /// Verify entered PIN against saved PIN
  bool verifyPin(String enteredPin) {
    final savedPin = getParentPin();
    return enteredPin == savedPin;
  }
}
