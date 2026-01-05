import 'package:avvento/features/client/address/models/address_model.dart';
import 'package:avvento/features/client/address/services/address_service.dart';
import 'package:get/get.dart';

class AddressController extends GetxController {
  final AddressService _addressService = AddressService();

  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<AddressModel?> activeAddress = Rx<AddressModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
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
      Get.snackbar('خطأ', 'فشل في تحميل العناوين');
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
      await _addressService.addAddress(newAddress);
      await fetchAddresses();
      Get.back(); // Return to list
      Get.snackbar('نجاح', 'تم إضافة العنوان بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إضافة العنوان');
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
      Get.snackbar('خطأ', 'فشل في تفعيل العنوان');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      isLoading.value = true;
      await _addressService.deleteAddress(id);
      addresses.removeWhere((a) => a.id == id);
      Get.snackbar('نجاح', 'تم حذف العنوان بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في حذف العنوان');
    } finally {
      isLoading.value = false;
    }
  }
}
