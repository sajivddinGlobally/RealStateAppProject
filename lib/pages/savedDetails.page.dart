import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:realstate/Controller/getMyPropertyController.dart';
import 'package:realstate/Model/getLikeProperyResModel.dart';
import 'package:realstate/Model/saveContactInPropertyBodyModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SavedDetailsPage extends StatefulWidget {
  final Datum savedData;
  const SavedDetailsPage({super.key, required this.savedData});

  @override
  State<SavedDetailsPage> createState() => _SavedDetailsPageState();
}

class _SavedDetailsPageState extends State<SavedDetailsPage> {
  final PageController _pageController = PageController();

  void showContactBottomSheet(
    BuildContext context,
    WidgetRef ref,
    dynamic propertyData,
  ) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    String? nameError;
    String? emailError;
    String? phoneError;
    bool agreeToContact = false;
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
                    Text(
                      "Contact Details",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 25.h),
                    TextField(
                      controller: nameController,
                      onChanged: (v) => setDialogState(() => nameError = null),
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        errorText: nameError,
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) => setDialogState(() => emailError = null),
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        errorText: emailError,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      onChanged: (v) => setDialogState(() => phoneError = null),
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        errorText: phoneError,
                        counterText: "",
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          color: primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "I agree to be contacted (Required)",
                        style: TextStyle(
                          color: agreeToContact == "Please check the agreement"
                              ? Colors.red
                              : Colors.black87,
                          fontSize: 14.sp,
                        ),
                      ),
                      value: agreeToContact,
                      activeColor: primaryColor,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) {
                        setDialogState(() {
                          agreeToContact = val ?? false;
                          if (agreeToContact) nameError = null;
                        });
                      },
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Interested in Home Loan (Optional)",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14.sp,
                        ),
                      ),
                      value: interestedHomeLoan,
                      activeColor: primaryColor,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) => setDialogState(
                        () => interestedHomeLoan = val ?? false,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      height: 55.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                bool isValid = true;
                                setDialogState(() {
                                  if (nameController.text.trim().isEmpty) {
                                    nameError = "Name is required";
                                    isValid = false;
                                  }
                                  if (emailController.text.trim().isEmpty) {
                                    emailError = "Email is required";
                                    isValid = false;
                                  } else if (!emailController.text.contains(
                                    "@",
                                  )) {
                                    emailError = "Enter a valid email";
                                    isValid = false;
                                  }
                                  if (phoneController.text.trim().length < 10) {
                                    phoneError = "Enter 10 digit phone number";
                                    isValid = false;
                                  }
                                  if (!agreeToContact) {
                                    nameError = "Please check the agreement";
                                    isValid = false;
                                  }
                                });

                                if (!isValid) return;

                                setDialogState(() => isLoading = true);
                                try {
                                  final body = SaveContactInPropertyBodyModel(
                                    email: emailController.text,
                                    name: nameController.text,
                                    phone: phoneController.text,
                                    propertyId: widget.savedData.propertyId!.id
                                        .toString(),
                                    interested: interestedHomeLoan,
                                  );
                                  final service = APIStateNetwork(createDio());
                                  final response = await service
                                      .saveContactInProperty(body);

                                  if (response.code == 0 ||
                                      response.error == false) {
                                    Fluttertoast.showToast(
                                      msg: response.message ?? "Success",
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
                                  log("Error: $e");
                                } finally {
                                  setDialogState(() => isLoading = false);
                                }
                              },
                        child: isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "SUBMIT",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
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

  bool _hasOverviewData(AveneuOverView overview) {
    return (overview.projectArea != null && overview.projectArea!.isNotEmpty) ||
        (overview.size != null && overview.size.toString().isNotEmpty) ||
        (overview.projectSize != null &&
            overview.projectSize.toString().isNotEmpty) ||
        (overview.launchDate != null && overview.launchDate!.isNotEmpty) ||
        (overview.possessionStart != null &&
            overview.possessionStart!.isNotEmpty);
  }

  bool _hasOtherInfo(PropertyId data) {
    return (data.rera != null && data.rera!.isNotEmpty) ||
        (data.permitNo != null && data.permitNo!.isNotEmpty) ||
        (data.ded != null && data.ded!.isNotEmpty) ||
        (data.brn != null && data.brn!.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF24ADD7);
    final data = widget.savedData.propertyId;

    if (data == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
        ),
        body: const Center(child: Text("Property Details Not Found")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // 1. Image Header with Back Button
          SliverAppBar(
            expandedHeight: 320.h,
            pinned: true,
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount:
                        (data.uploadedPhotos == null ||
                            data.uploadedPhotos!.isEmpty)
                        ? 1
                        : data.uploadedPhotos!.length,
                    itemBuilder: (context, index) {
                      final url =
                          (data.uploadedPhotos == null ||
                              data.uploadedPhotos!.isEmpty)
                          ? 'https://via.placeholder.com/600x400'
                          : data.uploadedPhotos![index];
                      return Image.network(
                        url,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                                strokeWidth: 2.w,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (data.uploadedPhotos != null &&
                      data.uploadedPhotos!.length > 1)
                    Positioned(
                      bottom: 20.h,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: data.uploadedPhotos!.length,
                            effect: ExpandingDotsEffect(
                              activeDotColor: Colors.white,
                              dotColor: Colors.white54,
                              dotHeight: 6,
                              dotWidth: 6,
                              expansionFactor: 3,
                              spacing: 6,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // 2. Content Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data.price != null && data.price!.isNotEmpty)
                              Text(
                                "₹${data.price}",
                                style: TextStyle(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w900,
                                  color: primaryColor,
                                ),
                              ),
                            if (data.propertyType != null &&
                                data.propertyType!.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 6.h),
                                child: Text(
                                  "${data.propertyType?.toUpperCase() ?? ''}${data.property != null && data.property!.isNotEmpty ? ' - ${data.property?.toUpperCase()}' : ''}",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (data.listingCategory != null &&
                          data.listingCategory!.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            data.listingCategory!.toUpperCase(),
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Location
                  if ((data.propertyAddress != null &&
                          data.propertyAddress!.isNotEmpty) ||
                      (data.localityArea != null &&
                          data.localityArea!.isNotEmpty) ||
                      (data.city != null && data.city!.isNotEmpty))
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18.sp,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            [
                              if (data.propertyAddress != null &&
                                  data.propertyAddress!.isNotEmpty)
                                data.propertyAddress,
                              if (data.localityArea != null &&
                                  data.localityArea!.isNotEmpty)
                                data.localityArea,
                              if (data.city != null && data.city!.isNotEmpty)
                                data.city,
                            ].join(', '),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14.sp,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: 20.h),
                  const Divider(color: Colors.black12),
                  SizedBox(height: 20.h),

                  // Quick Info (Icons Row)
                  if ((data.bedRoom != null && data.bedRoom!.isNotEmpty) ||
                      (data.bathrooms != null && data.bathrooms!.isNotEmpty) ||
                      (data.kitchen != null && data.kitchen!.isNotEmpty) ||
                      (data.balcony != null && data.balcony!.isNotEmpty) ||
                      (data.parking != null && data.parking!.isNotEmpty) ||
                      (data.area != null && data.area!.isNotEmpty) ||
                      (data.furnishing != null && data.furnishing!.isNotEmpty))
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: [
                          if (data.bedRoom != null && data.bedRoom!.isNotEmpty)
                            _buildQuickInfoCard(
                              Icons.king_bed_outlined,
                              "Beds",
                              data.bedRoom!,
                            ),
                          if (data.bathrooms != null &&
                              data.bathrooms!.isNotEmpty)
                            _buildQuickInfoCard(
                              Icons.bathtub_outlined,
                              "Baths",
                              data.bathrooms!,
                            ),
                          if (data.kitchen != null && data.kitchen!.isNotEmpty)
                            _buildQuickInfoCard(
                              Icons.soup_kitchen_outlined,
                              "Kitchen",
                              data.kitchen!,
                            ),
                          if (data.balcony != null && data.balcony!.isNotEmpty)
                            _buildQuickInfoCard(
                              Icons.balcony_outlined,
                              "Balcony",
                              data.balcony!,
                            ),
                          if (data.parking != null && data.parking!.isNotEmpty)
                            _buildQuickInfoCard(
                              Icons.local_parking_outlined,
                              "Parking",
                              data.parking!,
                            ),
                          if (data.area != null && data.area!.isNotEmpty)
                            _buildQuickInfoCard(
                              Icons.square_foot,
                              "Area",
                              "${data.area} sqft",
                            ),
                          if (data.furnishing != null &&
                              data.furnishing!.isNotEmpty)
                            _buildQuickInfoCard(
                              Icons.chair_outlined,
                              "Furnishing",
                              data.furnishing!,
                            ),
                        ],
                      ),
                    ),

                  // Project Overview
                  if (data.aveneuOverView != null &&
                      _hasOverviewData(data.aveneuOverView!)) ...[
                    const Divider(color: Colors.black12),
                    SizedBox(height: 20.h),
                    _buildSectionTitle("Project Overview"),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        children: [
                          if (data.aveneuOverView!.projectArea != null &&
                              data.aveneuOverView!.projectArea!.isNotEmpty)
                            _buildDetailRow(
                              "Project Area",
                              data.aveneuOverView!.projectArea!,
                            ),
                          if (data.aveneuOverView!.size != null &&
                              data.aveneuOverView!.size.toString().isNotEmpty)
                            _buildDetailRow(
                              "Size",
                              data.aveneuOverView!.size.toString(),
                            ),
                          if (data.aveneuOverView!.projectSize != null &&
                              data.aveneuOverView!.projectSize
                                  .toString()
                                  .isNotEmpty)
                            _buildDetailRow(
                              "Project Size",
                              data.aveneuOverView!.projectSize.toString(),
                            ),
                          if (data.aveneuOverView!.launchDate != null &&
                              data.aveneuOverView!.launchDate!.isNotEmpty)
                            _buildDetailRow(
                              "Launch Date",
                              data.aveneuOverView!.launchDate!,
                            ),
                          if (data.aveneuOverView!.possessionStart != null &&
                              data.aveneuOverView!.possessionStart!.isNotEmpty)
                            _buildDetailRow(
                              "Possession Start",
                              data.aveneuOverView!.possessionStart!,
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],

                  // Credentials
                  if (_hasOtherInfo(data)) ...[
                    const Divider(color: Colors.black12),
                    SizedBox(height: 20.h),
                    _buildSectionTitle("Property Credentials"),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        children: [
                          if (data.rera != null && data.rera!.isNotEmpty)
                            _buildDetailRow("RERA", data.rera!),
                          if (data.permitNo != null &&
                              data.permitNo!.isNotEmpty)
                            _buildDetailRow("Permit No.", data.permitNo!),
                          if (data.ded != null && data.ded!.isNotEmpty)
                            _buildDetailRow("DED", data.ded!),
                          if (data.brn != null && data.brn!.isNotEmpty)
                            _buildDetailRow("BRN", data.brn!),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],

                  // Amenities
                  if (data.amenities != null && data.amenities!.isNotEmpty) ...[
                    const Divider(color: Colors.black12),
                    SizedBox(height: 20.h),
                    _buildSectionTitle("Amenities"),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 10.h,
                      children: data.amenities!.map((amenity) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: primaryColor,
                                size: 16.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                amenity,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10.h),
                  ],
                  // Furnishing Items
                  if (data.furnishingItems != null &&
                      data.furnishingItems!.isNotEmpty) ...[
                    const Divider(color: Colors.black12),
                    SizedBox(height: 20.h),
                    _buildSectionTitle("Furnishing Items"),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 10.h,
                      children: data.furnishingItems!.map((item) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chair_alt,
                                color: primaryColor,
                                size: 16.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                item,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10.h),
                  ],
                  // Around Project
                  if (data.aroundProject != null &&
                      data.aroundProject!.isNotEmpty) ...[
                    const Divider(color: Colors.black12),
                    SizedBox(height: 20.h),
                    _buildSectionTitle("Around Project"),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        children: data.aroundProject!.map((around) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: data.aroundProject!.last == around
                                  ? 0
                                  : 12.h,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.place,
                                  color: primaryColor,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (around.name != null &&
                                          around.name!.isNotEmpty)
                                        Text(
                                          around.name!,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      if (around.details != null &&
                                          around.details!.isNotEmpty) ...[
                                        SizedBox(height: 4.h),
                                        Text(
                                          around.details!,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                  // Description
                  if (data.description != null &&
                      data.description!.trim().isNotEmpty) ...[
                    const Divider(color: Colors.black12),
                    SizedBox(height: 20.h),
                    _buildSectionTitle("Description"),
                    SizedBox(height: 12.h),
                    Text(
                      data.description!
                          .replaceAll(RegExp(r'<[^>]*>'), '')
                          .replaceAll('&nbsp;', ' ')
                          .trim(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],

                  // Owner Details
                  if (data.fullName != null &&
                      data.fullName!.trim().isNotEmpty) ...[
                    const Divider(color: Colors.black12),
                    SizedBox(height: 20.h),
                    _buildSectionTitle("Contact Person"),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(color: Colors.black12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25.r,
                            backgroundColor: primaryColor.withOpacity(0.15),
                            child: Text(
                              data.fullName!.trim()[0].toUpperCase(),
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 15.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.fullName!,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "Property Owner",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Action Button
      bottomSheet: Consumer(
        builder: (context, ref, child) {
          return Container(
            padding: EdgeInsets.all(20.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: Size(double.infinity, 55.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ),
              onPressed: () {
                showContactBottomSheet(context, ref, widget.savedData);
              },
              child: Text(
                "Contact Now",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCard(IconData icon, String label, String value) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF24ADD7), size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 11.sp),
          ),
        ],
      ),
    );
  }
}
