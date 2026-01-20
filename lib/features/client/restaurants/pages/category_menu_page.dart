import 'package:avvento/core/widgets/reusable/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/restaurant_details_controller.dart';
import '../models/menu_category_model.dart';
import '../models/restaurant_model.dart';
import 'meal_details_dialog.dart';

class CategoryMenuPage extends StatelessWidget {
  final Restaurant restaurant;
  final MenuCategory category;

  CategoryMenuPage({
    super.key,
    required this.restaurant,
    required this.category,
  });

  RestaurantDetailsController get controller => Get.find<RestaurantDetailsController>();

  @override
  Widget build(BuildContext context) {
    
    // Set the category and fetch subcategories when entering this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectCategory(category.id);
    });

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          controller.clearFilters();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: category.name,
          centerTitle: true,
          elevation: 0,
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              SizedBox(height: 2.h),
            // Subcategories Horizontal List
            Obx(() {
              if (controller.isLoadingSubCategories && controller.subCategories.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.subCategories.isEmpty) return const SizedBox.shrink();
              
              return Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                height: 72.h,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.subCategories.length + 1,
                  separatorBuilder: (context, index) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Obx(() {
                        final isSelected = controller.selectedSubCategoryId.isEmpty;
                        return GestureDetector(
                          onTap: () => controller.selectSubCategory(''),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF7F22FE) : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(20.r),
                              border: isSelected ? null : Border.all(color: Theme.of(context).dividerColor),
                            ),
                            child: Text(
                              'الكل',
                              style: const TextStyle().textColorMedium(
                                fontSize: 14.sp,
                                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                        );
                      });
                    }
                    
                    final subCategory = controller.subCategories[index - 1];
                    return Obx(() {
                      final isSelected = controller.selectedSubCategoryId == subCategory.id;
                      return GestureDetector(
                        onTap: () => controller.selectSubCategory(subCategory.id),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF7F22FE) : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20.r),
                            border: isSelected ? null : Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: Text(
                            subCategory.name,
                            style: const TextStyle().textColorMedium(
                              fontSize: 14.sp,
                              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              );
            }),

            // Items List
            Expanded(
              child: Obx(() {
                if (controller.isLoadingItems && controller.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                // When we are in this page, we only want to see items 
                // that belong to this category (and selected subcategory)
                final items = controller.items.where((item) => item.categoryId == category.id).toList();

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد أصناف في هذا القسم',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildItemCard(context, item);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildItemCard(BuildContext context, dynamic item) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => MealDetailsDialog(menuItem: item),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        child: Row(
          children: [
            // Item Image
            Container(
              width: 88.w,
              height: 76.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: item.image != null && item.image!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.image!,
                        width: 88.w,
                        height: 76.h,
                        fit: BoxFit.cover,
                      )
                    : Container(color: Colors.grey[300]),
              ),
            ),

            SizedBox(width: 12.w),

            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => controller.toggleFavorite(item.id),
                        child: Icon(
                          item.isFav ? Icons.favorite : Icons.favorite_border,
                          size: 20.w,
                          color: item.isFav ? Colors.red : Colors.grey,
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle().textColorMedium(
                      fontSize: 12.sp,
                      color: (Theme.of(context).textTheme.titleLarge?.color ?? Colors.black).withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${item.price} د.ل',
                    style: const TextStyle().textColorMedium(
                      fontSize: 12.sp,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Selector (Reusing the one from Details Screen style)
            // _buildQuantitySelector(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(BuildContext context) {
    return Container(
      width: 70.w,
      height: 28.h,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? const Color(0xFF121223)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(50.r),
        border: Theme.of(context).brightness == Brightness.dark
            ? Border.all(color: Theme.of(context).dividerColor)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.remove, size: 14.w, color: Colors.white),
          Text(
            '0',
            style: const TextStyle().textColorBold(fontSize: 10.sp, color: Colors.white),
          ),
          Icon(Icons.add, size: 14.w, color: Colors.white),
        ],
      ),
    );
  }
}
