# Enhanced Dialog UI - Using App Brand Colors

## Overview
Updated the confirmation dialog to use the **app's main brand colors**:
- **🟣 Purple (#7F22FE)** - For starting work (primary action)
- **🔴 Red (#F44336)** - For stopping work (destructive action)

---

## Visual Design

### When Driver Wants to START Working:

```
┌─────────────────────────────────────────┐
│  ┌─────────────────────────────────────┐│
│  │     🟣 (purple circle with icon)    ││
│  │                                     ││
│  │    تأكيد تغيير الحالة               ││
│  │  (Header: light purple background)  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │   🏷️ بدء العمل                     ││
│  │     (purple badge)                  ││
│  │                                     ││
│  │ هل أنت متأكد أنك تريد                ││
│  │ بدء العمل؟                          ││
│  │                                     ││
│  │ ℹ️ ستبدأ بتلقي طلبات جديدة الآن     ││
│  │     (purple info icon)              ││
│  │                                     ││
│  │  ┌──────────┐    ┌──────────┐      ││
│  │  │ إلغاء   │    │ نعم ابدأ │      ││
│  │  └──────────┘    └──────────┘      ││
│  │ (gray outline)   (purple filled)    ││
│  └─────────────────────────────────────┘│
│                                         │
└─────────────────────────────────────────┘
```

### When Driver Wants to STOP Working:

```
┌─────────────────────────────────────────┐
│  ┌─────────────────────────────────────┐│
│  │     🔴 (red circle with icon)       ││
│  │                                     ││
│  │    تأكيد تغيير الحالة               ││
│  │  (Header: light red background)     ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │   🏷️ التوقف عن العمل              ││
│  │     (red badge)                     ││
│  │                                     ││
│  │ هل أنت متأكد أنك تريد               ││
│  │ التوقف عن العمل؟                   ││
│  │                                     ││
│  │ ℹ️ لن تتلقى أي طلبات جديدة أثناء   ││
│  │    توقفك (red info icon)           ││
│  │                                     ││
│  │  ┌──────────┐    ┌──────────┐      ││
│  │  │ إلغاء   │    │ نعم توقف │      ││
│  │  └──────────┘    └──────────┘      ││
│  │ (gray outline)   (red filled)       ││
│  └─────────────────────────────────────┘│
│                                         │
└─────────────────────────────────────────┘
```

---

## Color Definitions

From `app_colors.dart`:

```dart
// Primary (Purple) - Used for starting work
static const Color primary = Color(0xFF7F22FE);
static const Color primaryLight = Color(0xFF9D5AFF);

// Error (Red) - Used for stopping work
static const Color error = Color(0xFFF44336);
```

---

## Complete Implementation

```dart
// Toggle driver availability
Future<void> toggleAvailability() async {
  final currentStatus = _isAvailable.value;
  final isStoppingWork = currentStatus; // true if going from working to stopped

  // Show enhanced confirmation dialog with app colors
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon and title
            Container(
              decoration: BoxDecoration(
                // 🟣 Purple for start, 🔴 Red for stop
                color: isStoppingWork
                    ? AppColors.error.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  // Icon Circle
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isStoppingWork ? AppColors.error : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isStoppingWork ? Icons.pause_circle : Icons.play_circle,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    'تأكيد تغيير الحالة',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101828),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isStoppingWork
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isStoppingWork ? 'التوقف عن العمل' : 'بدء العمل',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isStoppingWork ? AppColors.error : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Main Message
                  Text(
                    isStoppingWork
                        ? 'هل أنت متأكد أنك تريد التوقف عن العمل؟'
                        : 'هل أنت متأكد أنك تريد بدء العمل؟',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF4A5565),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Information Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: isStoppingWork ? AppColors.error : AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isStoppingWork
                                ? 'لن تتلقى أي طلبات جديدة أثناء توقفك'
                                : 'ستبدأ بتلقي طلبات جديدة الآن',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6A7282),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6A7282),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Confirm Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        _isAvailable.value = !_isAvailable.value;
                        try {
                          final result = await _ordersService.toggleWorkingStatus();

                          if (result.success && result.data != null) {
                            final newStatus = result.data!['newStatus'] as String;
                            _isAvailable.value = newStatus == 'working';

                            final message = result.data!['message'] as String? ??
                                (newStatus == 'working'
                                    ? 'أنت الآن في وضع العمل'
                                    : 'أنت الآن متوقف');

                            showSnackBar(
                              message: message,
                              isSuccess: true,
                            );
                          } else {
                            _isAvailable.value = !_isAvailable.value;
                            showSnackBar(
                              title: 'خطأ',
                              message: result.message ?? 'فشل في تغيير حالة العمل',
                            );
                          }
                        } catch (e) {
                          _isAvailable.value = !_isAvailable.value;
                          showSnackBar(
                            title: 'خطأ',
                            message: 'حدث خطأ: ${e.toString()}',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        // 🟣 Purple for start, 🔴 Red for stop
                        backgroundColor: isStoppingWork
                            ? AppColors.error
                            : AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(
                        isStoppingWork ? 'نعم، توقف' : 'نعم، ابدأ',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

---

## Color Scheme Summary

| Component | Start (Working) | Stop (Not Working) |
|-----------|-----------------|-------------------|
| **Header Background** | Purple (0.1) | Red (0.1) |
| **Icon Circle** | 🟣 Purple | 🔴 Red |
| **Status Badge** | Purple text on purple (0.1) | Red text on red (0.1) |
| **Info Icon** | 🟣 Purple | 🔴 Red |
| **Confirm Button** | 🟣 Purple background | 🔴 Red background |
| **Button Text** | White | White |
| **Cancel Button** | Gray outline | Gray outline |

---

## Color Values

```dart
Primary (Purple):
  - Color: #7F22FE
  - Light: #9D5AFF
  - Dark: #4C0F9E

Error (Red):
  - Color: #F44336
  - Used for destructive actions
```

---

## Files Modified

✅ `driver_orders_controller.dart`
- Added `AppColors` import
- Updated all color references to use app colors
- Purple (#7F22FE) for start/positive actions
- Red (#F44336) for stop/destructive actions

---

## Benefits

✅ **Brand Consistency**
- Uses app's official color palette
- Matches overall design system
- Professional appearance

✅ **Semantic Meaning**
- 🟣 Purple = Positive action (start working)
- 🔴 Red = Caution/Destructive (stop working)
- Users immediately understand the consequence

✅ **Visual Hierarchy**
- Clear distinction between start and stop
- Color indicates the severity of the action
- Better UX through color psychology

---

## Summary

✅ **Colors Updated:**
- Start Work: **🟣 Purple (#7F22FE)**
- Stop Work: **🔴 Red (#F44336)**
- Uses official app color palette
- Consistent with design system
- Professional and intuitive

The dialog now uses the **brand colors** perfectly! 🎨✨
