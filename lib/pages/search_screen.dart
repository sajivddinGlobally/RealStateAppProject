import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realstate/Model/commonLoanModel.dart';
import 'package:realstate/pages/perticulerProperty.page.dart';
import '../Model/commanLoanModel.dart';
import '../Model/propertyDetailModel.dart';
import '../Model/searchPropertyListResponse.dart';
import '../core/network/api.state.dart';
import '../core/utils/preety.dio.dart';
import 'package:flutter/cupertino.dart';

import 'homeServiceDetails.page.dart';
import 'loanServiceDetails.page.dart';

class SearchResultScreen extends ConsumerStatefulWidget {
  String? selectedCity;

  SearchResultScreen(this.selectedCity, {super.key});

  @override
  ConsumerState<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends ConsumerState<SearchResultScreen> {
  final TextEditingController searchController = TextEditingController();
  SearchPropertyListResponse? searchResponse;
  bool isLoading = false;

  Future<void> searchProperty(String keyword) async {
    if (keyword.trim().isEmpty) {
      if (mounted) {
        setState(() {
          searchResponse = null;
        });
      }
      return;
    }
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      final service = APIStateNetwork(createDio());

      final response = await service.universalSearch(keyword);

      if (mounted) {
        setState(() {
          searchResponse = response;
        });
      }
    } catch (e, st) {
      debugPrint("Search Error: $e");
      log(st.toString());
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _formatPrice(num price) {
    if (price >= 10000000) return '${(price / 10000000).toStringAsFixed(2)} Cr';
    if (price >= 100000) return '${(price / 100000).toStringAsFixed(1)} Lac';
    return price.toStringAsFixed(0);
  }

  @override
  void initState() {
    super.initState();
    if (widget.selectedCity != null && widget.selectedCity!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        searchProperty(widget.selectedCity!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final properties = searchResponse?.data?.properties ?? [];
    final services = searchResponse?.data?.services ?? [];
    final loans = searchResponse?.data?.loans ?? [];
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Search",
          style: TextStyle(
            color: Color(0xFF24ADD7),
            fontWeight: FontWeight.bold,
            fontSize: 22.sp,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 16.h),
            child: Container(
              height: 54.h,
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
                controller: searchController,
                onChanged: (value) {
                  searchProperty(value);
                },
                decoration: InputDecoration(
                  hintText: "Search city, area, BHK, price...",
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey[500],
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey[700],
                  ),
                  suffixIcon: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();

                            setState(() {
                              searchResponse = null;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16.h,
                    horizontal: 16.w,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: searchResponse == null
                ? const Center(child: Text("Start typing to search"))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      /// PROPERTIES
                      if (properties.isNotEmpty) ...[
                        const Text(
                          "Properties",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.58,
                                mainAxisSpacing: 12.h,
                                crossAxisSpacing: 12.w,
                              ),
                          itemCount: properties.length,
                          itemBuilder: (context, index) {
                            final property = properties[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PerticulerPropertyPage(
                                          data:
                                              PropertyDetailsModel.fromProperty(
                                                property,
                                              ),
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(14.r),
                                      ),
                                      child: Image.network(
                                        property.uploadedPhotos!.first ?? "",
                                        height: 110.h,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Image.network(
                                          "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800",
                                          height: 110.h,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10.w),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${int.tryParse(property.bedRoom ?? '0') ?? '?'} BHK ${property.propertyType ?? ""}",
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 10.sp,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  "${property.localityArea ?? ""}, ${property.city ?? ""}",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 8.sp,
                                                    color: Colors.grey[700],
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),

                                          Text(
                                            "₹ ${property.price}",
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFF24ADD7),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Container(
                                      margin: EdgeInsets.only(left: 10.w),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Listed by Owner",
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10.sp,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Container(
                                      padding: EdgeInsets.only(
                                        left: 10.w,
                                        right: 10.w,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                color: Color(0xff8A38F5),
                                              ),
                                              height: 25.h,
                                              child: Center(
                                                child: Text(
                                                  '${property.bedRoom} BHK',
                                                  // "3 BHK",
                                                  style: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontSize: 8.sp,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                color: Color(0xff8A38F5),
                                              ),
                                              height: 25.h,
                                              child: Center(
                                                child: Text(
                                                  '${property.propertyType}',
                                                  // "Apartment",
                                                  style: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontSize: 8.sp,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 12.h),

                                    Container(
                                      padding: EdgeInsets.only(
                                        left: 10.w,
                                        right: 10.w,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PerticulerPropertyPage(
                                                          data:
                                                              PropertyDetailsModel.fromProperty(
                                                                property,
                                                              ),
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey[400]!,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  // color: Color(0xff8A38F5)
                                                ),
                                                height: 30.h,
                                                child: Center(
                                                  child: Text(
                                                    "View",
                                                    style: GoogleFonts.inter(
                                                      color: Colors.black,
                                                      fontSize: 8.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),

                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PerticulerPropertyPage(
                                                          data:
                                                              PropertyDetailsModel.fromProperty(
                                                                property,
                                                              ),
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  // border: Border.all(color:Colors.grey[400]! ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: const Color(
                                                    0xFF24ADD7,
                                                  ),
                                                ),
                                                height: 30.h,
                                                child: Center(
                                                  child: Text(
                                                    "Contact",
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontSize: 8.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                      ],

                      /// SERVICES
                      if (services.isNotEmpty) ...[
                        const Text(
                          "Services",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ...services.map(
                          (service) => GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 0.75,
                                  mainAxisSpacing: 12.h,
                                  crossAxisSpacing: 12.w,
                                ),
                            itemCount: services.length,
                            itemBuilder: (context, index) {
                              final service = services[index];

                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) =>
                                              HomeServiceDetailsPage(
                                                // service: item,
                                                id: service.id.toString(),
                                              ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Image.network(
                                        // categories[index]['url']!,
                                        service.image ??
                                            "https://s3-media0.fl.yelpcdn.com/bphoto/y2N9GweV0RhaXx9dYbXHTA/l.jpg",
                                        width: 80.w,
                                        height: 80.h,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Container(
                                                width: 80.w,
                                                height: 80.h,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.r,
                                                      ),
                                                  color: Colors.grey.shade300,
                                                ),
                                                child: Center(
                                                  child: SizedBox(
                                                    width: 20.w,
                                                    height: 20.h,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color:
                                                              Colors.deepOrange,
                                                          strokeWidth: 1.w,
                                                        ),
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    //  categories[index]['label']!,
                                    service.name ?? "N/A",
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                ],
                              );
                            },
                          ),
                        ),
                      ],

                      /// LOANS
                      if (loans.isNotEmpty) ...[
                        const Text(
                          "Loans",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ...loans.map(
                          (loan) => GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 0.65,
                                  mainAxisSpacing: 12.h,
                                  crossAxisSpacing: 12.w,
                                ),
                            itemCount: loans.length,
                            itemBuilder: (context, index) {
                              final loan = loans[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LoanServiceDetailsPage(
                                        item: CommonLoanModel.fromSearchLoan(
                                          loan,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                        child:
                                            (loan.bankLogo?.trim().isNotEmpty ??
                                                false)
                                            ? Image.network(
                                                loan.bankLogo!,
                                                width: 100.w,
                                                height: 55.h,
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        width: 100.w,
                                                        height: 55.h,
                                                        alignment:
                                                            Alignment.center,
                                                        child: Icon(
                                                          Icons
                                                              .broken_image_outlined,
                                                          size: 40.sp,
                                                          color: Colors.grey,
                                                        ),
                                                      );
                                                    },
                                              )
                                            : Container(
                                                width: 100.w,
                                                height: 55.h,
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.broken_image_outlined,
                                                  size: 40.sp,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),

                                      SizedBox(height: 6.h),
                                      Text(
                                        // loanList[index].title,
                                        loan.name ?? "N/A",
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        height: 28.h,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF24ADD7),
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Contact Now",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      SizedBox(height: 20.h),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
