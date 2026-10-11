# Prompt for AI Assistant: Custom Kids YouTube App

Act as an expert Flutter developer. I want to build a custom Android app (specifically targeting a OnePlus 8T) for my toddler. It will be a parent-curated video player similar to YouTube Kids, but entirely controlled by me. 

Please generate the Flutter project structure, required dependencies (pubspec.yaml), and the core Dart code for the following requirements:

### Core Features
1. **Parental Dashboard (Admin Mode):**
   - Protected by a simple 4-digit PIN.
   - A screen where I can add, edit, or delete YouTube video URLs or Video IDs.
   - Save this curated list locally using `shared_preferences` or `hive`.
   
2. **Kid's Interface (Home & Playlist):**
   - A highly simplified, colorful, and distraction-free home screen displaying a grid of video thumbnails from the curated list.
   - **Playlist View:** When a video is tapped, open a player screen. In portrait mode, position the YouTube video player at the top of the screen. Directly below the player, display a scrollable `ListView` of the other curated videos (showing thumbnails and titles), exactly like YouTube's "Up Next" or playlist view. 
   - Tapping any video in this bottom list should immediately switch the currently playing video.

3. **Video Player & Screen Lock Mode (Crucial):**
   - Use a package like `youtube_player_flutter`.
   - **Screen Lock Feature:** There must be a prominent "Lock Screen" button on the player screen. 
   - Once the lock is activated, the app should ideally switch to fullscreen landscape mode (or hide the playlist) and apply a transparent overlay that intercepts and disables ALL touch interactions (tapping, swiping) so my toddler can't accidentally pause the video or tap other videos in the list.
   - Require a specific gesture (e.g., long-press a hidden semi-transparent lock icon for 3 seconds) to unlock the screen, restore touch functionality, and bring back the playlist view.

### Technical Constraints
- **State Management:** Use Riverpod (or Provider) for managing the video list, the currently playing video, and the UI lock state.
- **Local Storage:** Keep it offline-first for the data layer (store video metadata locally).
- **Android Optimization:** Ensure the app utilizes immersive sticky mode to hide the OnePlus 8T's navigation and status bars while the kid's interface is active.
- **Architecture:** Keep the code modular, separating the UI, State, and Data layers.

### Instructions for Output
1. Provide the `pubspec.yaml` with the necessary packages.
2. Outline the recommended folder structure.
3. Generate the core logic for the Player Screen, showing how to layout the video player at the top and the playlist `ListView` at the bottom.
4. Generate the exact code for the "Touch Lock" overlay mechanism and how it toggles the UI state.