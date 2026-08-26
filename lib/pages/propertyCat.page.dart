import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realstate/Model/getMyPropertyResModel.dart';
import 'package:realstate/Model/getPropertyResponsemodel.dart';
import 'package:realstate/pages/about.page.dart';
import 'package:realstate/pages/perticulerProperty.page.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:realstate/CityProvider.dart';

import '../Controller/getPropertyController.dart';
import '../Model/Body/PropertyListBodyModel.dart';
import 'listingPage.dart';

class PropertyPageCat extends ConsumerStatefulWidget {
  final String property;
  final bool isBuy;

  const PropertyPageCat({super.key, required this.property, this.isBuy = true});

  @override
  ConsumerState<PropertyPageCat> createState() => _PropertyPageCatState();
}

class _PropertyPageCatState extends ConsumerState<PropertyPageCat> {
  late bool isBuy;
  final TextEditingController searchController = TextEditingController();

  String searchText = "";
  late PropertyListBodyModel bodyProvider;

  @override
  void initState() {
    super.initState();
    isBuy = widget.isBuy;
    String propType = widget.property.trim().toLowerCase();
    if (propType == "house")
      propType = "Home";
    else if (propType == "flats" ||
        propType == "appartment" ||
        propType == "apartment")
      propType = "apartment";
    else if (propType == "plots")
      propType = "land";

    String apiPropType = propType;
    String apiCity = ref.read(currentCityProvider) ?? "";
    if (propType == "commercial") {
      apiPropType = "";
      apiCity = "";
    }

    bodyProvider = PropertyListBodyModel(
      size: 50,
      pageNo: 1,
      sortBy: 'createdAt',
      sortOrder: 'desc',
      minPrice: "",
      maxPrice: "",
      city: apiCity,
      keyWord: "",
      balcony: [],
      bathrooms: [],
      bedroom: [],
      kitchen: [],
      locality: [],
      parking: [],
      // listingCategory: isBuy ? 'buy' : 'rent',
      listingCategory: isBuy ? 'sell' : 'rent',
      propertyType: apiPropType,
    );
  }

  @override
  Widget build(BuildContext context) {
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchText = value.toLowerCase();
                        });
                      },
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 22.sp,
                          color: const Color(0xFF24ADD7),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: const BorderSide(
                            color: Color(0xFF24ADD7),
                            width: 1.5,
                          ),
                        ),
                        hintText: "Search city, locality, price...",
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                InkWell(
                  onTap: () {
                    String prop = "residential";
                    final pTypeLower = widget.property.toLowerCase().trim();
                    if ([
                      "office",
                      "retail",
                      "industry",
                      "hospitality",
                    ].contains(pTypeLower)) {
                      prop = "commercial";
                    }

                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => ListingPage(
                          initialData: ListElement(
                            property: prop,
                            propertyType: bodyProvider.propertyType,
                            listingCategory: bodyProvider.listingCategory,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 50.h,
                    width: 50.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF24ADD7),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isBuy = true;
                      // bodyProvider.listingCategory = "buy";
                      bodyProvider.listingCategory = "sell";
                    });
                    ref.invalidate(getPropertyController); // Fresh API call
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 45.h,
                    decoration: BoxDecoration(
                      color: isBuy ? const Color(0xFF24ADD7) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: isBuy
                          ? [
                              BoxShadow(
                                color: const Color(0xFF24ADD7).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        "Buy",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isBuy ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isBuy = false;
                      bodyProvider.listingCategory = "rent";
                    });
                    ref.invalidate(getPropertyController);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 45.h,
                    decoration: BoxDecoration(
                      color: !isBuy
                          ? const Color(0xFF24ADD7)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: !isBuy
                          ? [
                              BoxShadow(
                                color: const Color(0xFF24ADD7).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        "Rent",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: !isBuy ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ).paddingAll(16.w),
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

                final filteredList = response.data!.list!.where((property) {
                  final matchesSearch =
                      searchText.isEmpty ||
                      (property.city ?? "").toLowerCase().contains(
                        searchText,
                      ) ||
                      (property.localityArea ?? "").toLowerCase().contains(
                        searchText,
                      ) ||
                      (property.propertyType ?? "").toLowerCase().contains(
                        searchText,
                      ) ||
                      (property.propertyAddress ?? "").toLowerCase().contains(
                        searchText,
                      ) ||
                      (property.price ?? "").contains(searchText) ||
                      (property.bedRoom ?? "").contains(searchText);

                  bool matchesCommercial = true;
                  if (widget.property.trim().toLowerCase() == "commercial") {
                    matchesCommercial =
                        property.property?.toLowerCase() == "commercial";
                  }

                  return matchesSearch && matchesCommercial;
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, i) {
                    final prop = filteredList[i];
                    return InkWell(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   CupertinoPageRoute(
                        //     builder: (context) =>
                        //         ListingPage(initialData: prop),
                        //   ),
                        // );
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => PerticulerPropertyPage(
                              propertyId: prop.slug ?? prop.id ?? "",
                            ),
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
          final String msg = "Hi, I am interested in your property services.";
          final Uri url = Uri.parse(
            "whatsapp://send?phone=919171719060&text=${Uri.encodeComponent(msg)}",
          );
          try {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } catch (e) {
            final Uri webUrl = Uri.parse(
              "https://wa.me/919171719060?text=${Uri.encodeComponent(msg)}",
            );
            await launchUrl(webUrl, mode: LaunchMode.externalApplication);
          }
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

  String _formatPrice(String? priceStr) {
    if (priceStr == null || priceStr.isEmpty) return 'N/A';
    final price = double.tryParse(priceStr) ?? 0;
    if (price >= 10000000) return '${(price / 10000000).toStringAsFixed(2)} Cr';
    if (price >= 100000) return '${(price / 100000).toStringAsFixed(1)} Lac';
    return price.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final img = property.uploadedPhotos?.isNotEmpty == true
        ? property.uploadedPhotos!.first
        : "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800";

    final title =
        property.bedRoom == "0" ||
            property.bedRoom == null ||
            property.bedRoom!.isEmpty
        ? "${property.propertyType?.toUpperCase() ?? ''}"
        : "${property.bedRoom} BHK ${property.propertyType?.toUpperCase() ?? ''}";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.4, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 12.h,
            left: 12.w,
            right: 12.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white70, size: 10.sp),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        "${property.localityArea ?? ''}, ${property.city ?? ''}",
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 10.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  "₹ ${_formatPrice(property.price)}",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF24ADD7),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
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
