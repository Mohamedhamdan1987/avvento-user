import 'package:avvento/features/client/address/models/address_model.dart';
import 'package:avvento/features/client/address/services/address_service.dart';
import 'package:get/get.dart';
import '../../../../core/utils/location_utils.dart';
import '../../../../core/utils/show_snackbar.dart';

class AddressController extends GetxController {
  final AddressService _addressService = AddressService();

  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<AddressModel?> activeAddress = Rx<AddressModel?>(null);

  /// IDs currently being deleted — prevents duplicate delete calls
  final RxSet<String> deletingIds = <String>{}.obs;

  /// Minimum distance (in km) to consider the user at a "new" location
  static const double _locationMismatchThresholdKm = 0.5; // 500 meters

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  /// Checks if the user's current device location is far from ALL saved
  /// addresses. Returns `true` when no saved address is within
  /// [_locationMismatchThresholdKm] of the current GPS position.
  bool isCurrentLocationNew() {
    // Need a valid device location
    if (!LocationUtils.isInitialized) return false;

    // If there are no saved addresses at all, prompt to add one
    if (addresses.isEmpty) return true;

    final double deviceLat = LocationUtils.currentLatitude;
    final double deviceLong = LocationUtils.currentLongitude;

    for (final addr in addresses) {
      final double distance = LocationUtils.calculateDistance(
        userLat: deviceLat,
        userLong: deviceLong,
        restaurantLat: addr.lat,
        restaurantLong: addr.long,
      );
      // At least one address is close enough — no reminder needed
      if (distance <= _locationMismatchThresholdKm) return false;
    }

    // All addresses are far from current location
    return true;
  }

  Future<void> fetchAddresses() async {
    try {
      isLoading.value = true;
      final result = await _addressService.getAddresses();
      addresses.assignAll(result);

      // Update active address
      final active = result.firstWhereOrNull((a) => a.isActive);
      activeAddress.value = active;
    } catch (e) {
      showSnackBar(message: 'فشل في تحميل العناوين', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAddress({
    required String label,
    required String address,
    required double lat,
    required double long,
  }) async {
    try {
      isLoading.value = true;
      final newAddress = AddressModel(
        id: '',
        user: '',
        label: label,
        address: address,
        lat: lat,
        long: long,
        isActive: false,
      );
      final created = await _addressService.addAddress(newAddress);
      await _addressService.setActiveAddress(created.id);
      await fetchAddresses();
      Get.back();
      showSnackBar(message: 'تم إضافة العنوان بنجاح', isSuccess: true);
    } catch (e) {
      showSnackBar(message: 'فشل في إضافة العنوان', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setActive(String id) async {
    try {
      isLoading.value = true;
      await _addressService.setActiveAddress(id);
      await fetchAddresses();
    } catch (e) {
      showSnackBar(message: 'فشل في تفعيل العنوان', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAddress(String id) async {
    // Prevent duplicate delete for the same address
    if (deletingIds.contains(id)) return;

    try {
      deletingIds.add(id);
      isLoading.value = true;

      // Optimistically remove from list so the UI updates immediately
      addresses.removeWhere((a) => a.id == id);

      await _addressService.deleteAddress(id);
      showSnackBar(message: 'تم حذف العنوان بنجاح', isSuccess: true);
    } catch (e) {
      // Re-fetch to restore the list if the delete failed
      await fetchAddresses();
      showSnackBar(message: 'فشل في حذف العنوان', isError: true);
    } finally {
      deletingIds.remove(id);
      isLoading.value = deletingIds.isNotEmpty;
    }
  }
}
