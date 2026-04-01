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

                        /// ==== LOGO ====
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              "assets/logo.png", // replace with your logo
                              width: 220,
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),

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

                        /// ==== USERNAME ====
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person_outline, color: Colors.grey),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  maxLength: 10,
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

                        const SizedBox(height: 22),

                        /// ==== PASSWORD ====
                        const Text(
                          "Password",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff0E1A35),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          height: 58,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.key_outlined,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
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

                        const SizedBox(height: 30),

                        /// ==== SIGN IN BUTTON ====
                        Center(
                          child: GestureDetector(
                            onTap: isLoading ? null : loginUser,
                            child: Container(
                              height: 45,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isLoading
                                    ? Color(0xffE86A34).withOpacity(0.8)
                                    : Color(0xffE86A34),
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
                                  builder: (context) => LoginPageWithOtp(),
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Login",
                                style: TextStyle(
                                  color: Color(0xffE86A34),
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

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              // Expanded(child: SizedBox()),
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
                          color: Color(0xffE86A34),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15.h),
            ],
          ),
        ),
      ),
    );
  }
}
