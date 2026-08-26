import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realstate/Controller/myRequestBookingSerivceController.dart';
import 'package:realstate/Model/Body/serviceRatingBodyModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';

class RatingPage extends ConsumerStatefulWidget {
  final dynamic item; // Pass the booking item

  const RatingPage({Key? key, required this.item}) : super(key: key);

  @override
  ConsumerState<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends ConsumerState<RatingPage> {
  int rating = 0;
  String reviewText = "";
  File? problemSolvePhoto;
  bool showImage = false;
  String? existingImage;

  void showImagePicker() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        problemSolvePhoto = File(image.path);
        showImage = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Rate Your Experience",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16.sp,
          ),
        ),
        backgroundColor: Color(0xFF24ADD7),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.green.shade100, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.rate_review_rounded,
                    color: Colors.green.shade600,
                    size: 22.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "Rate Your Experience",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        setState(() {
                          rating = index + 1;
                        });
                      },
                      child: Icon(
                        index < rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: index < rating
                            ? Colors.amber.shade500
                            : Colors.grey.shade300,
                        size: 40.sp,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: TextEditingController(text: reviewText)
                  ..selection = TextSelection.collapsed(
                    offset: reviewText.length,
                  ),
                maxLines: 4,
                onChanged: (val) {
                  reviewText = val;
                },
                decoration: InputDecoration(
                  hintText: "Tell us about your experience...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13.sp,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: EdgeInsets.all(16.w),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(color: Colors.green.shade300),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Upload Problem Resolution Photo (Optional)",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 12.h),
              Center(
                child: Container(
                  width: double.infinity,
                  height: 160.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: showImage
                          ? Colors.green.shade200
                          : Colors.grey.shade200,
                      width: showImage ? 2 : 1,
                    ),
                    image: showImage && problemSolvePhoto != null
                        ? DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(problemSolvePhoto!),
                          )
                        : null,
                  ),
                  child: !showImage
                      ? InkWell(
                          borderRadius: BorderRadius.circular(16.r),
                          onTap: () => showImagePicker(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 28.sp,
                                  color: Colors.green.shade600,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                "Tap to upload photo",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (rating == 0) {
                      Fluttertoast.showToast(msg: "Please give rating");
                      return;
                    }

                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(color: Colors.green),
                      ),
                    );

                    final service = APIStateNetwork(createDio());
                    if (problemSolvePhoto != null) {
                      final imgResponse = await service.uploadImage(
                        problemSolvePhoto!,
                      );
                      if (imgResponse.code == 0 && imgResponse.error == false) {
                        existingImage = imgResponse.data!.imageUrl.toString();
                      } else {
                        Fluttertoast.showToast(
                          msg: "Image upload failed, trying again.",
                        );
                        Navigator.pop(context); // hide loading
                        return;
                      }
                    }

                    final body = ServiceRatingBodyModel(
                      serviceBooking: widget.item.id,
                      rating: rating,
                      review: reviewText,
                      image: existingImage,
                    );

                    try {
                      final response = await service.createServiceRating(body);

                      if (response.code == 0 && response.error == false) {
                        Fluttertoast.showToast(
                          msg: response.message ?? "Success",
                          backgroundColor: Colors.green,
                        );
                        ref.invalidate(myRequestBookingServiceContorller);
                        Navigator.pop(context);
                        Navigator.pop(
                          context,
                        ); // Navigate back to myRequest page
                      } else {
                        Fluttertoast.showToast(
                          msg: response.message ?? "Error",
                        );
                      }
                    } catch (e, st) {
                      Navigator.pop(context); // hide loading
                      log(st.toString());
                      log(e.toString());
                      Fluttertoast.showToast(msg: "Rating failed $e");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    "Submit Review",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
