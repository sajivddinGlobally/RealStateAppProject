import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:realstate/Controller/getMyPropertyController.dart';
import 'package:realstate/Controller/getPropertyController.dart';
import 'package:realstate/Controller/likePropertyController.dart';
import 'package:realstate/Model/Body/PropertyListBodyModel.dart';
import 'package:realstate/Model/likePropertyBodyModel.dart';
import 'package:realstate/Model/saveContactInPropertyBodyModel.dart';
import 'package:realstate/Model/propertyDetailsResModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Model/getPropertyResponsemodel.dart' hide AroundProject;

class PerticulerPropertyPage extends ConsumerStatefulWidget {
  final String propertyId;
  const PerticulerPropertyPage({super.key, required this.propertyId});

  @override
  ConsumerState<PerticulerPropertyPage> createState() =>
      _PerticulerPropertyPageState();
}

class _PerticulerPropertyPageState
    extends ConsumerState<PerticulerPropertyPage> {
  int currentPage = 1;
  int _activeImageIndex = 0;
  final PageController _pageController = PageController();
  bool isLiked = false;
  late PropertyListBodyModel body;

  // In-Page Contact Form State
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  bool _agreeToContact = true;
  bool _interestedHomeLoan = false;
  bool _isSubmittingContact = false;

  // Expandable sections
  bool _showAllAmenities = false;
  bool _isDescExpanded = false;

  @override
  void initState() {
    super.initState();
    body = PropertyListBodyModel(
      size: 6,
      pageNo: currentPage,
      sortBy: 'createdAt',
      sortOrder: 'desc',
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  // --- Date Formatter ---
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "Recently";
    try {
      DateTime dt;
      if (timestamp is int) {
        if (timestamp > 100000000000) {
          dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
        } else {
          dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        }
      } else if (timestamp is String) {
        dt = DateTime.tryParse(timestamp) ?? DateTime.now();
      } else {
        return "Recently";
      }
      return DateFormat("dd MMM yyyy").format(dt);
    } catch (_) {
      return "Recently";
    }
  }

  // --- Price Formatter (matching website) ---
  String _formatPrice(String? priceStr) {
    if (priceStr == null || priceStr.isEmpty) return '—';
    final price = double.tryParse(priceStr) ?? 0;
    if (price >= 10000000) {
      return '₹ ${(price / 10000000).toStringAsFixed(2)} Cr';
    }
    if (price >= 100000) {
      return '₹ ${(price / 100000).toStringAsFixed(2)} Lac';
    }
    return '₹ ${price.toStringAsFixed(0)}';
  }

  String? _calcPricePerSqFt(String? priceStr, String? areaStr) {
    if (priceStr == null || areaStr == null) return null;
    final price = double.tryParse(priceStr);
    final area = double.tryParse(areaStr);
    if (price != null && area != null && area > 0) {
      final rate = (price / area).round();
      return '₹ $rate / sq.ft';
    }
    return null;
  }

  String _stripHtml(String? html) {
    if (html == null || html.trim().isEmpty) return "No description available.";
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // --- Amenity Icons ---
  IconData _getAmenityIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('pool')) return Icons.pool_rounded;
    if (lower.contains('gym') || lower.contains('fitness')) return Icons.fitness_center_rounded;
    if (lower.contains('yoga')) return Icons.self_improvement_rounded;
    if (lower.contains('lift') || lower.contains('elevator')) return Icons.elevator_rounded;
    if (lower.contains('parking')) return Icons.local_parking_rounded;
    if (lower.contains('security') || lower.contains('guard') || lower.contains('cctv')) {
      return Icons.security_rounded;
    }
    if (lower.contains('fire')) return Icons.local_fire_department_rounded;
    if (lower.contains('water')) return Icons.water_drop_rounded;
    if (lower.contains('power') || lower.contains('backup')) return Icons.bolt_rounded;
    if (lower.contains('party') || lower.contains('club')) return Icons.celebration_rounded;
    if (lower.contains('restaurant') || lower.contains('dining') || lower.contains('kitchen')) {
      return Icons.restaurant_rounded;
    }
    if (lower.contains('spa')) return Icons.spa_rounded;
    if (lower.contains('garden') || lower.contains('park') || lower.contains('terrace')) {
      return Icons.park_rounded;
    }
    if (lower.contains('play') || lower.contains('kid') || lower.contains('sports')) {
      return Icons.sports_tennis_rounded;
    }
    if (lower.contains('wifi') || lower.contains('internet')) return Icons.wifi_rounded;
    if (lower.contains('furnish')) return Icons.chair_rounded;
    if (lower.contains('balcony')) return Icons.balcony_rounded;
    if (lower.contains('living') || lower.contains('room')) return Icons.weekend_rounded;
    if (lower.contains('storage') || lower.contains('sotorage')) return Icons.inventory_2_rounded;
    if (lower.contains('floor')) return Icons.layers_rounded;
    return Icons.verified_rounded;
  }

  // --- Fullscreen Gallery Lightbox Viewer ---
  void _openFullScreenGallery(
    BuildContext context,
    List<String> photos,
    int initialIndex,
  ) {
    int currentIndex = initialIndex;
    final PageController modalPageCtrl =
        PageController(initialPage: initialIndex);
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Stack(
              children: [
                PageView.builder(
                  controller: modalPageCtrl,
                  itemCount: photos.length,
                  onPageChanged: (idx) =>
                      setModalState(() => currentIndex = idx),
                  itemBuilder: (context, idx) {
                    return InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.network(
                          photos[idx],
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Close button top right
                Positioned(
                  top: 40.h,
                  right: 20.w,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ),
                // Prev button
                if (currentIndex > 0)
                  Positioned(
                    left: 16.w,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            modalPageCtrl.previousPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                // Next button
                if (currentIndex < photos.length - 1)
                  Positioned(
                    right: 16.w,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            modalPageCtrl.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                // Counter pill bottom center
                Positioned(
                  bottom: 30.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        "${currentIndex + 1} / ${photos.length}",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- In-Page Contact Submit ---
  Future<void> _submitInPageContact(String propertyId) async {
    final name = _contactNameController.text.trim();
    final phone = _contactPhoneController.text.trim();
    final email = _contactEmailController.text.trim();

    if (name.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your name");
      return;
    }
    if (phone.length < 10) {
      Fluttertoast.showToast(msg: "Please enter valid 10-digit phone number");
      return;
    }
    if (!_agreeToContact) {
      Fluttertoast.showToast(msg: "Please agree to be contacted");
      return;
    }

    setState(() => _isSubmittingContact = true);
    try {
      final reqBody = SaveContactInPropertyBodyModel(
        email: email,
        name: name,
        phone: phone,
        propertyId: propertyId,
        interested: _interestedHomeLoan,
      );

      final service = APIStateNetwork(createDio());
      final response = await service.saveContactInProperty(reqBody);

      if (response.code == 0 || response.error == false) {
        Fluttertoast.showToast(
          msg: response.message ?? "Contact shared successfully",
        );
        _contactNameController.clear();
        _contactPhoneController.clear();
        _contactEmailController.clear();
        ref.invalidate(getMyPropertyContantListController);
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? "Failed to share contact",
        );
      }
    } catch (e) {
      log("Contact share error: $e");
      Fluttertoast.showToast(msg: "Submission failed. Please try again.");
    } finally {
      if (mounted) setState(() => _isSubmittingContact = false);
    }
  }

  // --- Bottom Sheet Contact Dialog (Fallback) ---
  void showContactBottomSheet(
    BuildContext context,
    WidgetRef ref,
    dynamic propertyData,
  ) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String? nameError;
    String? phoneError;
    bool agreeToContact = true;
    bool interestedHomeLoan = false;
    bool isLoading = false;
    const primaryColor = Color(0xFF24ADD7);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 15.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 45.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundColor: const Color(0xFF24ADD7),
                          child: Text(
                            "A",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Contact Seller",
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "Please share your contact details",
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Full Name *",
                        errorText: nameError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone Number *",
                        prefixText: "+91 ",
                        errorText: phoneError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email Address (Optional)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Checkbox(
                          value: agreeToContact,
                          activeColor: primaryColor,
                          onChanged: (val) {
                            setDialogState(() => agreeToContact = val ?? false);
                          },
                        ),
                        Expanded(
                          child: Text(
                            "I agree to be contacted",
                            style: GoogleFonts.inter(fontSize: 12.sp),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: interestedHomeLoan,
                          activeColor: primaryColor,
                          onChanged: (val) {
                            setDialogState(
                              () => interestedHomeLoan = val ?? false,
                            );
                          },
                        ),
                        Expanded(
                          child: Text(
                            "I am interested in Home Loans",
                            style: GoogleFonts.inter(fontSize: 12.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      height: 46.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                final name = nameController.text.trim();
                                final phone = phoneController.text.trim();
                                if (name.isEmpty) {
                                  setDialogState(
                                    () => nameError = "Name is required",
                                  );
                                  return;
                                }
                                if (phone.length < 10) {
                                  setDialogState(
                                    () => phoneError = "Valid phone required",
                                  );
                                  return;
                                }
                                if (!agreeToContact) {
                                  Fluttertoast.showToast(
                                    msg: "Please agree to be contacted",
                                  );
                                  return;
                                }

                                setDialogState(() => isLoading = true);
                                try {
                                  final reqBody =
                                      SaveContactInPropertyBodyModel(
                                        email: emailController.text.trim(),
                                        name: name,
                                        phone: phone,
                                        propertyId:
                                            propertyData.id?.toString() ?? "",
                                        interested: interestedHomeLoan,
                                      );

                                  final service = APIStateNetwork(createDio());
                                  final response = await service
                                      .saveContactInProperty(reqBody);

                                  if (response.code == 0 ||
                                      response.error == false) {
                                    Fluttertoast.showToast(
                                      msg:
                                          response.message ??
                                          "Contact shared successfully",
                                    );
                                    ref.invalidate(
                                      getMyPropertyContantListController,
                                    );
                                    Navigator.pop(context);
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: response.message ?? "Error",
                                    );
                                  }
                                } catch (e) {
                                  Fluttertoast.showToast(
                                    msg: "Failed to submit. Try again.",
                                  );
                                } finally {
                                  setDialogState(() => isLoading = false);
                                }
                              },
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "Contact Us",
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync = ref.watch(getPropertyController(body));
    final propertyDetailsAsync = ref.watch(
      propertyDetailsController(widget.propertyId),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Property Details',
          style: GoogleFonts.inter(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: propertyDetailsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF24ADD7)),
        ),
        error: (e, stack) => Center(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                SizedBox(height: 12.h),
                Text(
                  "Failed to load property details",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24ADD7),
                  ),
                  onPressed: () =>
                      ref.refresh(propertyDetailsController(widget.propertyId)),
                  child: const Text(
                    "Retry",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (response) {
          final prop = response.data;
          if (prop == null) {
            return Center(
              child: Text(
                "Property not found",
                style: GoogleFonts.inter(fontSize: 16.sp),
              ),
            );
          }

          final List<String> photos = prop.uploadedPhotos ?? [];
          final List<String> amenities = prop.amenities ?? [];
          final List<String> furnishingItems = prop.furnishingItems ?? [];
          final List<AroundProject> aroundProjects = prop.aroundProject ?? [];
          final overview = prop.aveneuOverView;

          // Title formatting matching website: [bedRoom BHK] [propertyType] [localityArea]
          final String title = [
            (prop.bedRoom != null && prop.bedRoom!.isNotEmpty)
                ? "${prop.bedRoom} BHK"
                : null,
            prop.propertyType != null ? "${prop.propertyType}" : null,
            prop.localityArea != null ? "${prop.localityArea}" : null,
          ].whereType<String>().join(" ");

          final String locationText = (prop.propertyAddress != null &&
                  prop.propertyAddress!.trim().isNotEmpty)
              ? prop.propertyAddress!
              : "${prop.localityArea ?? ""}, ${prop.city ?? ""}";

          final String pricePerSqFt =
              _calcPricePerSqFt(prop.price, prop.area) ?? "";

          // Contact phone matching website logic
          final String contactPhone =
              (prop.uploadBy?.phone != null && prop.uploadBy!.phone!.isNotEmpty)
                  ? prop.uploadBy!.phone!
                  : "919171719060";

          final bool isVerified = prop.verifyed == true ||
              (prop.isBroker != null &&
                  prop.isBroker!.toLowerCase() == 'yes') ||
              (prop.rera != null &&
                  prop.rera!.trim().isNotEmpty &&
                  prop.rera!.trim().toLowerCase() != 'null');

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================================
                // 1. TOP BREADCRUMB & HEADER CARD (WEBSITE comp_header MIRROR)
                // ==========================================================
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Breadcrumb navigation
                      Row(
                        children: [
                          Text(
                            "Home",
                            style: GoogleFonts.inter(
                              fontSize: 11.5.sp,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 14.sp,
                            color: Colors.grey.shade400,
                          ),
                          Text(
                            "Properties",
                            style: GoogleFonts.inter(
                              fontSize: 11.5.sp,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 14.sp,
                            color: Colors.grey.shade400,
                          ),
                          Expanded(
                            child: Text(
                              prop.localityArea ?? "Property Details",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11.5.sp,
                                color: const Color(0xFF1E293B),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // Title
                      Text(
                        title.isNotEmpty ? title : "Property Details",
                        style: GoogleFonts.inter(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                          letterSpacing: -0.3,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Badges: RERA Verified & Category (For Sale / For Rent)
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 6.h,
                        children: [
                          if (isVerified)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF8F1),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: const Color(0xFF1B9E60).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified,
                                    color: const Color(0xFF1B9E60),
                                    size: 13.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "RERA Verified",
                                    style: GoogleFonts.inter(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1B9E60),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (prop.listingCategory != null &&
                              prop.listingCategory!.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBF7FA),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: const Color(0xFF24ADD7).withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                prop.listingCategory?.toLowerCase() == 'buy'
                                    ? "FOR SALE"
                                    : "FOR RENT",
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF24ADD7),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      // Location text with icon
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: const Color(0xFF24ADD7),
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              locationText,
                              style: GoogleFonts.inter(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4B5563),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // Last updated row
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 13.sp,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            "Last updated: ${_formatDate(prop.updatedAt)}",
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Price Display Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _formatPrice(prop.price),
                            style: GoogleFonts.inter(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF24ADD7),
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (pricePerSqFt.isNotEmpty) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                pricePerSqFt,
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF4B5563),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 14.h),

                      // Action CTA Buttons: WhatsApp & Call Now (Matching website)
                      Row(
                        children: [
                          // WhatsApp Button
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.r),
                              onTap: () async {
                                final msg =
                                    "Hi, I am interested in your property: $title in ${prop.localityArea ?? ''}";
                                final Uri url = Uri.parse(
                                  "whatsapp://send?phone=$contactPhone&text=${Uri.encodeComponent(msg)}",
                                );
                                try {
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } catch (_) {
                                  final Uri webUrl = Uri.parse(
                                    "https://wa.me/$contactPhone?text=${Uri.encodeComponent(msg)}",
                                  );
                                  await launchUrl(
                                    webUrl,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                              child: Container(
                                height: 44.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF25D366),
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF25D366).withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/Svg/whatsapp.svg",
                                      width: 18.w,
                                      height: 18.h,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      "WhatsApp",
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),

                          // Call Now Button
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.r),
                              onTap: () async {
                                final url = Uri.parse("tel:$contactPhone");
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                              child: Container(
                                height: 44.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF24ADD7),
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF24ADD7).withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.call,
                                      color: Colors.white,
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      "Call Now",
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5.sp,
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
                  ),
                ),

                SizedBox(height: 12.h),

                // ==========================================================
                // 2. HERO GALLERY & THUMBNAILS (WEBSITE comp_gallery MIRROR)
                // ==========================================================
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Featured Main Carousel Card
                      GestureDetector(
                        onTap: () {
                          if (photos.isNotEmpty) {
                            _openFullScreenGallery(
                              context,
                              photos,
                              _activeImageIndex,
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18.r),
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: 240.h,
                                  width: double.infinity,
                                  child: PageView.builder(
                                    controller: _pageController,
                                    onPageChanged: (idx) {
                                      setState(() {
                                        _activeImageIndex = idx;
                                      });
                                    },
                                    itemCount:
                                        photos.isEmpty ? 1 : photos.length,
                                    itemBuilder: (context, index) {
                                      final imgUrl = photos.isEmpty
                                          ? 'https://via.placeholder.com/800x500?text=Property'
                                          : photos[index];
                                      return Image.network(
                                        imgUrl,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, progress) {
                                          if (progress == null) return child;
                                          return Container(
                                            color: Colors.grey.shade100,
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(
                                                color: Color(0xFF24ADD7),
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (_, __, ___) =>
                                            Container(
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                              size: 50,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Top-Left: "Cover image" Badge
                                Positioned(
                                  top: 14.h,
                                  left: 14.w,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.55),
                                      borderRadius:
                                          BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      "Cover image",
                                      style: GoogleFonts.inter(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                // Top-Right: Share & Save Action Buttons
                                Positioned(
                                  top: 14.h,
                                  right: 14.w,
                                  child: Row(
                                    children: [
                                      // Share Button
                                      InkWell(
                                        onTap: () {
                                          final slug =
                                              prop.slug ?? prop.id ?? "";
                                          const baseUrl =
                                              "https://propertyleinnovation.com/property";
                                          final finalUrl = slug.startsWith('/')
                                              ? "$baseUrl$slug"
                                              : "$baseUrl/$slug";
                                          Share.share(
                                            "Check out this property: $finalUrl",
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 6.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.12),
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.share_outlined,
                                                color: Colors.black87,
                                                size: 15.sp,
                                              ),
                                              SizedBox(width: 4.w),
                                              Text(
                                                "Share",
                                                style: GoogleFonts.inter(
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),

                                      // Save / Wishlist Button
                                      StatefulBuilder(
                                        builder: (context, setLikeState) {
                                          return InkWell(
                                            onTap: () async {
                                              setLikeState(() {
                                                isLiked = !isLiked;
                                              });

                                              final likeBody =
                                                  LikePropertyBodyModel(
                                                propertyId:
                                                    prop.id?.toString() ?? "",
                                              );

                                              try {
                                                final service =
                                                    APIStateNetwork(
                                                  createDio(),
                                                );
                                                final res = await service
                                                    .likeProperties(likeBody);
                                                if (res.code == 0 ||
                                                    res.error == false) {
                                                  ref.invalidate(
                                                    likePropertyController,
                                                  );
                                                } else {
                                                  setLikeState(() {
                                                    isLiked = !isLiked;
                                                  });
                                                  Fluttertoast.showToast(
                                                    msg: res.message ?? "Error",
                                                  );
                                                }
                                              } catch (e) {
                                                setLikeState(() {
                                                  isLiked = !isLiked;
                                                });
                                                log("Like error: $e");
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10.w,
                                                vertical: 6.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.12),
                                                    blurRadius: 6,
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    isLiked
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: isLiked
                                                        ? Colors.red
                                                        : Colors.black87,
                                                    size: 15.sp,
                                                  ),
                                                  SizedBox(width: 4.w),
                                                  Text(
                                                    isLiked ? "Saved" : "Save",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: isLiked
                                                          ? Colors.red
                                                          : Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                // Bottom-Right: Photo Counter Pill
                                if (photos.isNotEmpty)
                                  Positioned(
                                    bottom: 12.h,
                                    right: 14.w,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.6),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      child: Text(
                                        "${_activeImageIndex + 1} / ${photos.length}",
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10.h),

                      // Indicators
                      Center(
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: photos.isEmpty ? 1 : photos.length,
                          effect: ExpandingDotsEffect(
                            activeDotColor: const Color(0xFF24ADD7),
                            dotColor: Colors.grey.shade300,
                            dotHeight: 5.h,
                            dotWidth: 6.w,
                            expansionFactor: 3,
                            spacing: 4.w,
                          ),
                        ),
                      ),

                      // Horizontal Thumbnail Strip (Matching website's u.slice(1).map)
                      if (photos.length > 1) ...[
                        SizedBox(height: 10.h),
                        SizedBox(
                          height: 64.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: photos.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, idx) {
                              final bool isCurrent = _activeImageIndex == idx;
                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    idx,
                                    duration:
                                        const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Container(
                                  width: 80.w,
                                  margin: EdgeInsets.only(right: 8.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: isCurrent
                                          ? const Color(0xFF24ADD7)
                                          : Colors.transparent,
                                      width: 2.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.r),
                                    child: Image.network(
                                      photos[idx],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 14.h),

                // ==========================================================
                // 3. PROPERTY LOCATION CARD (WEBSITE GRADIENT BAR MIRROR)
                // ==========================================================
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 14.w),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEFF9FC), Color(0xFFF9FAFB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFD9F0F8)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF24ADD7).withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF24ADD7).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.location_on,
                            color: const Color(0xFF24ADD7),
                            size: 24.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "PROPERTY LOCATION",
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF24ADD7),
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              locationText,
                              style: GoogleFonts.inter(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14.h),

                // ==========================================================
                // 4. PRICE ROW CARD (WEBSITE comp_details PRICE MIRROR)
                // ==========================================================
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 14.w),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        prop.listingCategory == 'rent'
                            ? "RENT PRICE"
                            : prop.listingCategory == 'buy'
                                ? "SELL PRICE"
                                : "PROPERTY PRICE",
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        "Price : ${_formatPrice(prop.price)}",
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF24ADD7),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14.h),

                // ==========================================================
                // 5. DEAL DETAILS (KEY DETAILS)
                // ==========================================================
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 14.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        "Deal Details",
                        subtitle: "(Key Details)",
                      ),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 10.h,
                        children: [
                          if (prop.bedRoom != null && prop.bedRoom!.isNotEmpty)
                            _buildKeyDetailChip(
                              icon: Icons.king_bed_outlined,
                              label: "${prop.bedRoom} Bed",
                            ),
                          if (prop.room != null && prop.room!.isNotEmpty)
                            _buildKeyDetailChip(
                              icon: Icons.meeting_room_outlined,
                              label: "${prop.room} Rooms",
                            ),
                          if (prop.guestRoom != null &&
                              prop.guestRoom!.isNotEmpty &&
                              prop.guestRoom!.toLowerCase() != 'none')
                            _buildKeyDetailChip(
                              icon: Icons.person_outline,
                              label: "${prop.guestRoom} Guest Room",
                            ),
                          if (prop.bathrooms != null &&
                              prop.bathrooms!.isNotEmpty)
                            _buildKeyDetailChip(
                              icon: Icons.bathtub_outlined,
                              label: "${prop.bathrooms} Baths",
                            ),
                          if (prop.balcony != null && prop.balcony!.isNotEmpty)
                            _buildKeyDetailChip(
                              icon: Icons.balcony_outlined,
                              label: "${prop.balcony} Balconies",
                            ),
                          if (prop.kitchen != null && prop.kitchen!.isNotEmpty)
                            _buildKeyDetailChip(
                              icon: Icons.kitchen_outlined,
                              label: "${prop.kitchen} Kitchen",
                            ),
                          if (prop.parking != null && prop.parking!.isNotEmpty)
                            _buildKeyDetailChip(
                              icon: Icons.local_parking_outlined,
                              label: "${prop.parking} Parking",
                            ),
                          if (prop.area != null && prop.area!.isNotEmpty)
                            _buildKeyDetailChip(
                              icon: Icons.square_foot_outlined,
                              label: "${prop.area} sqft",
                            ),
                          if (prop.furnishing != null &&
                              prop.furnishing!.isNotEmpty)
                            _buildKeyDetailChip(
                              icon: Icons.chair_outlined,
                              label: prop.furnishing!.toUpperCase(),
                            ),
                          if (prop.securityDeposit != null &&
                              prop.securityDeposit!.isNotEmpty)
                            _buildKeyDetailChip(
                              icon: Icons.account_balance_wallet_outlined,
                              label: "Deposit: ${prop.securityDeposit}",
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ==========================================================
                // 6. PROPERTY SPECIFICATIONS
                // ==========================================================
                if ((prop.propertyType != null && prop.propertyType!.isNotEmpty) ||
                    (prop.localityArea != null && prop.localityArea!.isNotEmpty) ||
                    (prop.city != null && prop.city!.isNotEmpty)) ...[
                  SizedBox(height: 14.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 14.w),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Property Specifications"),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 10.h,
                          children: [
                            if (prop.propertyType != null &&
                                prop.propertyType!.isNotEmpty)
                              _buildKeyDetailChip(
                                icon: Icons.apartment_outlined,
                                label: "Type: ${prop.propertyType}",
                              ),
                            if (prop.listingCategory != null &&
                                prop.listingCategory!.isNotEmpty)
                              _buildKeyDetailChip(
                                icon: Icons.category_outlined,
                                label:
                                    "Category: ${prop.listingCategory == 'buy' ? 'For Sale' : 'For Rent'}",
                              ),
                            if (prop.localityArea != null &&
                                prop.localityArea!.isNotEmpty)
                              _buildKeyDetailChip(
                                icon: Icons.near_me_outlined,
                                label: "Locality: ${prop.localityArea}",
                              ),
                            if (prop.city != null && prop.city!.isNotEmpty)
                              _buildKeyDetailChip(
                                icon: Icons.location_city_outlined,
                                label: "City: ${prop.city}",
                              ),
                            if (prop.rera != null &&
                                prop.rera!.trim().isNotEmpty &&
                                prop.rera!.trim().toLowerCase() != 'null')
                              _buildKeyDetailChip(
                                icon: Icons.verified_outlined,
                                label: "RERA: ${prop.rera}",
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                // ==========================================================
                // 7. FURNISHING ITEMS
                // ==========================================================
                if (furnishingItems.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 14.w),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Furnishing Items"),
                        Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: furnishingItems.map((item) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 20.w,
                                    height: 20.h,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF24ADD7).withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 13.sp,
                                      color: const Color(0xFF24ADD7),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    item,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],

                // ==========================================================
                // 8. PROJECT AMENITIES (WEBSITE comp_amenities MIRROR)
                // ==========================================================
                if (amenities.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 14.w),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Project Amenities"),
                        SizedBox(height: 6.h),
                        Builder(
                          builder: (context) {
                            final visibleCount = _showAllAmenities
                                ? amenities.length
                                : (amenities.length > 11 ? 11 : amenities.length);
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: visibleCount,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 16.h,
                                crossAxisSpacing: 12.w,
                                childAspectRatio: 0.95,
                              ),
                              itemBuilder: (context, index) {
                                final amenity = amenities[index];
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 48.w,
                                      height: 48.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF24ADD7).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(14.r),
                                      ),
                                      child: Icon(
                                        _getAmenityIcon(amenity),
                                        size: 24.sp,
                                        color: const Color(0xFF24ADD7),
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      amenity,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF334155),
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),

                        // "+ X More" / "Show Less" Expand Button (Matching website)
                        if (amenities.length > 11) ...[
                          SizedBox(height: 14.h),
                          Center(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.r),
                              onTap: () {
                                setState(() {
                                  _showAllAmenities = !_showAllAmenities;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDEDFF),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  _showAllAmenities
                                      ? "Show Less"
                                      : "+ ${amenities.length - 11} More Amenities",
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF8A38F5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // ==========================================================
                // 9. AROUND THIS PROJECT (WEBSITE comp_around MIRROR)
                // ==========================================================
                if (aroundProjects.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 14.w),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAEAEA),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Around This Project",
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: aroundProjects.map((item) {
                              return Container(
                                width: 220.w,
                                margin: EdgeInsets.only(right: 12.w),
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(
                                    color: Colors.black.withValues(alpha: 0.1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "assets/Group 25.png",
                                      width: 28.w,
                                      height: 28.h,
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name ?? "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 3.h),
                                          Text(
                                            item.details ?? "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
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
                  ),
                ],

                // ==========================================================
                // 10. AVENUE OVERVIEW (WEBSITE comp_avenue MIRROR)
                // ==========================================================
                if (overview != null &&
                    ((overview.projectArea != null &&
                            overview.projectArea!.isNotEmpty) ||
                        (overview.size != null && overview.size!.isNotEmpty) ||
                        (overview.projectSize != null &&
                            overview.projectSize!.isNotEmpty) ||
                        (overview.launchDate != null &&
                            overview.launchDate!.isNotEmpty) ||
                        (overview.possessionStart != null &&
                            overview.possessionStart!.isNotEmpty))) ...[
                  SizedBox(height: 14.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 14.w),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAEAEA),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Avenue Overview",
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        const Divider(height: 1, color: Colors.black26),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 16.w,
                          runSpacing: 14.h,
                          children: [
                            if (overview.projectArea != null &&
                                overview.projectArea!.isNotEmpty)
                              _overviewItem(
                                "Project Area",
                                overview.projectArea!,
                                "assets/Group 30.png",
                              ),
                            if (overview.size != null &&
                                overview.size!.isNotEmpty)
                              _overviewItem(
                                "Sizes",
                                overview.size!,
                                "assets/turf-size.png",
                              ),
                            if (overview.projectSize != null &&
                                overview.projectSize!.isNotEmpty)
                              _overviewItem(
                                "Project Size",
                                overview.projectSize!,
                                "assets/Vector.png",
                              ),
                            if (overview.launchDate != null &&
                                overview.launchDate!.isNotEmpty)
                              _overviewItem(
                                "Launch Date",
                                overview.launchDate!,
                                "assets/Group 33.png",
                              ),
                            if (overview.possessionStart != null &&
                                overview.possessionStart!.isNotEmpty)
                              _overviewItem(
                                "Possession Starts",
                                overview.possessionStart!,
                                "assets/Vector (1).png",
                              ),
                            if (pricePerSqFt.isNotEmpty)
                              _overviewItem(
                                "Avg. Price",
                                pricePerSqFt,
                                "assets/turf-size.png",
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                // ==========================================================
                // 11. PROPERTY DESCRIPTION
                // ==========================================================
                SizedBox(height: 14.h),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 14.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("Property Description"),
                      Text(
                        _stripHtml(prop.description),
                        maxLines: _isDescExpanded ? null : 4,
                        overflow: _isDescExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF4B5563),
                          height: 1.55,
                        ),
                      ),
                      if ((prop.description ?? "").length > 180) ...[
                        SizedBox(height: 8.h),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isDescExpanded = !_isDescExpanded;
                            });
                          },
                          child: Text(
                            _isDescExpanded ? "Read Less" : "Read More",
                            style: GoogleFonts.inter(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF24ADD7),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ==========================================================
                // 12. IN-PAGE CONTACT CARD (WEBSITE CONTACT FORM MIRROR)
                // ==========================================================
                SizedBox(height: 14.h),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 14.w),
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: const Color(0xFF24ADD7).withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF24ADD7).withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Contact",
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // Seller info row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22.r,
                            backgroundColor: const Color(0xFF24ADD7),
                            child: Text(
                              (prop.uploadBy?.name?.isNotEmpty == true)
                                  ? prop.uploadBy!.name![0].toUpperCase()
                                  : "A",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prop.uploadBy?.name ?? "Admin",
                                  style: GoogleFonts.inter(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  contactPhone,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        "Please share your contact",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Name Input
                      TextField(
                        controller: _contactNameController,
                        decoration: InputDecoration(
                          hintText: "Name",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: Colors.grey.shade400,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(
                              color: Color(0xFF24ADD7),
                              width: 1.5,
                            ),
                          ),
                        ),
                        style: GoogleFonts.inter(fontSize: 13.sp),
                      ),
                      SizedBox(height: 10.h),

                      // Phone Input
                      TextField(
                        controller: _contactPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixText: "+91  ",
                          prefixStyle: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          hintText: "Mobile Number",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: Colors.grey.shade400,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(
                              color: Color(0xFF24ADD7),
                              width: 1.5,
                            ),
                          ),
                        ),
                        style: GoogleFonts.inter(fontSize: 13.sp),
                      ),
                      SizedBox(height: 10.h),

                      // Email Input
                      TextField(
                        controller: _contactEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: Colors.grey.shade400,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(
                              color: Color(0xFF24ADD7),
                              width: 1.5,
                            ),
                          ),
                        ),
                        style: GoogleFonts.inter(fontSize: 13.sp),
                      ),
                      SizedBox(height: 8.h),

                      // Checkboxes: "I agree to be contacted" & "I am interested in Home Loans"
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToContact,
                            activeColor: const Color(0xFF24ADD7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _agreeToContact = val ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              "I agree to be contacted",
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _interestedHomeLoan,
                            activeColor: const Color(0xFF24ADD7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _interestedHomeLoan = val ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              "I am interested in Home Loans",
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 46.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF24ADD7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _isSubmittingContact
                              ? null
                              : () => _submitInPageContact(
                                    prop.id?.toString() ?? "",
                                  ),
                          child: _isSubmittingContact
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  "Contact Us",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ==========================================================
                // 13. SIMILAR PROPERTIES / EXPLORE OTHER PROPERTIES
                // ==========================================================
                SizedBox(height: 22.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: _buildSectionHeader("Similar Properties"),
                ),

                propertyAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        color: Color(0xFF24ADD7),
                      ),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text("Error: $e"),
                    ),
                  ),
                  data: (res) {
                    final list = res.data?.list ?? [];
                    if (list.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("No properties found"),
                        ),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      itemCount: list.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 0.60,
                      ),
                      itemBuilder: (context, index) {
                        return PropertyCard(property: list[index]);
                      },
                    );
                  },
                ),

                SizedBox(height: 12.h),
                paginationBar(),
                SizedBox(height: 40.h),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Widget for Avenue Overview Items ---
  Widget _overviewItem(String title, String value, String assetPath) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(assetPath, width: 22.w, height: 22.h),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFFFF6725),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Section Header with Gradient Bar ---
  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 18.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF24ADD7), Color(0xFF1A85A6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1F2937),
              letterSpacing: 0.5,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(width: 6.w),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- Key Detail Chip ---
  Widget _buildKeyDetailChip({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: const Color(0xFF24ADD7).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 16.sp, color: const Color(0xFF24ADD7)),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  // --- Pagination Bar ---
  Widget paginationBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: currentPage > 1
                  ? const Color(0xFF24ADD7)
                  : Colors.grey[300],
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: currentPage > 1
                ? () {
                    setState(() {
                      currentPage--;
                      body = PropertyListBodyModel(
                        size: 6,
                        pageNo: currentPage,
                        sortBy: 'createdAt',
                        sortOrder: 'desc',
                      );
                    });
                  }
                : null,
            child: const Text("PREV"),
          ),
          SizedBox(width: 12.w),
          Text(
            "Page $currentPage",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(width: 12.w),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF24ADD7),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              setState(() {
                currentPage++;
                body = PropertyListBodyModel(
                  size: 6,
                  pageNo: currentPage,
                  sortBy: 'createdAt',
                  sortOrder: 'desc',
                );
              });
            },
            child: const Text("NEXT"),
          ),
        ],
      ),
    );
  }
}

// --- Property Card for Similar Properties ---
class PropertyCard extends StatelessWidget {
  final ListElement property;
  const PropertyCard({super.key, required this.property});

  String _formatPrice(String? priceStr) {
    if (priceStr == null || priceStr.isEmpty) return '—';
    final price = double.tryParse(priceStr) ?? 0;
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(2)} Cr';
    }
    if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(1)} Lac';
    }
    return price.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        (property.uploadedPhotos != null && property.uploadedPhotos!.isNotEmpty)
            ? property.uploadedPhotos!.first
            : "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PerticulerPropertyPage(
              propertyId: property.slug ?? property.id ?? "",
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
              child: Image.network(
                imageUrl,
                height: 110.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.network(
                  "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800",
                  height: 110.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.propertyType?.toLowerCase() == 'land'
                              ? "${property.propertyType ?? ""}"
                              : "${property.bedRoom ?? ""} BHK ${property.propertyType ?? ""}",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "${property.localityArea ?? ""}, ${property.city ?? ""}",
                          style: GoogleFonts.inter(
                            fontSize: 8.sp,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "₹ ${_formatPrice(property.price)}",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF24ADD7),
                      fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.w),
              child: Row(
                children: [
                  Text(
                    "Listed by Owner",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 10.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                children: [
                  if (property.bedRoom != null && property.bedRoom!.isNotEmpty)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: const Color(0xff8A38F5),
                        ),
                        height: 25.h,
                        child: Center(
                          child: Text(
                            '${property.bedRoom} BHK',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 8.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (property.bedRoom != null && property.bedRoom!.isNotEmpty)
                    SizedBox(width: 8.w),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: const Color(0xff8A38F5),
                      ),
                      height: 25.h,
                      child: Center(
                        child: Text(
                          '${property.propertyType ?? ""}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 8.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PerticulerPropertyPage(
                              propertyId: property.slug ?? property.id ?? "",
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 30.h,
                        child: Center(
                          child: Text(
                            "View",
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 8.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PerticulerPropertyPage(
                              propertyId: property.slug ?? property.id ?? "",
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFF24ADD7),
                        ),
                        height: 30.h,
                        child: Center(
                          child: Text(
                            "Contact",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 8.sp,
                            ),
                          ),
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
    );
  }
}
