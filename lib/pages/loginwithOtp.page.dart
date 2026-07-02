import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:realstate/Model/loginWithPhoneBodyModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:realstate/pages/OTPVerify.page.dart';
import 'package:realstate/pages/login.page.dart';
import 'package:realstate/pages/register.page.dart';

class LoginPageWithOtp extends StatefulWidget {
  const LoginPageWithOtp({super.key});

  @override
  State<LoginPageWithOtp> createState() => _LoginPageWithOtpState();
}

class _LoginPageWithOtpState extends State<LoginPageWithOtp> {
  bool isLoading = false;
  bool isChecked = true;
  final phoneController = TextEditingController();

  Future<void> loginWithPhone() async {
    if (phoneController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please Enter Register Mobile Number");
      return;
    }

    if (!isChecked) {
      Fluttertoast.showToast(msg: "Please accept Terms & Privacy Policy");
      return;
    }

    setState(() => isLoading = true);

    // final body = LoginWithPhoneResisterBodyModel(phone: phoneController.text);
    final body = LoginWithPhoneBodyModel(phone: phoneController.text);

    try {
      final service = APIStateNetwork(createDio());
      // final response = await service.LoginRegister(body);
      final response = await service.loginUser(body);

      if (response.code == 0 || response.error == false) {
        Fluttertoast.showToast(msg: response.message ?? "");

        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => OtpVerifyPage(
              token: response.data!.token ?? "",
              phone: phoneController.text,
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Error");
      }
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLoader(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xffF6F7FB),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 60.h),
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

                        SizedBox(height: 25.h),

                        Text(
                          // "Login or Signup",
                          "Login",
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff0E1A35),
                          ),
                        ),
                        SizedBox(height: 20.h),
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
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "+91",
                                      style: TextStyle(fontSize: 16.sp),
                                    ),

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

                              SizedBox(height: 15.h),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 24.w,
                                    height: 24.h,
                                    child: Checkbox(
                                      value: isChecked,
                                      activeColor: const Color(0xFF24ADD7),
                                      onChanged: (v) {
                                        setState(() {
                                          isChecked = v ?? false;
                                        });
                                      },
                                    ),
                                  ),

                                  SizedBox(width: 10.w),

                                  Expanded(
                                    child: Text(
                                      "By continuing, I agree to Terms of Use & Privacy Policy",
                                      style: TextStyle(fontSize: 12.sp),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20.h),

                              GestureDetector(
                                onTap: isLoading ? null : loginWithPhone,
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

                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => LoginPage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.h,
                                      horizontal: 20.w,
                                    ),
                                    // decoration: BoxDecoration(
                                    //   borderRadius: BorderRadius.circular(15.r),
                                    //   border: Border.all(
                                    //     color: Colors.grey.shade300,
                                    //   ),
                                    // ),
                                    child: RichText(
                                      text: TextSpan(
                                        text: "Login",
                                        style: TextStyle(
                                          color: Color(0xFF24ADD7),
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: " with password",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Color(0xff0E1A35),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // SizedBox(height: 16.h),
                              // Row(
                              //   children: [
                              //     Expanded(
                              //       child: Divider(color: Colors.grey.shade300),
                              //     ),
                              //     Padding(
                              //       padding: EdgeInsets.symmetric(
                              //         horizontal: 10.w,
                              //       ),
                              //       child: Text(
                              //         "OR",
                              //         style: TextStyle(fontSize: 14.sp),
                              //       ),
                              //     ),
                              //     Expanded(
                              //       child: Divider(color: Colors.grey.shade300),
                              //     ),
                              //   ],
                              // ),
                              // SizedBox(height: 12.h),
                              // SizedBox(
                              //   height: 55.h,
                              //   width: double.infinity,
                              //   child: OutlinedButton.icon(
                              //     onPressed: () {},
                              //     icon: Image.asset(
                              //       "assets/google.png",
                              //       height: 24.h,
                              //     ),
                              //     label: Text(
                              //       "Continue with Google",
                              //       style: TextStyle(
                              //         color: Colors.black87,
                              //         fontWeight: FontWeight.w600,
                              //         fontSize: 15.sp,
                              //       ),
                              //     ),
                              //     style: OutlinedButton.styleFrom(
                              //       shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(14.r),
                              //         side: BorderSide(color: Colors.grey.shade300),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        color: const Color(0xff0E1A35),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      children: const [
                        TextSpan(
                          text: "Sign Up",
                          style: TextStyle(
                            color: Color(0xFF24ADD7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
