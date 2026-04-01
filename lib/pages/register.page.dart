import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- Add this
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:realstate/pages/OTPVerify.page.dart';
import 'package:realstate/pages/login.page.dart';
import 'package:realstate/pages/registerVerifyOTP.page.dart';

import '../Controller/resisterController.dart';
import '../Model/Body/userResister.dart';

class RegisterPage extends ConsumerStatefulWidget {
  // <-- ConsumerStatefulWidget
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  bool _obscurePassword = true;
  bool _isLoading = false; // Loading state
  // Text Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Form submit function
  Future<void> _register() async {
    if (_isLoading) return; // Prevent multiple taps

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    // Basic validation
    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields");
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      Fluttertoast.showToast(msg: "Please enter a valid email");
      return;
    }

    if (password.length < 6) {
      Fluttertoast.showToast(msg: "Password must be at least 6 characters");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userData = UserResisterBodyModel(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );



      final registerService = APIStateNetwork(createDio());
      final response = await registerService.userRegister(userData);
      if (response.code == 0 || response.error == false) {
        Fluttertoast.showToast(msg: response.message ?? "");
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (context) =>
                RegisterVerifyOtpPage(token: response.data!.token ?? ""),
          ),
          (route) => false,
        );
      } else {
        Fluttertoast.showToast(msg: response.message ?? "");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Registration failed. Try again.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLoader(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xffF6F7FB),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),

                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.asset(
                        "assets/logo.png",
                        width: 220.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(height: 50.h),

                  Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff0E1A35),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Name
                  Text(
                    "Name",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff0E1A35),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _buildTextField(
                    controller: _nameController,
                    hintText: "Enter your name",
                    icon: Icons.person_outline,
                  ),

                  SizedBox(height: 22.h),

                  // Email
                  Text(
                    "Email",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff0E1A35),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _buildTextField(
                    controller: _emailController,
                    hintText: "Enter your email",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  SizedBox(height: 22.h),

                  // Phone
                  Text(
                    "Phone Number",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff0E1A35),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _buildTextField(
                    controller: _phoneController,
                    hintText: "Enter your phone number",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    mxLength: 10,
                  ),

                  SizedBox(height: 22.h),

                  // Password
                  Text(
                    "Password",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff0E1A35),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    height: 60.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline, color: Colors.grey),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: "Enter your password",
                              hintStyle: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Sign Up Button
                  GestureDetector(
                    onTap: _isLoading ? null : _register,
                    child: Container(
                      height: 60.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _isLoading
                            ? Colors.grey
                            : const Color(0xffE86A34),
                        borderRadius: BorderRadius.circular(40.r),
                      ),
                      child: Center(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Already have account
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(
                            color: const Color(0xff0E1A35),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          children: const [
                            TextSpan(
                              text: "Sign In",
                              style: TextStyle(
                                color: Color(0xffE86A34),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    final int? mxLength,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              maxLength: mxLength,
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                counterText: "",
                hintText: hintText,
                hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
