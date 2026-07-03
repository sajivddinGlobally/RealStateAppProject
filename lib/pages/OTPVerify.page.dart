import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:realstate/Model/loginWithPhoneBodyModel.dart';
import 'package:realstate/Model/verifyBodyModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:realstate/pages/home.page.dart';

import 'WelcomePage.dart';
import 'editProfile.page.dart';

class OtpVerifyPage extends StatefulWidget {
  final String token;
  final String phone;

  const OtpVerifyPage({super.key, required this.token, required this.phone});

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

    final body = VerifyBodyModel(token: currentToken, otp: otpController.text);

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

        // if (!mounted) return;

        // if (response.data!.register == false) {
        //   Navigator.pushAndRemoveUntil(
        //     context,
        //     CupertinoPageRoute(builder: (context) => RealEstateHomePage()),
        //     (route) => false,
        //   );
        // } else {
        //   Navigator.pushAndRemoveUntil(
        //     context,
        //     CupertinoPageRoute(builder: (context) => WelcomeNamePage()),
        //     (route) => false,
        //   );
        // }

        // return; // 🔥 VERY IMPORTANT
      } else {
        otpController.clear();
        Fluttertoast.showToast(msg: response.message ?? "");
      }
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() => isVerify = false);
    }
  }

  late String currentToken;

  Timer? _timer;
  int _start = 60;
  @override
  void initState() {
    super.initState();
    currentToken = widget.token;
    startTimer();
  }

  void startTimer() {
    _start = 30;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_start == 0) {
        timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  bool isResend = false;

  Future<void> resendOTP() async {
    setState(() => isResend = true);

    // final body = LoginWithPhoneResisterBodyModel(phone: phoneController.text);
    final body = LoginWithPhoneBodyModel(phone: widget.phone);

    try {
      final service = APIStateNetwork(createDio());
      // final response = await service.LoginRegister(body);
      final response = await service.loginUser(body);

      if (response.code == 0 || response.error == false) {
        Fluttertoast.showToast(msg: "Resend OTP Sucess");
        startTimer();
        currentToken = response.data!.token.toString();
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Error");
      }
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() => isResend = false);
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

                  /// LOGO
                  Container(
                    height: 120.h,
                    width: 120.w,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
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
                        fit: BoxFit.contain, // 👉 image stretch nahi hogi
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                            borderRadius: BorderRadius.circular(10),
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

                        const SizedBox(height: 10),

                        _start == 0
                            ? GestureDetector(
                                onTap: () {
                                  resendOTP();
                                },
                                child: isResend
                                    ? SizedBox(
                                        width: 20.w,
                                        height: 20.h,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.blue,
                                            strokeWidth: 1.5,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        "Resend OTP",
                                        style: TextStyle(
                                          color: Color(0xFF24ADD7),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              )
                            : Text(
                                "00:${_start.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                  color: Color(0xFF24ADD7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                        const SizedBox(height: 20),

                        /// VERIFY BUTTON
                        GestureDetector(
                          onTap: isVerify ? null : verifyUser,
                          child: Container(
                            height: 55.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isVerify
                                  ? Colors.grey
                                  : const Color(0xFF24ADD7),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                "Verify",
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
