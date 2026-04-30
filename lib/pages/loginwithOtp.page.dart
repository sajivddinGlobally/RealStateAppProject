/*
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:realstate/Model/loginWithPhoneBodyModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:realstate/pages/OTPVerify.page.dart';

class LoginPageWithOtp extends StatefulWidget {
  const LoginPageWithOtp({super.key});

  @override
  State<LoginPageWithOtp> createState() => _LoginPageWithOtpState();
}

class _LoginPageWithOtpState extends State<LoginPageWithOtp> {
  bool obscure = true;
  bool isLoading = false;
  final phoneController = TextEditingController();

  Future<void> loginWithPhone() async {
    if (phoneController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please Enter Register Mobile Number");
      return;
    }
    setState(() {
      isLoading = true;
    });
    final body = LoginWithPhoneBodyModel(phone: phoneController.text);

    try {
      final service = APIStateNetwork(createDio());
      final response = await service.loginUser(body);
      if (response.code == 0 || response.error == false) {
        Fluttertoast.showToast(msg: response.message ?? "");
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) =>
                OtpVerifyPage(token: response.data!.token ?? ""),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Error");
      }
    } catch (e) {
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
                    "Login",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff0E1A35),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// ==== USERNAME ====
                  const Text(
                    "Mobile Number",
                    style: TextStyle(
                      fontSize: 16,
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

                  /// ==== SIGNt IN BUTTON ====
                  Center(
                    child: GestureDetector(
                      onTap: isLoading ? null : loginWithPhone,
                      child: Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isLoading
                              ? Colors.grey
                              : const Color(0xffE86A34),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Center(
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
*/

import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:realstate/Model/loginWithPhoneBodyModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:realstate/pages/OTPVerify.page.dart';

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

    final body = LoginWithPhoneResisterBodyModel(phone: phoneController.text);

    try {
      final service = APIStateNetwork(createDio());
      final response = await service.LoginRegister(body);

      if (response.code == 0 || response.error == false) {
        Fluttertoast.showToast(msg: response.message ?? "");

        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => OtpVerifyPage(
              token: response.data!.token ?? "",
              phone: phoneController.text, // ADD THIS
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  /// ===== CARD =====
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                        /// LOGO
                        Center(
                          child: Container(
                            height: 110,
                            width: 140,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.asset(
                                "assets/png/real_logo.png",
                                fit: BoxFit
                                    .contain, // 👉 image stretch nahi hogi
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          "Login or Signup",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0E1A35),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// MOBILE LABEL
                        const Text(
                          "Mobile Number",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// MOBILE FIELD
                        Container(
                          height: 58,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Text("+91", style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 10,
                                  decoration: const InputDecoration(
                                    counterText: "",
                                    hintText: "Enter Mobile Number",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        /// TERMS CHECKBOX
                        Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              activeColor: const Color(0xFF24ADD7),
                              onChanged: (v) {
                                setState(() {
                                  isChecked = v ?? false;
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                "By continuing, I agree to Terms of Use & Privacy Policy",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        /// BUTTON
                        GestureDetector(
                          onTap: isLoading ? null : loginWithPhone,
                          child: Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isLoading
                                  ? Colors.grey
                                  : const Color(0xFF24ADD7),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                "CONTINUE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
