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
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final initialCity = widget.initialData?.city ?? "";

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

  int get _activeFilterCount {
    int count = 0;
    if (body.city != null && body.city!.isNotEmpty) count++;
    if (body.locality != null && body.locality!.isNotEmpty) {
      count += body.locality!.length;
    }
    if (body.bedroom != null && body.bedroom!.isNotEmpty) {
      count += body.bedroom!.length;
    }
    if (body.bathrooms != null && body.bathrooms!.isNotEmpty) {
      count += body.bathrooms!.length;
    }
    if (body.kitchen != null && body.kitchen!.isNotEmpty) {
      count += body.kitchen!.length;
    }
    if (body.balcony != null && body.balcony!.isNotEmpty) {
      count += body.balcony!.length;
    }
    if (body.parking != null && body.parking!.isNotEmpty) {
      count += body.parking!.length;
    }
    if (body.minPrice != null && body.minPrice!.isNotEmpty) count++;
    if (body.maxPrice != null && body.maxPrice!.isNotEmpty) count++;
    if (body.furnishing != null && body.furnishing!.isNotEmpty) count++;
    return count;
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF24ADD7).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF24ADD7).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF24ADD7),
            ),
          ),
          SizedBox(width: 4.w),
          InkWell(
            onTap: onDeleted,
            child: Icon(
              Icons.close,
              size: 14.sp,
              color: const Color(0xFF24ADD7),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync = ref.watch(getPropertyController(body));
    final cityAsync = ref.watch(getCityController);
    final selectedCityFromHome = ref.watch(currentCityProvider);

    final isRent =
        (body.listingCategory ?? widget.initialData?.listingCategory)
            ?.toLowerCase() ==
        'rent';
    final action = isRent ? 'RENT' : 'BUY';
    String type = (body.propertyType?.isNotEmpty == true)
        ? body.propertyType!.toUpperCase()
        : (widget.initialData?.property?.toUpperCase() ?? '');
    if (type == "HOME") type = "HOUSE";
    final String pageTitle = widget.initialData != null
        ? '$action $type PROPERTIES'.trim()
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
          style: GoogleFonts.inter(
            color: const Color(0xFF24ADD7),
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.tune, color: Color(0xFF24ADD7)),
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
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
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
                    width: 40.w,
                    height: 40.h,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFC4C4C4),
                    ),
                    child: ClipOval(
                      child: profileImage.isNotEmpty
                          ? Image.network(
                              profileImage,
                              width: 40.w,
                              height: 40.h,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.person,
                                  size: 25.sp,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.person,
                                size: 25.sp,
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
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
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
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Image.asset(
                      "assets/particular (2).png",
                      width: double.infinity,
                      height: 130.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 130.h,
                        color: const Color(0xFF24ADD7),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 130.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      color: Colors.black.withOpacity(0.38),
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
                        SizedBox(height: 4.h),
                        Text(
                          'Home Buying, Selling, Renting & Loan Support',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==================== WEBSITE-STYLE ACTIONS ====================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  // My Properties button (website style)
                  InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF24ADD7),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF24ADD7).withOpacity(0.32),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home_work_outlined,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "My Properties",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Filters & Sorting button (website mobile style)
                  Builder(
                    builder: (scaffoldContext) => InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTap: () {
                        Scaffold.of(scaffoldContext).openEndDrawer();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF97316,
                          ), // Orange matching website
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF97316).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.tune, color: Colors.white, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text(
                              "Filters & Sorting",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                              ),
                            ),
                            if (_activeFilterCount > 0) ...[
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 7.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  "$_activeFilterCount",
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFF97316),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Active Filter Chips (if any filters applied)
                  if (_activeFilterCount > 0) ...[
                    SizedBox(height: 12.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (body.city != null && body.city!.isNotEmpty)
                            _buildFilterChip("City: ${body.city}", () {
                              setState(() => body.city = "");
                              ref.invalidate(getPropertyController);
                            }),
                          if (body.bedroom != null && body.bedroom!.isNotEmpty)
                            ...body.bedroom!.map(
                              (b) => _buildFilterChip("$b BHK", () {
                                setState(() => body.bedroom!.remove(b));
                                ref.invalidate(getPropertyController);
                              }),
                            ),
                          if (body.bathrooms != null &&
                              body.bathrooms!.isNotEmpty)
                            ...body.bathrooms!.map(
                              (b) => _buildFilterChip("$b Bath", () {
                                setState(() => body.bathrooms!.remove(b));
                                ref.invalidate(getPropertyController);
                              }),
                            ),
                          if (body.minPrice != null &&
                              body.minPrice!.isNotEmpty)
                            _buildFilterChip("Min: ₹${body.minPrice}", () {
                              setState(() => body.minPrice = "");
                              ref.invalidate(getPropertyController);
                            }),
                          if (body.maxPrice != null &&
                              body.maxPrice!.isNotEmpty)
                            _buildFilterChip("Max: ₹${body.maxPrice}", () {
                              setState(() => body.maxPrice = "");
                              ref.invalidate(getPropertyController);
                            }),
                          if (body.furnishing != null &&
                              body.furnishing!.isNotEmpty)
                            _buildFilterChip(
                              "Furnishing: ${body.furnishing}",
                              () {
                                setState(() => body.furnishing = null);
                                ref.invalidate(getPropertyController);
                              },
                            ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                body = PropertyListBodyModel(
                                  size: 20,
                                  pageNo: 1,
                                  sortBy: 'createdAt',
                                  sortOrder: 'desc',
                                  city: widget.initialData?.city ?? "",
                                  propertyType:
                                      widget.initialData?.propertyType ?? "",
                                  listingCategory:
                                      widget.initialData?.listingCategory ?? "",
                                  keyWord: "",
                                  balcony: [],
                                  bathrooms: [],
                                  bedroom: [],
                                  kitchen: [],
                                  locality: [],
                                  parking: [],
                                );
                              });
                              ref.invalidate(getPropertyController);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              child: Text(
                                "Clear All",
                                style: GoogleFonts.inter(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Properties Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
                        child: Text(
                          "Showing ${filteredList.length} properties",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      GridView.builder(
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
                      ),
                    ],
                  );
                },
              ),
            ),

            SizedBox(height: 100.h),
          ],
        ),
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
