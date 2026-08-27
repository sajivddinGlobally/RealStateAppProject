import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:realstate/CityProvider.dart';
import 'package:realstate/Controller/getPropertyController.dart';
import 'package:realstate/Controller/getCityListController.dart';
import 'package:realstate/Model/Body/PropertyListBodyModel.dart';
import 'package:realstate/Model/getPropertyResponsemodel.dart';
import 'package:realstate/pages/perticulerProperty.page.dart';
import 'package:realstate/pages/filter_drawer.dart';

import '../Model/propertyDetailModel.dart';

const String _cityBoxName = 'user_prefs';
const String _cityKey = 'user_city';

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

class ListingPage extends ConsumerStatefulWidget {
  final ListElement? initialData;

  const ListingPage({this.initialData, super.key});

  @override
  ConsumerState<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends ConsumerState<ListingPage> {
  int currentPage = 1;
  late PropertyListBodyModel body;

  @override
  void initState() {
    super.initState();
    final initialCity = ref.read(currentCityProvider) ?? "";

    body = PropertyListBodyModel(
      size: 20,
      pageNo: currentPage,
      sortBy: 'createdAt',
      sortOrder: 'desc',
      minPrice: "",
      maxPrice: "",
      city: initialCity,
      propertyType: widget.initialData?.propertyType ?? "",
      listingCategory: widget.initialData?.listingCategory ?? "",
      keyWord: "",
      balcony: [],
      bathrooms: [],
      bedroom: [],
      kitchen: [],
      locality: [],
      parking: [],
    );
  }

  void _applyNewFilters(PropertyListBodyModel newBody) {
    setState(() {
      body = newBody;
      currentPage = 1;
    });
    ref.invalidate(getPropertyController);
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync = ref.watch(getPropertyController(body));
    final cityAsync = ref.watch(getCityController);
    final selectedCityFromHome = ref.watch(currentCityProvider);

    final String pageTitle = widget.initialData != null
        ? '${widget.initialData!.listingCategory?.toUpperCase() ?? ''} '
              '${widget.initialData!.property?.toUpperCase() ?? ''} PROPERTIES'
        : 'Property Listing';

    final userDataBox = Hive.box('userdata');
    final profileImage = userDataBox.get('image', defaultValue: "") as String;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      endDrawer: FilterDrawer(currentFilters: body, onApply: _applyNewFilters),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          pageTitle,
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.filter_alt, color: Color(0xFF24ADD7)),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Let’s Find your',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          color: const Color(0xFF8997A9),
                        ),
                      ),
                      Text(
                        'Favorite Home',
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          color: const Color(0xFF122D4D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFC4C4C4),
                    ),
                    child: ClipOval(
                      child: profileImage.isNotEmpty
                          ? Image.network(
                              profileImage,
                              width: 50.w,
                              height: 50.h,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.person,
                                  size: 35.sp,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.person,
                                size: 35.sp,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    ref.read(searchQueryProvider.notifier).state = value
                        .trim()
                        .toLowerCase();
                    setState(() {
                      body.keyWord = value.trim();
                      currentPage = 1;
                    });
                    ref.invalidate(getPropertyController);
                  },
                  decoration: InputDecoration(
                    hintText: "Search by keyword...",
                    hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF24ADD7),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // Banner
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Image.asset(
                      "assets/particular (2).png",
                      width: double.infinity,
                      height: 140.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 140.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      color: Colors.black.withOpacity(0.35),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Column(
                      children: [
                        Text(
                          'Best Property Consultants in India',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Home Buying, Selling, Renting & Loan Support',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Properties
            Padding(
              padding: EdgeInsets.all(16.w),
              child: propertyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stk) => Center(child: Text("Error: $err")),
                data: (res) {
                  final allProperties = res?.data?.list ?? [];
                  final filteredList = allProperties;

                  if (filteredList.isEmpty) {
                    final searchQuery = ref.read(searchQueryProvider);
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          searchQuery.isNotEmpty
                              ? "No properties found for \"$searchQuery\""
                              : "No properties match your filters",
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.62,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return PropertyCard(property: filteredList[index]);
                    },
                  );
                },
              ),
            ),

            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }
}

// PropertyCard premium redesign
class PropertyCard extends StatelessWidget {
  final ListElement property;

  const PropertyCard({super.key, required this.property});

  String _formatPrice(String? priceStr) {
    if (priceStr == null || priceStr.isEmpty) return '—';
    final price = double.tryParse(priceStr) ?? 0;
    if (price >= 10000000) return '${(price / 10000000).toStringAsFixed(2)} Cr';
    if (price >= 100000) return '${(price / 100000).toStringAsFixed(1)} Lac';
    return price.toStringAsFixed(0);
  }

  Widget _buildActionBtn(
    BuildContext context,
    String text,
    Color bgColor,
    Color textColor,
    bool isOutline,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PerticulerPropertyPage(
              propertyId: property.slug ?? property.id ?? "",
              // data: PropertyDetailsModel.fromListElement(property),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: isOutline ? Border.all(color: textColor, width: 1) : null,
          borderRadius: BorderRadius.circular(8.r),
        ),
        height: 32.h,
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: textColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        (property.uploadedPhotos != null && property.uploadedPhotos!.isNotEmpty)
        ? property.uploadedPhotos!.first
        : "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800";

    final title =
        property.bedRoom == "0" ||
            property.bedRoom == null ||
            property.bedRoom!.isEmpty
        ? "${property.propertyType?.toUpperCase() ?? ''}"
        : "${property.bedRoom} BHK ${property.propertyType?.toUpperCase() ?? ''}";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PerticulerPropertyPage(
              propertyId: property.slug ?? property.id ?? "",
              // data: PropertyDetailsModel.fromListElement(property),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: Stack(
                children: [
                  Image.network(
                    imageUrl,
                    height: 120.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.network(
                      "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800",
                      height: 120.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        "Listed by Owner",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: const Color(0xFF122D4D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12.sp,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          "${property.localityArea ?? ""}, ${property.city ?? ""}",
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "₹ ${_formatPrice(property.price)}",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF24ADD7),
                      fontWeight: FontWeight.w800,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionBtn(
                          context,
                          "View",
                          Colors.white,
                          const Color(0xFF24ADD7),
                          true,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildActionBtn(
                          context,
                          "Contact",
                          const Color(0xFF24ADD7),
                          Colors.white,
                          false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
