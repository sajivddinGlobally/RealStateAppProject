import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:realstate/Model/Body/resetPassBodyMOdel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:realstate/pages/OTPVerify.page.dart';
import 'package:realstate/pages/login.page.dart';

class VerifyOrResectPasswordPage extends StatefulWidget {
  final String token;
  const VerifyOrResectPasswordPage({super.key, required this.token});

  @override
  State<VerifyOrResectPasswordPage> createState() =>
      _VerifyOrResectPasswordPageState();
}

class _VerifyOrResectPasswordPageState
    extends State<VerifyOrResectPasswordPage> {
  bool isLoading = false;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> verifyOrResetPassword() async {
    if (otpController.text.trim().isEmpty) {
      return;
    }
    if (newPasswordController.text.trim().isEmpty) {
      return;
    }
    if (confirmPasswordController.text.trim().isEmpty) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    final body = ResetPassBodyModel(
      otp: otpController.text.trim(),
      newPassword: newPasswordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
      token: widget.token,
    );
    try {
      final service = APIStateNetwork(createDio());
      final res = await service.resetPassword(body);
      if (res.code == 0 && res.error == false) {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => LoginPage()),
        );
        Fluttertoast.showToast(msg: res.message ?? "");
      } else {
        otpController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 25.h),
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
                SizedBox(height: 35.h),
                Text(
                  "Verify OTP & Reset Password",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Enter OTP and create a new password",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                ),
                SizedBox(height: 28.h),
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
                      /// OTP
                      Text(
                        "OTP",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: otpController,
                        autoDisposeControllers: false,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        cursorColor: const Color(0xFF24ADD7),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10.r),
                          fieldHeight: 45.h,
                          fieldWidth: 45.w,
                          activeFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          selectedFillColor: Colors.white,
                          activeColor: const Color(0xFF24ADD7),
                          selectedColor: const Color(0xFF24ADD7),
                          inactiveColor: Colors.grey.shade300,
                        ),
                        enableActiveFill: true,
                        onChanged: (value) {},
                      ),
                      Align(
                        alignment: AlignmentGeometry.centerRight,
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            "Resend OTP",
                            style: TextStyle(
                              color: const Color(0xFF24ADD7),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        "New Password",
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
                            Icon(
                              Icons.lock_outline,
                              color: Colors.grey,
                              size: 20.sp,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: TextField(
                                style: TextStyle(fontSize: 15.sp),
                                controller: newPasswordController,
                                obscureText: obscureNewPassword,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Enter New Password",
                                  hintStyle: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  obscureNewPassword = !obscureNewPassword;
                                });
                              },
                              child: Icon(
                                obscureNewPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 18.h),
                      Text(
                        "Confirm Password",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 10.h),
                      Container(
                        height: 58,
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: Colors.grey,
                              size: 20.sp,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: TextField(
                                style: TextStyle(fontSize: 15.sp),
                                controller: confirmPasswordController,
                                obscureText: obscureConfirmPassword,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Confirm Password",
                                  hintStyle: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                              child: Icon(
                                obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30.h),

                      GestureDetector(
                        onTap: isLoading ? null : verifyOrResetPassword,
                        child: Container(
                          height: 52.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isLoading
                                ? Colors.grey
                                : const Color(0xFF24ADD7),
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Center(
                            child: Text(
                              "Reset Password",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10.h),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
