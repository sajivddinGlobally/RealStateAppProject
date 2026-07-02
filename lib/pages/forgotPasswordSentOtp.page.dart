import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:realstate/Model/Body/forgotPassSentOtpBodyModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:realstate/pages/OTPVerify.page.dart';
import 'package:realstate/pages/verifyOrResectPassword.page.dart';

class ForgotPasswordSentOtpPage extends StatefulWidget {
  const ForgotPasswordSentOtpPage({super.key});

  @override
  State<ForgotPasswordSentOtpPage> createState() =>
      _ForgotPasswordSentOtpPageState();
}

class _ForgotPasswordSentOtpPageState extends State<ForgotPasswordSentOtpPage> {
  bool isLoading = false;
  final phoneController = TextEditingController();

  Future<void> forgotPassword() async {
    if (phoneController.text.trim().isEmpty) {
      return;
    }
    final body = ForgotPassSentOtpBodyModel(phone: phoneController.text.trim());
    setState(() {
      isLoading = true;
    });
    try {
      final service = APIStateNetwork(createDio());
      final res = await service.forgotPassSentOTP(body);
      if (res.code == 0 && res.error == false) {
        Fluttertoast.showToast(msg: res.message ?? "");
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) =>
                VerifyOrResectPasswordPage(token: res.data!.token.toString()),
          ),
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     backgroundColor: Colors.white,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(20.r),
        //     ),
        //     behavior: SnackBarBehavior.floating,
        //     margin: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),

        //     content: Text(
        //       "OTP: ${res.data!.otp}",
        //       style: TextStyle(color: Colors.black),
        //     ),
        //     duration: const Duration(seconds: 16),
        //   ),
        // );
        ScaffoldMessenger.of(context).clearMaterialBanners();
        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            backgroundColor: Colors.white,
            content: Text(
              "OTP: ${res.data!.otp}",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                },
                child: const Text("Close"),
              ),
            ],
          ),
        );
        Future.delayed(const Duration(seconds: 12), () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          }
        });
      } else {
        Fluttertoast.showToast(msg: res.message ?? "");
      }
    } catch (e, st) {
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
        backgroundColor: const Color(0xffF6F7FB),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Center(
                child: Container(
                  height: 120.h,
                  width: 120.w,
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/png/real_logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              Container(
                padding: EdgeInsets.all(22.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mobile Number",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      height: 58.h,
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Text("+91", style: TextStyle(fontSize: 16.sp)),

                          SizedBox(width: 10.w),
                          Expanded(
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              style: TextStyle(fontSize: 15.sp),
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: "Enter Mobile Number",
                                hintStyle: TextStyle(fontSize: 14.sp),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    GestureDetector(
                      onTap: isLoading ? null : forgotPassword,
                      child: Container(
                        height: 50.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isLoading
                              ? Colors.grey
                              : const Color(0xFF24ADD7),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Center(
                          child: Text(
                            "Sent OTP",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
