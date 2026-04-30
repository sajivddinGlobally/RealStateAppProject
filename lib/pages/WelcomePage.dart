import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Model/editProfileBodyModel.dart';
import '../core/network/api.state.dart';
import '../core/utils/preety.dio.dart';
import 'home.page.dart';

class WelcomeNamePage extends StatefulWidget {
  const WelcomeNamePage({super.key});

  @override
  State<WelcomeNamePage> createState() => _WelcomeNamePageState();
}

class _WelcomeNamePageState extends State<WelcomeNamePage> {
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  /// ===== CONTINUE CLICK =====
  void onContinue() {
    nameController.text.isEmpty?onSkip():
    updateNameApi();
  }

  /// ===== SKIP CLICK =====
  void onSkip() {
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (context) => RealEstateHomePage()),
          (route) => false,
    );
  }

  /// ===== API =====
  Future<void> updateNameApi() async {
    setState(() => isLoading = true);

    try {
      final service = APIStateNetwork(createDio());

      final body = EditProfileBodyModel(
        name: nameController.text,
      );

      final response = await service.editProfile(body);

      if (response.code == 0 || response.error == false) {
        Fluttertoast.showToast(msg: response.message ?? "");

        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => RealEstateHomePage()),
              (route) => false,
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
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xffF6F7FB),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    /// ===== SKIP BUTTON =====
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: onSkip,
                        child: const Text(
                          "SKIP",
                          style: TextStyle(
                            color: Color(0xFF24ADD7),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// ===== CARD =====
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: Offset(0, 6),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// ===== SUCCESS BANNER =====
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xffE6F4F1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 30),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Welcome to PropertyLe",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        "Your account has been created",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          /// ===== TITLE =====
                          const Text(
                            "What should we call you?",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff0E1A35),
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// ===== OPTIONAL TEXT =====
                          const Text(
                            "Optional",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 14),

                          /// ===== NAME FIELD =====
                          Container(
                            height: 55,
                            padding:
                            const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border:
                              Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                hintText: "Enter your name",
                                border: InputBorder.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          /// ===== CONTINUE BUTTON =====
                          GestureDetector(
                            onTap: onContinue,
                            child: Container(
                              height: 55,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF24ADD7),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Center(
                                child: Text(
                                  "CONTINUE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
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

        /// ===== LOADER =====
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }
}
