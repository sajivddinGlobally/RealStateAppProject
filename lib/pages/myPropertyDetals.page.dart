import 'dart:developer';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:realstate/Controller/getMyPropertyController.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class MyPropertyDetalsPage extends ConsumerStatefulWidget {
  final String propetyId;
  const MyPropertyDetalsPage({super.key, required this.propetyId});

  @override
  ConsumerState<MyPropertyDetalsPage> createState() =>
      _MyPropertyDetalsPageState();
}

class _MyPropertyDetalsPageState extends ConsumerState<MyPropertyDetalsPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF24ADD7);

    final provider = ref.watch(propertyDetailsController(widget.propetyId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Slightly cleaner background
      body: provider.when(
        data: (snap) {
          final item = snap.data;

          if (item == null) {
            return const Center(child: Text("No property found"));
          }

          final photos = item.uploadedPhotos ?? [];

          return CustomScrollView(
            slivers: [
              /// 🔥 IMAGE SLIDER
              SliverAppBar(
                expandedHeight: 300.h, // Slightly larger for better visuals
                pinned: true,
                elevation: 0,
                backgroundColor: primary,
                leading: _backButton(),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      CarouselSlider.builder(
                        itemCount: photos.isEmpty ? 1 : photos.length,
                        itemBuilder: (context, index, realIndex) {
                          return Image.network(
                            photos.isEmpty
                                ? 'https://via.placeholder.com/600x400'
                                : photos[index],
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                        options: CarouselOptions(
                          height: double.infinity,
                          viewportFraction: 1,
                          autoPlay: photos.length > 1,
                          onPageChanged: (index, reason) {
                            setState(() => _currentIndex = index);
                          },
                        ),
                      ),

                      /// Gradient overlay for better top bar visibility
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 100.h,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// 🔥 DOT INDICATOR
              if (photos.length > 1)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
                    child: Center(
                      child: AnimatedSmoothIndicator(
                        activeIndex: _currentIndex,
                        count: photos.length,
                        effect: ExpandingDotsEffect(
                          activeDotColor: primary,
                          dotColor: Colors.grey.shade300,
                          dotHeight: 6.h,
                          dotWidth: 6.w,
                          expansionFactor: 3,
                        ),
                      ),
                    ),
                  ),
                ),

              /// 🔥 CONTENT
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// PRICE & BUTTONS CARD
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            if (item.price != null)
                              Expanded(
                                child: Text(
                                  "₹ ${item.price}",
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w800,
                                    color: primary,
                                  ),
                                ),
                              ),
                            Row(
                              children: [
                                _actionCircleBtn(
                                  icon: Icons.call,
                                  color: Colors.blue,
                                  onTap: () async {
                                    final Uri url = Uri.parse(
                                      "tel:+91 9171719060",
                                    );
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                ),
                                SizedBox(width: 12.w),
                                _actionCircleBtn(
                                  svgPath: "assets/Svg/whatsapp.svg",
                                  color: const Color(0xFF25D366),
                                  onTap: () async {
                                    final String msg =
                                        "Hi, I am interested in your property: ${item.propertyType ?? ''} in ${item.localityArea ?? ''}";
                                    final Uri url = Uri.parse(
                                      "whatsapp://send?phone=919171719060&text=${Uri.encodeComponent(msg)}",
                                    );
                                    try {
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } catch (e) {
                                      final Uri webUrl = Uri.parse(
                                        "https://wa.me/919171719060?text=${Uri.encodeComponent(msg)}",
                                      );
                                      await launchUrl(
                                        webUrl,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      /// TITLE
                      Text(
                        "${item.bedRoom ?? ""} BHK ${item.propertyType ?? ""}"
                            .trim(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),

                      SizedBox(height: 8.h),

                      /// LOCATION
                      if (item.localityArea != null || item.city != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16.sp,
                              color: primary,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                "${item.localityArea ?? ""}, ${item.city ?? ""}"
                                    .trim()
                                    .replaceAll(RegExp(r'^,\s*'), ''),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: 20.h),

                      /// SPECS GRID
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          crossAxisCount: 4,
                          crossAxisSpacing: 10.w,
                          mainAxisSpacing: 10.h,
                          childAspectRatio: 0.85,
                          children: [
                            if ((item.bedRoom ?? "").trim().isNotEmpty)
                              _spec(
                                Icons.king_bed,
                                "Beds",
                                item.bedRoom.toString(),
                                primary,
                              ),
                            if ((item.bathrooms ?? "").trim().isNotEmpty)
                              _spec(
                                Icons.bathtub,
                                "Bath",
                                item.bathrooms.toString(),
                                primary,
                              ),
                            if ((item.kitchen ?? "").trim().isNotEmpty)
                              _spec(
                                Icons.kitchen,
                                "Kitchen",
                                item.kitchen.toString(),
                                primary,
                              ),
                            if ((item.area ?? "").trim().isNotEmpty)
                              _spec(
                                Icons.square_foot,
                                "Area",
                                "${item.area}",
                                primary,
                              ),
                            if ((item.furnishing ?? "").trim().isNotEmpty)
                              _spec(
                                Icons.chair,
                                "Furnish",
                                item.furnishing.toString(),
                                primary,
                              ),
                            if ((item.parking ?? "").trim().isNotEmpty)
                              _spec(
                                Icons.park_outlined,
                                "Parking",
                                item.parking.toString(),
                                primary,
                              ),
                            if ((item.balcony ?? "").trim().isNotEmpty)
                              _spec(
                                Icons.balcony,
                                "Balcony",
                                item.balcony.toString(),
                                primary,
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      /// BROKER
                      if (item.isBroker != null && item.isBroker!.isNotEmpty)
                        _tag("Broker: ${item.isBroker}", primary),

                      /// AMENITIES
                      if (item.amenities != null &&
                          item.amenities!.isNotEmpty) ...[
                        _title("Amenities"),
                        Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: item.amenities!
                              .map((e) => _chipItem(e.toString(), primary))
                              .toList(),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      /// FURNISHING ITEMS
                      if (item.furnishingItems != null &&
                          item.furnishingItems!.isNotEmpty) ...[
                        _title("Furnishing Items"),
                        Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: item.furnishingItems!
                              .map((e) => _chipItem(e.toString(), primary))
                              .toList(),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      /// AVENUE OVERVIEW
                      if (item.aveneuOverView != null &&
                          ((item.aveneuOverView!.projectArea != null &&
                                  item
                                      .aveneuOverView!
                                      .projectArea!
                                      .isNotEmpty) ||
                              (item.aveneuOverView!.size != null &&
                                  item.aveneuOverView!.size!.isNotEmpty) ||
                              (item.aveneuOverView!.projectSize != null &&
                                  item
                                      .aveneuOverView!
                                      .projectSize!
                                      .isNotEmpty) ||
                              (item.aveneuOverView!.launchDate != null &&
                                  item
                                      .aveneuOverView!
                                      .launchDate!
                                      .isNotEmpty) ||
                              (item.aveneuOverView!.possessionStart != null &&
                                  item
                                      .aveneuOverView!
                                      .possessionStart!
                                      .isNotEmpty))) ...[
                        _title("Avenue Overview"),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              if (item.aveneuOverView!.projectArea != null &&
                                  item.aveneuOverView!.projectArea!.isNotEmpty)
                                _infoTile(
                                  "Project Area",
                                  item.aveneuOverView!.projectArea!,
                                  isLast: false,
                                ),
                              if (item.aveneuOverView!.size != null &&
                                  item.aveneuOverView!.size!.isNotEmpty)
                                _infoTile(
                                  "Size",
                                  item.aveneuOverView!.size!,
                                  isLast: false,
                                ),
                              if (item.aveneuOverView!.projectSize != null &&
                                  item.aveneuOverView!.projectSize!.isNotEmpty)
                                _infoTile(
                                  "Project Size",
                                  item.aveneuOverView!.projectSize!,
                                  isLast: false,
                                ),
                              if (item.aveneuOverView!.launchDate != null &&
                                  item.aveneuOverView!.launchDate!.isNotEmpty)
                                _infoTile(
                                  "Launch Date",
                                  item.aveneuOverView!.launchDate!,
                                  isLast: false,
                                ),
                              if (item.aveneuOverView!.possessionStart !=
                                      null &&
                                  item
                                      .aveneuOverView!
                                      .possessionStart!
                                      .isNotEmpty)
                                _infoTile(
                                  "Possession Start",
                                  item.aveneuOverView!.possessionStart!,
                                  isLast: true,
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      /// DESCRIPTION
                      if (item.description != null &&
                          item.description!.isNotEmpty) ...[
                        _title("Description"),
                        Text(
                          item.description!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade700,
                            height: 1.5,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      /// ADDRESS
                      if (item.propertyAddress != null &&
                          item.propertyAddress!.isNotEmpty) ...[
                        _title("Address"),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: primary.withOpacity(0.2)),
                          ),
                          child: Text(
                            item.propertyAddress!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      /// EXTRA INFO
                      if ((item.rera != null && item.rera!.isNotEmpty) ||
                          (item.permitNo != null &&
                              item.permitNo!.isNotEmpty) ||
                          (item.brn != null && item.brn!.isNotEmpty) ||
                          (item.ded != null && item.ded!.isNotEmpty)) ...[
                        _title("Additional Details"),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              if (item.rera != null && item.rera!.isNotEmpty)
                                _infoTile("RERA", item.rera!, isLast: false),
                              if (item.permitNo != null &&
                                  item.permitNo!.isNotEmpty)
                                _infoTile(
                                  "Permit",
                                  item.permitNo!,
                                  isLast: false,
                                ),
                              if (item.brn != null && item.brn!.isNotEmpty)
                                _infoTile("BRN", item.brn!, isLast: false),
                              if (item.ded != null && item.ded!.isNotEmpty)
                                _infoTile("DED", item.ded!, isLast: true),
                            ],
                          ),
                        ),
                        SizedBox(height: 50.h),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        error: (e, s) {
          log(e.toString());
          return const Center(child: Text("Something went wrong"));
        },
        loading: () => Center(child: CircularProgressIndicator(color: primary)),
      ),
    );
  }

  /// 🔹 ACTION CIRCLE BUTTON (CALL / WHATSAPP)
  Widget _actionCircleBtn({
    IconData? icon,
    String? svgPath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(100.r),
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.h,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, size: 20.sp, color: Colors.white)
              : SvgPicture.asset(svgPath!, width: 22.w, height: 22.h),
        ),
      ),
    );
  }

  /// 🔹 BACK BUTTON
  Widget _backButton() {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: InkWell(
        onTap: () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(100.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
            ],
          ),
          child: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
        ),
      ),
    );
  }

  /// 🔹 TITLE
  Widget _title(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  /// 🔹 TAG
  Widget _tag(String text, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 🔹 CHIP ITEM
  Widget _chipItem(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 🔹 INFO TILE
  Widget _infoTile(String title, String value, {bool isLast = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 SPEC BOX
  Widget _spec(IconData icon, String title, String value, Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22.sp, color: primary),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
