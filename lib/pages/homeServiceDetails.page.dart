import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:realstate/Controller/homeServiceCategoryByIdController.dart';
import 'package:realstate/Controller/myRequestBookingSerivceController.dart';
import 'package:realstate/Model/Body/checkSlotBodyModel.dart';
import 'package:realstate/Model/homeBookingServiceBodyModel.dart';
import 'package:realstate/Model/homeGetServiceCateogryModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:realstate/pages/myRequest.page.dart';

class HomeServiceDetailsPage extends ConsumerStatefulWidget {
  final String id;
  const HomeServiceDetailsPage({super.key, required this.id});

  @override
  ConsumerState<HomeServiceDetailsPage> createState() =>
      _HomeServiceDetailsPageState();
}

class _HomeServiceDetailsPageState
    extends ConsumerState<HomeServiceDetailsPage> {
  String? serviceType;
  String? Id;
  //static const primaryColor = Color(0xFFFF5722);
  static const primaryColor = Color(0xFFFF5722);
  static const darkBlue = Color(0xff0E1A35);

  File? selectedImage; // List ki jagah single file
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source, StateSetter dialogState) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      dialogState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void showImagePicker(BuildContext context, StateSetter dialogState) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera, dialogState);
                // uploadMultipleImage(file);
              },
              child: const Text("Camera"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery, dialogState);
                // uploadMultipleImage(file);
              },
              child: const Text("Gallery"),
            ),
          ],
        );
      },
    );
  }

  // 1. Updated to return the list of uploaded URLs
  Future<String?> uploadSingleImage(File file) async {
    try {
      final service = APIStateNetwork(createDio());
      // Maan lete hain aapka service single file leta hai,
      // agar purana hi function use karna hai to [file] pass karein
      final response = await service.uploadImageMultiple([file]);

      if (response.code == 0 && response.error == false) {
        log("Image uploaded successfully");
        // List ka pehla URL return karein string ke roop mein
        return response.data?.first.imageUrl.toString();
      }
      return null;
    } catch (e) {
      log("Upload Error: $e");
      return null;
    }
  }

  void showBookingDialog(
    BuildContext context,
    List slots,
    String id,
    int amount,
  ) {
    final addressController = TextEditingController();
    final issueController = TextEditingController();
    final PageController pageController = PageController();

    DateTime? selectedDate;
    String? selectedSlot;

    int currentPage = 0;
    bool isLoading = false;
    bool isFinalizing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    children: [
                      /// 🔹 HEADER
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            currentPage == 1
                                ? IconButton(
                                    onPressed: () {
                                      pageController.previousPage(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                      setState(() => currentPage = 0);
                                    },
                                    icon: const Icon(
                                      Icons.arrow_back_ios,
                                      size: 20,
                                    ),
                                  )
                                : const SizedBox(width: 40),

                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      /// 🔹 BODY
                      Expanded(
                        child: PageView(
                          controller: pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            /// ✅ STEP 1
                            SingleChildScrollView(
                              controller: scrollController,
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(
                                  context,
                                ).viewInsets.bottom,
                              ),
                              child: _buildSlotStep(
                                context,
                                setState,
                                addressController,
                                selectedDate,
                                selectedSlot,
                                slots,
                                (date) => selectedDate = date,
                                (slot) => selectedSlot = slot,
                                () async {
                                  if (addressController.text.isEmpty ||
                                      selectedDate == null ||
                                      selectedSlot == null) {
                                    return;
                                  }

                                  setState(() => isLoading = true);

                                  final body = CheckSlotBodyModel(
                                    serviceDate: selectedDate,
                                    serviceTimeSlot: selectedSlot,
                                    serviceType: id,
                                  );

                                  try {
                                    final service = APIStateNetwork(
                                      createDio(),
                                    );
                                    final response = await service
                                        .checkSlotAvailability(body);

                                    if (response.code == 0 &&
                                        response.error == false) {
                                      pageController.nextPage(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeIn,
                                      );

                                      setState(() => currentPage = 1);

                                      // Fluttertoast.showToast(
                                      //   msg:
                                      //       response.message ??
                                      //       "Slot Available!",
                                      // );
                                    } else {
                                      Fluttertoast.showToast(
                                        msg:
                                            response.message ??
                                            "Slot Not Available",
                                      );
                                    }
                                  } catch (e) {
                                    log("Error: $e");
                                  } finally {
                                    setState(() => isLoading = false);
                                  }
                                },
                                isLoading,
                              ),
                            ),

                            /// ✅ STEP 2
                            SingleChildScrollView(
                              controller: scrollController,
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(
                                  context,
                                ).viewInsets.bottom,
                              ),
                              child: _buildRequirementStep(
                                context,
                                issueController,
                                setState,
                                () async {
                                  setState(() => isFinalizing = true);

                                  String? uploadedImageUrl = "";

                                  if (selectedImage != null) {
                                    uploadedImageUrl = await uploadSingleImage(
                                      selectedImage!,
                                    );

                                    if (uploadedImageUrl == null) {
                                      Fluttertoast.showToast(
                                        msg: "Image upload failed.",
                                      );
                                      setState(() => isFinalizing = false);
                                      return;
                                    }
                                  }

                                  final body = HomeBookingServiceBodyModel(
                                    address: addressController.text.trim(),
                                    message: issueController.text.trim(),
                                    problemImgae: uploadedImageUrl,
                                    serviceDate: selectedDate,
                                    serviceFee: amount,
                                    serviceTimeSlot: selectedSlot,
                                    serviceType: id,
                                  );

                                  try {
                                    final service = APIStateNetwork(
                                      createDio(),
                                    );
                                    final response = await service
                                        .bookHomeService(body);

                                    if (response.code == 0 &&
                                        response.error == false) {
                                      Navigator.pushReplacement(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => MyRequestPage(),
                                        ),
                                      );
                                      ref.invalidate(
                                        myRequestBookingServiceContorller,
                                      );
                                      Fluttertoast.showToast(
                                        msg: response.message ?? "Success",
                                      );
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: response.message ?? "Error",
                                      );
                                    }
                                  } catch (e) {
                                    log(e.toString());
                                  } finally {
                                    setState(() => isFinalizing = false);
                                  }
                                },
                                isFinalizing,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// --- Step 1: Address, Date & Slot ---
  Widget _buildSlotStep(
    BuildContext context,
    StateSetter setState,
    TextEditingController address,
    DateTime? date,
    String? selSlot,
    List slots,
    Function(DateTime) onDateChange,
    Function(String) onSlotChange,
    VoidCallback onNext,
    bool isLoading,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Request Service",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          SizedBox(height: 10.h),
          _sectionLabel("VISIT ADDRESS"),
          TextField(
            controller: address,
            decoration: InputDecoration(
              hintText: "Enter address",
              filled: true,
              fillColor: Colors.grey[50],
              prefixIcon: Icon(
                Icons.location_on,
                size: 16,
                color: Colors.grey.shade500,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          _sectionLabel("SELECT DAY"),
          InkWell(
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) setState(() => onDateChange(picked));
            },
            child: Container(
              padding: EdgeInsets.all(15.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date == null
                        ? "Select Date"
                        : DateFormat('dd/MM/yyyy').format(date),
                  ),
                  const Icon(Icons.calendar_month, color: Colors.black54),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
          _sectionLabel("SELECT TIME SLOT"),
          slots.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 30.h),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[400],
                        size: 30,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "No slots available",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: slots.length,
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final slot = slots[index].timeSlot;
                    bool isSelected = selSlot == slot;
                    return InkWell(
                      onTap: () => setState(() => onSlotChange(slot!)),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepOrange : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? Colors.deepOrange
                                : Colors.grey.shade400,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.3),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          slot ?? "",
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
          SizedBox(height: 30.h),
          ElevatedButton(
            onPressed: isLoading ? null : onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111827), // Dark Navy
              minimumSize: Size(double.infinity, 55.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 1,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "PROCEED NEXT",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
                  ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  /// --- Step 2: Requirement & Photos ---
  Widget _buildRequirementStep(
    BuildContext context,
    TextEditingController issue,
    StateSetter dialogState,
    VoidCallback onConfirm,
    bool isLoading,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel("REQUIREMENT"),
          TextField(
            controller: issue,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Describe the issue...",
              filled: true,
              fillColor: Colors.grey[50],
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          _sectionLabel("PROBLEM PHOTO"),
          // _photoUploadBox(Icons.upload, "Upload Problem Photo", dialogState),
          _photoUploadBox(dialogState),
          SizedBox(height: 40.h),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111827),
              minimumSize: Size(double.infinity, 55.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 1,
                    ),
                  )
                : Text(
                    "REVIEW & PAY",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _photoUploadBox(StateSetter dialogState) {
    return InkWell(
      onTap: () => showImagePicker(context, dialogState),
      child: Container(
        height: 120.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: selectedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, color: Colors.grey, size: 30),
                  Text(
                    "Upload Problem Photo",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(selectedImage!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => dialogState(() => selectedImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeServiceDetislState = ref.watch(
      homeServiceCategoryByIdController(widget.id),
    );
    return homeServiceDetislState.when(
      data: (data) {
        return Scaffold(
          backgroundColor: Colors.white, // Pure white for a cleaner look
          bottomNavigationBar: _buildBottomAction(
            data.data?.slots ?? [],
            data.data!.id ?? "",
            data.data!.serviceFee ?? 0,
          ),
          body: CustomScrollView(
            slivers: [
              /// ================= DYNAMIC HEADER =================
              SliverAppBar(
                expandedHeight: 300.h,
                pinned: true,
                elevation: 0,
                stretch: true,
                backgroundColor: primaryColor,
                leading: _circleIconButton(
                  Icons.arrow_back_ios_new,
                  () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        // widget.service.image ??
                        data.data!.image ??
                            "https://images.unsplash.com/photo-1581578731548-c64695cc6952",
                        fit: BoxFit.cover,
                      ),
                      // Bottom Shadow Gradient for Text Visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30.r),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// --- Title & Badge ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                data.data!.name ?? "Service Detail",
                                style: GoogleFonts.inter(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w800,
                                  color: darkBlue,
                                ),
                              ),
                            ),
                            _statusBadge("Top Rated"),
                          ],
                        ),

                        SizedBox(height: 12.h),

                        /// --- Rating & Stats ---
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 22,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "4.8",
                              style: GoogleFonts.inter(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: darkBlue,
                              ),
                            ),
                            Text(
                              " (1,240 Reviews)",
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "Starting from",
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),

                        /// --- Highlights Row ---
                        // SingleChildScrollView(
                        //   scrollDirection: Axis.horizontal,
                        //   child: Row(
                        //     children: [
                        //       _modernChip(Icons.timer_outlined, "60 min"),
                        //       _modernChip(
                        //         Icons.verified_user_outlined,
                        //         "Verified",
                        //       ),
                        //       _modernChip(Icons.security_outlined, "Warranty"),
                        //     ],
                        //   ),
                        // ),
                        const Divider(height: 40, thickness: 1),

                        /// --- Price Section ---
                        _buildPremiumPriceCard(data.data!.serviceFee ?? 0),
                        SizedBox(height: 30.h),

                        /// --- Service Features ---
                        _serviceDetailsSection(data.data?.name ?? ""),

                        SizedBox(height: 30.h),

                        /// --- Trust Section ---
                        _whyChooseUs(),

                        SizedBox(height: 100.h), // Space for bottom button
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) {
        return Center(child: Text(error.toString()));
      },
      loading: () =>
          Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
    );
  }

  // Helper Widgets
  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
            ],
          ),
          child: Icon(icon, size: 20, color: darkBlue),
        ),
      ),
    );
  }

  Widget _statusBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.green.shade700,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _modernChip(IconData icon, String label) {
    return Container(
      margin: EdgeInsets.only(right: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: primaryColor),
          SizedBox(width: 6.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumPriceCard(int amount) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [darkBlue, darkBlue.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Estimated Cost",
                style: TextStyle(color: Colors.white70, fontSize: 13.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                "₹${amount}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Text(
              "SAVE 20%",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(List slots, String id, int amount) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: Size(double.infinity, 56.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            elevation: 0,
          ),
          onPressed: () {
            showBookingDialog(context, slots, id, amount);
          },
          child: Text(
            "Book Now",
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _serviceDetailsSection(String type) {
    final lowerType = type.toLowerCase();

    if (lowerType.contains("plumber")) {
      return _infoCard(
        title: "Plumber Services",
        description:
            "Professional plumbing services for homes and offices with quick and reliable solutions.",
        points: [
          "Tap & Pipe Leakage Repair",
          "Bathroom & Toilet Fittings",
          "Water Tank Cleaning",
          "Kitchen Sink Repair",
        ],
      );
    }

    if (type.contains("carpenter")) {
      return _infoCard(
        title: "Carpenter Services",
        description:
            "Expert carpenter services for furniture work and wooden fittings with premium finish.",
        points: [
          "Furniture Repair & Assembly",
          "Door & Window Fixing",
          "Modular Furniture Work",
          "Custom Wood Design",
        ],
      );
    }

    if (type.contains("electrician")) {
      return _infoCard(
        title: "Electrician Services",
        description:
            "Certified electricians for electrical installation, repair and maintenance.",
        points: [
          "Wiring & Switch Repair",
          "Fan & Light Installation",
          "Power Backup Setup",
          "Electrical Safety Check",
        ],
      );
    }

    if (type.contains("painter")) {
      return _infoCard(
        title: "Painting Services",
        description:
            "Interior and exterior painting services with premium quality finish.",
        points: [
          "Interior Wall Painting",
          "Exterior Painting",
          "Wall Texture Design",
          "Waterproof Coating",
        ],
      );
    }

    return const SizedBox();
  }

  Widget _infoCard({
    required String title,
    required String description,
    required List<String> points,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(0.06), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          ...points.map(
            (e) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 18, color: primaryColor),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(e, style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _whyChooseUs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Why choose us?",
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        _whyItem(Icons.verified, "Verified professionals"),
        _whyItem(Icons.timer, "On-time service"),
        _whyItem(Icons.support_agent, "24/7 customer support"),
      ],
    );
  }

  Widget _whyItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primaryColor),
          SizedBox(width: 8.w),
          Text(text, style: GoogleFonts.inter(fontSize: 13.sp)),
        ],
      ),
    );
  }
}
