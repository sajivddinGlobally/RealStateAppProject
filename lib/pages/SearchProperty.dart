
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:realstate/Controller/getPropertyController.dart';
// import 'package:realstate/Controller/getCityListController.dart';
// import 'package:realstate/Model/Body/PropertyListBodyModel.dart';
// import 'package:realstate/Model/getPropertyResponsemodel.dart';
// import 'package:realstate/pages/perticulerProperty.page.dart';

// const String _cityBoxName = 'user_prefs';
// const String _cityKey = 'user_city';

// class SearchPropertyPage extends ConsumerStatefulWidget {
//   final ListElement? initialData;

//   const SearchPropertyPage({this.initialData, super.key});

//   @override
//   ConsumerState<SearchPropertyPage> createState() => _SearchPropertyPageState();
// }

// class _SearchPropertyPageState extends ConsumerState<SearchPropertyPage> {
//   int currentPage = 1;
//   late PropertyListBodyModel body;

//   RangeValues _priceRange = const RangeValues(0, 7000000);
//   final TextEditingController _minPriceCtrl = TextEditingController(text: "0");
//   final TextEditingController _maxPriceCtrl = TextEditingController(
//     text: "7000000",
//   );

//   final List<String> bhkOptions = ["1", "2", "3", "4", "5", "6", "7", "8+"];
//   late List<bool> selectedBHK;

//   final List<String> items = [
//     "1 BHK",
//     "2 BHK",
//     "3 BHK",
//     "4 BHK",
//     "5 BHK",
//     "6 BHK",
//     "7 BHK",
//     "8+ BHK",
//   ];
//   late List<bool> selected;

//   List<String> cityOptions = [];
//   late List<bool> selectedCities;

//   bool _citiesLoaded = false;
//   bool _initialCityApplied = false;

//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';

//   List<ListElement> _loadedProperties = [];

//   @override
//   void initState() {
//     super.initState();
//     selectedBHK = List<bool>.filled(bhkOptions.length, false);
//     selected = List<bool>.filled(items.length, false);

//     _resetAllFilters();

//     _searchController.addListener(() {
//       if (mounted) {
//         setState(() {
//           _searchQuery = _searchController.text.trim().toLowerCase();
//         });
//       }
//     });
//   }

//   void _resetAllFilters() {
//     setState(() {
//       _priceRange = const RangeValues(0, 7000000);
//       _minPriceCtrl.text = "0";
//       _maxPriceCtrl.text = "7000000";
//       selectedBHK.fillRange(0, selectedBHK.length, false);
//       selected.fillRange(0, selected.length, false);
//       if (_citiesLoaded) {
//         selectedCities.fillRange(0, selectedCities.length, false);
//       }
//       _searchController.clear();
//       _searchQuery = '';
//       currentPage = 1;
//       _loadedProperties.clear();

//       body = PropertyListBodyModel(
//         size: 20,
//         pageNo: currentPage,
//         sortBy: 'createdAt',
//         sortOrder: 'desc',
//       );
//     });
//   }

//   String _formatPrice(num price) {
//     if (price >= 10000000) return '${(price / 10000000).toStringAsFixed(2)} Cr';
//     if (price >= 100000) return '${(price / 100000).toStringAsFixed(1)} Lac';
//     return price.toStringAsFixed(0);
//   }

//   void _applyFilters() {
//     setState(() {
//       currentPage = 1;
//       body = PropertyListBodyModel(
//         size: 20,
//         pageNo: currentPage,
//         sortBy: 'createdAt',
//         sortOrder: 'desc',
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final propertyAsync = ref.watch(getPropertyController(body));
//     final cityAsync = ref.watch(getCityController);

//     final pageTitle = widget.initialData != null
//         ? '${widget.initialData!.listingCategory?.toUpperCase() ?? ''} '
//               '${widget.initialData!.property?.toUpperCase() ?? ''} Properties'
//         : 'Property Listing';

//     return Scaffold(
//       backgroundColor: const Color(0xFFF9FBFF),
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           pageTitle,
//           style: TextStyle(
//             color: Color(0xFF24ADD7),
//             fontWeight: FontWeight.bold,
//             fontSize: 22.sp,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: cityAsync.when(
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, stk) => Center(child: Text("Cities failed to load: $err")),
//         data: (cityResponse) {
//           if (!_citiesLoaded && cityResponse?.data != null) {
//             cityOptions = cityResponse.data!
//                 .map((d) => d.cityName ?? "")
//                 .where((name) => name.isNotEmpty)
//                 .toList();

//             selectedCities = List<bool>.filled(cityOptions.length, false);
//             _citiesLoaded = true;

