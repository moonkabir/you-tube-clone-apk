import '../../data/models/curated_video.dart';

/// Pre-populated safe default toddler videos so app works immediately upon first launch
class DefaultVideos {
  static const String defaultParentPin = '1234';

  static List<CuratedVideo> get initialList => [
    CuratedVideo(
      id: 'default_1',
      youtubeId: 'WRVsOCh907o', // Wheels on the Bus
      title: 'Wheels on the Bus | Nursery Rhymes',
      category: 'Songs',
      durationText: '3:20',
      addedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    CuratedVideo(
      id: 'default_2',
      youtubeId: '75p-N9YKqNo', // Old MacDonald Had a Farm
      title: 'Old MacDonald Had a Farm | Animal Fun',
      category: 'Animals',
      durationText: '2:45',
      addedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CuratedVideo(
      id: 'default_3',
      youtubeId: 'ezmsrB59WJ8', // Twinkle Twinkle Little Star
      title: 'Twinkle Twinkle Little Star | Bedtime Songs',
      category: 'Lullaby',
      durationText: '3:05',
      addedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    CuratedVideo(
      id: 'default_4',
      youtubeId: 'hq3yfQnllfQ', // Learn Colors with Toys
      title: 'Learn Colors with Fun Balloons & Balls',
      category: 'Learning',
      durationText: '4:15',
      addedAt: DateTime.now(),
    ),
    CuratedVideo(
      id: 'default_5',
      youtubeId: '36n93jvjkAk', // ABC Phonics Song
      title: 'ABC Song & Phonics for Toddlers',
      category: 'Learning',
      durationText: '3:40',
      addedAt: DateTime.now(),
    ),
  ];
}
