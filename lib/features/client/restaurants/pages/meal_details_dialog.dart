import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MealDetailsDialog extends StatefulWidget {
  const MealDetailsDialog({super.key});

  @override
  State<MealDetailsDialog> createState() => _MealDetailsDialogState();
}

class _MealDetailsDialogState extends State<MealDetailsDialog> {
  int quantity = 1;
  String? selectedNote;
  final TextEditingController notesController = TextEditingController();
  final Set<String> excludedIngredients = {};
  final Set<String> selectedAdditions = {'جبنة إضافية', 'صوص خاص'};
  double basePrice = 25.0;

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  double get totalPrice {
    double additionsPrice = 0.0;
    if (selectedAdditions.contains('جبنة إضافية')) additionsPrice += 2.0;
    if (selectedAdditions.contains('صوص خاص')) additionsPrice += 1.0;
    if (selectedAdditions.contains('شريحة لحم')) additionsPrice += 5.0;
    return (basePrice + additionsPrice) * quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Color(0xFFFDFDFD),
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
                    
                    // Exclude Ingredients Section
                    _buildExcludeIngredientsSection(),
                    
                    SizedBox(height: 16.h),
                    
                    // Additions Section
                    _buildAdditionsSection(),
                    
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
            child: CachedNetworkImage(
              imageUrl: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800",
              fit: BoxFit.cover,
              width: double.infinity,
              height: 290.h,
            ),
          ),
        ),
        
        // Gradient Overlay
        Container(
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
                Colors.white.withOpacity(0.2),
                Colors.white,
              ],
              stops: [0.0, 0.5, 1.0],
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
              // Handle favorite
            },
            childWidget: SvgIcon(
              iconName: 'assets/svg/client/fav.svg',
              width: 24.w,
              height: 24.h,
              color: Colors.white,
            ),
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
              // Price and Rating
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '25',
                        style: TextStyle().textColorBold(
                          fontSize: 24.sp,
                          color: Color(0xFF101828),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: Text(
                          'د.ل',
                          style: TextStyle().textColorBold(
                            fontSize: 14.sp,
                            color: Color(0xFF101828),
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
              
              SizedBox(width: 16.w),
              
              // Meal Name
              Expanded(
                child: Text(
                  'وجبة دسمة',
                  style: TextStyle().textColorBold(
                    fontSize: 25.sp,
                    color: Color(0xFF101828),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          // Description
          Text(
            'شريحة لحم بقري، جبنة شيدر، خس، طماطم، صوص خاص',
            style: TextStyle().textColorMedium(
              fontSize: 14.sp,
              color: Color(0xFF6A7282),
            ),
            textAlign: TextAlign.right,
          ),
          
          SizedBox(height: 8.h),
          
          // Time and Calories
          Row(
            children: [
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 12.w,
                      color: Color(0xFF99A1AF),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '320 سعرة',
                      style: TextStyle().textColorBold(
                        fontSize: 12.sp,
                        color: Color(0xFF99A1AF),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
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
                      iconName: 'assets/svg/client/restaurant_details/clock.svg',
                      width: 12.w,
                      height: 12.h,
                      color: Color(0xFF99A1AF),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '15-20 دقيقة',
                      style: TextStyle().textColorBold(
                        fontSize: 12.sp,
                        color: Color(0xFF99A1AF),
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
                  color: Color(0xFF101828),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: 'ملاحظات على الطلب',
                hintStyle: TextStyle().textColorBold(
                  fontSize: 14.sp,
                  color: Color(0xFF99A1AF),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 18.h,
                ),
              ),
              style: TextStyle().textColorBold(
                fontSize: 14.sp,
                color: Color(0xFF101828),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExcludeIngredientsSection() {
    final ingredients = [
      {'emoji': '🥒', 'name': 'بدون مخلل'},
      {'emoji': '🍅', 'name': 'بدون طماطم'},
      {'emoji': '🍚', 'name': 'بدون أرز'},
      {'emoji': '🍟', 'name': 'بدون بطاطا'},
      {'emoji': '🥗', 'name': 'بدون سلطة'},
      {'emoji': '🥬', 'name': 'بدون خس'},
      {'emoji': '🧀', 'name': 'بدون جبن'},
      {'emoji': '🏺', 'name': 'بدون صوص'},
      {'emoji': '🍗', 'name': 'بدون دجاج'},
      {'emoji': '🥩', 'name': 'بدون لحم'},
      {'emoji': '🍳', 'name': 'بدون بيض'},
      {'emoji': '🧅', 'name': 'بدون بصل'},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'اختياري',
                  style: TextStyle().textColorNormal(
                    fontSize: 12.sp,
                    color: Color(0xFF99A1AF),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              SvgIcon(
                iconName: 'assets/svg/client/restaurant_details/menu_icon.svg',
                width: 20.w,
                height: 20.h,
              ),
              SizedBox(width: 8.w),
              Text(
                'استثناء مكونات',
                style: TextStyle().textColorBold(
                  fontSize: 18.sp,
                  color: Color(0xFF101828),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          SizedBox(
            height: 83.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...ingredients.map((ingredient) {
                  final isSelected = excludedIngredients.contains(ingredient['name']);
                  return Padding(
                    padding: EdgeInsetsDirectional.only(end: 12.w),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            excludedIngredients.remove(ingredient['name']);
                          } else {
                            excludedIngredients.add(ingredient['name']!);
                          }
                        });
                      },
                      child: Container(
                        width: 110.w,
                        height: 83.h,
                        decoration: BoxDecoration(
                          color: isSelected && ingredient['name'] == 'بدون طماطم'
                              ? Color(0xFFFEF2F2)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected && ingredient['name'] == 'بدون طماطم'
                                ? Color(0xFFFB2C36)
                                : Color(0xFFE5E7EB),
                            width: 1.5.w,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ingredient['emoji']!,
                              style: TextStyle(fontSize: 24.sp),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              ingredient['name']!,
                              style: TextStyle().textColorBold(
                                fontSize: 12.sp,
                                color: isSelected && ingredient['name'] == 'بدون طماطم'
                                    ? Color(0xFFE7000B)
                                    : Color(0xFF6A7282),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionsSection() {
    final additions = [
      {
        'name': 'جبنة إضافية',
        'price': 2.0,
        'emoji': '🧀',
        'icon': 'assets/svg/client/restaurant_details/menu_icon.svg',
      },
      {
        'name': 'صوص خاص',
        'price': 1.0,
        'emoji': '🏺',
        'icon': 'assets/svg/client/restaurant_details/menu_icon.svg',
      },
      {
        'name': 'شريحة لحم',
        'price': 5.0,
        'emoji': '🥩',
        'icon': 'assets/svg/client/restaurant_details/menu_icon.svg',
      },
    ];

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
                  color: Color(0xFF101828),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          ...additions.map((addition) {
            final name = addition['name'] as String;
            final isSelected = selectedAdditions.contains(name);
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedAdditions.remove(name);
                    } else {
                      selectedAdditions.add(name);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFFF5F3FF) : Colors.white,
                    border: Border.all(
                      color: isSelected ? Color(0xFF8E51FF) : Color(0xFFF3F4F6),
                      width: isSelected ? 1.5.w : 0.76.w,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Color(0xFF8E51FF).withOpacity(0.1),
                              blurRadius: 0,
                              offset: Offset(0, 0),
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Checkbox
                      Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Color(0xFF7F22FE) : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? Color(0xFF7F22FE)
                                : Color(0xFFD1D5DC),
                            width: 1.5.w,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 14.w,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      
                      SizedBox(width: 16.w),
                      
                      // Name and Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              addition['name'] as String,
                              style: TextStyle().textColorBold(
                                fontSize: 14.sp,
                                color: Color(0xFF101828),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '+${(addition['price'] as double).toStringAsFixed(0)} د.ل',
                              style: TextStyle().textColorBold(
                                fontSize: 12.sp,
                                color: Color(0xFF7F22FE),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Emoji
                      Text(
                        addition['emoji'] as String,
                        style: TextStyle(fontSize: 30.sp),
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
        color: Colors.white,
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
              color: Colors.white,
              border: Border.all(
                color: Color(0xFFE5E7EB),
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
                      color: Color(0xFF101828),
                    ),
                  ),
                ),
                Text(
                  quantity.toString(),
                  style: TextStyle().textColorBold(
                    fontSize: 20.sp,
                    color: Color(0xFF101828),
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
                      color: Color(0xFF101828),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(width: 16.w),
          
          // Add to Cart Button
          Expanded(
            child: CustomButtonApp(
              height: 40.h,
              borderRadius: 20.r,
              color: Color(0xFF101828),
              onTap: () {
                // Handle add to cart
                Navigator.pop(context);
              },
              childWidget: Row(
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
            ),
          ),
        ],
      ),
    );
  }
}

