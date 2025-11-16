class Video {
  final String name;
  final String url;

  Video({
    required this.name,
    required this.url,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      name: json['name'],
      url: json['url'],
    );
  }
}