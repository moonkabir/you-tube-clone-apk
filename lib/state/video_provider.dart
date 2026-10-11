import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/models/curated_video.dart';
import '../data/services/storage_service.dart';
import '../core/utils/youtube_helper.dart';
import 'storage_provider.dart';

class VideoListNotifier extends StateNotifier<AsyncValue<List<CuratedVideo>>> {
  final StorageService _storageService;
  static const _uuid = Uuid();

  VideoListNotifier(this._storageService) : super(const AsyncValue.loading()) {
    loadVideos();
  }

  Future<void> loadVideos() async {
    state = const AsyncValue.loading();
    try {
      final videos = await _storageService.loadVideos();
      state = AsyncValue.data(videos);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addVideo({
    required String rawUrlOrId,
    required String customTitle,
    String category = 'General',
  }) async {
    final youtubeId = YoutubeHelper.extractVideoId(rawUrlOrId);
    if (youtubeId == null) {
      return false;
    }

    final newVideo = CuratedVideo(
      id: _uuid.v4(),
      youtubeId: youtubeId,
      title: YoutubeHelper.formatTitle(customTitle, youtubeId),
      category: category,
      addedAt: DateTime.now(),
    );

    try {
      final updatedList = await _storageService.addVideo(newVideo);
      state = AsyncValue.data(updatedList);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<void> updateVideo(CuratedVideo updatedVideo) async {
    try {
      final updatedList = await _storageService.updateVideo(updatedVideo);
      state = AsyncValue.data(updatedList);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteVideo(String id) async {
    try {
      final updatedList = await _storageService.deleteVideo(id);
      state = AsyncValue.data(updatedList);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> resetToDefaults() async {
    state = const AsyncValue.loading();
    try {
      final list = await _storageService.resetToDefaults();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider for the list of curated videos
final videoListProvider = StateNotifierProvider<VideoListNotifier, AsyncValue<List<CuratedVideo>>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return VideoListNotifier(storageService);
});

/// Provider for currently selected video in player
final currentVideoProvider = StateProvider<CuratedVideo?>((ref) => null);
