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
import 'package:photo_view/photo_view.dart';
import 'package:realstate/Controller/myRequestBookingSerivceController.dart';
import 'package:realstate/Model/Body/serviceRatingBodyModel.dart';
import 'package:realstate/Model/verfiyServiceAgenetBodyModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Model/myBookingServiceRequestResModel.dart';

class MyrequestPage extends ConsumerStatefulWidget {
  const MyrequestPage({super.key});

  @override
  ConsumerState<MyrequestPage> createState() => _MyrequestPageState();
}

class _MyrequestPageState extends ConsumerState<MyrequestPage> {
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.amber;
      case 'on_way':
        return Colors.blue;
      case 'working':
        return Colors.indigo;
      case 'complete':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  final ratingProvider = StateProvider.family<int, String>((ref, id) => 0);
  final reviewTextProvider = StateProvider.family<String, String>(
    (ref, id) => "",
  );

  File? problemSolvePhtot;
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
        problemSolvePhtot = File(pickedFile.path);
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
  Widget build(BuildContext context) {
    List<Rating>? ratings;
    const primaryColor = Color(0xFF24ADD7);
    final myRequestProvider = ref.watch(myRequestBookingServiceContorller);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "My Service Requests",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: primaryColor,
          color: Colors.white,
          onRefresh: () async {
            ref.invalidate(myRequestBookingServiceContorller);
          },
          child: myRequestProvider.when(
            data: (data) {
              final list = data.data?.list ?? [];
              if (list.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: EdgeInsets.all(15.w),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  final status = (item.status ?? "pending").toLowerCase();
                  return Container(
                    margin: EdgeInsets.only(bottom: 15.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildCardHeader(item, status, primaryColor),
                        // 2. Status Stepper (new chain)
                        _buildStatusStepper(status, primaryColor),

                        const Divider(height: 1),

                        // 3. Details
                        // _buildDetailsSection(item, status),

                        // 4. Verification & Technician Section
                        if (status != 'rejected')
                          _buildVerificationCard(
                            item,
                            context,
                            primaryColor,
                            ref,
                            status,
                          ),

                        // 5. Footer
                        _buildFooter(item, primaryColor),
                      ],
                    ),
                  );
                },
              );
            },
            error: (error, stackTrace) {
              log(stackTrace.toString());
              return Center(child: Text("Error: $error"));
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF24ADD7)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_late_outlined,
            size: 80.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            "No Requests Found",
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            "You haven't booked any services yet.",
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(dynamic item, String status, Color primaryColor) {
    final lowerStatus = status.toLowerCase();

    final bool isPending = lowerStatus == 'pending';
    final bool isAssigned = lowerStatus == 'in_progress';
    // final bool isOnWay = lowerStatus == 'on_way';
    final bool isWorking = lowerStatus == 'working';
    final bool isCompleted = lowerStatus == 'complete';

    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  "ID:${(item.bookingId ?? "")}",
                  style: TextStyle(color: primaryColor, fontSize: 10.sp),
                ),
              ),
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.shade50
                      : isWorking
                      ? Colors.blue.shade50
                      : isAssigned
                      ? Colors.blue.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  "${(item.status ?? "")}",
                  style: TextStyle(
                    color: isCompleted
                        ? Colors.green
                        : isWorking
                        ? Colors.blue
                        : isAssigned
                        ? Colors.blue
                        : Colors.orange,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Image.network(
                  item.serviceType?.image ?? "",
                  width: 40.w,
                  height: 40.w,
                  errorBuilder: (c, e, s) =>
                      Icon(Icons.build, color: primaryColor, size: 30.sp),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.serviceType?.name ?? "Service",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    Row(
                      children: [
                        _buildDetailChip(
                          icon: Icons.calendar_month,
                          text: DateFormat(
                            'd MMM yyyy',
                          ).format(DateTime.parse(item.serviceDate.toString())),
                          iconColor: Colors.orange,
                        ),
                        SizedBox(width: 5.w),
                        _buildDetailChip(
                          icon: Icons.access_time_filled,
                          text: item.serviceTimeSlot,
                          iconColor: Colors.orange,
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        _buildDetailChip(
                          icon: Icons.location_on,
                          text: item.address,
                          iconColor: Colors.orange,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            left: 5.w,
                            right: 5.w,
                            top: 4.h,
                            bottom: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            "₹${(item.serviceFee ?? "")}",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10.sp,
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
        ],
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String text,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.sp, color: iconColor),
          SizedBox(width: 5.w),
          Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF37474F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStepper(String status, Color primaryColor) {
    if (status == 'rejected') {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cancel, color: Colors.red, size: 22.sp),
                SizedBox(width: 10.w),
                Text(
                  "REQUEST REJECTED",
                  style: GoogleFonts.inter(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    int currentStepIndex = 0;
    if (status == 'pending') {
      currentStepIndex = 0;
    } else if (status == 'in_progress') {
      currentStepIndex = 1;
    } else if (status == 'working') {
      currentStepIndex = 3; // On Way (index 2) ko skip karke seedha 3 par
    } else if (status == 'complete') {
      currentStepIndex = 4;
    }

    // 2. CUSTOM LOGIC: Agar status 'assigned' hai, toh hum 3rd circle (index 2) ko
    // FORCEfully active mark karenge taaki UI par "On Way" fill dikhe.
    int activeUntil = currentStepIndex;
    if (status == 'in_progress') {
      activeUntil = 2; // Yeh "On Way" wale container aur line ko fill kar dega
    } else if (status == 'working' || status == 'complete') {
      activeUntil = currentStepIndex; // 'working' par index 3 tak sab fill hoga
    }

    final stepTitles = [
      "Pending",
      "Assigned",
      "On Way",
      "Working",
      "Completed",
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(stepTitles.length, (i) {
            // Circle Fill Logic
            final bool isCircleActive = i <= activeUntil;

            // Line Fill Logic: Previous step se current step tak ki line
            final bool isLineActive = i < activeUntil;

            final bool isLast = i == stepTitles.length - 1;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    // --- CIRCLE (Container) ---
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Yahan isCircleActive se container fill hoga
                        color: isCircleActive
                            ? primaryColor
                            : Colors.grey.shade200,
                        border: Border.all(
                          color: isCircleActive
                              ? primaryColor
                              : Colors.grey.shade400,
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: isCircleActive
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // --- TITLE ---
                    Text(
                      stepTitles[i],
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: isCircleActive
                            ? primaryColor
                            : Colors.grey.shade700,
                        fontWeight: isCircleActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                // --- CONNECTING LINE ---
                if (!isLast)
                  Container(
                    width: 50.w,
                    height: 3.h,
                    margin: EdgeInsets.only(
                      left: 4.w,
                      right: 4.w,
                      bottom: 20.h,
                    ),
                    color: isLineActive ? primaryColor : Colors.grey.shade300,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(dynamic item, String status) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        children: [
          _infoRow(
            Icons.location_on_outlined,
            "Address",
            item.address ?? "No Address Provided",
          ),
          if ((item.message ?? "").isNotEmpty) ...[
            SizedBox(height: 10.h),
            _infoRow(Icons.message_outlined, "Message", item.message!),
          ],
        ],
      ),
    );
  }

  Widget _buildVerificationCard(
    dynamic item,
    BuildContext context,
    Color primaryColor,
    WidgetRef ref,
    String status,
  ) {
    final lowerStatus = status.toLowerCase();

    final bool isPending = lowerStatus == 'pending';
    final bool isAssigned = lowerStatus == 'in_progress';
    // final bool isOnWay = lowerStatus == 'on_way';
    final bool isWorking = lowerStatus == 'working';
    final bool isCompleted = lowerStatus == 'complete';

    final serviceCategory = item.serviceType?.name ?? "Technician";
    final technicianName =
        item.serviceBoy?.name ?? "Assigning $serviceCategory...";
    final technicianImage = item.serviceProviderImage ?? "";

    final existingRating = (item.ratings != null && item.ratings!.isNotEmpty)
        ? item.ratings!.first
        : null;
    final bool isAlreadyRated = existingRating != null;

    /// ✅ AUTO FILL FROM API
    if (isAlreadyRated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(ratingProvider(item.id ?? "").notifier).state =
            existingRating.rating ?? 0;

        ref.read(reviewTextProvider(item.id ?? "").notifier).state =
            existingRating.review?.toString() ?? "";
      });
    }
    final hasRating = item.ratings != null && item.ratings.isNotEmpty;
    // 2. Agar rating hai, to uski image nikalo (maan lo pehle index par hai)
    final String? apiImage = hasRating ? item.ratings[0].image : null;

    // 3. UI logic check: Nayi photo pick hui ho OR API se purani photo aa rahi ho
    final bool showImage =
        problemSolvePhtot != null || (apiImage != null && apiImage.isNotEmpty);
    final rating = ref.watch(ratingProvider(item.id ?? ""));
    final reviewText = ref.watch(reviewTextProvider(item.id ?? ""));

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.shade50
            : isWorking
            // ? Colors.indigo.shade50
            // : isOnWay
            ? Colors.blue.shade50
            : isAssigned
            ? Colors.blue.shade50
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isCompleted
              ? Colors.green.shade200
              : isWorking
              // ? Colors.indigo.shade200
              // : isOnWay
              ? Colors.blue.shade200
              : isAssigned
              ? Colors.blue.shade50
              : Colors.orange.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap:
                        technicianImage.isNotEmpty &&
                            (isAssigned || isWorking || isCompleted)
                        ? () {
                            showDialog(
                              context: context,
                              barrierColor: Colors.black87,
                              builder: (_) => Stack(
                                children: [
                                  Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: EdgeInsets.zero,
                                    child: Hero(
                                      tag: technicianImage,
                                      child: PhotoView(
                                        imageProvider: NetworkImage(
                                          technicianImage,
                                        ),
                                        backgroundDecoration:
                                            const BoxDecoration(
                                              color: Colors.black,
                                            ),
                                        minScale:
                                            PhotoViewComputedScale.contained,
                                        maxScale:
                                            PhotoViewComputedScale.covered *
                                            2.5,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 40.h,
                                    left: 16.w,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        : null,
                    child: CircleAvatar(
                      radius: 26.r,
                      backgroundColor: Colors.white,
                      backgroundImage: technicianImage.isNotEmpty
                          ? NetworkImage(technicianImage)
                          : null,
                      child: technicianImage.isEmpty
                          ? Icon(
                              Icons.person_search,
                              color: Colors.orange,
                              size: 28.sp,
                            )
                          : null,
                    ),
                  ),
                  if (!isPending)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap:
                            technicianImage.isNotEmpty &&
                                (isAssigned || isWorking || isCompleted)
                            ? () {
                                showDialog(
                                  context: context,
                                  barrierColor: Colors.black87,
                                  builder: (_) => Stack(
                                    children: [
                                      Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding: EdgeInsets.zero,
                                        child: Hero(
                                          tag: technicianImage,
                                          child: PhotoView(
                                            imageProvider: NetworkImage(
                                              technicianImage,
                                            ),
                                            backgroundDecoration:
                                                const BoxDecoration(
                                                  color: Colors.black,
                                                ),
                                            minScale: PhotoViewComputedScale
                                                .contained,
                                            maxScale:
                                                PhotoViewComputedScale.covered *
                                                2.5,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 40.h,
                                        left: 16.w,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            : null,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.zoom_in_rounded,
                              color: Colors.white,
                              size: 12.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isPending)
                      Text(
                        "Service Partner",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    Text(
                      technicianName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isPending
                          ? "Finding technician..."
                          : isAssigned
                          ? "Technician is on the way"
                          // : isOnWay
                          // ? "Technician is on the way"
                          : isWorking
                          ? "Service in progress"
                          : isCompleted
                          ? "Service completed"
                          : "Status updating...",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAssigned || isWorking)
                IconButton(
                  onPressed: () async {
                    final phone = item.serviceBoy?.phone ?? "";
                    if (phone.isEmpty) return;
                    final uri = Uri.parse('tel:$phone');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      log("Cannot call: $uri");
                    }
                  },
                  icon: const Icon(Icons.call, color: Colors.green),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.all(10.w),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),

          // Action / Status indicator
          if (isAssigned)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _showVerifyDialog(context, technicianName, item.id, ref),
                icon: const Icon(Icons.verified_user, size: 18),
                label: Text("VERIFY TECHNICIAN ARRIVAL"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade100,
                  foregroundColor: Colors.blue.shade800,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            )
          else if (isCompleted) ...[
            _statusIndicator(
              Icons.check_circle,
              "SERVICE COMPLETED SUCCESSFULLY",
              Colors.green.shade800,
              Colors.green.shade100,
            ),
            SizedBox(height: 12.h),

            // ⭐ REVIEW CARD
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rate Your Experience",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),

                  SizedBox(height: 10.h),

                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 26.sp,
                        ),
                        onPressed: isAlreadyRated
                            ? null
                            : () {
                                ref
                                        .read(
                                          ratingProvider(
                                            item.id ?? "",
                                          ).notifier,
                                        )
                                        .state =
                                    index + 1;
                              },
                      );
                    }),
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: TextEditingController(text: reviewText)
                      ..selection = TextSelection.collapsed(
                        offset: reviewText.length,
                      ),
                    enabled: !isAlreadyRated,
                    maxLines: 3,
                    onChanged: (val) {
                      ref
                              .read(reviewTextProvider(item.id ?? "").notifier)
                              .state =
                          val;
                    },
                    decoration: InputDecoration(
                      hintText: "Write your review...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: EdgeInsets.all(10.w),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Upload Problem Solve Photo",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 180.h,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xffE86A34).withOpacity(0.5),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(18.r),
                          image: showImage
                              ? DecorationImage(
                                  fit: BoxFit.cover,
                                  image: problemSolvePhtot != null
                                      ? FileImage(problemSolvePhtot!)
                                      : NetworkImage(apiImage!)
                                            as ImageProvider,
                                )
                              : null,
                        ),
                        child: !showImage
                            ? InkWell(
                                onTap: isAlreadyRated
                                    ? null
                                    : () => showImagePicker(),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 40.sp,
                                      color: Colors.grey.shade400,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      "Upload Solve Photo",
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (!isAlreadyRated)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (rating == 0) {
                            Fluttertoast.showToast(msg: "Please give rating");
                            return;
                          }
                          final serivce = APIStateNetwork(createDio());
                          if (problemSolvePhtot != null) {
                            final imgResponse = await serivce.uploadImage(
                              problemSolvePhtot!,
                            );
                            if (imgResponse.code == 0 &&
                                imgResponse.error == false) {
                              existingImage = imgResponse.data!.imageUrl
                                  .toString();
                            } else {
                              Fluttertoast.showToast(
                                msg: "Image upload failed, trying again.",
                              );
                            }
                          }
                          final body = ServiceRatingBodyModel(
                            serviceBooking: item.id,
                            rating: rating,
                            review: reviewText,
                            image: existingImage,
                          );

                          try {
                            final resposne = await serivce.createServiceRating(
                              body,
                            );
                            if (resposne.code == 0 && resposne.error == false) {
                              Fluttertoast.showToast(
                                msg: resposne.message ?? "Sucess",
                              );
                              ref.invalidate(myRequestBookingServiceContorller);
                            } else {
                              Fluttertoast.showToast(
                                msg: resposne.message ?? "Error",
                              );
                            }
                          } catch (e, st) {
                            log(st.toString());
                            log(e.toString());
                            Fluttertoast.showToast(msg: "Rating failed $e");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text("Submit Review"),
                      ),
                    )
                  else
                    Center(
                      child: Text(
                        "✅ Review Submitted",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ] else if (isWorking)
            _statusIndicator(
              Icons.engineering,
              "TECHNICIAN WORKING ON SITE",
              Colors.indigo.shade800,
              Colors.indigo.shade50,
            )
          else if (isAssigned)
            _statusIndicator(
              Icons.directions_car,
              "TECHNICIAN IS ON THE WAY",
              Colors.blue.shade800,
              Colors.blue.shade50,
            )
          else if (isPending)
            _statusIndicator(
              Icons.sync,
              "SEARCHING FOR TECHNICIAN...",
              Colors.orange.shade800,
              Colors.orange.shade100,
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(dynamic item, Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.access_time, size: 12.sp, color: Colors.grey),
          SizedBox(width: 4.w),
          Text(
            item.createdAt != null
                ? DateFormat(
                    'dd MMM yyyy, hh:mm a',
                  ).format(DateTime.fromMillisecondsSinceEpoch(item.createdAt!))
                : "",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 10.sp),
          ),
        ],
      ),
    );
  }

  Widget _statusIndicator(
    IconData icon,
    String text,
    Color textColor,
    Color bgColor,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20.sp),
          SizedBox(width: 10.w),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showVerifyDialog(
    BuildContext context,
    String name,
    String? id,
    WidgetRef ref,
  ) {
    if (id == null) return;

    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: const Text("Confirm Arrival"),
            content: isLoading
                ? const SizedBox(
                    height: 60,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Text("Has $name arrived at your location?"),
            actions: isLoading
                ? null
                : [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("No"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() => isLoading = true);
                        try {
                          final service = APIStateNetwork(createDio());
                          final response = await service.verifyServiceAgent(
                            VerifyServiceAgentBodyModel(id: id),
                          );

                          if (response.code == 0) {
                            if (context.mounted) Navigator.pop(context);
                            Fluttertoast.showToast(
                              msg: "Verified! Service has started.",
                              backgroundColor: Colors.green,
                            );
                            ref.invalidate(myRequestBookingServiceContorller);
                          } else {
                            Fluttertoast.showToast(
                              msg: response.message ?? "Failed",
                            );
                          }
                        } catch (e) {
                          Fluttertoast.showToast(msg: "Connection Error");
                        } finally {
                          if (context.mounted)
                            setState(() => isLoading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5722),
                      ),
                      child: const Text("Yes, Arrived"),
                    ),
                  ],
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sp, color: color ?? Colors.grey.shade700),
        SizedBox(width: 10.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                color: color ?? Colors.black87,
                fontSize: 13.sp,
              ),
              children: [
                TextSpan(
                  text: "$title:  ",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
