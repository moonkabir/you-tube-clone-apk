import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/system_ui_helper.dart';
import '../../state/video_provider.dart';
import '../widgets/kid_video_card.dart';
import '../widgets/parent_pin_dialog.dart';
import 'player_screen.dart';
import 'parent_dashboard_screen.dart';

class KidsHomeScreen extends ConsumerStatefulWidget {
  const KidsHomeScreen({super.key});

  @override
  ConsumerState<KidsHomeScreen> createState() => _KidsHomeScreenState();
}

class _KidsHomeScreenState extends ConsumerState<KidsHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Maintain sticky immersive mode on OnePlus 8T
    SystemUiHelper.enableStickyImmersiveMode();
  }

  void _openParentDashboard() async {
    final unlocked = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const ParentPinDialog(),
    );

    if (unlocked == true && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ParentDashboardScreen()),
      );
      // Re-enable sticky immersive mode when returning to kids interface
      SystemUiHelper.enableStickyImmersiveMode();
    }
  }

  void _openVideo(dynamic video) {
    ref.read(currentVideoProvider.notifier).state = video;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerScreen(initialVideo: video),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoListAsync = ref.watch(videoListProvider);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Cheerful Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Playful Kids Tube Logo
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.vibrantCoral, AppColors.bubbleGumPink],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.vibrantCoral.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'KIDS TUBE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Parent Dashboard Access (Secret Pin Shield)
                  InkWell(
                    onTap: _openParentDashboard,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        color: AppColors.textMuted,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Video Grid List
            Expanded(
              child: videoListAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                ),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.vibrantCoral),
                      const SizedBox(height: 12),
                      Text('Oops! Could not load videos: $error'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.read(videoListProvider.notifier).loadVideos(),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
                data: (videos) {
                  if (videos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.movie_filter_rounded, size: 64, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          const Text(
                            'No videos yet!\nTap the gear icon to add some safe videos.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _openParentDashboard,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Open Parent Settings'),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isLandscape ? 3 : 2,
                      childAspectRatio: isLandscape ? 1.25 : 0.88,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      final video = videos[index];
                      return KidVideoCard(
                        video: video,
                        index: index,
                        onTap: () => _openVideo(video),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
