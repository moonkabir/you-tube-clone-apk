import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/system_ui_helper.dart';
import '../../data/models/curated_video.dart';
import '../../state/player_lock_provider.dart';
import '../../state/video_provider.dart';
import '../widgets/touch_lock_overlay.dart';

/// Fullscreen Landscape YouTube Kids Player
/// Matches YouTube Kids experience:
/// - Auto-locks into Landscape orientation
/// - Plays video in full screen
/// - Tap video or bottom to show/hide controls & horizontal Up Next video tray
/// - Auto-hides controls after 4 seconds of playback
/// - Toddler Screen Lock mode blocks all touches until sustained 3-second hold
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
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _currentVideo = widget.initialVideo;

    // Force landscape mode for immersive video playback
    SystemUiHelper.setLandscapeMode();
    SystemUiHelper.enableStickyImmersiveMode();

    _playerController = YoutubePlayerController(
      initialVideoId: _currentVideo.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        isLive: false,
        forceHD: true,
        hideControls: true, // Hide default iframe controls for toddler safety
        showLiveFullscreenButton: false,
      ),
    )..addListener(_onPlayerStateChange);

    _startHideTimer();
  }

  void _onPlayerStateChange() {
    if (mounted) {
      setState(() {
        // Keeps position, slider, and play/pause state updated
      });
    }
  }

  void _startHideTimer() {
    _hideControlsTimer?.cancel();
    final lockState = ref.read(playerLockProvider);
    if (lockState.isLocked) return;

    if (_playerController.value.isPlaying) {
      _hideControlsTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && _playerController.value.isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _toggleControls() {
    final lockState = ref.read(playerLockProvider);
    if (lockState.isLocked) return;

    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _startHideTimer();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  void _togglePlayPause() {
    if (_playerController.value.isPlaying) {
      _playerController.pause();
    } else {
      _playerController.play();
    }
    _startHideTimer();
  }

  void _switchVideo(CuratedVideo newVideo) {
    if (_currentVideo.id == newVideo.id) return;

    setState(() {
      _currentVideo = newVideo;
      _showControls = true;
    });
    ref.read(currentVideoProvider.notifier).state = newVideo;

    _playerController.load(newVideo.youtubeId);
    _startHideTimer();
  }

  void _playNextVideo(List<CuratedVideo> videos) {
    if (videos.isEmpty) return;
    final currentIndex = videos.indexWhere((v) => v.id == _currentVideo.id);
    if (currentIndex >= 0 && currentIndex < videos.length - 1) {
      _switchVideo(videos[currentIndex + 1]);
    } else if (currentIndex == videos.length - 1) {
      _switchVideo(videos.first);
    }
  }

  void _playPreviousVideo(List<CuratedVideo> videos) {
    if (videos.isEmpty) return;
    final currentIndex = videos.indexWhere((v) => v.id == _currentVideo.id);
    if (currentIndex > 0) {
      _switchVideo(videos[currentIndex - 1]);
    } else {
      _switchVideo(videos.last);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _playerController.removeListener(_onPlayerStateChange);
    _playerController.dispose();

    // Restore orientation when exiting player
    SystemUiHelper.setFlexibleOrientation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(playerLockProvider);
    final videoListAsync = ref.watch(videoListProvider);
    final isLocked = lockState.isLocked;

    final videos = videoListAsync.value ?? [];

    // Position and duration calculations for the scrubber bar
    final duration = _playerController.metadata.duration;
    final position = _playerController.value.position;
    final maxSeconds = duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0;
    final currentSeconds = position.inSeconds.toDouble().clamp(0.0, maxSeconds);

    return PopScope(
      canPop: !isLocked,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          top: false,
          bottom: false,
          left: false,
          right: false,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Fullscreen Landscape Video Player
              Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: YoutubePlayer(
                    controller: _playerController,
                    showVideoProgressIndicator: false,
                    onReady: () {
                      setState(() {
                        _isPlayerReady = true;
                      });
                      _startHideTimer();
                    },
                    onEnded: (_) {
                      _playNextVideo(videos);
                    },
                  ),
                ),
              ),

              // Loading Spinner until player is ready
              if (!_isPlayerReady)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.vibrantCoral),
                ),

              // 2. Fullscreen Tap Detector to Toggle Controls (when unlocked)
              if (!isLocked)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _toggleControls,
                  ),
                ),

              // 3. Bottom Pill / Indicator when controls are hidden
              if (!isLocked && !_showControls)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _toggleControls,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 6),
                            Text(
                              'Up Next Videos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // 4. YouTube Kids Controls & Up Next Tray Overlay
              AnimatedOpacity(
                opacity: (_showControls && !isLocked) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: IgnorePointer(
                  ignoring: !_showControls || isLocked,
                  child: Stack(
                    children: [
                      // Dark gradient scrims (Top & Bottom)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.8),
                                Colors.black.withValues(alpha: 0.2),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.4),
                                Colors.black.withValues(alpha: 0.9),
                              ],
                              stops: const [0.0, 0.2, 0.45, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // TOP BAR: Back Button, Title, Category & Toddler Lock
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                // Circular Back Button
                                InkWell(
                                  onTap: () => Navigator.of(context).pop(),
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Channel / App Icon
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.vibrantCoral, AppColors.bubbleGumPink],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Video Title & Category
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _currentVideo.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _currentVideo.category,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.75),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Prominent Toddler Screen Lock Button
                                ElevatedButton.icon(
                                  onPressed: () {
                                    ref.read(playerLockProvider.notifier).lockScreen();
                                  },
                                  icon: const Icon(Icons.lock_rounded, size: 16, color: Colors.white),
                                  label: const Text(
                                    'Lock Screen',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.vibrantCoral,
                                    elevation: 2,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // CENTER CONTROLS: Previous, Play/Pause, Next
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Previous Video
                            IconButton(
                              onPressed: () => _playPreviousVideo(videos),
                              iconSize: 42,
                              color: Colors.white,
                              tooltip: 'Previous Video',
                              icon: const Icon(Icons.skip_previous_rounded),
                            ),
                            const SizedBox(width: 28),

                            // Play / Pause Button
                            InkWell(
                              onTap: _togglePlayPause,
                              borderRadius: BorderRadius.circular(40),
                              child: Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _playerController.value.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 44,
                                ),
                              ),
                            ),
                            const SizedBox(width: 28),

                            // Next Video
                            IconButton(
                              onPressed: () => _playNextVideo(videos),
                              iconSize: 42,
                              color: Colors.white,
                              tooltip: 'Next Video',
                              icon: const Icon(Icons.skip_next_rounded),
                            ),
                          ],
                        ),
                      ),

                      // BOTTOM SECTION: Progress Bar & Horizontal Curated Videos Carousel
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 1. Scrubber / Timeline Bar
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Text(
                                      _formatDuration(position),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          trackHeight: 3,
                                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                          activeTrackColor: AppColors.vibrantCoral,
                                          inactiveTrackColor: Colors.white30,
                                          thumbColor: AppColors.vibrantCoral,
                                        ),
                                        child: Slider(
                                          value: currentSeconds,
                                          min: 0.0,
                                          max: maxSeconds,
                                          onChanged: (val) {
                                            _playerController.seekTo(Duration(seconds: val.toInt()));
                                            _startHideTimer();
                                          },
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(duration),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 2. Horizontal Curated Videos Tray (matching Screenshot 1)
                              Container(
                                height: 92,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: videos.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                                  itemBuilder: (context, index) {
                                    final video = videos[index];
                                    final isPlaying = video.id == _currentVideo.id;
                                    return _buildHorizontalVideoCard(video, isPlaying);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Toddler Touch Lock Interceptor Overlay
              if (isLocked)
                const TouchLockOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  /// Horizontal video card matching YouTube Kids thumbnail carousel
  Widget _buildHorizontalVideoCard(CuratedVideo video, bool isPlaying) {
    return InkWell(
      onTap: () => _switchVideo(video),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 136,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPlaying ? AppColors.vibrantCoral : Colors.white24,
            width: isPlaying ? 2.5 : 1.0,
          ),
          boxShadow: isPlaying
              ? [
                  BoxShadow(
                    color: AppColors.vibrantCoral.withValues(alpha: 0.55),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              Image.network(
                video.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade900,
                  child: const Icon(Icons.movie_rounded, color: Colors.white54),
                ),
              ),

              // Bottom duration & status badge bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isPlaying)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.vibrantCoral,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PLAYING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      if (video.durationText.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            video.durationText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Playing overlay equalizer icon
              if (isPlaying)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.equalizer_rounded,
                      color: AppColors.vibrantCoral,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
