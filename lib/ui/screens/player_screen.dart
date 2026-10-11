import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/system_ui_helper.dart';
import '../../data/models/curated_video.dart';
import '../../state/player_lock_provider.dart';
import '../../state/video_provider.dart';
import '../widgets/touch_lock_overlay.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final CuratedVideo initialVideo;

  const PlayerScreen({
    super.key,
    required this.initialVideo,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late YoutubePlayerController _playerController;
  late CuratedVideo _currentVideo;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _currentVideo = widget.initialVideo;

    _playerController = YoutubePlayerController(
      initialVideoId: _currentVideo.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        isLive: false,
        forceHD: true,
        hideControls: false,
        showLiveFullscreenButton: false,
      ),
    )..addListener(_onPlayerStateChange);

    // Keep sticky immersive mode active
    SystemUiHelper.enableStickyImmersiveMode();
  }

  void _onPlayerStateChange() {
    if (_isPlayerReady && mounted && !_playerController.value.isFullScreen) {
      // Keep UI state synchronized
    }
  }

  void _switchVideo(CuratedVideo newVideo) {
    if (_currentVideo.id == newVideo.id) return;

    setState(() {
      _currentVideo = newVideo;
    });
    ref.read(currentVideoProvider.notifier).state = newVideo;

    _playerController.load(newVideo.youtubeId);
  }

  @override
  void dispose() {
    _playerController.removeListener(_onPlayerStateChange);
    _playerController.dispose();
    // Restore flexible orientation when exiting player
    SystemUiHelper.setFlexibleOrientation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(playerLockProvider);
    final videoListAsync = ref.watch(videoListProvider);
    final isLocked = lockState.isLocked;

    return PopScope(
      // Prevent toddler back-button escape if locked
      canPop: !isLocked,
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _playerController,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.vibrantCoral,
          progressColors: const ProgressBarColors(
            playedColor: AppColors.vibrantCoral,
            handleColor: AppColors.sunnyYellow,
            bufferedColor: Colors.white30,
            backgroundColor: Colors.white10,
          ),
          onReady: () {
            setState(() {
              _isPlayerReady = true;
            });
          },
        ),
        builder: (context, player) {
          return Scaffold(
            backgroundColor: isLocked ? Colors.black : AppColors.backgroundLight,
            body: SafeArea(
              top: !isLocked,
              bottom: !isLocked,
              left: !isLocked,
              right: !isLocked,
              child: Stack(
                children: [
                  // Primary Content Layout
                  isLocked
                      ? _buildLockedPlayer(player)
                      : _buildUnlockedLayout(player, videoListAsync),

                  // Crucial Touch Lock Interceptor Overlay
                  if (isLocked)
                    const TouchLockOverlay(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Fullscreen player when toddler lock is active
  Widget _buildLockedPlayer(Widget player) {
    return Center(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: player,
      ),
    );
  }

  /// Standard portrait layout with Player on Top and Up Next Playlist on Bottom
  Widget _buildUnlockedLayout(
    Widget player,
    AsyncValue<List<CuratedVideo>> videoListAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. YouTube Player at Top (16:9 Aspect Ratio)
        Container(
          color: Colors.black,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: player,
          ),
        ),

        // 2. Playback Action Bar (Back button, Title & Lock Screen Button)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              // Exit button
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textDark,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Current Video Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentVideo.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentVideo.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // PROMINENT LOCK SCREEN BUTTON (Crucial requirement)
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(playerLockProvider.notifier).lockScreen();
                },
                icon: const Icon(Icons.lock_rounded, size: 20, color: Colors.white),
                label: const Text(
                  'Lock Screen',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vibrantCoral,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. Up Next Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Icon(
                Icons.playlist_play_rounded,
                color: AppColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 6),
              const Text(
                'Up Next (Curated Playlist)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              videoListAsync.when(
                data: (list) => Text(
                  '${list.length} videos',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),

        // 4. Scrollable ListView of Curated Videos directly below the player
        Expanded(
          child: videoListAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (err, _) => Center(
              child: Text('Error loading playlist: $err'),
            ),
            data: (videos) {
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: videos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final video = videos[index];
                  final isPlaying = video.id == _currentVideo.id;

                  return _buildPlaylistTile(video, isPlaying);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistTile(CuratedVideo video, bool isPlaying) {
    return InkWell(
      onTap: () => _switchVideo(video),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isPlaying ? AppColors.primaryBlue.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPlaying ? AppColors.primaryBlue : Colors.grey.shade200,
            width: isPlaying ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail with playing overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 100,
                height: 60,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.movie, color: Colors.grey),
                      ),
                    ),
                    if (isPlaying)
                      Container(
                        color: AppColors.primaryBlue.withValues(alpha: 0.6),
                        child: const Center(
                          child: Icon(
                            Icons.equalizer_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Video Title & Category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isPlaying ? FontWeight.bold : FontWeight.w600,
                      color: isPlaying ? AppColors.primaryBlue : AppColors.textDark,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          video.category,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isPlaying) ...[
                        const SizedBox(width: 8),
                        const Text(
                          'Now Playing',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.play_arrow_rounded,
              color: AppColors.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
