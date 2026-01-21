import 'package:avvento/core/constants/app_colors.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controllers/restaurant_details_controller.dart';
import '../models/menu_item_model.dart';

class MealDetailsDialog extends StatefulWidget {
  final MenuItem menuItem;
  const MealDetailsDialog({super.key, required this.menuItem});

  @override
  State<MealDetailsDialog> createState() => _MealDetailsDialogState();
}

class _MealDetailsDialogState extends State<MealDetailsDialog> {
  int quantity = 1;
  String? selectedNote;
  final TextEditingController notesController = TextEditingController();
  
  Variation? selectedVariation;
  final Set<String> selectedAddOnIds = {};
  
  late double basePrice;

  @override
  void initState() {
    super.initState();
    basePrice = widget.menuItem.price;
    if (widget.menuItem.variations.isNotEmpty) {
      selectedVariation = widget.menuItem.variations.first;
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  double get totalPrice {
    double variationPrice = selectedVariation?.price ?? basePrice;
    double addOnsTotal = 0.0;
    for (final addOn in widget.menuItem.addOns) {
      if (selectedAddOnIds.contains(addOn.id)) {
        addOnsTotal += addOn.price;
      }
    }
    return (variationPrice + addOnsTotal) * quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.r),
          topRight: Radius.circular(40.r),
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Header Image Section
            _buildHeaderImage(context),
            
            // Content Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meal Info Section
                    _buildMealInfoSection(),
                    
                    SizedBox(height: 16.h),
                    
                    // Chef Notes Section
                    _buildChefNotesSection(),
                    
                    SizedBox(height: 16.h),
                    
                    // Variations Section
                    if (widget.menuItem.variations.isNotEmpty) ...[
                      _buildVariationsSection(),
                      SizedBox(height: 16.h),
                    ],
                    
                    // Additions Section
                    if (widget.menuItem.addOns.isNotEmpty) ...[
                      _buildAdditionsSection(),
                      SizedBox(height: 16.h),
                    ],
                    
                    SizedBox(height: 100.h), // Space for bottom bar
                  ],
                ),
              ),
            ),
            
            // Bottom Action Bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background Image
        Container(
          height: 290.h,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.r),
              topRight: Radius.circular(40.r),
            ),
            child: widget.menuItem.image != null && widget.menuItem.image!.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      print("object");
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: EdgeInsets.zero,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Dismiss by tapping background
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(

                                    color: Colors.black.withOpacity(0.9),
                                  ),
                                ),
                              ),
                              // Interactive Viewer for zooming
                              InteractiveViewer(
                                panEnabled: true,
                                boundaryMargin: EdgeInsets.all(20),
                                minScale: 0.5,
                                maxScale: 4.0,
                                child: CachedNetworkImage(
                                  imageUrl: widget.menuItem.image!,
                                  fit: BoxFit.contain,
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                ),
                              ),
                              // Close Button
                              Positioned(
                                top: 40.h,
                                right: 20.w,
                                child: CustomIconButtonApp(
                                  width: 40.w,
                                  height: 40.h,
                                  radius: 100.r,
                                  color: Colors.white.withOpacity(0.2),
                                  borderColor: Colors.white.withOpacity(0.2),
                                  onTap: () => Navigator.pop(context),
                                  childWidget: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 24.w,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: CachedNetworkImage(
                      imageUrl: widget.menuItem.image!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 290.h,
                    ),
                  )
                : Container(color: Colors.grey[300]),
          ),
        ),
        
        // Gradient Overlay
        IgnorePointer(
          ignoring: true,
          child: Container(
            height: 290.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.r),
                topRight: Radius.circular(40.r),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Theme.of(context).cardColor.withOpacity(0.2),
                  Theme.of(context).cardColor,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        
        // Close and Favorite Buttons
        Positioned(
          top: 24.h,
          right: 24.w,
          child: CustomIconButtonApp(
            width: 40.w,
            height: 40.h,
            radius: 100.r,
            color: Colors.white.withOpacity(0.2),
            borderColor: Colors.white.withOpacity(0.2),
            onTap: () {
              Navigator.pop(context);
            },
            childWidget: SvgIcon(
              iconName: 'assets/svg/arrow-right.svg',
              width: 20.w,
              height: 20.h,
              color: Colors.white,
            ),
          ),
        ),
        
        Positioned(
          top: 24.h,
          left: 24.w,
          child: CustomIconButtonApp(
            width: 40.w,
            height: 40.h,
            radius: 100.r,
            color: Colors.white.withOpacity(0.2),
            borderColor: Colors.white.withOpacity(0.2),
            onTap: () {
              final controller = Get.find<RestaurantDetailsController>();
              controller.toggleFavorite(widget.menuItem.id);
            },
            childWidget: Obx(() {
              final controller = Get.find<RestaurantDetailsController>();
              final isFav = controller.isItemFavorite(widget.menuItem.id);
              return GestureDetector(
                onTap: () => controller.toggleFavorite(widget.menuItem.id),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    size: 20.w,
                    color: isFav ? AppColors.primary : Colors.grey[400],
                  ),
                ),
              );

              return SvgIcon(
                iconName: 'assets/svg/client/fav.svg',
                width: 24.w,
                height: 24.h,
                color: isFav ? Colors.red : Colors.white,
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMealInfoSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price, Rating, and Name Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Meal Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.menuItem.name,
                      style: TextStyle().textColorBold(
                        fontSize: 25.sp,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                      textAlign: TextAlign.right,
                    ),

                    SizedBox(height: 8.h),

                    // Description
                    Text(
                      widget.menuItem.description,
                      style: TextStyle().textColorMedium(
                        fontSize: 14.sp,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      textAlign: TextAlign.right,
                    ),

                  ],
                ),
              ),
              SizedBox(width: 16.w),
              // Price and Rating
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.menuItem.price.toStringAsFixed(0),
                        style: TextStyle().textColorBold(
                          fontSize: 24.sp,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: Text(
                          'د.ل',
                          style: TextStyle().textColorBold(
                            fontSize: 14.sp,
                            color: Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF7ED),
                      border: Border.all(
                        color: Color(0xFFFFEDD4),
                        width: 0.76.w,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '4.8',
                          style: TextStyle().textColorBold(
                            fontSize: 12.sp,
                            color: Color(0xFFCA3500),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.star,
                          size: 12.w,
                          color: Color(0xFFCA3500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),


            ],
          ),

          SizedBox(height: 8.h),
          
          // Time and Calories
          Row(
            children: [
              // Spacer(),
              if(widget.menuItem.calories != null)
                ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon(
                        //   Icons.local_fire_department,
                        //   size: 12.w,
                        //   color: Theme.of(context).textTheme.bodySmall?.color,
                        // ),
                        SvgIcon(
                          iconName: 'assets/svg/client/restaurant_details/fire_department.svg',
                          // width: 12.w,
                          // height: 12.h,
                          // color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${widget.menuItem.calories } سعرة',
                          style: TextStyle().textColorBold(
                            fontSize: 12.sp,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),

                ],
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgIcon(
                      iconName: 'assets/svg/client/restaurant_details/clock2.svg',
                      // width: 12.w,
                      // height: 12.h,
                      // color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${widget.menuItem.preparationTime} دقيقة',
                      style: TextStyle().textColorBold(
                        fontSize: 12.sp,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChefNotesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgIcon(
                iconName: 'assets/svg/client/restaurant_details/menu_icon.svg',
                width: 20.w,
                height: 20.h,
              ),
              SizedBox(width: 8.w),
              Text(
                'أكتب ملاحظتك للشيف',
                style: TextStyle().textColorBold(
                  fontSize: 15.sp,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor ?? const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: 'ملاحظات على الطلب',
                hintStyle: TextStyle().textColorBold(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 18.h,
                ),
              ),
              style: TextStyle().textColorBold(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariationsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgIcon(
                iconName: 'assets/svg/client/restaurant_details/menu_icon.svg',
                width: 20.w,
                height: 20.h,
              ),
              SizedBox(width: 8.w),
              Text(
                'اختر الحجم',
                style: TextStyle().textColorBold(
                  fontSize: 18.sp,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: widget.menuItem.variations.map((variation) {
              final isSelected = selectedVariation?.id == variation.id;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedVariation = variation;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF5F3FF) : Theme.of(context).cardColor,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF8E51FF) : Theme.of(context).dividerColor,
                      width: isSelected ? 1.5.w : 0.76.w,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        variation.name,
                        style: TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${variation.price.toStringAsFixed(0)} د.ل',
                        style: TextStyle().textColorBold(
                          fontSize: 12.sp,
                          color: Color(0xFF7F22FE),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgIcon(
                iconName: 'assets/svg/client/restaurant_details/menu_icon.svg',
                width: 20.w,
                height: 20.h,
              ),
              SizedBox(width: 8.w),
              Text(
                'إضافات لذيذة',
                style: TextStyle().textColorBold(
                  fontSize: 18.sp,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...widget.menuItem.addOns.map((addOn) {
            final isSelected = selectedAddOnIds.contains(addOn.id);
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedAddOnIds.remove(addOn.id);
                    } else {
                      selectedAddOnIds.add(addOn.id);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF5F3FF) : Theme.of(context).cardColor,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF8E51FF) : Color(0xFFF2F4F6),
                      width: isSelected ? 1.5.w : 0.76.w,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // color: isSelected ? const Color(0xFF7F22FE) : Colors.transparent,
                          border: Border.all(
                            color: const Color(0xFF7F22FE) ,
                            width: 1.5.w,
                          ),
                        ),
                        // child: isSelected
                        //     ? Icon(Icons.check, size: 14.w, color: Colors.white)
                        //     : null,
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              addOn.name,
                              style: TextStyle().textColorBold(
                                fontSize: 14.sp,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '+${addOn.price.toStringAsFixed(0)} د.ل',
                              style: TextStyle().textColorBold(
                                fontSize: 12.sp,
                                color: Color(0xFF7F22FE),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? const Color(0xFF7F22FE) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF7F22FE) : Theme.of(context).dividerColor,
                            width: 1.5.w,
                          ),
                        ),
                        child: isSelected
                            ? Icon(Icons.check, size: 14.w, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Quantity Selector
          Container(
            width: 120.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 0.76.w,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    if (quantity > 1) {
                      setState(() {
                        quantity--;
                      });
                    }
                  },
                  child: Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.remove,
                      size: 20.w,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
                Text(
                  quantity.toString(),
                  style: TextStyle().textColorBold(
                    fontSize: 20.sp,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      quantity++;
                    });
                  },
                  child: Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 20.w,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(width: 16.w),
          
          // Add to Cart Button
          Expanded(
            child: Obx(() {
              final controller = Get.find<RestaurantDetailsController>();
              final isLoading = controller.isAddingToCart;
              
              return CustomButtonApp(
                height: 40.h,
                borderRadius: 20.r,
                color: const Color(0xFF101828),
                onTap: isLoading ? null : () async {
                  final selectedVariationNames = selectedVariation != null 
                      ? [selectedVariation!.name] 
                      : <String>[];
                  
                  final selectedAddOnNames = widget.menuItem.addOns
                      .where((addOn) => selectedAddOnIds.contains(addOn.id))
                      .map((addOn) => addOn.name)
                      .toList();
                  
                  await controller.addToCart(
                    itemId: widget.menuItem.id,
                    quantity: quantity,
                    selectedVariations: selectedVariationNames,
                    selectedAddOns: selectedAddOnNames,
                    notes: notesController.text,
                  );
                  
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                childWidget: isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${totalPrice.toStringAsFixed(0)} د.ل',
                            style: TextStyle().textColorBold(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'إضافة للسلة',
                            style: TextStyle().textColorBold(
                              fontSize: 15.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.shopping_cart,
                            size: 20.w,
                            color: Colors.white,
                          ),
                        ],
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

