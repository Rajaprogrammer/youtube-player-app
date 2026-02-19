import 'dart:convert';

class VideoItem {
  final String id;
  final String title;
  final String url;
  final String category;
  final String description;

  VideoItem({
    required this.id,
    required this.title,
    required this.url,
    this.category = 'General',
    this.description = '',
  });

  String get youtubeId {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';
    
    // Handle youtu.be short links
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    }
    
    // Handle youtube.com links
    if (uri.host.contains('youtube.com')) {
      // /watch?v=VIDEO_ID
      if (uri.queryParameters.containsKey('v')) {
        return uri.queryParameters['v'] ?? '';
      }
      // /embed/VIDEO_ID
      if (uri.pathSegments.contains('embed') && uri.pathSegments.length > 1) {
        final idx = uri.pathSegments.indexOf('embed');
        if (idx + 1 < uri.pathSegments.length) {
          return uri.pathSegments[idx + 1];
        }
      }
      // /shorts/VIDEO_ID
      if (uri.pathSegments.contains('shorts') && uri.pathSegments.length > 1) {
        final idx = uri.pathSegments.indexOf('shorts');
        if (idx + 1 < uri.pathSegments.length) {
          return uri.pathSegments[idx + 1];
        }
      }
    }
    
    return url;
  }

  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';

  String get highResThumbnailUrl =>
      'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg';

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Untitled',
      url: json['url'] ?? '',
      category: json['category'] ?? 'General',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'url': url,
        'category': category,
        'description': description,
      };
}

class AppData {
  final String appTitle;
  final String themeColor;
  final String accentColor;
  final List<VideoItem> videos;

  AppData({
    required this.appTitle,
    this.themeColor = '#6C63FF',
    this.accentColor = '#FF6584',
    required this.videos,
  });

  factory AppData.fromJson(Map<String, dynamic> json) {
    final videosList = (json['videos'] as List<dynamic>?)
            ?.map((v) => VideoItem.fromJson(v as Map<String, dynamic>))
            .toList() ??
        [];
    return AppData(
      appTitle: json['app_title'] ?? 'YouTube Viewer',
      themeColor: json['theme_color'] ?? '#6C63FF',
      accentColor: json['accent_color'] ?? '#FF6584',
      videos: videosList,
    );
  }

  Map<String, dynamic> toJson() => {
        'app_title': appTitle,
        'theme_color': themeColor,
        'accent_color': accentColor,
        'videos': videos.map((v) => v.toJson()).toList(),
      };

  String toJsonString() =>
      const JsonEncoder.withIndent('  ').convert(toJson());

  AppData copyWith({
    String? appTitle,
    String? themeColor,
    String? accentColor,
    List<VideoItem>? videos,
  }) {
    return AppData(
      appTitle: appTitle ?? this.appTitle,
      themeColor: themeColor ?? this.themeColor,
      accentColor: accentColor ?? this.accentColor,
      videos: videos ?? this.videos,
    );
  }
}
