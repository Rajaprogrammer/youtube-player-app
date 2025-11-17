import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../models/video_model.dart';

class VideoScreen extends StatefulWidget {
  final Video video;

  const VideoScreen({super.key, required this.video});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    
    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Extract video ID from URL
    final videoId = _extractVideoId(widget.video.url);
    final embedUrl = 'https://www.youtube.com/embed/$videoId?autoplay=1&rel=0';
    
    print('Loading YouTube video: $embedUrl');
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow YouTube domains, block others
            if (request.url.contains('youtube.com') || 
                request.url.contains('youtu.be') ||
                request.url.contains('google.com')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(embedUrl));

    // Enable Android-specific features
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  String _extractVideoId(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.first;
      } else if (uri.host.contains('youtube.com')) {
        final videoId = uri.queryParameters['v'];
        if (videoId != null && videoId.isNotEmpty) {
          return videoId;
        }
      }
      
      // Fallback regex
      final regExp = RegExp(
        r'(?:youtube\.com\/\watch\?v=|youtu\.be\/)([^&?\n]+)',
        caseSensitive: false,
      );
      final match = regExp.firstMatch(url);
      return match?.group(1) ?? 'dQw4w9WgXcQ'; // Fallback to a working video
    } catch (e) {
      return 'dQw4w9WgXcQ'; // Fallback video ID
    }
  }

  @override
  void dispose() {
    // Reset to portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            
            // Loading indicator
            if (_isLoading)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _loadingProgress,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      backgroundColor: Colors.white24,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading YouTube Video...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_loadingProgress > 0)
                      Text(
                        '${(_loadingProgress * 100).round()}%',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            
            // Back button
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            
            // Video title
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  widget.video.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}