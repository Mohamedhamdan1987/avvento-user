import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:story_view/story_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import '../models/story_model.dart';
import '../controllers/restaurants_controller.dart';

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
  // final Map<String, bool> _lovedState = {};
  // final Map<String, bool> _viewedState = {};
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();


  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // Initialize loved & viewed state from API data
    // for (final story in widget.stories) {
    //   _lovedState[story.id] = story.isLoved;
    //   _viewedState[story.id] = story.isViewed;
    // }
    _initializeStories();
  }

  Future<void> _initializeStories() async {
    final items = <StoryItem>[];

    // Start generating items from the initialIndex
    for (int i = widget.initialIndex; i < widget.stories.length; i++) {
      final story = widget.stories[i];
      if (story.mediaType == 'image' && story.mediaUrl != null) {
        items.add(StoryItem.pageImage(
          url: story.mediaUrl!,
          caption: Text(
            story.text ?? '',
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
          duration: const Duration(seconds: 10),
        ));
      } else if (story.mediaType == 'video' && story.mediaUrl != null) {
        Duration? videoDuration;
        try {
          // Pre-fetch video duration to ensure correct progress bar and playback time
          final controller = VideoPlayerController.networkUrl(Uri.parse(story.mediaUrl!));
          await controller.initialize();
          videoDuration = controller.value.duration;
          await controller.dispose();
        } catch (e) {
          debugPrint('Failed to get video duration: $e');
        }

        items.add(StoryItem.pageVideo(
          story.mediaUrl!,
          caption: Text(
            story.text ?? '',
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
          title: story.text ?? '',
          backgroundColor: const Color(0xFF7F22FE), // Purple brand color
          textStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'IBM Plex Sans Arabic',
          ),
          duration: const Duration(seconds: 10),
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
    _replyController.dispose();
    _replyFocusNode.dispose();
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
                 final storyIndex = widget.initialIndex + _storyItems.indexOf(s);
                 final story = widget.stories[storyIndex];

                 // Only call viewStory API if not already viewed
                 if (story.isViewed != true) {

                   Get.find<RestaurantsController>().viewStory(story.id);
                 }

                 // We need to update the header safely
                 WidgetsBinding.instance.addPostFrameCallback((_) {
                   if (mounted) {
                     setState(() {
                       _currentIndex = storyIndex;
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
            PositionedDirectional(
              width: MediaQuery.of(context).size.width ,
              top: 80.h,
              // start: 16.w,
              // end: 16.w,
            child: Row(
              children: [
                SizedBox(width: 8.w),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.stories[_currentIndex].restaurant?.name ?? '',
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
                SizedBox(width: 8.w),
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
                      imageUrl: widget.stories[_currentIndex].restaurant?.logo ?? '', // Safely access using index
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),

              ],
            ),
          ),

          // Love & Reply Section
          if(widget.stories.isNotEmpty && _currentIndex >= 0 && _currentIndex < widget.stories.length)
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom + 30.h,
            left: 20.w,
            right: 20.w,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 54.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(27.r),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(27.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: TextField(
                          controller: _replyController,
                          focusNode: _replyFocusNode,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                          decoration: InputDecoration(
                            hintText: 'رد على القصة...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14.sp,
                              fontFamily: 'IBMPlexSansArabic',
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            suffixIcon: Padding(
                              padding: EdgeInsetsDirectional.only(end: 8.w),
                              child: IconButton(
                                icon: Icon(Icons.send_rounded, color: Colors.white, size: 22.w),
                                onPressed: () async {
                                  if (_replyController.text.trim().isNotEmpty) {
                                    final story = widget.stories[_currentIndex];
                                    final message = _replyController.text.trim();
                                    
                                    _replyController.clear();
                                    _replyFocusNode.unfocus();
                                    _storyController.play();

                                    await Get.find<RestaurantsController>().replyToStory(story.id, message);
                                  }
                                },
                              ),
                            ),
                          ),
                          onTap: () {
                            _storyController.pause();
                          },
                          onSubmitted: (value) async {
                             if (value.trim().isNotEmpty) {
                                  final story = widget.stories[_currentIndex];
                                  
                                  _replyController.clear();
                                  _storyController.play();

                                  await Get.find<RestaurantsController>().replyToStory(story.id, value.trim());
                                }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () async {
                    final story = widget.stories[_currentIndex];
                    final isCurrentlyLoved = story.isLoved ?? false;
                    // Optimistic toggle
                    // setState(() {
                    //   _lovedState[story.id] = !isCurrentlyLoved;
                    // });
                    
                    // Call API
                    await Get.find<RestaurantsController>().loveStory(story.id);
                  },
                  child: Builder(
                    builder: (context) {
                      final story = widget.stories[_currentIndex];
                      final isLoved = story.isLoved;
                      return Container(
                        width: 54.w,
                        height: 54.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.w),
                        ),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Center(
                              child: Icon(
                                isLoved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: isLoved ? const Color(0xFFFB2C36) : Colors.white,
                                size: 26.w,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays >= 7) {
      return intl.DateFormat('d MMM yyyy').format(date);
    } else if (difference.inDays >= 1) {
      if (difference.inDays == 1) return 'منذ يوم';
      if (difference.inDays == 2) return 'منذ يومين';
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inHours >= 1) {
      if (difference.inHours == 1) return 'منذ ساعة';
      if (difference.inHours == 2) return 'منذ ساعتين';
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes >= 1) {
      if (difference.inMinutes == 1) return 'منذ دقيقة';
      if (difference.inMinutes == 2) return 'منذ دقيقتين';
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
