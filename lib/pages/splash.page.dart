import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realstate/pages/onboarding.page.dart';

class PropertyIntroPage extends StatelessWidget {
  const PropertyIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
        ),

        child: Stack(
          children: [
            Positioned(
              top: -90,
              left: -30,
              child: Transform.rotate(
                angle: 12 * pi / 180,
                child: SizedBox(
                  height: 1000,
                  width: 700,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          imageBox(
                            "https://images.unsplash.com/photo-1600585154340-be6161a56a0c",
                          ),
                          const SizedBox(width: 18),
                          imageBox(
                            "https://images.unsplash.com/photo-1568605114967-8130f3a36994",
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          imageBox(
                            "https://images.unsplash.com/photo-1572120360610-d971b9d7767c",
                          ),
                          const SizedBox(width: 18),
                          imageBox(
                            "https://images.unsplash.com/photo-1507089947368-19c1da9775ae",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 330,
                decoration: const BoxDecoration(color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 180,
              left: 0,
              right: 0,
              child: Center(
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
                      fit: BoxFit.contain, // 👉 image stretch nahi hogi
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 40,
              right: 40,
              child: SizedBox(
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF24ADD7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(45),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => OnboardingScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 16.h,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget imageBox(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        height: 350,
        width: 280,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
        child: Image.network(url, fit: BoxFit.cover),
      ),
    );
  }
}
