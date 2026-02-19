import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_viewer/models/video_model.dart';

void main() {
  group('VideoItem', () {
    test('parses standard YouTube URL', () {
      final video = VideoItem(
        id: '1',
        title: 'Test',
        url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      );
      expect(video.youtubeId, 'dQw4w9WgXcQ');
    });

    test('parses short YouTube URL', () {
      final video = VideoItem(
        id: '2',
        title: 'Test',
        url: 'https://youtu.be/dQw4w9WgXcQ',
      );
      expect(video.youtubeId, 'dQw4w9WgXcQ');
    });

    test('parses embed YouTube URL', () {
      final video = VideoItem(
        id: '3',
        title: 'Test',
        url: 'https://www.youtube.com/embed/dQw4w9WgXcQ',
      );
      expect(video.youtubeId, 'dQw4w9WgXcQ');
    });

    test('parses shorts YouTube URL', () {
      final video = VideoItem(
        id: '4',
        title: 'Test',
        url: 'https://www.youtube.com/shorts/dQw4w9WgXcQ',
      );
      expect(video.youtubeId, 'dQw4w9WgXcQ');
    });

    test('generates correct thumbnail URL', () {
      final video = VideoItem(
        id: '1',
        title: 'Test',
        url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      );
      expect(video.thumbnailUrl,
          'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg');
    });

    test('serializes to JSON correctly', () {
      final video = VideoItem(
        id: '1',
        title: 'Test Video',
        url: 'https://www.youtube.com/watch?v=abc123',
        category: 'Flutter',
        description: 'A test video',
      );
      final json = video.toJson();
      expect(json['id'], '1');
      expect(json['title'], 'Test Video');
      expect(json['url'], 'https://www.youtube.com/watch?v=abc123');
      expect(json['category'], 'Flutter');
      expect(json['description'], 'A test video');
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'id': '1',
        'title': 'Test',
        'url': 'https://youtube.com/watch?v=abc',
        'category': 'Dart',
        'description': 'desc',
      };
      final video = VideoItem.fromJson(json);
      expect(video.id, '1');
      expect(video.title, 'Test');
      expect(video.category, 'Dart');
    });
  });

  group('AppData', () {
    test('serializes and deserializes correctly', () {
      final data = AppData(
        appTitle: 'Test App',
        themeColor: '#FF0000',
        accentColor: '#00FF00',
        videos: [
          VideoItem(
            id: '1',
            title: 'V1',
            url: 'https://youtube.com/watch?v=abc',
          ),
        ],
      );
      final json = data.toJson();
      final restored = AppData.fromJson(json);
      expect(restored.appTitle, 'Test App');
      expect(restored.themeColor, '#FF0000');
      expect(restored.accentColor, '#00FF00');
      expect(restored.videos.length, 1);
      expect(restored.videos.first.title, 'V1');
    });

    test('copyWith works correctly', () {
      final data = AppData(
        appTitle: 'Original',
        videos: [],
      );
      final copy = data.copyWith(appTitle: 'Modified');
      expect(copy.appTitle, 'Modified');
      expect(data.appTitle, 'Original');
    });

    test('handles missing fields with defaults', () {
      final data = AppData.fromJson({});
      expect(data.appTitle, 'YouTube Viewer');
      expect(data.themeColor, '#6C63FF');
      expect(data.videos.isEmpty, true);
    });

    test('toJsonString produces valid JSON', () {
      final data = AppData(
        appTitle: 'Test',
        videos: [],
      );
      final jsonStr = data.toJsonString();
      expect(jsonStr.contains('"app_title": "Test"'), true);
    });
  });
}
