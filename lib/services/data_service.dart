import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/video_model.dart';

class DataService {
  static const String _fileName = 'youtube_viewer_data.json';

  static Future<AppData> loadData() async {
    try {
      if (!kIsWeb) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$_fileName');
        if (await file.exists()) {
          final content = await file.readAsString();
          final json = jsonDecode(content) as Map<String, dynamic>;
          return AppData.fromJson(json);
        }
      }
    } catch (e) {
      debugPrint('Error loading saved data: $e');
    }

    // Load default from assets
    try {
      final content =
          await rootBundle.loadString('assets/default_videos.json');
      final json = jsonDecode(content) as Map<String, dynamic>;
      return AppData.fromJson(json);
    } catch (e) {
      debugPrint('Error loading default data: $e');
      return AppData(appTitle: 'YouTube Viewer', videos: []);
    }
  }

  static Future<void> saveData(AppData data) async {
    try {
      if (!kIsWeb) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$_fileName');
        await file.writeAsString(data.toJsonString());
      }
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  static Future<AppData?> importJson() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final content = utf8.decode(result.files.single.bytes!);
        final json = jsonDecode(content) as Map<String, dynamic>;
        final data = AppData.fromJson(json);
        await saveData(data);
        return data;
      }
    } catch (e) {
      debugPrint('Error importing JSON: $e');
      rethrow;
    }
    return null;
  }

  static Future<void> exportJson(AppData data) async {
    try {
      final jsonString = data.toJsonString();

      if (!kIsWeb) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/youtube_viewer_export.json');
        await file.writeAsString(jsonString);

        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'YouTube Viewer Data',
          text: 'YouTube Viewer configuration file',
        );
      }
    } catch (e) {
      debugPrint('Error exporting JSON: $e');
      rethrow;
    }
  }
}