//             if (!_initialCityApplied) {
//               _applySavedCityFilter();
//             }
//           }

//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Search bar
//                 Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 25.w,
//                     vertical: 16.h,
//                   ),
//                   child: Container(
//                     height: 54.h,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(30.r),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.10),
//                           blurRadius: 16,
//                           offset: const Offset(0, 8),
//                         ),
//                       ],
//                     ),
//                     child: TextField(
//                       controller: _searchController,
//                       decoration: InputDecoration(
//                         hintText: "Search city, area, BHK, price...",
//                         hintStyle: GoogleFonts.inter(
//                           color: Colors.grey[500],
//                           fontSize: 14.sp,
//                         ),
//                         prefixIcon: Icon(
//                           Icons.search_rounded,
//                           color: Colors.grey[700],
//                         ),
//                         suffixIcon: _searchQuery.isNotEmpty
//                             ? IconButton(
//                                 icon: const Icon(
//                                   Icons.clear,
//                                   color: Colors.grey,
//                                 ),
//                                 onPressed: () => _searchController.clear(),
//                               )
//                             : null,
//                         border: InputBorder.none,
//                         contentPadding: EdgeInsets.symmetric(
//                           vertical: 16.h,
//                           horizontal: 16.w,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Apply Filters Button
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 25.w),
//                   child: SizedBox(
//                     width: double.infinity,
//                     height: 52.h,
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.filter_alt, color: Colors.white),
//                       label: Text(
//                         "Apply Filters",
//                         style: GoogleFonts.inter(
//                           color: Colors.white,
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF24ADD7),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30.r),
//                         ),
//                       ),
//                       onPressed: _applyFilters,
//                     ),
//                   ),
//                 ),

//                 SizedBox(height: 20.h),

//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.w),
//                   child: propertyAsync.when(
//                     loading: () =>
//                         const Center(child: CircularProgressIndicator()),
//                     error: (err, stk) => Center(child: Text("Error: $err")),
//                     data: (res) {
//                       final newProperties = res?.data?.list ?? [];

//                       final allLoaded = [
//                         ..._loadedProperties,
//                         ...newProperties,
//                       ].toSet().toList();

//                       if (_loadedProperties.length != allLoaded.length) {
//                         setState(() => _loadedProperties = allLoaded);
//                       }

//                       final displayed = _loadedProperties.where((prop) {
//                         // Debug print – production mein remove kar dena
//                         print(
//                           "Property: ${prop.city} | BHK: ${prop.bedRoom} | ₹${prop.price} | Query: '$_searchQuery'",
//                         );

//                         // Price filter
//                         final price = double.tryParse(prop.price ?? '0') ?? 0;
//                         if (price < _priceRange.start ||
//                             price > _priceRange.end) {
//                           print("  Rejected: Price out of range");
//                           return false;
//                         }

//                         // BHK filter
//                         final bhkStr = prop.bedRoom ?? '';
//                         final bhkNum = int.tryParse(bhkStr) ?? 0;
//                         if (selectedBHK.any((sel) => sel)) {
//                           bool bhkMatch = false;
//                           for (int i = 0; i < bhkOptions.length; i++) {
//                             if (selectedBHK[i]) {
//                               final opt = bhkOptions[i];
//                               if (opt == "8+" && bhkNum >= 8) bhkMatch = true;
//                               if (bhkStr == opt) bhkMatch = true;
//                             }
//                           }
//                           if (!bhkMatch) {
//                             print("  Rejected: BHK not matching");
//                             return false;
//                           }
//                         }

//                         // City checkbox filter – SEARCH ACTIVE HONE PAR IGNORE
//                         final propCityLower = (prop.city ?? '')
//                             .trim()
//                             .toLowerCase();
//                         if (_searchQuery.isEmpty &&
//                             selectedCities.any((sel) => sel)) {
//                           bool cityMatch = false;
//                           for (int i = 0; i < cityOptions.length; i++) {
//                             if (selectedCities[i] &&
//                                 propCityLower ==
//                                     cityOptions[i].toLowerCase().trim()) {
//                               cityMatch = true;
//                               break;
//                             }
//                           }
//                           if (!cityMatch) {
//                             print(
//                               "  Rejected: City checkbox filter - ${prop.city}",
//                             );
//                             return false;
//                           }
//                         }

//                         // // Search logic
//                         // if (_searchQuery.isNotEmpty) {
//                         //   final q = _searchQuery.toLowerCase();

