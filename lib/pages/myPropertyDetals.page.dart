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

    final provider = ref.watch(
      getMyPropertyDetailsController(widget.propetyId),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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
                expandedHeight: 260.h,
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
                    ],
                  ),
                ),
              ),

              /// 🔥 DOT INDICATOR
              if (photos.length > 1)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Center(
                      child: AnimatedSmoothIndicator(
                        activeIndex: _currentIndex,
                        count: photos.isEmpty ? 1 : photos.length,
                        effect: WormEffect(
                          activeDotColor: primary,
                          dotHeight: 6,
                          dotWidth: 6,
                        ),
                      ),
                    ),
                  ),
                ),

              /// 🔥 CONTENT
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// PRICE
                      Row(
                        children: [
                          if (item.price != null)
                            Text(
                              "₹ ${item.price}",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            ),
                          Spacer(),
                          InkWell(
                            borderRadius: BorderRadius.circular(100.r),
                            onTap: () async {
                              final Uri url = Uri.parse("tel:+91 9171719060");

                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: Container(
                              width: 40.w,
                              height: 40.h,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.call,
                                size: 20.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          SizedBox(width: 10.w),

                          InkWell(
                            borderRadius: BorderRadius.circular(100.r),
                            onTap: () async {
                              final Uri url = Uri.parse(
                                "https://wa.me/9171719060",
                              );

                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: Container(
                              width: 40.w,
                              height: 40.h,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  "assets/Svg/whatsapp.svg",
                                  width: 20.w,
                                  height: 20.h,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      /// TITLE
                      Text(
                        "${item.bedRoom ?? ""} ${item.propertyType ?? ""}",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 6.h),

                      /// LOCATION
                      if (item.localityArea != null || item.city != null)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                "${item.localityArea ?? ""}, ${item.city ?? ""}",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: 14.h),

                      /// 🔥 DETAILS GRID
                      Container(
                        padding: EdgeInsets.only(
                          left: 12.w,
                          right: 12.w,
                          bottom: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.only(top: 12.h),
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.9,
                          children: [
                            if ((item.bedRoom ?? "").trim().isNotEmpty)
                              _spec(
                                Icons.king_bed,
                                "Beds",
                                item.bedRoom.toString(),
                              ),

                            if ((item.bathrooms ?? "").trim().isNotEmpty)
                              _spec(
                                Icons.bathtub,
                                "Bath",
                                item.bathrooms.toString(),
                              ),

                            if ((item.kitchen ?? "").trim().isNotEmpty)
                              _spec(
                                Icons.kitchen,
                                "Kitchen",
                                item.kitchen.toString(),
                              ),

                            if ((item.area ?? "").trim().isNotEmpty)
                              _spec(Icons.square_foot, "Area", "${item.area}"),

                            if ((item.furnishing ?? "").trim().isNotEmpty)
                              _spec(
                                Icons.chair,
                                "Furnish",
                                item.furnishing.toString(),
                              ),
                            if ((item.parking ?? "").trim().isNotEmpty)
                              _spec(
                                Icons.park_outlined,
                                "Parking",
                                item.parking.toString(),
                              ),

                            if ((item.balcony ?? "").trim().isNotEmpty)
                              _spec(
                                Icons.balcony,
                                "Balcony",
                                item.balcony.toString(),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      /// BROKER
                      if (item.isBroker != null)
                        _tag("Broker: ${item.isBroker}", primary),

                      /// AMENITIES
                      if (item.amenities != null &&
                          item.amenities!.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        _title("Amenities"),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: item.amenities!
                              .map(
                                (e) => Chip(
                                  label: Text(
                                    e.toString(),
                                    style: TextStyle(fontSize: 10.sp),
                                  ),
                                  backgroundColor: primary.withOpacity(.1),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      if (item.furnishingItems != null &&
                          item.furnishingItems!.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        _title("Furnishing Items"),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: item.furnishingItems!
                              .map(
                                (e) => Chip(
                                  label: Text(
                                    e.toString(),
                                    style: TextStyle(fontSize: 10.sp),
                                  ),
                                  backgroundColor: primary.withOpacity(.1),
                                ),
                              )
                              .toList(),
                        ),
                      ],

                      /// DESCRIPTION
                      if (item.description != null &&
                          item.description!.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        _title("Description"),
                        Text(
                          item.description!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],

                      /// ADDRESS
                      if (item.propertyAddress != null &&
                          item.propertyAddress!.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        _title("Address"),
                        Text(
                          item.propertyAddress!,
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],

                      SizedBox(height: 10.h),

                      /// EXTRA INFO
                      if (item.rera != null && item.rera!.isNotEmpty)
                        _infoTile("RERA", item.rera!),

                      if (item.permitNo != null && item.permitNo!.isNotEmpty)
                        _infoTile("Permit", item.permitNo!),

                      if (item.brn != null && item.brn!.isNotEmpty)
                        _infoTile("BRN", item.brn!),

                      if (item.ded != null && item.ded!.isNotEmpty)
                        _infoTile("DED", item.ded!),

                      SizedBox(height: 50.h),
                    ],
                  ),
                ),
              ),
            ],
          );
        },

        error: (e, s) {
          log(e.toString());
          return Center(child: Text("Something went wrong"));
        },

        loading: () =>
            Center(child: CircularProgressIndicator(color: Color(0xFF24ADD7))),
      ),
    );
  }

  /// 🔹 BACK BUTTON
  Widget _backButton() {
    return Container(
      margin: EdgeInsets.all(8.w),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(Icons.arrow_back, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  /// 🔹 TITLE
  Widget _title(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// 🔹 TAG
  Widget _tag(String text, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11.sp, color: color),
      ),
    );
  }

  /// 🔹 INFO TILE
  Widget _infoTile(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 SPEC BOX
  Widget _spec(IconData icon, String title, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          SizedBox(height: 3.h),
          Text(
            value,
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 9.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
