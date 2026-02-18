import 'package:avvento/core/widgets/reusable/app_refresh_indicator.dart';
import 'package:avvento/features/support/presentation/widgets/support_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/shimmer/shimmer_loading.dart';
import '../controllers/order_support_controller.dart';

class OrderSupportPage extends StatefulWidget {
  const OrderSupportPage({super.key});

  @override
  State<OrderSupportPage> createState() => _OrderSupportPageState();
}

class _OrderSupportPageState extends State<OrderSupportPage> {
  final textController = TextEditingController();
  final scrollController = ScrollController();
  Worker? _messagesWorker;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<OrderSupportController>();
    // Auto-scroll when new messages arrive (via socket or send)
    _messagesWorker = ever(controller.messages, (_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messagesWorker?.dispose();
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderSupportController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'دعم الطلب',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.messages.isEmpty) {
          return const SupportChatShimmer();
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: Theme.of(context).colorScheme.error,
                ),
                SizedBox(height: 16.h),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    controller.loadOrderChat();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Header Info
            _buildHeader(context, controller),

            // Closed banner
            if (controller.isConversationClosed.value) _buildClosedBanner(context),

            // Messages List
            Expanded(
              child: AppRefreshIndicator(
                onRefresh: () => controller.refreshMessages(),
                child: ListView.builder(
                  controller: scrollController,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  reverse: false,
                  itemCount: controller.messages.length +
                      (controller.isTyping.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Typing indicator at the end
                    if (controller.isTyping.value &&
                        index == controller.messages.length) {
                      return Padding(
                        padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
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
                    final isFromSupport =
                        controller.isMessageFromSupport(message);

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
            if (!controller.isConversationClosed.value) _buildInputField(context, controller),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, OrderSupportController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: AppColors.purple,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'دعم الطلب #${controller.orderShortId}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: 2.h),
                Obx(() => Row(
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: controller.isConversationClosed.value
                                ? Colors.red
                                : const Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          controller.isConversationClosed.value
                              ? 'المحادثة مغلقة'
                              : 'محادثة نشطة',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosedBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      color: Colors.orange.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18.sp,
            color: Colors.orange,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'تم إغلاق هذه المحادثة لانتهاء الطلب',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.orange.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
      BuildContext context, OrderSupportController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: TextField(
                  controller: textController,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك...',
                    hintStyle: TextStyle(
                      fontSize: 13.sp,
                      color: Theme.of(context).hintColor,
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
                      _scrollToBottom();
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
                        ? Theme.of(context).disabledColor
                        : AppColors.purple,
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
                              _scrollToBottom();
                            }
                          },
                    icon: controller.isLoading.value
                        ? SizedBox(
                            width: 18.w,
                            height: 18.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                  ),
                )),
          ],
        ),
      ),
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
            color: AppColors.purple.withOpacity(0.3 + (value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