//                         //   final cityLower = propCityLower;
//                         //   final areaLower = (prop.localityArea ?? '')
//                         //       .trim()
//                         //       .toLowerCase();
//                         //   final bhkLower = bhkStr.trim().toLowerCase();
//                         //   final priceFormatted = _formatPrice(
//                         //     price,
//                         //   ).toLowerCase();
//                         //   final rawPrice = (prop.price ?? '').toLowerCase();

//                         //   final match =
//                         //       cityLower.contains(q) ||
//                         //       areaLower.contains(q) ||
//                         //       bhkLower.contains(q) ||
//                         //       "${bhkLower}bhk".contains(q) ||
//                         //       priceFormatted.contains(q) ||
//                         //       rawPrice.contains(q);

//                         //   if (!match) {
//                         //     print(
//                         //       "  Rejected by search → $q not found in $cityLower / $areaLower",
//                         //     );
//                         //     return false;
//                         //   }
//                         //   print("  Accepted by search");
//                         // }
//                         if (_searchQuery.isNotEmpty) {
//                           final q = _searchQuery.toLowerCase().trim();

//                           final match =
//                               (prop.city ?? '').toLowerCase().contains(q) ||
//                               (prop.localityArea ?? '').toLowerCase().contains(
//                                 q,
//                               ) ||
//                               (prop.property ?? '').toLowerCase().contains(q) ||
//                               (prop.propertyType ?? '').toLowerCase().contains(
//                                 q,
//                               ) ||
//                               (prop.listingCategory ?? '')
//                                   .toLowerCase()
//                                   .contains(q) ||
//                               (prop.bedRoom ?? '').toLowerCase().contains(q) ||
//                               (prop.bathrooms ?? '').toLowerCase().contains(
//                                 q,
//                               ) ||
//                               (prop.furnishing ?? '').toLowerCase().contains(
//                                 q,
//                               ) ||
//                               (prop.area ?? '').toLowerCase().contains(q) ||
//                               (prop.propertyAddress ?? '')
//                                   .toLowerCase()
//                                   .contains(q) ||
//                               (prop.description ?? '').toLowerCase().contains(
//                                 q,
//                               ) ||
//                               (prop.price ?? '').toLowerCase().contains(q) ||
//                               (prop.uploadBy?.name ?? '')
//                                   .toLowerCase()
//                                   .contains(q) ||
//                               (prop.uploadBy?.email ?? '')
//                                   .toLowerCase()
//                                   .contains(q) ||
//                               (prop.amenities
//                                       ?.join(' ')
//                                       .toLowerCase()
//                                       .contains(q) ??
//                                   false);

//                           if (!match) {
//                             return false;
//                           }
//                         }

//                         print("  → SHOWING THIS PROPERTY");
//                         return true;
//                       }).toList();

//                       if (displayed.isEmpty) {
//                         return Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(32),
//                             child: Text(
//                               _searchQuery.isNotEmpty
//                                   ? "No properties found for \"$_searchQuery\""
//                                   : "No properties match current filters",
//                               style: TextStyle(
//                                 fontSize: 16.sp,
//                                 color: Colors.grey[600],
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         );
//                       }

//                       return GridView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           childAspectRatio: 0.58,
//                           mainAxisSpacing: 12.h,
//                           crossAxisSpacing: 12.w,
//                         ),
//                         itemCount: displayed.length,
//                         itemBuilder: (context, index) =>
//                             PropertyCard(property: displayed[index]),
//                       );
//                     },
//                   ),
//                 ),

//                 SizedBox(height: 120.h),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Future<void> _applySavedCityFilter() async {
//     if (_initialCityApplied) return;

//     try {
//       final box = await Hive.openBox(_cityBoxName);
//       final saved = box.get(_cityKey) as String?;

//       if (saved != null && saved.trim().isNotEmpty && mounted) {
//         final normalized = saved.trim().toLowerCase();

//         final idx = cityOptions
//             .map((c) => c.toLowerCase().trim())
//             .toList()
//             .indexOf(normalized);

//         if (idx != -1) {
//           print("Auto-selecting saved city: $saved (index $idx)");
//           setState(() {
//             selectedCities.fillRange(0, selectedCities.length, false);
//             selectedCities[idx] = true;
//           });

//           // Auto apply filter taaki sirf saved city ki properties dikhe
//           _applyFilters();
//         } else {
//           print("Saved city '$saved' API cities list mein nahi mila");
//         }
//       } else {
//         print("No saved city in Hive");
//       }
//     } catch (e) {
//       debugPrint("Error applying saved city: $e");
//     }

//     _initialCityApplied = true;
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _minPriceCtrl.dispose();
//     _maxPriceCtrl.dispose();
//     super.dispose();
//   }
// }
