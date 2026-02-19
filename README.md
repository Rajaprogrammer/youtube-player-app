# 🎬 YouTube Viewer

A beautiful Flutter app for viewing YouTube videos with a sleek dark UI.

## ✨ Features

- 🎥 **Embedded YouTube Player** - Watch videos directly in the app
- 📁 **JSON Import/Export** - Manage your video collection via JSON files
- ➕ **Add Videos** - Add new YouTube videos with title, URL, category & description
- 🗂️ **Categories** - Filter videos by category
- 🗑️ **Delete Videos** - Remove videos from your collection
- 🎨 **Custom Theming** - Set primary and accent colors via JSON
- 📱 **Beautiful UI** - Glassmorphism, animations, and gradient effects
- 🌙 **Dark Theme** - Easy on the eyes

## 📋 JSON Format

```json
{
  "app_title": "My YouTube Viewer",
  "theme_color": "#6C63FF",
  "accent_color": "#FF6584",
  "videos": [
    {
      "id": "1",
      "title": "Video Title",
      "url": "https://www.youtube.com/watch?v=VIDEO_ID",
      "category": "Category Name",
      "description": "Video description"
    }
  ]
}
```

## 🚀 Getting Started

```bash
cd youtube_viewer_app
flutter pub get
flutter run
```

## 📱 Supported Platforms

- Android
- iOS
- Web

## 🛠️ Built With

- Flutter 3.24+
- youtube_player_flutter
- file_picker
- google_fonts
- animate_do
- cached_network_image
- shimmer
