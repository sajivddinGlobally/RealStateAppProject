/*
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';  // ← Yeh add karna zaroori
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realstate/pages/about.page.dart';
import 'package:realstate/pages/perticulerProperty.page.dart';

import '../Controller/getPropertyController.dart';
import '../Model/Body/PropertyListBodyModel.dart';

class PropertyPageCat extends ConsumerStatefulWidget {  // ← ConsumerStatefulWidget
  final String property;

  const PropertyPageCat({super.key, required this.property});

  @override
  ConsumerState<PropertyPageCat> createState() => _PropertyPageCatState();
}

class _PropertyPageCatState extends ConsumerState<PropertyPageCat> {  // ← ConsumerState

  bool isBuy = true;

  final List<Map<String, String>> buyCategories = [
    {
      "title": "HOUSE",
      "img": "https://images.unsplash.com/photo-1570129477492-45c003edd2be?auto=format",
    },
    {
      "title": "FLATS",
      "img": "https://images.unsplash.com/photo-1507089947368-19c1da9775ae?auto=format",
    },
    {
      "title": "DUPLEX",
      "img": "https://images.unsplash.com/photo-1572120360610-d971b9d7767c?auto=format",
    },
    {
      "title": "PLOTS",
      "img": "https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format",
    },
    {
      "title": "COMMERCIAL PROPERTIES",
      "img": "https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format",
    },
    {
      "title": "HOTELS",
      "img": "https://images.unsplash.com/photo-1542317854-2b4acb67c5cd?auto=format",
    },
    {
      "title": "CONDOS",
      "img": "https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format",
    },
    {
      "title": "STUDIOS",
      "img": "https://images.unsplash.com/photo-1486304873000-235643847519?auto=format",
    },
  ];
  final List<Map<String, String>> rentCategories = [
    {
      "title": "APARTMENTS",
      "img": "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format",
    },
    {
      "title": "ROOMS",
      "img": "https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format",
    },
    {
      "title": "HOSTEL",
      "img": "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format",
    },
    {
      "title": "PG",
      "img": "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Example body – aap apne hisab se change kar sakte ho
    final requestBody = PropertyListBodyModel(
      size: 10,
      pageNo: 1,
      sortBy: 'createdAt',
      sortOrder: 'desc',
      // agar type ke basis pe filter karna hai toh

    );

    final propertyAsync = ref.watch(getPropertyController(requestBody));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Buy Rent Property",
          style: TextStyle(
            color: Color(0xFFFF6725),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isBuy = true),
                  child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: isBuy ? const Color(0xFFFF6725) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "Buy",
                        style: TextStyle(
                          fontSize: 18,
                          color: isBuy ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isBuy = false),
                  child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: !isBuy ? const Color(0xFFFF6725) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "Rent",
                        style: TextStyle(
                          fontSize: 18,
                          color: !isBuy ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ).paddingAll(16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.12,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: isBuy ? buyCategories.length : rentCategories.length,
              itemBuilder: (context, i) {
                final data = isBuy ? buyCategories[i] : rentCategories[i];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const PerticulerPropertyPage(),
                      ),
                    );
                  },
                  child: cardWidget(data["title"]!, data["img"]!),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 8,
        backgroundColor: const Color(0xff27D045),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.r),
        ),
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => const AboutUsPage()),
          );
        },
        icon: SvgPicture.asset("assets/Svg/whatsapp.svg"),
        label: Text(
          "Let’s Connect",
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );

  }

  Widget cardWidget(String title, String url) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

extension PaddingExt on Widget {
  Widget paddingAll(double value) => Padding(padding: EdgeInsets.all(value), child: this);
}



*/

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realstate/pages/about.page.dart';
import 'package:realstate/pages/perticulerProperty.page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Controller/getPropertyController.dart';
import '../Model/Body/PropertyListBodyModel.dart';
import '../Model/getPropertyResponsemodel.dart';
import 'listingPage.dart';

class PropertyPageCat extends ConsumerStatefulWidget {
  final String property; // "HOUSE", "FLATS", "COMMERCIAL PROPERTIES" etc.

