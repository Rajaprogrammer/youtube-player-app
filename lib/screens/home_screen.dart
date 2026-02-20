import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../models/video_model.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/video_card.dart';
import '../widgets/add_video_dialog.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  AppData? _appData;
  bool _isLoading = true;
  String _selectedCategory = 'All';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await DataService.loadData();
    AppTheme.updateColors(data.themeColor, data.accentColor);
    setState(() {
      _appData = data;
      _isLoading = false;
    });
  }

  List<String> get _categories {
    if (_appData == null) return ['All'];
    final cats = _appData!.videos
        .map((v) => v.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    cats.sort();
    return ['All', ...cats];
  }

  List<VideoItem> get _filteredVideos {
    if (_appData == null) return [];
    if (_selectedCategory == 'All') return _appData!.videos;
    return _appData!.videos
        .where((v) => v.category == _selectedCategory)
        .toList();
  }

  Future<void> _importJson() async {
    try {
      final data = await DataService.importJson();
      if (data != null) {
        AppTheme.updateColors(data.themeColor, data.accentColor);
        setState(() {
          _appData = data;
          _selectedCategory = 'All';
        });
        if (mounted) {
          _showSnackBar(
              'Data imported successfully!', AppTheme.successGreen);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to import: $e', AppTheme.errorRed);
      }
    }
  }

  Future<void> _exportJson() async {
    if (_appData == null) return;
    try {
      await DataService.exportJson(_appData!);
      if (mounted) {
        _showSnackBar(
            'Data exported successfully!', AppTheme.successGreen);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to export: $e', AppTheme.errorRed);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == AppTheme.successGreen
                  ? Icons.check_circle_rounded
                  : Icons.error_rounded,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _addVideo() async {
    final video = await showDialog<VideoItem>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const AddVideoDialog(),
    );

    if (video != null && _appData != null) {
      final updatedData = _appData!.copyWith(
        videos: [..._appData!.videos, video],
      );
      await DataService.saveData(updatedData);
      setState(() => _appData = updatedData);
      _showSnackBar(
          'Video added successfully!', AppTheme.successGreen);
    }
  }

  Future<void> _deleteVideo(VideoItem video) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete Video',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to remove "${video.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text(
              'Delete',
              style:
                  GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && _appData != null) {
      final updatedVideos =
          _appData!.videos.where((v) => v.id != video.id).toList();
      final updatedData =
          _appData!.copyWith(videos: updatedVideos);
      await DataService.saveData(updatedData);
      setState(() => _appData = updatedData);
      _showSnackBar(
          'Video removed successfully!', AppTheme.warningOrange);
    }
  }

  void _openPlayer(VideoItem video) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PlayerScreen(video: video),
    ),
  ).then((_) {
    // Refresh state when returning from player
    if (mounted) {
      setState(() {});
    }
  });
}

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Options',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              icon: Icons.file_download_rounded,
              title: 'Import JSON',
              subtitle: 'Load videos from a JSON file',
              color: AppTheme.primaryColor,
              onTap: () {
                Navigator.pop(ctx);
                _importJson();
              },
            ),
            _buildOptionTile(
              icon: Icons.file_upload_rounded,
              title: 'Export JSON',
              subtitle: 'Save current data as JSON',
              color: AppTheme.accentColor,
              onTap: () {
                Navigator.pop(ctx);
                _exportJson();
              },
            ),
            _buildOptionTile(
              icon: Icons.add_circle_rounded,
              title: 'Add Video',
              subtitle: 'Add a new YouTube video',
              color: AppTheme.successGreen,
              onTap: () {
                Navigator.pop(ctx);
                _addVideo();
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Loading...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final videos = _filteredVideos;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.darkBg,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 20, bottom: 16),
              title: FadeInLeft(
                duration: const Duration(milliseconds: 600),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.accentColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _appData?.appTitle ?? 'YouTube Viewer',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.15),
                      AppTheme.darkBg,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              FadeInRight(
                duration: const Duration(milliseconds: 600),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: _showOptionsMenu,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: const Icon(
                        Icons.more_vert_rounded,
                        color: AppTheme.textPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 200),
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
                  children: [
                    _buildStatChip(
                      Icons.play_circle_rounded,
                      '${_appData?.videos.length ?? 0} videos',
                      AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 10),
                    _buildStatChip(
                      Icons.category_rounded,
                      '${_categories.length - 1} categories',
                      AppTheme.accentColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_categories.length > 1)
            SliverToBoxAdapter(
              child: FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 300),
                child: SizedBox(
                  height: 64,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (ctx, i) {
                      final cat = _categories[i];
                      final isSelected =
                          cat == _selectedCategory;
                      return Padding(
                        padding:
                            const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => setState(() =>
                              _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(
                                milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [
                                        AppTheme.primaryColor,
                                        AppTheme.accentColor,
                                      ],
                                    )
                                  : null,
                              color: isSelected
                                  ? null
                                  : Colors.white
                                      .withOpacity(0.05),
                              borderRadius:
                                  BorderRadius.circular(14),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: Colors.white
                                          .withOpacity(0.08),
                                    ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme
                                            .primaryColor
                                            .withOpacity(0.3),
                                        blurRadius: 10,
                                        offset:
                                            const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              cat,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          if (videos.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: _buildEmptyState(),
              ),
            )
          else
            SliverPadding(
              padding:
                  const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final video = videos[i];
                    return FadeInUp(
                      duration:
                          const Duration(milliseconds: 500),
                      delay: Duration(
                          milliseconds: 100 + (i * 80)),
                      child: VideoCard(
                        video: video,
                        index: i,
                        onTap: () => _openPlayer(video),
                        onDelete: () => _deleteVideo(video),
                      ),
                    );
                  },
                  childCount: videos.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: videos.isNotEmpty
          ? FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 500),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.accentColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor
                          .withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: _addVideo,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  highlightElevation: 0,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    'Add Video',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.video_library_rounded,
              size: 48,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Videos Yet',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a video or import a JSON file\nto get started',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _addVideo,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Video'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _importJson,
                icon: const Icon(Icons.file_download_rounded),
                label: const Text('Import'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(
                      color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
