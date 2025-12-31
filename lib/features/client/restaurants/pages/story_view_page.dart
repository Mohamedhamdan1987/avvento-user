import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:story_view/story_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import '../models/story_model.dart';

class StoryViewPage extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;

  const StoryViewPage({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewPage> createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage> {
  final StoryController _storyController = StoryController();
  List<StoryItem> _storyItems = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initializeStories();
  }

  Future<void> _initializeStories() async {
    final items = <StoryItem>[];

    // Start generating items from the initialIndex
    for (int i = widget.initialIndex; i < widget.stories.length; i++) {
      final story = widget.stories[i];
      if (story.mediaType == 'image') {
        items.add(StoryItem.pageImage(
          url: story.mediaUrl,
          caption: Text(
            story.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          controller: _storyController,
        ));
      } else if (story.mediaType == 'video') {
        Duration? videoDuration;
        try {
          // Pre-fetch video duration to ensure correct progress bar and playback time
          final controller = VideoPlayerController.networkUrl(Uri.parse(story.mediaUrl));
          await controller.initialize();
          videoDuration = controller.value.duration;
          await controller.dispose();
        } catch (e) {
          debugPrint('Failed to get video duration: $e');
        }

        items.add(StoryItem.pageVideo(
          story.mediaUrl,
          caption: Text(
            story.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          controller: _storyController,
          duration: videoDuration, // Explicitly pass the duration
        ));
      } else {
        // Text story
        items.add(StoryItem.text(
          title: story.text,
          backgroundColor: const Color(0xFF7F22FE), // Purple brand color
          textStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'IBM Plex Sans Arabic',
          ),
        ));
      }
    }

    if (mounted) {
      setState(() {
        _storyItems = items;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7F22FE),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            StoryView(
              storyItems: _storyItems,
              controller: _storyController,
              repeat: false,
              onStoryShow: (s, index) {
                 // We need to update the header safely
                 WidgetsBinding.instance.addPostFrameCallback((_) {
                   if (mounted) {
                     setState(() {
                       // Adjust index by adding initialIndex because _storyItems starts from there
                       _currentIndex = widget.initialIndex + _storyItems.indexOf(s);
                     });
                   }
                 });
              },
              onComplete: () {
                Get.back();
              },
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Get.back();
                }
              },
            ),

            // Custom Header
            if(widget.stories.isNotEmpty && _currentIndex >= 0 && _currentIndex < widget.stories.length)
            Positioned(
              top: 50.h,
              left: 16.w,
              right: 16.w,
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.stories[_currentIndex].restaurant.logo, // Safely access using index
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.stories[_currentIndex].restaurant.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBM Plex Sans Arabic',
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(widget.stories[_currentIndex].createdAt),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontFamily: 'IBM Plex Sans Arabic',
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format: 10:30 AM | 31 Dec 2025
    final timeFormat = intl.DateFormat('h:mm a');
    final dateFormat = intl.DateFormat('d MMM yyyy');
    return '${timeFormat.format(date)} | ${dateFormat.format(date)}';
  }
}
