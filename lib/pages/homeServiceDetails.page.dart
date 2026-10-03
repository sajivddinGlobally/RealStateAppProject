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
import 'package:realstate/Model/Body/homeGerServiceCategoryByIdModel.dart';
import 'package:realstate/Model/homeBookingServiceBodyModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:realstate/pages/myRequest.page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomeServiceDetailsPage extends ConsumerStatefulWidget {
  final String id;
  const HomeServiceDetailsPage({super.key, required this.id});

  @override
  ConsumerState<HomeServiceDetailsPage> createState() =>
      _HomeServiceDetailsPageState();
}

class _HomeServiceDetailsPageState
    extends ConsumerState<HomeServiceDetailsPage> {
  static const primaryColor = Color(0xFF24ADD7);
  static const primaryDark = Color(0xFF131224);
  static const textDark = Color(0xFF111827);
  static const textMuted = Color(0xFF6B7280);
  static const bgLight = Color(0xFFFAFAFA);
  static const cardBorder = Color(0xFFF3F4F6);

  List<PricingOption> cartItems = [];
  File? selectedImage;
  bool isFetchingLocation = false;
  final ImagePicker _picker = ImagePicker();

  static const List<String> defaultSlots = [
    "09:00 AM - 11:00 AM",
    "11:00 AM - 01:00 PM",
    "01:00 PM - 03:00 PM",
    "03:00 PM - 05:00 PM",
    "05:00 PM - 07:00 PM",
    "07:00 PM - 09:00 PM",
  ];

  void addToCart(PricingOption item) {
    final exists = cartItems.any((e) => e.title == item.title);
    if (!exists) {
      setState(() {
        cartItems.add(item);
      });
    }
  }

  void removeFromCart(PricingOption item) {
    setState(() {
      cartItems.removeWhere((e) => e.title == item.title);
    });
  }

  bool isItemAdded(PricingOption item) {
    return cartItems.any((e) => e.title == item.title);
  }

  int get cartTotal {
    int total = 0;
    for (var item in cartItems) {
      total += item.price ?? 0;
    }
    return total;
  }

  Future<void> pickImage(ImageSource source, StateSetter dialogState) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        dialogState(() {
          selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Could not pick image: $e");
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
              },
              child: const Text("Camera"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery, dialogState);
              },
              child: const Text("Gallery"),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
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

  Future<String?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Location services are disabled.");
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location permissions are denied");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
        msg: "Location permissions are permanently denied.",
      );
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        List<String> addressParts = [];
        if (place.subThoroughfare != null &&
            place.subThoroughfare!.isNotEmpty) {
          addressParts.add(place.subThoroughfare!);
        }
        if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          addressParts.add(place.thoroughfare!);
        }
        if (place.name != null &&
            place.name!.isNotEmpty &&
            !addressParts.contains(place.name)) {
          addressParts.add(place.name!);
        }
        if (place.street != null &&
            place.street!.isNotEmpty &&
            !addressParts.contains(place.street)) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addressParts.add(place.postalCode!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        return addressParts.join(', ');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to get location: $e");
    }
    return null;
  }

  bool _isSlotPast(String slotStr, DateTime? selectedDate) {
    if (selectedDate == null) return false;
    final now = DateTime.now();
    if (selectedDate.year != now.year ||
        selectedDate.month != now.month ||
        selectedDate.day != now.day) {
      return false;
    }
    try {
      final startTimePart = slotStr.split(" - ").first.trim();
      final parsedTime = DateFormat("hh:mm a").parse(startTimePart);
      final slotDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        parsedTime.hour,
        parsedTime.minute,
      );
      return now.isAfter(slotDateTime);
    } catch (e) {
      return false;
    }
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

  // Quick action launchers
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(msg: "Could not launch phone dialer");
    }
  }

  Future<void> _openWhatsApp(String phoneNumber, String message) async {
    final Uri nativeUrl = Uri.parse(
      "whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}",
    );
    try {
      if (await canLaunchUrl(nativeUrl)) {
        await launchUrl(nativeUrl, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    final Uri webUrl = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
    );
    if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(msg: "Could not open WhatsApp");
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeServiceState = ref.watch(
      homeServiceCategoryByIdController(widget.id),
    );

    return homeServiceState.when(
      data: (res) {
        final data = res.data;
        if (data == null) {
          return Scaffold(
            backgroundColor: bgLight,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: textDark),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                "Service Details",
                style: GoogleFonts.inter(
                  color: textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Center(
              child: Text(
                "Service not found",
                style: GoogleFonts.inter(fontSize: 16.sp, color: textMuted),
              ),
            ),
          );
        }

        final pricingOptions = data.pricingOptions ?? [];
        final reviews = data.reviewsList ?? [];
        final totalReviews = data.totalReviews ?? reviews.length;
        final double averageRating = (data.averageRating?.toDouble() ?? 0.0);
        final int serviceFee = data.serviceFee ?? 0;

        List<String> slotList = [];
        if (data.slots != null && data.slots!.isNotEmpty) {
          slotList = data.slots!
              .map((s) => s.timeSlot ?? "")
              .where((s) => s.isNotEmpty)
              .toList();
        }
        if (slotList.isEmpty) {
          slotList = defaultSlots;
        }

        return Scaffold(
          backgroundColor: bgLight,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Hero Header with custom Back Button & Badges
                  SliverToBoxAdapter(
                    child: _buildHeroSection(
                      context,
                      data,
                      averageRating,
                      totalReviews,
                    ),
                  ),

                  // Main Content Body (Website order)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 8. PropertyLe Promise
                          _buildPropertyLePromiseCard(),
                          SizedBox(height: 16.h),
                          // 1. Quick Connect Bar (Call Us & WhatsApp)
                          // _buildQuickConnectBar(data.name ?? "Service"),
                          // SizedBox(height: 18.h),

                          // 2. Select Services (Pricing Options)
                          if (pricingOptions.isNotEmpty) ...[
                            _buildSectionHeader("Select Services"),
                            SizedBox(height: 10.h),
                            _buildPricingOptionsList(pricingOptions),
                            SizedBox(height: 22.h),
                          ],

                          // 3. Facility Overview
                          _buildSectionHeader("Facility Overview"),
                          SizedBox(height: 10.h),
                          _buildFacilityOverviewCard(),
                          SizedBox(height: 22.h),

                          // 4. Key Features (Website 6 Features)
                          _buildSectionHeader("Key Features"),
                          SizedBox(height: 10.h),
                          _buildKeyFeaturesCard(),
                          SizedBox(height: 22.h),

                          // 5. Service Process (01, 02, 03)
                          _buildSectionHeader("Service Process"),
                          SizedBox(height: 10.h),
                          _buildServiceProcessSection(),
                          SizedBox(height: 22.h),

                          // 6. Resident FAQs
                          _buildSectionHeader("Resident FAQs"),
                          SizedBox(height: 10.h),
                          _buildResidentFaqsCard(),
                          SizedBox(height: 22.h),

                          // 7. Customer Reviews
                          _buildSectionHeader("Customer Reviews"),
                          SizedBox(height: 10.h),
                          _buildCustomerReviewsCard(
                            reviews,
                            averageRating,
                            totalReviews,
                          ),
                          SizedBox(height: 16.h),

                          // 9. Call Us Banner
                          _buildSupportCallBanner(),
                          SizedBox(
                            height: 100.h,
                          ), // Spacing for sticky bottom bar
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Floating Back Button on top
              Positioned(
                top: MediaQuery.of(context).padding.top + 8.h,
                left: 16.w,
                child: _buildCircularButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          bottomSheet: _buildBottomActionBar(
            context,
            data,
            slotList,
            serviceFee,
          ),
        );
      },
      error: (error, _) => Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: textDark),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Text(
              "Failed to load service details: $error",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.red, fontSize: 14.sp),
            ),
          ),
        ),
      ),
      loading: () => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
            strokeWidth: 2.5.w,
          ),
        ),
      ),
    );
  }

  // --- Hero Section ---
  Widget _buildHeroSection(
    BuildContext context,
    Data data,
    double averageRating,
    int totalReviews,
  ) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        12.w,
        MediaQuery.of(context).padding.top + 8.h,
        12.w,
        4.h,
      ),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: cardBorder, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          height: 260.h,
          width: double.infinity,
          color: Colors.grey.shade100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Hero Image
              Image.network(
                data.image != null && data.image!.isNotEmpty
                    ? data.image!
                    : "https://images.unsplash.com/photo-1581578731548-c64695cc6952",
                fit: BoxFit.cover,
                errorBuilder: (context, _, __) => Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Icon(
                      Icons.home_repair_service,
                      size: 60.sp,
                      color: primaryColor.withOpacity(0.4),
                    ),
                  ),
                ),
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.15),
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
              ),

              // Overlay Details at Bottom
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: 16.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge: Premium Society Services
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        "PREMIUM SOCIETY SERVICES",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),

                    // Service Name
                    Text(
                      (data.name ?? "Service").trim(),
                      style: GoogleFonts.inter(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Rating Pill
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            averageRating > 0
                                ? averageRating.toStringAsFixed(1)
                                : "New",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "($totalReviews reviews)",
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

  // --- Quick Connect Bar ---
  Widget _buildQuickConnectBar(String serviceName) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Call Button
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: () => _makePhoneCall("+919171719060"),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(5.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.call, color: Colors.white, size: 13.sp),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Let's Connect",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),

          // WhatsApp Button
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: () => _openWhatsApp(
                "919171719060",
                "Hi, I am interested in your $serviceName.",
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(5.w),
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                        size: 13.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "WhatsApp",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Section Header with Cyan Accent Bar ---
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1F2937),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // --- Pricing Options List (Select Services) ---
  Widget _buildPricingOptionsList(List<PricingOption> pricingOptions) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: pricingOptions.map((item) {
          final bool isAdded = isItemAdded(item);
          return Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isAdded
                    ? primaryColor.withOpacity(0.4)
                    : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Item Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    width: 65.w,
                    height: 65.h,
                    color: Colors.white,
                    child: Image.network(
                      item.image != null && item.image!.isNotEmpty
                          ? item.image!
                          : "https://t4.ftcdn.net/jpg/07/91/22/59/360_F_791225927_caRPPH99D6D1iFonkCRmCGzkJPf36QDw.jpg",
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, __) => Center(
                        child: Icon(
                          Icons.handyman,
                          color: primaryColor.withOpacity(0.5),
                          size: 28.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title ?? "",
                        style: GoogleFonts.inter(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.price != null && item.price! > 0) ...[
                        SizedBox(height: 3.h),
                        Text(
                          "₹${item.price}",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                      ],
                      if (item.description != null &&
                          item.description!.trim().isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          item.description!.trim(),
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontStyle: FontStyle.italic,
                            color: textMuted,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),

                // Add / Remove Button
                InkWell(
                  borderRadius: BorderRadius.circular(10.r),
                  onTap: () {
                    if (isAdded) {
                      removeFromCart(item);
                    } else {
                      addToCart(item);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: isAdded ? const Color(0xFFFEF2F2) : Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isAdded ? const Color(0xFFEF4444) : primaryColor,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isAdded ? Colors.red : primaryColor)
                              .withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      isAdded ? "Remove" : "Add",
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: isAdded ? const Color(0xFFEF4444) : primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- Facility Overview Card ---
  Widget _buildFacilityOverviewCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        "We provide professionally managed, society-approved services designed for modern urban living.\nOur services are available 24/7 with verified staff, transparent processes, and quick response times.\n\nEvery service request is handled with priority, safety, and quality assurance in mind. Whether it’s an emergency or routine assistance, our trained professionals ensure a hassle-free experience for residents.",
        textAlign: TextAlign.justify,
        style: GoogleFonts.inter(
          fontSize: 13.sp,
          color: const Color(0xFF4B5563),
          height: 1.65,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // --- Key Features Card (Website 6 Features) ---
  Widget _buildKeyFeaturesCard() {
    final List<Map<String, String>> features = [
      {"label": "Availability", "value": "24/7 Service Support"},
      {"label": "Staff", "value": "Police Verified"},
      {"label": "Response Time", "value": "Quick & Reliable"},
      {"label": "Quality", "value": "Premium Tools"},
      {"label": "Security", "value": "Society Approved"},
      {"label": "Support", "value": "Dedicated Helpdesk"},
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 14.h,
          childAspectRatio: 2.1,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final f = features[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                f["label"]!.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade400,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 2.5.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      f["value"]!,
                      style: GoogleFonts.inter(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Service Process (01, 02, 03) ---
  Widget _buildServiceProcessSection() {
    final List<Map<String, String>> steps = [
      {
        "step": "01",
        "title": "Raise Request",
        "desc":
            "Submit your service request via the app or website in just a few clicks.",
      },
      {
        "step": "02",
        "title": "Professional Assigned",
        "desc":
            "A trained and verified professional is assigned based on availability.",
      },
      {
        "step": "03",
        "title": "Service Delivered",
        "desc":
            "Work is completed efficiently with quality checks and resident confirmation.",
      },
    ];

    return Column(
      children: steps.map((s) {
        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Subtle background watermark
              Positioned(
                right: 0,
                top: -8.h,
                child: Text(
                  s["step"]!,
                  style: GoogleFonts.inter(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w900,
                    color: primaryColor.withOpacity(0.06),
                  ),
                ),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      s["step"]!,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s["title"]!,
                          style: GoogleFonts.inter(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          s["desc"]!,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: textMuted,
                            height: 1.45,
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
      }).toList(),
    );
  }

  // --- Resident FAQs ---
  Widget _buildResidentFaqsCard() {
    final List<Map<String, String>> faqs = [
      {
        "q": "Are services available 24/7?",
        "a":
            "Yes, our services are available round-the-clock, including emergencies and holidays.",
      },
      {
        "q": "Are the service professionals verified?",
        "a":
            "All professionals are police-verified and society-approved for maximum safety.",
      },
      {
        "q": "How quickly will someone arrive?",
        "a":
            "Most requests are addressed within 30–60 minutes depending on availability.",
      },
    ];

    return Column(
      children: faqs.map((faq) {
        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22.w,
                    height: 22.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF7ED),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Q",
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      faq["q"]!,
                      style: GoogleFonts.inter(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Padding(
                padding: EdgeInsets.only(left: 30.w),
                child: Text(
                  faq["a"]!,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: textMuted,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- Customer Reviews ---
  Widget _buildCustomerReviewsCard(
    List<ReviewsList> reviews,
    double averageRating,
    int totalReviews,
  ) {
    Map<int, int> ratingCount = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in reviews) {
      final r = review.rating ?? 0;
      if (ratingCount.containsKey(r)) {
        ratingCount[r] = ratingCount[r]! + 1;
      }
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Summary Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Big Score
              Column(
                children: [
                  Text(
                    averageRating > 0
                        ? averageRating.toStringAsFixed(1)
                        : "New",
                    style: GoogleFonts.inter(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < averageRating.round()
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 16.sp,
                      );
                    }),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "$totalReviews reviews",
                    style: GoogleFonts.inter(fontSize: 11.sp, color: textMuted),
                  ),
                ],
              ),
              SizedBox(width: 18.w),

              // Bars
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
                    final count = ratingCount[star] ?? 0;
                    final double progress = totalReviews > 0
                        ? count / totalReviews
                        : 0.0;
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Row(
                        children: [
                          Text(
                            "$star",
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: textMuted,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 12.sp,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 5.h,
                                backgroundColor: Colors.grey.shade100,
                                valueColor: const AlwaysStoppedAnimation(
                                  Colors.amber,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          SizedBox(
                            width: 16.w,
                            child: Text(
                              "$count",
                              textAlign: TextAlign.end,
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          const Divider(height: 24, thickness: 0.8),

          // Reviews List
          if (reviews.isEmpty) ...[
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  "No reviews yet. Be the first to review!",
                  style: GoogleFonts.inter(fontSize: 12.5.sp, color: textMuted),
                ),
              ),
            ),
          ] else ...[
            ...reviews.map((r) {
              final userName = r.user?.name ?? "User";
              final initial = userName.isNotEmpty
                  ? userName[0].toUpperCase()
                  : "U";
              return Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade100, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16.r,
                          backgroundColor: primaryColor,
                          child: Text(
                            initial,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: textDark,
                                ),
                              ),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < (r.rating ?? 5)
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: Colors.amber,
                                    size: 13.sp,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        if (r.createdAt != null) ...[
                          Text(
                            timeAgo(r.createdAt!),
                            style: GoogleFonts.inter(
                              fontSize: 10.5.sp,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (r.review != null && r.review!.trim().isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Text(
                        r.review!.trim(),
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: const Color(0xFF4B5563),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // --- PropertyLe Promise Card ---
  Widget _buildPropertyLePromiseCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PropertyLe Promise",
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          SizedBox(height: 10.h),
          _promiseItem("Verified Professionals"),
          _promiseItem("Hassle Free Booking"),
          _promiseItem("Transparent Pricing"),
        ],
      ),
    );
  }

  Widget _promiseItem(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: const Color(0xFF22C55E),
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  // --- Support Call Banner ---
  Widget _buildSupportCallBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "CALL US TODAY",
                style: GoogleFonts.inter(
                  color: primaryColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "+91-9171719060",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => _makePhoneCall("+919171719060"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            icon: Icon(Icons.call, size: 14.sp),
            label: Text(
              "Call",
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Sticky Bottom Action Bar ---
  Widget _buildBottomActionBar(
    BuildContext context,
    Data data,
    List<String> slots,
    int serviceFee,
  ) {
    final bool hasItems = cartItems.isNotEmpty;
    final int totalPayable = cartTotal + serviceFee;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        MediaQuery.of(context).padding.bottom + 10.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15.r,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Total & items info with breakdown tap
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: hasItems
                  ? () => _showPriceBreakdownBottomSheet(
                      context,
                      serviceFee,
                      slots,
                      data.id ?? widget.id,
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        hasItems
                            ? "${cartItems.length} item${cartItems.length > 1 ? 's' : ''} selected"
                            : "No items selected",
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          color: textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (hasItems) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.info_outline,
                          size: 13.sp,
                          color: primaryColor,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Text(
                        hasItems ? "₹$totalPayable" : "₹0",
                        style: GoogleFonts.inter(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w900,
                          color: hasItems ? primaryColor : textMuted,
                        ),
                      ),
                      if (hasItems) ...[
                        SizedBox(width: 6.w),
                        Text(
                          "Total",
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (hasItems) ...[
                    SizedBox(height: 2.h),
                    Text(
                      serviceFee > 0
                          ? "Items: ₹$cartTotal  |  Service Fee: ₹$serviceFee"
                          : "Items Total: ₹$cartTotal",
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Action Button
          SizedBox(
            height: 48.h,
            child: ElevatedButton(
              onPressed: hasItems
                  ? () => showBookingDialog(
                      context,
                      slots,
                      data.id ?? widget.id,
                      serviceFee,
                    )
                  : () {
                      Fluttertoast.showToast(
                        msg: "Please select at least one service.",
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: hasItems ? primaryColor : Colors.grey.shade300,
                elevation: hasItems ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
              ),
              child: Row(
                children: [
                  Text(
                    "Request Service",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: hasItems ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: hasItems ? Colors.white : Colors.grey.shade600,
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Price Breakdown Modal Sheet ---
  void _showPriceBreakdownBottomSheet(
    BuildContext context,
    int serviceFee,
    List<String> slots,
    String serviceId,
  ) {
    final int totalPayable = cartTotal + serviceFee;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Price Breakdown",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              ...cartItems.map((item) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title ?? "",
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: const Color(0xFF374151),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        "₹${item.price ?? 0}",
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Items Total",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "₹$cartTotal",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Service Charge",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "₹$serviceFee",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const Divider(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Final Total",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                  Text(
                    "₹$totalPayable",
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showBookingDialog(context, slots, serviceId, serviceFee);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    "Proceed to Book",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 6.h),
            ],
          ),
        );
      },
    );
  }

  // --- Circular Back Button ---
  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18.sp, color: textDark),
      ),
    );
  }

  // --- Comprehensive 3-Step Booking BottomSheet (Website Mirror) ---
  void showBookingDialog(
    BuildContext context,
    List<String> slots,
    String serviceId,
    int serviceFee,
  ) {
    final addressController = TextEditingController();
    final issueController = TextEditingController();
    final PageController pageController = PageController();

    DateTime selectedDate = DateTime.now();
    String? selectedSlot;
    String paymentMethod = "online"; // 'online' or 'cod'
    int currentStep = 1;

    bool isCheckingSlot = false;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(26.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header & Step Indicator
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                if (currentStep > 1) ...[
                                  InkWell(
                                    onTap: () {
                                      pageController.previousPage(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                      setSheetState(() => currentStep--);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 8.w),
                                      child: Icon(
                                        Icons.arrow_back_ios_new,
                                        size: 16.sp,
                                        color: textDark,
                                      ),
                                    ),
                                  ),
                                ],
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Request Service",
                                      style: GoogleFonts.inter(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w800,
                                        color: textDark,
                                      ),
                                    ),
                                    Text(
                                      "STEP $currentStep OF 3",
                                      style: GoogleFonts.inter(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w700,
                                        color: primaryColor,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Step Pills: 1, 2, 3
                            Row(
                              children: [1, 2, 3].map((step) {
                                final bool isActive = currentStep >= step;
                                return Container(
                                  margin: EdgeInsets.only(left: 6.w),
                                  width: 24.w,
                                  height: 24.h,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? primaryColor
                                        : Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "$step",
                                    style: GoogleFonts.inter(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w800,
                                      color: isActive
                                          ? Colors.white
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, thickness: 1),

                      // Step Pages
                      Expanded(
                        child: PageView(
                          controller: pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            // STEP 1: Visit Details (Address, Date, Time Slot)
                            _buildStepOne(
                              context,
                              scrollController,
                              setSheetState,
                              addressController,
                              selectedDate,
                              selectedSlot,
                              slots,
                              serviceId,
                              serviceFee,
                              (newDate) {
                                setSheetState(() {
                                  selectedDate = newDate;
                                  selectedSlot =
                                      null; // reset slot on date change
                                });
                              },
                              (slot) =>
                                  setSheetState(() => selectedSlot = slot),
                              isCheckingSlot,
                              () async {
                                if (addressController.text.trim().isEmpty) {
                                  Fluttertoast.showToast(
                                    msg: "Please enter your address",
                                  );
                                  return;
                                }
                                if (selectedSlot == null) {
                                  Fluttertoast.showToast(
                                    msg: "Please select a time slot",
                                  );
                                  return;
                                }

                                setSheetState(() => isCheckingSlot = true);

                                try {
                                  final body = CheckSlotBodyModel(
                                    serviceDate: selectedDate,
                                    serviceTimeSlot: selectedSlot,
                                    serviceType: serviceId,
                                  );
                                  final service = APIStateNetwork(createDio());
                                  final response = await service
                                      .checkSlotAvailability(body);

                                  if (response.code == 0 &&
                                      response.error == false) {
                                    if (response.data != null &&
                                        response.data!.slotAvailable == false) {
                                      Fluttertoast.showToast(
                                        msg:
                                            "This slot is full. Please choose another slot.",
                                      );
                                    } else {
                                      pageController.nextPage(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                      setSheetState(() => currentStep = 2);
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                      msg:
                                          response.message ??
                                          "Slot is not available",
                                    );
                                  }
                                } catch (e) {
                                  log("Slot Check error: $e");
                                  // allow next step if slot verification API encounters issue
                                  pageController.nextPage(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                  );
                                  setSheetState(() => currentStep = 2);
                                } finally {
                                  setSheetState(() => isCheckingSlot = false);
                                }
                              },
                            ),

                            // STEP 2: Requirement & Photos
                            _buildStepTwo(
                              context,
                              scrollController,
                              setSheetState,
                              issueController,
                              () {
                                if (issueController.text.trim().isEmpty) {
                                  Fluttertoast.showToast(
                                    msg: "Please describe your issue",
                                  );
                                  return;
                                }
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                );
                                setSheetState(() => currentStep = 3);
                              },
                            ),

                            // STEP 3: Confirm & Payment
                            _buildStepThree(
                              context,
                              scrollController,
                              setSheetState,
                              addressController.text.trim(),
                              selectedDate,
                              selectedSlot ?? "",
                              issueController.text.trim(),
                              paymentMethod,
                              (method) =>
                                  setSheetState(() => paymentMethod = method),
                              serviceFee,
                              isSubmitting,
                              () async {
                                setSheetState(() => isSubmitting = true);
                                try {
                                  String? uploadedImageUrl = "";
                                  if (selectedImage != null) {
                                    uploadedImageUrl = await uploadSingleImage(
                                      selectedImage!,
                                    );
                                  }

                                  final finalPayable = cartTotal + serviceFee;
                                  final body = HomeBookingServiceBodyModel(
                                    address: addressController.text.trim(),
                                    message: issueController.text.trim(),
                                    problemImgae: uploadedImageUrl,
                                    serviceDate: selectedDate,
                                    serviceTimeSlot: selectedSlot,
                                    serviceFee: finalPayable,
                                    serviceType: serviceId,
                                    paymentMethod: paymentMethod,
                                    items: cartItems.map((e) {
                                      return Item(
                                        id: e.id,
                                        serviceId: serviceId,
                                        title: e.title,
                                        price: e.price ?? 0,
                                        image: e.image,
                                        description: e.description,
                                        serviceFee: serviceFee,
                                      );
                                    }).toList(),
                                  );

                                  final service = APIStateNetwork(createDio());
                                  final response = await service
                                      .bookHomeService(body);

                                  if (response.code == 0 &&
                                      response.error == false) {
                                    ref.invalidate(
                                      myRequestBookingServiceContorller,
                                    );
                                    Navigator.pop(bottomSheetContext);
                                    Navigator.pushReplacement(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) =>
                                            const MyrequestPage(),
                                      ),
                                    );
                                    Fluttertoast.showToast(
                                      msg:
                                          response.message ??
                                          "Service booked successfully!",
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                      msg:
                                          response.message ??
                                          "Failed to book service.",
                                    );
                                  }
                                } catch (e) {
                                  log("Booking error: $e");
                                  Fluttertoast.showToast(
                                    msg: "Booking error: $e",
                                  );
                                } finally {
                                  setSheetState(() => isSubmitting = false);
                                }
                              },
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

  // --- Step 1: Visit Details ---
  Widget _buildStepOne(
    BuildContext context,
    ScrollController scrollController,
    StateSetter setSheetState,
    TextEditingController addressController,
    DateTime selectedDate,
    String? selectedSlot,
    List<String> slots,
    String serviceId,
    int serviceFee,
    Function(DateTime) onDateChange,
    Function(String) onSlotChange,
    bool isCheckingSlot,
    VoidCallback onNext,
  ) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected Services & Cost Breakdown Card
          Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          color: primaryColor,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "SELECTED SERVICES (${cartItems.length})",
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Total: ₹${cartTotal + serviceFee}",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ...cartItems.map((item) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title ?? "",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "₹${item.price ?? 0}",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Divider(
                  height: 16.h,
                  thickness: 0.8,
                  color: Colors.grey.shade300,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Items Total",
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        color: textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "₹$cartTotal",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Service Charge",
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        color: textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "₹$serviceFee",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 14.h,
                  thickness: 0.8,
                  color: Colors.grey.shade300,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Final Total",
                      style: GoogleFonts.inter(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    Text(
                      "₹${cartTotal + serviceFee}",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Address Label + GPS button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: primaryColor, size: 14.sp),
                  SizedBox(width: 4.w),
                  Text(
                    "VISIT ADDRESS",
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: isFetchingLocation
                    ? null
                    : () async {
                        setSheetState(() => isFetchingLocation = true);
                        final loc = await _getCurrentLocation();
                        if (loc != null) {
                          setSheetState(() {
                            addressController.text = loc;
                          });
                        }
                        setSheetState(() => isFetchingLocation = false);
                      },
                child: Text(
                  isFetchingLocation ? "Locating..." : "Use current location",
                  style: GoogleFonts.inter(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),

          // Address Input
          TextField(
            controller: addressController,
            decoration: InputDecoration(
              hintText: "e.g. Flat 402, Block B, Society Name",
              hintStyle: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey.shade400,
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: primaryColor),
              ),
            ),
            style: GoogleFonts.inter(fontSize: 13.sp, color: textDark),
          ),
          SizedBox(height: 16.h),

          // Select Day
          Row(
            children: [
              Icon(Icons.calendar_today, color: primaryColor, size: 14.sp),
              SizedBox(width: 4.w),
              Text(
                "SELECT DAY",
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: textMuted,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),

          InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: primaryColor,
                        onPrimary: Colors.white,
                        onSurface: textDark,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                onDateChange(picked);
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat("EEEE, dd MMM yyyy").format(selectedDate),
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                  Icon(Icons.edit_calendar, color: primaryColor, size: 18.sp),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Select Time Slot
          Row(
            children: [
              Icon(Icons.access_time, color: primaryColor, size: 14.sp),
              SizedBox(width: 4.w),
              Text(
                "SELECT TIME SLOT",
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: textMuted,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 2.7,
            ),
            itemCount: slots.length,
            itemBuilder: (context, index) {
              final slot = slots[index];
              final bool isSelected = selectedSlot == slot;
              final bool isPast = _isSlotPast(slot, selectedDate);

              return InkWell(
                onTap: isPast ? null : () => onSlotChange(slot),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor
                        : isPast
                        ? Colors.grey.shade100
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : isPast
                          ? Colors.grey.shade200
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    slot.replaceAll(" - ", " - "),
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : isPast
                          ? Colors.grey.shade400
                          : const Color(0xFF374151),
                      decoration: isPast ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24.h),

          // Proceed Next Button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: isCheckingSlot ? null : onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: isCheckingSlot
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "PROCEED NEXT",
                          style: GoogleFonts.inter(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.arrow_forward,
                          size: 16.sp,
                          color: Colors.white,
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // --- Step 2: Requirement & Photos ---
  Widget _buildStepTwo(
    BuildContext context,
    ScrollController scrollController,
    StateSetter setSheetState,
    TextEditingController issueController,
    VoidCallback onNext,
  ) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, color: primaryColor, size: 16.sp),
              SizedBox(width: 4.w),
              Text(
                "REQUIREMENT",
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: textMuted,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),

          TextField(
            controller: issueController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Describe the issue or service details...",
              hintStyle: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey.shade400,
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: EdgeInsets.all(14.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: primaryColor),
              ),
            ),
            style: GoogleFonts.inter(fontSize: 13.sp, color: textDark),
          ),
          SizedBox(height: 16.h),

          Row(
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                color: primaryColor,
                size: 14.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                "PROBLEM PHOTO (OPTIONAL)",
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: textMuted,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          if (selectedImage != null) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Image.file(
                    selectedImage!,
                    height: 120.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: InkWell(
                    onTap: () => setSheetState(() => selectedImage = null),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14.r),
                    onTap: () => pickImage(ImageSource.camera, setSheetState),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: primaryColor,
                            size: 24.sp,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Camera",
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14.r),
                    onTap: () => pickImage(ImageSource.gallery, setSheetState),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            color: primaryColor,
                            size: 24.sp,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Gallery",
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 24.h),

          // Review & Pay Button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: Text(
                "REVIEW & PAY",
                style: GoogleFonts.inter(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // --- Step 3: Review & Payment ---
  Widget _buildStepThree(
    BuildContext context,
    ScrollController scrollController,
    StateSetter setSheetState,
    String address,
    DateTime selectedDate,
    String selectedSlot,
    String issue,
    String paymentMethod,
    Function(String) onMethodChange,
    int serviceFee,
    bool isSubmitting,
    VoidCallback onSubmit,
  ) {
    final int finalPayable = cartTotal + serviceFee;

    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Confirm Details Card
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8.r,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CONFIRM DETAILS",
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade400,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 8.h),

                // Location & Date/Time chips
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: primaryColor,
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: primaryColor,
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                "$selectedSlot, ${DateFormat('dd MMM').format(selectedDate)}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Issue description & thumbnail
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "YOUR ISSUE",
                            style: GoogleFonts.inter(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "\"$issue\"",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11.5.sp,
                              color: const Color(0xFF4B5563),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selectedImage != null) ...[
                      SizedBox(width: 10.w),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          selectedImage!,
                          width: 42.w,
                          height: 42.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Payment Method Selector
          Text(
            "PAYMENT METHOD",
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: textMuted,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 8.h),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14.r),
                  onTap: () => onMethodChange("online"),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: paymentMethod == "online"
                          ? primaryDark
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: paymentMethod == "online"
                            ? primaryDark
                            : Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Pay Online",
                      style: GoogleFonts.inter(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: paymentMethod == "online"
                            ? Colors.white
                            : textMuted,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14.r),
                  onTap: () => onMethodChange("cod"),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: paymentMethod == "cod"
                          ? primaryDark
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: paymentMethod == "cod"
                            ? primaryDark
                            : Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Cash on Delivery",
                      style: GoogleFonts.inter(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: paymentMethod == "cod"
                            ? Colors.white
                            : textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Payable Breakdown Card
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "PAYABLE BREAKDOWN",
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade400,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      "₹$finalPayable",
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                ...cartItems.map((item) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.5.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title ?? "",
                            style: GoogleFonts.inter(
                              fontSize: 11.5.sp,
                              color: Colors.grey.shade300,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "₹${item.price ?? 0}",
                          style: GoogleFonts.inter(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: 6.h),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Items Total",
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Text(
                      "₹$cartTotal",
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Service Charge",
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Text(
                      "₹$serviceFee",
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Final Total",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "₹$finalPayable",
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: const Color(0xFF22C55E),
                          size: 12.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "Visiting Included",
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "No Hidden Charges",
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: isSubmitting
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      paymentMethod == "cod"
                          ? "BOOK NOW (COD)"
                          : "MAKE PAYMENT",
                      style: GoogleFonts.inter(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
