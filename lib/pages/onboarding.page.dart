import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realstate/pages/login.page.dart';

import 'loginwithOtp.page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Find Your Perfect Home\nEasily",
      "description":
          "Discover verified properties, trusted agents, and smooth buying–selling experiences — all in one place. Your dream home is now just a tap away.",
    },
    {
      "title": "Explore Properties\nAnytime, Anywhere",
      "description":
          "Browse thousands of listings, view detailed photos, virtual tours, and connect with agents instantly from your phone.",
    },
    {
      "title": "Secure & Hassle-Free\nTransactions",
      "description":
          "Enjoy safe payments, legal guidance, and transparent processes. We make buying or selling your property stress-free.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => LoginPageWithOtp()),
      );
    }
  }

  void _skip() {
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (context) => LoginPageWithOtp()),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      width: 14,
      height: 14,
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xffE86A34)
            : const Color(0xffF2C3A5),
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),

      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10.h),

            // Top Illustration (same for all pages)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Image.asset(
                "assets/Frame 1171275471.png", // same image on every page
                height: 320.h,
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: 20.h),

            // PageView for content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.w),
                    child: Column(
                      children: [
                        // Title
                        Text(
                          data["title"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xffE86A34),
                            height: 1.3,
                          ),
                        ),

                        SizedBox(height: 15.h),

                        // Description
                        Text(
                          data["description"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            height: 1.55,
                            color: const Color(0xff7B7B7B),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom section: Dots + Next button + Skip
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Row(
                children: [
                  // Dots
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) => _buildDot(index)),
                  ),

                  const Spacer(),

                  // Next Arrow Button
                  GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      height: 50.h,
                      width: 50.w,
                      decoration: const BoxDecoration(
                        color: Color(0xffE86A34),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Skip Text
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 25.w),
                child: GestureDetector(
                  onTap: _skip,
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xffE86A34),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
