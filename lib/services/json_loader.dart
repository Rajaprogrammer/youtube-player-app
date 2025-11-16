import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/video_model.dart';

class JsonLoader {
  static Future<List<Video>> loadVideos() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/videos.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      return jsonList.map((json) => Video.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading JSON: $e');
      }
      return [];
    }
  }
}