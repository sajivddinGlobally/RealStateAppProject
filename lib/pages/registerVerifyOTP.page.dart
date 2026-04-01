import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:realstate/Model/verifyBodyModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:realstate/pages/OTPVerify.page.dart';
import 'package:realstate/pages/home.page.dart';
import 'package:realstate/pages/login.page.dart';

class RegisterVerifyOtpPage extends StatefulWidget {
  final String token;
  const RegisterVerifyOtpPage({super.key, required this.token});

  @override
  State<RegisterVerifyOtpPage> createState() => _RegisterVerifyOtpPageState();
}

class _RegisterVerifyOtpPageState extends State<RegisterVerifyOtpPage> {
  bool isVerify = false;
  final otpController = TextEditingController();

  Future<void> verifyUser() async {
    if (otpController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please Enter OTP");
      return;
    }
    setState(() {
      isVerify = true;
    });
    final body = VerifyBodyModel(token: widget.token, otp: otpController.text);
    try {
      final service = APIStateNetwork(createDio());
      final response = await service.verifyUser(body);
      if (response.code == 0 || response.error == false) {
        var box = Hive.box("userdata");
        await box.put("token", response.data!.token.toString());
        await box.put("name", response.data!.user!.name.toString());
        await box.put("email", response.data!.user!.email.toString());
        await box.put("email", response.data!.user!.phone.toString());
        Fluttertoast.showToast(msg: response.message ?? "");
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => RealEstateHomePage()),
          (route) => false,
        );
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Error");
      }
    } catch (e, st) {
      log(e.toString());
    } finally {
      setState(() {
        isVerify = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLoader(
      isLoading: isVerify,
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
                    "Register OTP Verify",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff0E1A35),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// ==== USERNAME ====
                  const Text(
                    "Enter Your Code",
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
                        const Icon(Icons.person_outline, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: const InputDecoration(
                              counterText: "",
                              hintText: "OTP",
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
                      onTap: isVerify ? null : verifyUser,
                      child: Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isVerify
                              ? Colors.grey
                              : const Color(0xffE86A34),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Center(
                          child: Text(
                            "Verify",
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
