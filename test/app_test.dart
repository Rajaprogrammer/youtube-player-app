import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_viewer/models/video_model.dart';

void main() {
  test('VideoItem parses YouTube URL correctly', () {
    final video = VideoItem(
      id: '1',
      title: 'Test',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    );
    expect(video.youtubeId, 'dQw4w9WgXcQ');
  });

  test('VideoItem parses short YouTube URL', () {
    final video = VideoItem(
      id: '2',
      title: 'Test',
      url: 'https://youtu.be/dQw4w9WgXcQ',
    );
    expect(video.youtubeId, 'dQw4w9WgXcQ');
  });

  test('AppData serializes and deserializes correctly', () {
    final data = AppData(
      appTitle: 'Test App',
      videos: [
        VideoItem(id: '1', title: 'V1', url: 'https://youtube.com/watch?v=abc'),
      ],
    );
    final json = data.toJson();
    final restored = AppData.fromJson(json);
    expect(restored.appTitle, 'Test App');
    expect(restored.videos.length, 1);
    expect(restored.videos.first.title, 'V1');
  });
}