  const PropertyPageCat({super.key, required this.property});

  @override
  ConsumerState<PropertyPageCat> createState() => _PropertyPageCatState();
}

class _PropertyPageCatState extends ConsumerState<PropertyPageCat> {
  bool isBuy = true;

  late final bodyProvider = PropertyListBodyModel(
    size: 50,
    pageNo: 1,
    sortBy: 'createdAt',
    sortOrder: 'desc',
    // Optional: agar backend support kare toh direct filter bhej do
    // property: widget.property.toLowerCase(),
    // listingCategory: isBuy ? "buy" : "rent",
  );

  @override
  Widget build(BuildContext context) {
    // Har baar tab change ya property change pe fresh call
    // final currentBody = bodyProvider.copyWith(
    //   // Agar backend filter support nahi karta toh yeh comment kar do
    //   // listingCategory: isBuy ? "buy" : "rent",
    // );

    final propertyAsync = ref.watch(getPropertyController(bodyProvider));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        centerTitle: true,
        title: Text(
          "${widget.property} for ${isBuy ? 'Buy' : 'Rent'}",
          style: const TextStyle(
            color: Color(0xFF24ADD7),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => isBuy = true);
                    ref.invalidate(getPropertyController); // Fresh API call
                  },
                  child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: isBuy ? const Color(0xFF24ADD7) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        "Buy",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => isBuy = false);
                    ref.invalidate(getPropertyController);
                  },
                  child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: !isBuy
                          ? const Color(0xFF24ADD7)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        "Rent",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ).paddingAll(16),
          // API Response Handle
          Expanded(
            child: propertyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) {
                log(stack.toString());
                return Center(
                  child: Text(
                    "Error: $err",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              },
              data: (response) {
                if (response.data?.list == null ||
                    response.data!.list!.isEmpty) {
                  return const Center(child: Text("No properties found"));
                }

                // // Final Filtering (Frontend pe guarantee ke liye)
                // final filteredList = response.data!.list!.where((property) {
                //   final matchesProperty =
                //       property.property?.toUpperCase() ==
                //       widget.property.toUpperCase();
                //   final matchesCategory =
                //       property.listingCategory?.toLowerCase() ==
                //       (isBuy ? "sell" : "rent");
                //   return matchesProperty && matchesCategory;
                // }).toList();

                final filteredList = response.data!.list!.where((property) {
                  final matchesProperty =
                      property.property?.toLowerCase() ==
                      widget.property.toLowerCase();

                  final matchesCategory =
                      property.listingCategory?.toLowerCase() ==
                      (isBuy ? "buy" : "rent");

                  return matchesProperty && matchesCategory;
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Text(
                      "No ${isBuy ? 'Buy' : 'Rent'} ${widget.property} available",
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.12,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, i) {
                    final prop = filteredList[i];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) =>
                                // ListingPage(property: prop.property??"", listingCategory: prop.listingCategory??"",),
                                ListingPage(initialData: prop),
                          ),
                        );
                      },
                      child: PropertyCard(property: prop),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 8,
        backgroundColor: const Color(0xff27D045),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.r),
        ),
        onPressed: () async {
          final Uri url = Uri.parse("https://wa.me/9171719060");
          await launchUrl(url, mode: LaunchMode.externalApplication);
        },
        icon: SvgPicture.asset("assets/Svg/whatsapp.svg"),
        label: Text(
          "Let’s Connect",
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// Beautiful Card Widget
class PropertyCard extends StatelessWidget {
  final ListElement property;

  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final img = property.uploadedPhotos?.isNotEmpty == true
        ? property.uploadedPhotos!.first
        : "https://via.placeholder.com/300x300.png?text=No+Image";

    final title = property.bedRoom == "0" || property.bedRoom == null
        ? "${property.propertyType?.toUpperCase() ?? ''} in ${property.city ?? ''}"
        : "${property.bedRoom} BHK ${property.propertyType?.toUpperCase() ?? ''}";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(img),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "₹${property.price ?? 'N/A'}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension PaddingExt on Widget {
  Widget paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);
}
