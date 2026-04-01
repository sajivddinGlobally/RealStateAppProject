/*
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:realstate/Model/verifyBodyModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:realstate/pages/home.page.dart';

class OtpVerifyPage extends StatefulWidget {
  final String token;
  const OtpVerifyPage({super.key, required this.token});

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
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
        await box.put("phone", response.data!.user!.phone.toString());
        Fluttertoast.showToast(msg: response.message ?? "");
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => RealEstateHomePage()),
          (route) => false,
        );
      } else {
        otpController.clear();
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
                    "OTP Verify",
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
                        Icon(Icons.person_outline, color: Colors.grey),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: otpController,
                            maxLength: 6,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
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

class CommonLoader extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const CommonLoader({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,

        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
*/

import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:realstate/Model/verifyBodyModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:realstate/pages/home.page.dart';

import 'WelcomePage.dart';
import 'editProfile.page.dart';

class OtpVerifyPage extends StatefulWidget {
  final String token;
  final String phone;

  const OtpVerifyPage({
    super.key,
    required this.token,
    required this.phone,
  });

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  bool isVerify = false;
  final otpController = TextEditingController();

  Future<void> verifyUser() async {
    if (otpController.text.trim().length < 6) {
      Fluttertoast.showToast(msg: "Please Enter Valid OTP");
      return;
    }

    setState(() => isVerify = true);

    final body =
    VerifyBodyModel(token: widget.token, otp: otpController.text);

    try {
      final service = APIStateNetwork(createDio());
      final response = await service.verifyUser(body);

      if (response.code == 0 || response.error == false) {
        var box = Hive.box("userdata");
        await box.put("token", response.data!.token.toString());
        await box.put("name", response.data!.user!.name.toString());
        await box.put("email", response.data!.user!.email.toString());
        await box.put("phone", response.data!.user!.phone.toString());

        Fluttertoast.showToast(msg: response.message ?? "");

        response.data!.register==false?
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => RealEstateHomePage()),
              (route) => false,
        ):  Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => WelcomeNamePage()),
              (route) => false,
        );


      } else {
        otpController.clear();
        Fluttertoast.showToast(msg: response.message ?? "Error");
      }
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() => isVerify = false);
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
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// LOGO
                        Image.asset(
                          "assets/logo.png",
                          width: 150,
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Verify with OTP",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0E1A35),
                          ),
                        ),

                        const SizedBox(height: 6),

                        /// SENT TO NUMBER
                        Text(
                          "Sent to +91 ${widget.phone}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 25),

                        /// OTP BOXES
                        PinCodeTextField(
                          appContext: context,
                          length: 6,
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          animationType: AnimationType.fade,
                          cursorColor: const Color(0xffE86A34),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(10),
                            fieldHeight: 40.h,
                            fieldWidth: 40.w,
                            activeFillColor: Colors.white,
                            inactiveFillColor: Colors.white,
                            selectedFillColor: Colors.white,
                            activeColor: const Color(0xffE86A34),
                            selectedColor: const Color(0xffE86A34),
                            inactiveColor: Colors.grey.shade300,
                          ),
                          enableActiveFill: true,
                          onChanged: (value) {},
                        ),

                        const SizedBox(height: 10),

                        /// RESEND TIMER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("Resend OTP in "),
                            Text(
                              "00:22",
                              style: TextStyle(
                                color: Color(0xffE86A34),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// VERIFY BUTTON
                        GestureDetector(
                          onTap: isVerify ? null : verifyUser,
                          child: Container(
                            height: 55,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isVerify
                                  ? Colors.grey
                                  : const Color(0xffE86A34),
                              borderRadius:
                              BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                "VERIFY",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// PASSWORD LOGIN
                        RichText(
                          text: const TextSpan(
                            text: "Log in using ",
                            style: TextStyle(color: Colors.black54),
                            children: [
                              TextSpan(
                                text: "Password",
                                style: TextStyle(
                                  color: Color(0xffE86A34),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// TROUBLE LOGIN
                        RichText(
                          text: const TextSpan(
                            text: "Having trouble logging in? ",
                            style: TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text: "Get help",
                                style: TextStyle(
                                  color: Color(0xffE86A34),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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

class CommonLoader extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const CommonLoader({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
