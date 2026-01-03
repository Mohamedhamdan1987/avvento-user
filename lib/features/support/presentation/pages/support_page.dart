import 'package:avvento/features/support/presentation/widgets/support_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../support/presentation/controllers/support_controller.dart';

class RestaurantSupportPage extends StatefulWidget {
  const RestaurantSupportPage({super.key});

  @override
  State<RestaurantSupportPage> createState() => _RestaurantSupportPageState();
}

class _RestaurantSupportPageState extends State<RestaurantSupportPage> {
  final textController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupportController>();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.drawerPurple),
        title: Text(
          'الدعم الفني',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.messages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.drawerPurple),
          );
        }

        if (controller.errorMessage.value.isNotEmpty && controller.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: AppColors.error,
                ),
                SizedBox(height: 16.h),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(fontSize: 16.sp, color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    controller.initializeConversation();
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        return Column(
        children: [
          // Header Info
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A2C91).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.support_agent,
                    color: const Color(0xFF6A2C91),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الدعم الفني',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF18181B),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.h,
                            decoration: const BoxDecoration(
                              color: Color(0xFF16A34A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'متصل الآن',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF71717B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.refreshMessages(),
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                reverse: false,
                itemCount: controller.messages.length + (controller.isTyping.value ? 1 : 0),
                itemBuilder: (context, index) {
                  // Typing indicator at the end
                  if (controller.isTyping.value && index == controller.messages.length) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildTypingIndicator(0),
                                SizedBox(width: 3.w),
                                _buildTypingIndicator(1),
                                SizedBox(width: 3.w),
                                _buildTypingIndicator(2),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (index >= controller.messages.length) {
                    return const SizedBox.shrink();
                  }

                  final message = controller.messages[index];
                  final isFromSupport = controller.isMessageFromSupport(message);
                  
                  return Padding(
                    padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                    child: SupportMessageBubble(
                      text: message.content,
                      isFromSupport: isFromSupport,
                      timestamp: message.createdAt,
                      onTimeFormat: controller.formatTime,
                    ),
                  );
                },
              ),
            ),
          ),

          // Input Field
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: TextField(
                        controller: textController,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF18181B),
                        ),
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالتك...',
                          hintStyle: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF71717B),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 10.h,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (text) {
                          if (text.trim().isNotEmpty) {
                            controller.sendMessage(text);
                            textController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Obx(() => Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: controller.isLoading.value
                          ? AppColors.borderGray
                          : AppColors.drawerPurple,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              if (textController.text.trim().isNotEmpty) {
                                controller.sendMessage(textController.text);
                                textController.clear();
                              }
                            },
                      icon: controller.isLoading.value
                          ? SizedBox(
                              width: 18.w,
                              height: 18.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                              ),
                            )
                          : Icon(
                              Icons.send,
                              color: AppColors.white,
                              size: 18.sp,
                            ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
        );
      }),
    );
  }

  Widget _buildTypingIndicator(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 6.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: const Color(0xFF6A2C91).withOpacity(0.3 + (value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
