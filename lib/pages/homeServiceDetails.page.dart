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
  static const primaryColor = Color(0xFF24ADD7);
  static const darkBlue = Color(0xff0E1A35);
  List<bool> isAddedList = List.generate(2, (index) => false);

  File? selectedImage;
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

  Future<String?> uploadSingleImage(File file) async {
    try {
      final service = APIStateNetwork(createDio());
      final response = await service.uploadImageMultiple([file]);

      if (response.code == 0 && response.error == false) {
        log("Image uploaded successfully");
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
                                          builder: (context) => MyrequestPage(),
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
              color: Color(0xFF24ADD7),
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
                          color: isSelected ? Color(0xFF24ADD7) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? Color(0xFF24ADD7)
                                : Colors.grey.shade400,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Color(0xFF24ADD7).withOpacity(0.3),
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
              backgroundColor: const Color(0xFF24ADD7), // Dark Navy
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

  String timeAgo(int timestamp) {
    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return "Just now";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} hrs ago";
    } else if (diff.inDays < 7) {
      return "${diff.inDays} days ago";
    } else if (diff.inDays < 30) {
      return "${(diff.inDays / 7).floor()} weeks ago";
    } else if (diff.inDays < 365) {
      return "${(diff.inDays / 30).floor()} months ago";
    } else {
      return "${(diff.inDays / 365).floor()} years ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeServiceDetislState = ref.watch(
      homeServiceCategoryByIdController(widget.id),
    );
    return homeServiceDetislState.when(
      data: (data) {
        final reviews = data.data?.reviewsList ?? [];

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
                              data.data!.averageRating.toString(),
                              style: GoogleFonts.inter(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: darkBlue,
                              ),
                            ),
                            Text(
                              " (${data.data!.totalReviews ?? 0} Reviews)",
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

                        SizedBox(height: 10.h),

                        const Divider(height: 40, thickness: 1),

                        /// --- Price Section ---
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [darkBlue, darkBlue.withOpacity(0.8)],
                            ),
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
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "₹${data.data!.serviceFee ?? 0}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),

                        /// --- Service Features ---
                        _serviceDetailsSection(data.data?.name ?? ""),

                        SizedBox(height: 30.h),

                        /// --- Trust Section ---
                        _whyChooseUs(),
                        SizedBox(height: 30.h),
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: data.data?.pricingOptions?.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final item = data.data!.pricingOptions![index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 10.h),
                              padding: EdgeInsets.all(10.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // Image aur Text ko top se align rakha hai
                                children: [
                                  /// 🔹 Service Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.r),
                                    child: Image.network(
                                      item.image ??
                                          "https://media.istockphoto.com/id/1457385092/photo/an-asian-young-technician-service-man-wearing-blue-uniform-checking-cleaning-air-conditioner.jpg?s=612x612&w=0&k=20&c=Tqu5jMzD1TKFO1Fvow6d0JMDsEGU8T3kToP706bQFQI=",
                                      height: 70.h,
                                      width: 70.w,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 70.h,
                                          width: 70.w,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                          ),
                                          child: Center(
                                            child: Image.network(
                                              "https://media.istockphoto.com/id/1457385092/photo/an-asian-young-technician-service-man-wearing-blue-uniform-checking-cleaning-air-conditioner.jpg?s=612x612&w=0&k=20&c=Tqu5jMzD1TKFO1Fvow6d0JMDsEGU8T3kToP706bQFQI=",
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12.w),

                                  /// 🔹 Service Details (Text + Price & Button)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item.title ?? "",
                                          style: GoogleFonts.inter(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          item.description ?? "No Description",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            color: Colors.grey.shade600,
                                            fontSize: 10.sp,
                                            height: 1.2,
                                          ),
                                        ),
                                        SizedBox(height: 8.h),

                                        /// 🔹 Price and Button Row (Niche shift kiya taaki look better lage)
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "${item.price ?? ""}",
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.inter(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(
                                                    0xFF24ADD7,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            SizedBox(width: 10),

                                            SizedBox(
                                              height: 32.h,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12.w,
                                                  ),
                                                  backgroundColor: Colors.white,
                                                  elevation: 0,
                                                  side: BorderSide(
                                                    color: isAddedList[index]
                                                        ? Colors.red
                                                        : const Color(
                                                            0xFF24ADD7,
                                                          ),
                                                    width: 1.5,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10.r,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    isAddedList[index] =
                                                        !isAddedList[index];
                                                  });
                                                },
                                                child: Text(
                                                  isAddedList[index]
                                                      ? "Remove"
                                                      : "Add",
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12.sp,
                                                    color: isAddedList[index]
                                                        ? Colors.red
                                                        : const Color(
                                                            0xFF24ADD7,
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Customer Reviews",
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: darkBlue,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            reviews.isEmpty
                                ? Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(20.w),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.rate_review_outlined,
                                          size: 40.sp,
                                          color: Colors.grey.shade400,
                                        ),
                                        SizedBox(height: 10.h),
                                        Text(
                                          "No Reviews Yet",
                                          style: GoogleFonts.inter(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        Text(
                                          "Be the first to share your experience!",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: reviews.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final review = reviews[index];
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 14.h),
                                        padding: EdgeInsets.all(14.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.04,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 20.r,
                                                  backgroundImage: NetworkImage(
                                                    review.user!.image ??
                                                        "https://randomuser.me/api/portraits/men/32.jpg",
                                                  ),
                                                ),
                                                SizedBox(width: 10.w),

                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        review.user!.name ??
                                                            "N/A",
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 13.sp,
                                                            ),
                                                      ),
                                                      SizedBox(height: 2.h),

                                                      /// ⭐ Rating
                                                      Row(
                                                        children: List.generate(
                                                          5,
                                                          (starIndex) {
                                                            final rating =
                                                                review.rating ??
                                                                0;

                                                            return Icon(
                                                              starIndex < rating
                                                                  ? Icons.star
                                                                  : Icons
                                                                        .star_border,
                                                              size: 16,
                                                              color:
                                                                  Colors.orange,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                Text(
                                                  timeAgo(
                                                    review.createdAt ?? 0,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: 10.h),

                                            /// ✍️ Review Text
                                            Text(
                                              // "Service was very fast and professional. Technician was polite and fixed the issue quickly.",
                                              review.review ?? "No Review",
                                              style: GoogleFonts.inter(
                                                fontSize: 12.sp,
                                                color: Colors.grey.shade700,
                                                height: 1.4,
                                              ),
                                            ),

                                            SizedBox(height: 10.h),

                                            /// 📸 Review Image (Optional)
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
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
      loading: () => Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: Colors.white),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF24ADD7)),
        ),
      ),
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
