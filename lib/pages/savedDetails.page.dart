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
  final Datum savedData; // Saved API ka pura object pass karein
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
    bool interestedHomeLoan = false; // Ye optional rahega
    bool isLoading = false;
    const primaryColor = Color(0xffFF6A2A);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 45,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Contact Details",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // --- NAME FIELD ---
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
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // --- EMAIL FIELD ---
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
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // --- PHONE FIELD ---
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
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // --- REQUIRED CHECKBOX ---
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "I agree to be contacted (Required)",
                        style: TextStyle(
                          // Agar user bhool jaye toh text red ho jayega
                          color: agreeToContact == "Please check the agreement"
                              ? Colors.red
                              : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      value: agreeToContact,
                      activeColor: primaryColor,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) {
                        setDialogState(() {
                          agreeToContact = val ?? false;
                          if (agreeToContact)
                            nameError = null; // Clear error if checked
                        });
                      },
                    ),

                    // --- OPTIONAL CHECKBOX (Home Loan) ---
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "Interested in Home Loan (Optional)",
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                      value: interestedHomeLoan,
                      activeColor: primaryColor,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) => setDialogState(
                        () => interestedHomeLoan = val ?? false,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- SUBMIT BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                bool isValid = true;
                                setDialogState(() {
                                  // 1. Name Validation
                                  if (nameController.text.trim().isEmpty) {
                                    nameError = "Name is required";
                                    isValid = false;
                                  }
                                  // 2. Email Validation
                                  if (emailController.text.trim().isEmpty) {
                                    emailError = "Email is required";
                                    isValid = false;
                                  } else if (!emailController.text.contains(
                                    "@",
                                  )) {
                                    emailError = "Enter a valid email";
                                    isValid = false;
                                  }
                                  // 3. Phone Validation
                                  if (phoneController.text.trim().length < 10) {
                                    phoneError = "Enter 10 digit phone number";
                                    isValid = false;
                                  }
                                  // 4. Checkbox Validation (Important!)
                                  if (!agreeToContact) {
                                    // Hum nameError variable ka use karke alert de sakte hain ya toast dikha sakte hain
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
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "SUBMIT",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
    const primaryColor = Color(0xffFF6A2A);
    final data = widget.savedData.propertyId;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. Image Header with Back Button
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: data!.uploadedPhotos!.isEmpty
                        ? 1
                        : data.uploadedPhotos!.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        data.uploadedPhotos!.isEmpty
                            ? 'https://via.placeholder.com/600x400'
                            : data.uploadedPhotos![index],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                                strokeWidth: 1.w,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(Icons.image, size: 60),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10.h),
              alignment: Alignment.center,
              child: SmoothPageIndicator(
                controller: _pageController,
                count: data.uploadedPhotos!.isEmpty
                    ? 1
                    : data.uploadedPhotos!.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: primaryColor,
                  dotColor: Colors.grey,
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                  spacing: 6,
                ),
              ),
            ),
          ),

          // 2. Content Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${data.propertyType} in ${data.city}",
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16.sp,
                                  color: primaryColor,
                                ),
                                Text(
                                  data.propertyAddress ?? "",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "₹${data.price}",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 40),

                  // 3. Quick Info (Icons Row)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoIcon(
                        Icons.king_bed_outlined,
                        "Beds",
                        "N/A",
                      ), // Agar data ho toh dikhaye
                      _buildInfoIcon(
                        Icons.bathtub_outlined,
                        "Baths",
                        data.bathrooms ?? "",
                      ),
                      _buildInfoIcon(
                        Icons.square_foot,
                        "Area",
                        "${data.area} sqft",
                      ),
                      _buildInfoIcon(
                        Icons.category_outlined,
                        "Type",
                        data.listingCategory ?? "",
                      ),
                    ],
                  ),

                  const Divider(height: 40),

                  // 4. Description
                  Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    // HTML tags remove karne ke liye regex use kar sakte hain
                    data.description!.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ""),
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),

                  const Divider(height: 40),

                  // 5. Owner/Contact Details Section
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25.r,
                          backgroundColor: primaryColor,
                          child: Text(
                            data.fullName?[0].toUpperCase() ?? "",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 15.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.fullName ?? "N/A",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Property Owner",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed:
                              () {}, // WhatsApp integration yaha kar sakte hain
                          icon: const Icon(Icons.message, color: primaryColor),
                        ),
                        IconButton(
                          onPressed: () {}, // Call integration
                          icon: const Icon(Icons.phone, color: primaryColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 100.h), // Bottom space for button
                ],
              ),
            ),
          ),
        ],
      ),

      // 6. Bottom Action Button
      bottomSheet: Consumer(
        builder: (context, ref, child) {
          return Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
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
              child: const Text(
                "Contact",
                style: TextStyle(
                  fontSize: 16,
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

  Widget _buildInfoIcon(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[800], size: 28.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
        ),
      ],
    );
  }
}
