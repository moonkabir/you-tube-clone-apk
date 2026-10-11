import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/youtube_helper.dart';
import '../../data/models/curated_video.dart';
import '../../state/storage_provider.dart';
import '../../state/video_provider.dart';

class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> {
  void _showAddVideoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const _AddVideoBottomSheet(),
    );
  }

  void _showEditVideoDialog(CuratedVideo video) {
    final titleController = TextEditingController(text: video.title);
    final categoryController = TextEditingController(text: video.category);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Video Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Video Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = video.copyWith(
                title: titleController.text.trim().isEmpty ? video.title : titleController.text.trim(),
                category: categoryController.text.trim().isEmpty ? video.category : categoryController.text.trim(),
              );
              ref.read(videoListProvider.notifier).updateVideo(updated);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteVideo(CuratedVideo video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Video?'),
        content: Text('Are you sure you want to remove "${video.title}" from the toddler playlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.vibrantCoral),
            onPressed: () {
              ref.read(videoListProvider.notifier).deleteVideo(video.id);
              Navigator.of(context).pop();
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog() {
    final pinController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Change Parent PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Enter New 4-Digit PIN',
                  border: const OutlineInputBorder(),
                  errorText: errorText,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final pin = pinController.text.trim();
                if (pin.length != 4 || int.tryParse(pin) == null) {
                  setDialogState(() {
                    errorText = 'PIN must be exactly 4 numbers';
                  });
                  return;
                }
                await ref.read(storageServiceProvider).setParentPin(pin);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                if (mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('PIN successfully updated!')),
                  );
                }
              },
              child: const Text('Save PIN'),
            ),
          ],
        ),
      ),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Playlist?'),
        content: const Text('This will restore the default safe starter videos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(videoListProvider.notifier).resetToDefaults();
              Navigator.of(context).pop();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoListAsync = ref.watch(videoListProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Parental Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'pin') _showChangePinDialog();
              if (value == 'reset') _resetToDefaults();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pin',
                child: Row(
                  children: [
                    Icon(Icons.pin_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Change 4-Digit PIN'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restore_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Reset to Default Videos'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVideoSheet,
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Video', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: videoListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (videos) {
          if (videos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.video_library_outlined, size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  const Text('No videos in the curated list yet.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _showAddVideoSheet,
                    child: const Text('Add First Video'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: videos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final video = videos[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Video Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 90,
                          height: 60,
                          child: Image.network(
                            video.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.videocam_off_rounded),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title & ID
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'ID: ${video.youtubeId}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    video.category,
                                    style: const TextStyle(fontSize: 10, color: AppColors.primaryBlue),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Actions
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textMuted),
                        onPressed: () => _showEditVideoDialog(video),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.vibrantCoral),
                        onPressed: () => _confirmDeleteVideo(video),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AddVideoBottomSheet extends ConsumerStatefulWidget {
  const _AddVideoBottomSheet();

  @override
  ConsumerState<_AddVideoBottomSheet> createState() => _AddVideoBottomSheetState();
}

class _AddVideoBottomSheetState extends ConsumerState<_AddVideoBottomSheet> {
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  String _selectedCategory = 'Songs';
  String? _detectedVideoId;
  String? _errorText;

  final List<String> _categories = [
    'Songs',
    'Learning',
    'Animals',
    'Lullaby',
    'Cartoons',
    'Fun',
  ];

  @override
  void initState() {
    super.initState();
    _urlController.addListener(_onUrlChanged);
  }

  void _onUrlChanged() {
    final text = _urlController.text;
    final extracted = YoutubeHelper.extractVideoId(text);
    if (extracted != _detectedVideoId) {
      setState(() {
        _detectedVideoId = extracted;
        _errorText = null;
      });
    }
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChanged);
    _urlController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final input = _urlController.text.trim();
    final videoId = YoutubeHelper.extractVideoId(input);

    if (videoId == null) {
      setState(() {
        _errorText = 'Please enter a valid YouTube URL or 11-digit Video ID';
      });
      return;
    }

    final success = await ref.read(videoListProvider.notifier).addVideo(
      rawUrlOrId: videoId,
      customTitle: _titleController.text.trim(),
      category: _selectedCategory,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video successfully added!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.video_call_rounded, color: AppColors.primaryBlue, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Add Curated Video',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // URL or Video ID input
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'YouTube URL or Video ID',
                hintText: 'e.g. https://youtu.be/WRVsOCh907o',
                border: const OutlineInputBorder(),
                errorText: _errorText,
                prefixIcon: const Icon(Icons.link_rounded),
              ),
            ),
            const SizedBox(height: 14),

            // Live Preview Thumbnail if valid ID is detected
            if (_detectedVideoId != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 140,
                  color: Colors.black12,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        YoutubeHelper.getThumbnailUrl(_detectedVideoId!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text('Thumbnail not found'),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Detected ID: $_detectedVideoId',
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Custom Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Display Title (Optional)',
                hintText: 'Give it a toddler-friendly friendly name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title_rounded),
              ),
            ),
            const SizedBox(height: 14),

            // Category Chips
            const Text(
              'Category:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = cat);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Save Video to Curated List', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
