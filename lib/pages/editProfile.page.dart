/*
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realstate/Controller/userProfileController.dart';
import 'package:realstate/Model/editProfileBodyModel.dart';
import 'package:realstate/Model/uploadImageBodyModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:realstate/pages/OTPVerify.page.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final nameController = TextEditingController();
  final emailControler = TextEditingController();
  final phoneController = TextEditingController();
  bool isLoading = false;
  File? profileImage;
  String existingImage = "";

  final ImagePicker _picker = ImagePicker();

  /// Pick image (Camera / Gallery)
  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  /// Bottom sheet for image picker
  void showImagePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
              child: const Text("Camera"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
              child: const Text("Gallery"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadProfileData();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> loadProfileData() async {
    final profile = ref.read(userProfileController);
    profile.whenData((userdata) {
      nameController.text = userdata.data!.name ?? "";
      emailControler.text = userdata.data!.email ?? "";
      phoneController.text = userdata.data!.phone ?? "";
      existingImage = userdata.data!.image ?? "";
    });
  }

  Future<void> updateProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      final service = APIStateNetwork(createDio());
      String uploadImagePath = existingImage;

      if (profileImage != null) {
        final uploadResponse = await service.uploadImage(
          File(profileImage!.path),
        );

        log("UPLOAD RESPONSE: ${uploadResponse.data}");
        if (uploadResponse.error == false) {
          uploadImagePath = uploadResponse.data!.imageUrl ?? "";
        } else {
          log("Image upload failed");
        }
      }

      final body = EditProfileBodyModel(
        address: '',
        city: '',
        email: '',
        pincode: '',
        state: '',
        name: nameController.text,
        image: uploadImagePath,
      );

      final response = await service.editProfile(body);
      if (response.code == 0 || response.error == false) {
        Navigator.pop(context);
        ref.invalidate(userProfileController);
        Fluttertoast.showToast(msg: response.message ?? "");
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Error");
      }
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLoader(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: const Color(
          0xffF2F5FA,
        ), // Light Professional Gray-Blue
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Edit Profile",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 10.h),

              /// --- Profile Image Section ---
              Center(
                child: Stack(
                  children: [
                    // Glow effect behind image
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xffE86A34).withOpacity(0.5),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 64.r,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 60.r,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: profileImage != null
                              ? FileImage(profileImage!)
                              : (existingImage.isNotEmpty
                                        ? NetworkImage(existingImage)
                                        : const NetworkImage(
                                            "https://t4.ftcdn.net/jpg/16/74/69/27/240_F_1674692759_KcsTyCBrF888fdlD7eDFrGRyEUbniWXj.jpg",
                                          ))
                                    as ImageProvider,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: showImagePicker,
                        child: Container(
                          height: 36.h,
                          width: 36.h,
                          decoration: BoxDecoration(
                            color: const Color(0xffE86A34),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              /// --- Main Form Card ---
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      label: "FULL NAME",
                      controller: nameController,
                      icon: Icons.person_rounded,
                      isReadOnly: false,
                    ),
                    SizedBox(height: 20.h),

                    _buildInputField(
                      label: "EMAIL ADDRESS",
                      controller: emailControler,
                      icon: Icons.email_rounded,
                      isReadOnly: true,
                      onTap: () => Fluttertoast.showToast(
                        msg: "Email cannot be updated",
                      ),
                    ),
                    SizedBox(height: 20.h),

                    _buildInputField(
                      label: "MOBILE NUMBER",
                      controller: phoneController,
                      icon: Icons.phone_android_rounded,
                      isReadOnly: true,
                      onTap: () => Fluttertoast.showToast(
                        msg: "Phone cannot be updated",
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: 12.h, left: 4.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "Contact details are verified and locked.",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              /// --- Update Button ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: InkWell(
                  onTap: isLoading ? null : updateProfile,
                  borderRadius: BorderRadius.circular(18.r),
                  child: Container(
                    height: 58.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      gradient: LinearGradient(
                        colors: isLoading
                            ? [Colors.grey, Colors.grey]
                            : [
                                const Color(0xffE86A34),
                                const Color(0xffFF8C5A),
                              ],
                      ),
                      boxShadow: [
                        if (!isLoading)
                          BoxShadow(
                            color: const Color(0xffE86A34).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                      ],
                    ),
                    child: Center(
                      child: isLoading
                          ? const CupertinoActivityIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              "Update Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isReadOnly,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          onTap: onTap,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: isReadOnly ? Colors.grey.shade600 : const Color(0xff0E1A35),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xffE86A34), size: 20),
            suffixIcon: isReadOnly
                ? null
                : const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
            filled: true,
            fillColor: isReadOnly ? const Color(0xffF9FAFB) : Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: Color(0xffE86A34),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
*/


import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realstate/Controller/userProfileController.dart';
import 'package:realstate/Model/editProfileBodyModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';

