import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import '../models/user_profile_model.dart';
import '../services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();

  var isLoading = false.obs;
  var isUpdating = false.obs;
  var userProfile = Rxn<UserProfileModel>();

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final ownerNameController = TextEditingController();
  final descriptionController = TextEditingController();

  // Selected Images
  var selectedLogo = Rxn<File>();
  var selectedBackground = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final profile = await _profileService.getProfile();
      userProfile.value = profile;
      _fillControllers(profile);
    } catch (e) {
      // Get.snackbar('Error', 'Failed to fetch profile: $e',
      //     snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void _fillControllers(UserProfileModel profile) {
    nameController.text = profile.name;
    emailController.text = profile.email;
    phoneController.text = profile.phone;
    addressController.text = profile.address;
    ownerNameController.text = profile.ownerName ?? '';
    descriptionController.text = profile.description ?? '';
  }

  Future<void> pickImage(bool isLogo) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (isLogo) {
        selectedLogo.value = File(image.path);
      } else {
        selectedBackground.value = File(image.path);
      }
    }
  }

  Future<void> updateProfile() async {
    try {
      isUpdating.value = true;

      final Map<String, dynamic> data = {
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'ownerName': ownerNameController.text,
        'description': descriptionController.text,
      };

      if (selectedLogo.value != null) {
        data['files'] = [
          await dio.MultipartFile.fromFile(selectedLogo.value!.path,
              filename: 'logo.jpg'),
        ];
      }

      if (selectedBackground.value != null) {
        final List<dynamic> files = data['files'] ?? [];
        files.add(await dio.MultipartFile.fromFile(selectedBackground.value!.path,
            filename: 'background.jpg'));
        data['files'] = files;
      }

      await _profileService.updateProfile(data);
      Get.snackbar('نجاح', 'تم تحديث الملف الشخصي بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      
      fetchProfile();
      Get.back();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحديث الملف الشخصي: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isUpdating.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    ownerNameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
