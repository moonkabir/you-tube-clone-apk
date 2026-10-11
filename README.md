# Kids Tube - Custom Parent-Curated Toddler Video Player (Flutter)

A distraction-free, toddler-safe YouTube video player app built with Flutter and Riverpod, tailored for Android (specifically optimized for high-refresh devices like the **OnePlus 8T**).

---

## 🌟 Key Features

1. **Parental Dashboard (Admin Mode)**
   - Protected by a 4-digit PIN (default: `1234`).
   - Add videos via YouTube URL (`https://youtu.be/...`, `youtube.com/watch?v=...`, `youtube.com/shorts/...`) or 11-digit Video ID.
   - Live thumbnail and video ID detection preview.
   - Edit video titles, assign categories, and delete videos with confirmation.
   - Offline-first local storage via `shared_preferences`.

2. **Toddler-Friendly Interface (Distraction-Free)**
   - Simplified, cheerful home screen with rounded thumbnail cards and big touch targets.
   - Zero algorithms, zero ads, zero unapproved recommendations.

3. **Player Screen with Up Next Playlist**
   - **Portrait Mode:** YouTube player anchored at the top (16:9), with a scrollable "Up Next" curated playlist `ListView` directly below.
   - Tapping any video switches playback immediately.

4. **Foolproof Touch Screen Lock Mode (Crucial Toddler Protection)**
   - Prominent **Lock Screen** button right beneath the video player.
   - Automatically switches into **fullscreen landscape** mode.
   - Intercepts and blocks **ALL** toddler taps, swipes, and status bar interactions using a transparent `AbsorbPointer` overlay.
   - **Unlock Gesture:** Requires a continuous **3-second long press** on a subtle corner lock pill. Features a radial circular progress indicator that cancels if released early.

5. **OnePlus 8T Android Optimizations**
   - Employs **Sticky Immersive Mode** (`SystemUiMode.immersiveSticky`), hiding status and navigation bars.
   - Prevents accidental notification shade pull-downs or gesture back navigation while the child is watching.

---

## 📁 Project Architecture & Folder Structure

```text
youtube_kids_clone/
├── android/
│   └── app/src/main/AndroidManifest.xml   # Sticky immersive & hardware acceleration
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart            # Toddler color palette & lock colors
│   │   │   └── default_videos.dart        # Safe pre-seeded video list & PIN
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Fredoka typography & rounded themes
│   │   └── utils/
│   │       ├── system_ui_helper.dart      # Sticky immersive mode & orientation
│   │       └── youtube_helper.dart        # Regex URL parser & thumbnail extractor
│   ├── data/
│   │   ├── models/
│   │   │   └── curated_video.dart         # Video data model with JSON serialization
│   │   └── services/
│   │       └── storage_service.dart       # SharedPreferences persistence layer
│   ├── state/
│   │   ├── player_lock_provider.dart      # Riverpod screen lock & progress state
│   │   ├── storage_provider.dart          # Riverpod storage dependency injection
│   │   └── video_provider.dart            # Video list CRUD & current video state
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── kids_home_screen.dart      # Main toddler grid view
│   │   │   ├── parent_dashboard_screen.dart # Admin PIN-protected CRUD manager
│   │   │   └── player_screen.dart         # Top player + bottom playlist layout
│   │   └── widgets/
│   │       ├── kid_video_card.dart        # Playful thumbnail card with bounce
│   │       ├── parent_pin_dialog.dart     # Toddler-resistant 4-digit PIN dialer
│   │       └── touch_lock_overlay.dart    # 3-second hold touch interceptor
│   └── main.dart                          # App entry point & Riverpod root
├── kids_youtube_clone_prompt.md           # Original requirements prompt
└── pubspec.yaml                           # Flutter packages and configurations
```

---

## 🚀 How to Run the App on Your Device

1. **Install Flutter SDK** (if not already installed) from [flutter.dev](https://flutter.dev).
2. Connect your **OnePlus 8T** via USB with **USB Debugging** enabled.
3. Open a terminal in this directory:
   ```bash
   flutter pub get
   flutter run
   ```
4. **Default Parental PIN:** `1234` (can be changed anytime in the Parental Dashboard menu).