import 'OTPVerify.page.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();
  final stateController = TextEditingController();

  bool isLoading = false;
  File? profileImage;
  String existingImage = "";

  final ImagePicker _picker = ImagePicker();

  /// Pick image (Camera / Gallery)
  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  /// Bottom sheet for image picker
  void showImagePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
              child: const Text("Camera"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
              child: const Text("Gallery"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    stateController.dispose();
    super.dispose();
  }

  Future<void> loadProfileData() async {
    final profile = ref.read(userProfileController);
    profile.whenData((userdata) {
      final userData = userdata.data!;
      nameController.text = userData.name ?? "";
      emailController.text = userData.email ?? "";
      phoneController.text = userData.phone ?? "";
      addressController.text = userData.address ?? "";
      cityController.text = userData.city ?? "";
      pincodeController.text = userData.pincode ?? "";
      stateController.text = userData.state ?? "";
      existingImage = userData.image ?? "";
    });
  }

  Future<void> updateProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      final service = APIStateNetwork(createDio());
      String uploadImagePath = existingImage;

      if (profileImage != null) {
        final uploadResponse = await service.uploadImage(
          File(profileImage!.path),
        );

        log("UPLOAD RESPONSE: ${uploadResponse.data}");
        if (uploadResponse.error == false) {
          uploadImagePath = uploadResponse.data!.imageUrl ?? "";
        } else {
          Fluttertoast.showToast(msg: "Image upload failed");
        }
      }

      final body = EditProfileBodyModel(

        name: nameController.text.trim(),
        email: emailController.text.trim(),
        address: addressController.text.trim(),
        city: cityController.text.trim(),
        pincode: pincodeController.text.trim(),
        state: stateController.text.trim(),
        image: uploadImagePath,
      );

      final response = await service.editProfile(body);
      if (response.code == 0 || response.error == false) {
        Navigator.pop(context);
        ref.invalidate(userProfileController);
        Fluttertoast.showToast(msg: response.message ?? "Profile updated successfully");
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Failed to update profile");
      }
    } catch (e) {
      log("Update profile error: $e");
      Fluttertoast.showToast(msg: "Something went wrong");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLoader(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xffF2F5FA),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Edit Profile",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 10.h),

              /// Profile Image Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [const Color(0xffE86A34).withOpacity(0.5), Colors.transparent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 64.r,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 60.r,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: profileImage != null
                              ? FileImage(profileImage!)
                              : (existingImage.isNotEmpty
                              ? NetworkImage(existingImage)
                              : const NetworkImage(
                            "https://t4.ftcdn.net/jpg/16/74/69/27/240_F_1674692759_KcsTyCBrF888fdlD7eDFrGRyEUbniWXj.jpg",
                          )) as ImageProvider,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: showImagePicker,
                        child: Container(
                          height: 36.h,
                          width: 36.h,
                          decoration: BoxDecoration(
                            color: const Color(0xffE86A34),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              /// Main Form Card
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      label: "FULL NAME",
                      controller: nameController,
                      icon: Icons.person_rounded,
                      isReadOnly: false,
                    ),
                    SizedBox(height: 20.h),

                    _buildInputField(
                      label: "EMAIL ADDRESS",
                      controller: emailController,
                      icon: Icons.email_rounded,
                      isReadOnly: false,
                      onTap: () => Fluttertoast.showToast(msg: "Email cannot be updated"),
                    ),
                    SizedBox(height: 20.h),

                    _buildInputField(
                      label: "MOBILE NUMBER",
                      controller: phoneController,
                      icon: Icons.phone_android_rounded,
                      isReadOnly: true,
                      onTap: () => Fluttertoast.showToast(msg: "Phone cannot be updated"),
                    ),
                    SizedBox(height: 20.h),

                    _buildInputField(
                      label: "ADDRESS",
                      controller: addressController,
                      icon: Icons.home_rounded,
                      isReadOnly: false,
                    ),
                    SizedBox(height: 20.h),

                    _buildInputField(
                      label: "CITY",
                      controller: cityController,
                      icon: Icons.location_city_rounded,
                      isReadOnly: false,
                    ),
                    SizedBox(height: 20.h),

                    _buildInputField(
                      label: "PINCODE",
                      controller: pincodeController,
                      icon: Icons.pin_drop_rounded,
                      isReadOnly: false,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20.h),

                    _buildInputField(
                      label: "STATE",
                      controller: stateController,
                      icon: Icons.map_rounded,
                      isReadOnly: false,
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: 12.h, left: 4.w),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 14.sp, color: Colors.grey),
                          SizedBox(width: 6.w),
                          Text(
                            "Contact details are verified and locked.",
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              /// Update Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: InkWell(
                  onTap: isLoading ? null : updateProfile,
                  borderRadius: BorderRadius.circular(18.r),
                  child: Container(
                    height: 58.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      gradient: LinearGradient(
                        colors: isLoading
                            ? [Colors.grey, Colors.grey]
                            : [const Color(0xffE86A34), const Color(0xffFF8C5A)],
                      ),
                      boxShadow: [
                        if (!isLoading)
                          BoxShadow(
                            color: const Color(0xffE86A34).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                      ],
                    ),
                    child: Center(
                      child: isLoading
                          ? const CupertinoActivityIndicator(color: Colors.white)
                          : Text(
                        "Update Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isReadOnly,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          onTap: onTap,
          keyboardType: keyboardType ?? TextInputType.text,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: isReadOnly ? Colors.grey.shade600 : const Color(0xff0E1A35),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xffE86A34), size: 20),
            suffixIcon: isReadOnly
                ? null
                : const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
            filled: true,
            fillColor: isReadOnly ? const Color(0xffF9FAFB) : Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xffE86A34), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}