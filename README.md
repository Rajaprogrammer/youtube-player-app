# 🎬 YouTube Viewer

A beautiful Flutter Android app for viewing YouTube videos with a sleek dark UI.

![Flutter](https://img.shields.io/badge/Flutter-3.24-blue?logo=flutter)
![Android](https://img.shields.io/badge/Platform-Android-green?logo=android)

## ✨ Features

- 🎥 **Embedded YouTube Player** — Watch videos directly in the app with fullscreen support
- 📁 **JSON Import** — Load your video collection from a JSON file
- 📤 **JSON Export** — Share/download your current video collection as JSON
- ➕ **Add Videos** — Add new YouTube videos with title, URL, category & description
- 🗂️ **Categories** — Filter videos by category with animated chips
- 🗑️ **Delete Videos** — Remove videos from your collection
- 🎨 **Custom Theming** — Set primary and accent colors via JSON config
- 🌙 **Dark Theme** — Beautiful dark glassmorphism UI
- ✨ **Animations** — Smooth transitions, fade-ins, and scale effects

## 📋 JSON Format

Export the existing JSON to see the format, or create one like this:

```json
{
  "app_title": "My Tutorials",
  "theme_color": "#6C63FF",
  "accent_color": "#FF6584",
  "videos": [
    {
      "id": "1",
      "title": "Flutter Tutorial",
      "url": "https://www.youtube.com/watch?v=VIDEO_ID",
      "category": "Flutter",
      "description": "Learn Flutter basics"
    }
  ]
}
```

## 🚀 Getting Started

```bash
flutter pub get
flutter run
```

## 📱 Build APK

```bash
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`
