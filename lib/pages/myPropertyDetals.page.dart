import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realstate/Controller/getMyPropertyController.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MyPropertyDetalsPage extends ConsumerStatefulWidget {
  final String propetyId;
  const MyPropertyDetalsPage({super.key, required this.propetyId});

  @override
  ConsumerState<MyPropertyDetalsPage> createState() =>
      _MyPropertyDetalsPageState();
}

class _MyPropertyDetalsPageState extends ConsumerState<MyPropertyDetalsPage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF24ADD7);
    final myPropertyDetailProvider = ref.watch(
      getMyPropertyDetailsController(widget.propetyId),
    );
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: myPropertyDetailProvider.when(
        data: (snap) {
          final item = snap.data;

          if (item == null) {
            return const Center(child: Text("No property details found"));
          }

          final photos = item?.uploadedPhotos ?? [];

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // ================= IMAGE SLIDER =================
                  SliverAppBar(
                    expandedHeight: 280.h,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: primary,
                    surfaceTintColor: Colors.white,
                    forceElevated: true,
                    leading: Container(
                      margin: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: photos.isEmpty ? 1 : photos.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                photos.isEmpty
                                    ? 'https://via.placeholder.com/600x400'
                                    : photos[index],
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: primary,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => SizedBox.expand(
                                  child: Container(
                                    color: Colors.grey.shade300,
                                    child: Center(
                                      child: const Icon(Icons.image, size: 60),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ================= DOT INDICATOR (FIX) =================
                  SliverToBoxAdapter(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10.h),
                      alignment: Alignment.center,
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: photos.isEmpty ? 1 : photos.length,
                        effect: ExpandingDotsEffect(
                          activeDotColor: primary,
                          dotColor: Colors.grey,
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 3,
                          spacing: 6,
                        ),
                      ),
                    ),
                  ),
                  // ================= CONTENT =================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 16.w,
                        right: 16.w,
                        bottom: 16.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // PRICE
                          Text(
                            "₹ ${item!.price ?? ""}",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          // TITLE
                          Text(
                            "${item.bedRoom} BHK ${item.propertyType}",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          // LOCATION
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  "${item.localityArea}, ${item.city}",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          // ================= SPECS =================
                          Container(
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _spec(
                                  Icons.king_bed,
                                  "Bedrooms",
                                  item.bedRoom.toString(),
                                ),
                                _spec(
                                  Icons.bathtub,
                                  "Bathrooms",
                                  item.bathrooms.toString(),
                                ),
                                _spec(
                                  Icons.square_foot,
                                  "Area",
                                  "${item.area} sqft",
                                ),
                                _spec(
                                  Icons.chair,
                                  "Furnishing",
                                  item.furnishing ?? "-",
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          // ================= AMENITIES =================
                          if (item.amenities != null &&
                              item.amenities!.isNotEmpty) ...[
                            Text(
                              "Amenities",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Wrap(
                              spacing: 10.w,
                              runSpacing: 10.h,
                              children: item.amenities!
                                  .map(
                                    (e) => Chip(
                                      label: Text(e.toString()),
                                      backgroundColor: primary.withOpacity(.1),
                                      labelStyle: TextStyle(color: primary),
                                    ),
                                  )
                                  .toList(),
                            ),
                            SizedBox(height: 20.h),
                          ],
                          // ================= DESCRIPTION =================
                          if (item.description != null &&
                              item.description!.isNotEmpty) ...[
                            Text(
                              "Description",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              item.description ?? "",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade700,
                                height: 1.6,
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],

                          SizedBox(height: 100.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },

        error: (error, stackTrace) {
          log(error.toString());
          log(stackTrace.toString());
          return Center(child: Text(error.toString()));
        },

        loading: () => Center(child: CircularProgressIndicator(color: primary)),
      ),
    );
  }

  Widget _spec(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, size: 22, color: Colors.grey),
        SizedBox(height: 6.h),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(
          title,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
      ],
    );
  }
}
