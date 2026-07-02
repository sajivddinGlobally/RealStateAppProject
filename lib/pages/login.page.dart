import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:realstate/Model/loginWithPhoneBodyModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:realstate/pages/OTPVerify.page.dart';
import 'package:realstate/pages/forgotPasswordSentOtp.page.dart';
import 'package:realstate/pages/home.page.dart';
import 'package:realstate/pages/loginwithOtp.page.dart';
import 'package:realstate/pages/register.page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obscure = true;
  bool isLoading = false;
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> loginUser() async {
    if (phoneController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Please Enter Register Mobile Number and Password",
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    final body = LoginWithPhoneBodyModel(
      phone: phoneController.text,
      password: passwordController.text,
    );

    try {
      final service = APIStateNetwork(createDio());
      final response = await service.loginUser(body);
      if (response.code == 0 || response.error == false) {
        var box = Hive.box("userdata");
        await box.put("token", response.data!.token.toString());
        await box.put("name", response.data!.user!.name.toString());
        await box.put("email", response.data!.user!.email.toString());
        await box.put("phone", response.data!.user!.phone.toString());
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => RealEstateHomePage()),
          (route) => false,
        );

        Fluttertoast.showToast(msg: response.message ?? "");
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Error");
      }
    } catch (e) {
      log("Login Error : ${e.toString()}");
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
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

                        const SizedBox(height: 30),

                        /// ==== SIGN IN TITLE ====
                        const Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff0E1A35),
                          ),
                        ),
                        const SizedBox(height: 30),
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
                              const Text(
                                "Mobile Number",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff0E1A35),
                                ),
                              ),

                              const SizedBox(height: 10),

                              Container(
                                height: 58,
                                padding: EdgeInsets.symmetric(horizontal: 14.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      color: Colors.grey,
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: TextField(
                                        maxLength: 10,
                                        style: TextStyle(fontSize: 15.sp),
                                        controller: phoneController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          counterText: "",
                                          hintStyle: TextStyle(fontSize: 14.sp),
                                          hintText: "Mobile Number",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 15.h),

                              /// ==== PASSWORD ====
                              const Text(
                                "Password",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff0E1A35),
                                ),
                              ),

                              SizedBox(height: 10.h),

                              Container(
                                height: 58,
                                padding: EdgeInsets.symmetric(horizontal: 14.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.key_outlined,
                                      color: Colors.grey,
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: TextField(
                                        style: TextStyle(fontSize: 15.sp),
                                        controller: passwordController,
                                        obscureText: obscure,
                                        decoration: InputDecoration(
                                          hintStyle: TextStyle(fontSize: 14.sp),
                                          hintText: "Password",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() => obscure = !obscure);
                                      },
                                      child: Icon(
                                        obscure
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) =>
                                            ForgotPasswordSentOtpPage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      left: 15.w,
                                      right: 0,
                                      top: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    child: Text(
                                      "Forgot Password",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff0E1A35),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.h),

                              /// ==== SIGN IN BUTTON ====
                              Center(
                                child: GestureDetector(
                                  onTap: isLoading ? null : loginUser,
                                  child: Container(
                                    height: 45,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: isLoading
                                          ? Color(0xFF24ADD7).withOpacity(0.8)
                                          : Color(0xFF24ADD7),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Sign In",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// ==== LOGIN WITH OTP ====
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) =>
                                            LoginPageWithOtp(),
                                      ),
                                    );
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Login",
                                      style: TextStyle(
                                        color: Color(0xFF24ADD7),
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: " with Otp",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Color(0xff0E1A35),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account?",
                    style: TextStyle(
                      color: Color(0xff0E1A35),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: " Sign Up",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xFF24ADD7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
