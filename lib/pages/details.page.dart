import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realstate/pages/perticulerProperty.page.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: AlignmentGeometry.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Text(
                  "Last updated: Nov 21, 2025",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            /// 🔹 Cover Image
            Container(
              height: 220.h,
              width: double.infinity,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage("assets/Rectangle 91.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: AlignmentGeometry.topRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10.h, right: 10.w),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2.r),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.share,
                                color: Colors.black,
                                size: 16.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                "Share",
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10.h, right: 10.w),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2.r),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.favorite_border,
                                color: Colors.black,
                                size: 16.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                "Save",
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left: 20.w, top: 16.h, right: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 Title
                  Row(
                    children: [
                      Text(
                        "NRI Avenue",
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10.w),
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.r),
                          color: Color(0xFFECECEC),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.done, color: Colors.green),
                            Text(
                              "RERA",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "By ",
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: "Virat Developers Pvt. Ltd",
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFFF6725),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Jagatpura, NH - 8 Jaipur",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 6.h),

                  /// 🔹 Price
                  Text(
                    "₹40.95 L - 43.7 L",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 6.h),
                  Text(
                    "EMI starts at ₹21.68 K",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFF6725),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  /// 🔹 EMI Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF6725),
                      minimumSize: Size(150.w, 45.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.call_outlined, color: Colors.white),
                    label: Text(
                      "Contact",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20.h),
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 🔹 Title
                        Text(
                          "Around This Project",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        /// 🔹 Cards Row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(aroundList.length, (index) {
                              return Container(
                                width: 220.w,
                                height: 100.h,
                                margin: EdgeInsets.only(right: 12.w),
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /// Icon
                                        Image.asset("assets/Group 25.png"),

                                        SizedBox(width: 10.w),

                                        /// Text
                                        Expanded(
                                          child: Text(
                                            aroundList[index].title,
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              color: Color(0xFF000000),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      aroundList[index].subtitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Color.fromARGB(178, 0, 0, 0),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  /// 🔹 Overview
                  Text(
                    "Avenue Overview",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Wrap(
                    spacing: 16.w,
                    runSpacing: 20.h,
                    children: [
                      _info("2 Bed", "assets/bed.png", ""),
                      _info("3 Baths", "assets/bath.png", ""),
                      _info(
                        "Project Area",
                        "assets/Group 30.png",
                        "0.89 Acres",
                      ),
                      _info(
                        "Sizes",
                        "assets/turf-size.png",
                        "431 - 460 sq.ft.",
                      ),
                      _info("Launch Date", "assets/Group 33.png", "Mar, 2025"),
                      _info(
                        "PAvg. Pricer 2030",
                        "assets/Group 34.png",
                        "₹ 9.5 K/sq.ft",
                      ),
                      _info(
                        "Project Size",
                        "assets/Vector.png",
                        "1 Building - 258 units",
                      ),
                      _info(
                        "Possession Starts",
                        "assets/Vector (1).png",
                        "Mar, 2030",
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 90.w,
                        height: 42.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.r),
                          color: Color.fromARGB(52, 255, 103, 137),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.share, color: Colors.black, size: 16.sp),
                            SizedBox(width: 6.w),
                            Text(
                              "Share",
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 90.w,
                        height: 42.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.r),
                          color: Color.fromARGB(52, 255, 103, 137),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              color: Colors.black,
                              size: 16.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              "Save",
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 100.w,
                        height: 42.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.r),
                          color: Color(0xFFFF6725),
                        ),
                        child: Center(
                          child: Text(
                            "Ask For Details",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Photos & Videos: Tour this project virtually",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 15.h),

                  Text(
                    "Project Tour & Photos",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Stack(
                    alignment: AlignmentGeometry.center,
                    children: [
                      Image.asset("assets/Rectangle 92.png"),
                      Align(
                        alignment: AlignmentGeometry.center,
                        child: Icon(
                          Icons.play_circle_fill_outlined,
                          color: Colors.white,
                          size: 30.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        "assets/Rectangle 91.png",
                        width: 103.w,
                        height: 95.h,
                        fit: BoxFit.cover,
                      ),
                      Image.asset(
                        "assets/Rectangle 91.png",
                        width: 103.w,
                        height: 95.h,
                        fit: BoxFit.cover,
                      ),
                      Image.asset(
                        "assets/Rectangle 91.png",
                        width: 103.w,
                        height: 95.h,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  /// 🔹 Amenities
                  Text(
                    "Project Amenities",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: amenitiesList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 1.14,
                    ),
                    itemBuilder: (context, index) {
                      final item = amenitiesList[index];
                      return Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item.icon, size: 28.sp, color: Colors.black87),
                            SizedBox(height: 10.h),
                            Text(
                              // item.title,
                              amenitiesList[index].title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          textAlign: TextAlign.center,
                          "Studio Apartment Configuration",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "431 - 460 sq.ft",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "convert unit",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFF6725),
                              ),
                            ),
                            Text(
                              textAlign: TextAlign.center,
                              "(Super Builtup Area) \n Size",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  /// 🔹 Description
                  Text(
                    "Property Description",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    "Luxury 2-Bedroom Apartment | Off-Plan Resale | Damac Casa – Al Sufouh Second. "
                    "Property introduces a remarkable 2-bedroom apartment...",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "PropertyLe Properties proudly introduces this remarkable 2-bedroom apartment in Damac Casa, a premium waterfront development in the highly sought-after Al Sufouh Second community. Offering an expansive 1,857 sq. ",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(178, 0, 0, 0),
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),

            // GridView.builder(
            //   shrinkWrap: true,
            //   physics: NeverScrollableScrollPhysics(),
            //   padding: EdgeInsets.all(12),
            //   itemCount: 2,
            //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: 2,
            //     mainAxisSpacing: 12.h,
            //     crossAxisSpacing: 12.w,
            //     childAspectRatio: 0.60,
            //   ),
            //   itemBuilder: (context, index) {
            //     return const PropertyCard();
            //   },
            // ),

            /// 🔹 Action Button
            Container(
              margin: EdgeInsets.only(left: 20.w, right: 20.w),
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6725),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  "View More",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _info(String text, String image, String sub) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(image, width: 25.w, height: 25.h),
        SizedBox(width: 4.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Color(0xFFFF6725),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              sub,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 🔹 Amenities Data
final List<String> amenities = [
  "Power Backup",
  "Entrance Lobby",
  "Security Cabin",
  "Fire Sprinklers",
  "Party Hall",
  "24x7 CCTV",
  "Gymnasium",
  "Escalators",
  "Restaurant",
];

/// 🔹 Model
class AroundModel {
  final String title;
  final String subtitle;
  final IconData icon;

  AroundModel({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

/// 🔹 Sample Data (API-ready)
final List<AroundModel> aroundList = [
  AroundModel(
    title: "School",
    subtitle: "St. Mary's Convent Senior Secondary School",
    icon: Icons.school,
  ),
  AroundModel(
    title: "Hospital",
    subtitle: "No 7 Hospital",
    icon: Icons.local_hospital,
  ),
];

/// 🔹 Model
class AmenityModel {
  final String title;
  final IconData icon;

  AmenityModel(this.title, this.icon);
}

/// 🔹 Amenities Data (API ready)
final List<AmenityModel> amenitiesList = [
  AmenityModel("Partial Power\nBackup", Icons.car_crash_outlined),
  AmenityModel("Entrance\nLobby", Icons.meeting_room_outlined),
  AmenityModel("Security\nCabin", Icons.security),
  AmenityModel("Fire\nSprinklers", Icons.local_fire_department_outlined),
  AmenityModel("Party\nHall", Icons.celebration_outlined),
  AmenityModel("24x7 CCTV\nSurveillance", Icons.videocam_outlined),
  AmenityModel("Gymnasium", Icons.fitness_center),
  AmenityModel("Escalators", Icons.escalator),
  AmenityModel("Restaurant", Icons.restaurant),
  AmenityModel("24x7 Water\nSupply", Icons.water_drop_outlined),
];
