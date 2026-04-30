/*

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:realstate/Controller/getPropertyController.dart';
import 'package:realstate/Controller/getCityListController.dart';
import 'package:realstate/Model/Body/PropertyListBodyModel.dart';
import 'package:realstate/Model/getPropertyResponsemodel.dart';
import 'package:realstate/pages/perticulerProperty.page.dart';

// Hive constants - same as home screen
const String _cityBoxName = 'user_prefs';
const String _cityKey = 'user_city';

class SearchPropertyPage extends ConsumerStatefulWidget {
  final ListElement? initialData;

  const SearchPropertyPage({
    this.initialData,
    super.key,
  });

  @override
  ConsumerState<SearchPropertyPage> createState() => _SearchPropertyPageState();
}

class _SearchPropertyPageState extends ConsumerState<SearchPropertyPage> {
  int currentPage = 1;
  late PropertyListBodyModel body;

  RangeValues _priceRange = const RangeValues(0, 7000000);
  final TextEditingController _minPriceCtrl = TextEditingController(text: "0");
  final TextEditingController _maxPriceCtrl = TextEditingController(text: "7000000");

  final List<String> bhkOptions = ["1", "2", "3", "4", "5", "6", "7", "8+"];
  late List<bool> selectedBHK;

  final List<String> items = [
    "1 BHK",
    "2 BHK",
    "3 BHK",
    "4 BHK",
    "5 BHK",
    "6 BHK",
    "7 BHK",
    "8+ BHK"
  ];
  late List<bool> selected;

  // Dynamic cities
  List<String> cityOptions = [];
  late List<bool> selectedCities;

  bool _citiesLoaded = false;
  String? _savedCityFromHive;

  @override
  void initState() {
    super.initState();
    selectedBHK = List<bool>.filled(bhkOptions.length, false);
    selected = List<bool>.filled(items.length, false);

    _resetFilters();
    _applyFilters(); // initial load without filters

    // Hive se city load karo
    _loadSavedCityFromHive();
  }

  Future<void> _loadSavedCityFromHive() async {
    try {
      final box = await Hive.openBox(_cityBoxName);
      final saved = box.get(_cityKey) as String?;

      debugPrint("SearchPropertyPage: Hive se saved city mila → $saved");

      if (saved != null && saved.trim().isNotEmpty && mounted) {
        setState(() {
          _savedCityFromHive = saved.trim();
        });
      }
    } catch (e) {
      debugPrint("Hive load error in SearchPropertyPage: $e");
    }
  }

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 7000000);
      _minPriceCtrl.text = "0";
      _maxPriceCtrl.text = "7000000";
      selectedBHK.fillRange(0, selectedBHK.length, false);
      selected.fillRange(0, selected.length, false);
      currentPage = 1;

      body = PropertyListBodyModel(
        size: 20,
        pageNo: currentPage,
        sortBy: 'createdAt',
        sortOrder: 'desc',
      );
    });
  }

  String _formatPrice(num price) {
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(1)} Lac';
    } else {
      return price.toStringAsFixed(0);
    }
  }

  void _applyFilters() {
    setState(() {
      currentPage = 1;
      body = PropertyListBodyModel(
        size: 20,
        pageNo: currentPage,
        sortBy: 'createdAt',
        sortOrder: 'desc',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync = ref.watch(getPropertyController(body));
    final cityAsync = ref.watch(getCityController);

    final String pageTitle = widget.initialData != null
        ? '${widget.initialData!.listingCategory?.toUpperCase() ?? ''} '
        '${widget.initialData!.property?.toUpperCase() ?? ''} Properties'
        : 'Property Listing';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
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
            fontSize: 22.sp,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: cityAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stk) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Cities failed to load: $err"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(getCityController),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
        data: (cityResponse) {
          if (!_citiesLoaded && cityResponse?.data != null) {
            cityOptions = cityResponse.data!
                .map((d) => d.cityName ?? "")
                .where((name) => name.isNotEmpty)
                .toList();

            selectedCities = List<bool>.filled(cityOptions.length, false);

            debugPrint("API se cities aayi: ${cityOptions.join(', ')}");
            debugPrint("Hive saved city: $_savedCityFromHive");
            debugPrint("initialData?.city: ${widget.initialData?.city}");

            // Pehle Hive saved city ko priority do (Jaipur wala case)
            if (_savedCityFromHive != null) {
              final normalizedSaved = _savedCityFromHive!.toLowerCase().trim();
              final idx = cityOptions
                  .map((c) => c.toLowerCase().trim())
                  .toList()
                  .indexOf(normalizedSaved);

              if (idx != -1) {
                selectedCities[idx] = true;
                debugPrint("Hive city match mila → $normalizedSaved (index $idx)");

                // Auto apply filters taaki properties load ho
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _applyFilters();
                    debugPrint("Filters auto-apply hue saved city ke saath");
                  }
                });
              } else {
                debugPrint("Hive ka city API list mein nahi mila");
              }
            }

            // Agar Hive nahi mila, tab initialData check karo
            else if (widget.initialData?.city != null) {
              final incoming = widget.initialData!.city!.toLowerCase().trim();
              final idx = cityOptions
                  .map((c) => c.toLowerCase().trim())
                  .toList()
                  .indexOf(incoming);

              if (idx != -1) {
                selectedCities[idx] = true;
                debugPrint("initialData city select hua: ${widget.initialData!.city}");
              }
            }

            _citiesLoaded = true;
          }

          return SingleChildScrollView(
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
                            style: GoogleFonts.inter(fontSize: 16.sp, color: const Color(0xFF8997A9)),
                          ),
                          Text(
                            'Favorite Home',
                            style: GoogleFonts.inter(fontSize: 18.sp, color: const Color(0xFF122D4D), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        width: 50.w,
                        height: 50.h,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFC4C4C4)),
                        child: ClipOval(
                          child: Image.network(
                            "https://img.freepik.com/free-photo/plumber-fixing-pipe_23-2149371490.jpg",
                            width: 50.w,
                            height: 50.h,
                            fit: BoxFit.cover,
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
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 16, offset: const Offset(0, 8))],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search",
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
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
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              'Home Buying, Selling, Renting & Loan Support',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter header
                Container(
                  height: 45.h,
                  margin: EdgeInsets.symmetric(horizontal: 25.w),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF24ADD7),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Filter",
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                // Filter content
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 25.w),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.r), bottomRight: Radius.circular(20.r)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Price Range", style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w500)),

                      SizedBox(height: 12.h),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _minPriceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Min Price",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                              onChanged: (val) {
                                final min = double.tryParse(val.replaceAll(',', '')) ?? 0;
                                setState(() {
                                  _priceRange = RangeValues(min.clamp(0, _priceRange.end), _priceRange.end);
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: TextField(
                              controller: _maxPriceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Max Price",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                              onChanged: (val) {
                                final max = double.tryParse(val.replaceAll(',', '')) ?? 7000000;
                                setState(() {
                                  _priceRange = RangeValues(_priceRange.start, max.clamp(_priceRange.start, 7000000));
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                          trackHeight: 6,
                        ),
                        child: RangeSlider(
                          values: _priceRange,
                          min: 0,
                          max: 7000000,
                          divisions: 70,
                          activeColor: const Color(0xFF24ADD7),
                          inactiveColor: Colors.grey.shade300,
                          labels: RangeLabels(
                            _formatPrice(_priceRange.start),
                            _formatPrice(_priceRange.end),
                          ),
                          onChanged: (RangeValues values) {
                            setState(() {
                              _priceRange = values;
                              _minPriceCtrl.text = values.start.toStringAsFixed(0);
                              _maxPriceCtrl.text = values.end.toStringAsFixed(0);
                            });
                          },
                        ),
                      ),

                      const Divider(height: 40, thickness: 1.5),

                      Text("Bedroom", style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w500)),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        itemCount: items.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3.5,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 8,
                        ),
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Checkbox(
                                value: selected[index],
                                activeColor: const Color(0xFF24ADD7),
                                onChanged: (value) {
                                  setState(() {
                                    selected[index] = value!;
                                    final bhkVal = items[index].split(" ")[0];
                                    final bhkIdx = bhkOptions.indexOf(bhkVal);
                                    if (bhkIdx != -1) selectedBHK[bhkIdx] = value;
                                  });
                                },
                              ),
                              Text(items[index], style: GoogleFonts.inter(fontSize: 14.sp)),
                            ],
                          );
                        },
                      ),

                      const Divider(height: 40, thickness: 1.5),

                      Text("City", style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w500)),

                      SizedBox(height: 12.h),

                      if (cityOptions.isEmpty)
                        const Center(child: Text("No cities available"))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cityOptions.length,
                          itemBuilder: (context, index) {
                            return CheckboxListTile(
                              value: selectedCities[index],
                              activeColor: const Color(0xFF24ADD7),
                              title: Text(cityOptions[index], style: GoogleFonts.inter(fontSize: 14.sp)),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (value) {
                                setState(() {
                                  selectedCities[index] = value!;
                                });
                              },
                            );
                          },
                        ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.search, color: Colors.white),
                          label: Text("Apply Filters", style: GoogleFonts.inter(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF24ADD7),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                          ),
                          onPressed: _applyFilters,
                        ),
                      ),
                    ],
                  ),
                ),

                // Properties list
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: propertyAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stk) => Center(child: Text("Error: $err")),
                    data: (res) {
                      final allProperties = res?.data?.list ?? [];

                      final filteredList = allProperties.where((prop) {
                        // Property type & category filter
                        if (widget.initialData != null) {
                          final expProp = widget.initialData!.property?.toLowerCase() ?? '';
                          final expCat = widget.initialData!.listingCategory?.toLowerCase() ?? '';
                          if ((prop.property?.toLowerCase() ?? '') != expProp ||
                              (prop.listingCategory?.toLowerCase() ?? '') != expCat) {
                            return false;
                          }
                        }

                        // City filter
                        final propCity = prop.city?.toLowerCase() ?? '';
                        if (selectedCities.any((sel) => sel)) {
                          bool match = false;
                          for (int i = 0; i < cityOptions.length; i++) {
                            if (selectedCities[i] && propCity == cityOptions[i].toLowerCase().trim()) {
                              match = true;
                              break;
                            }
                          }
                          if (!match) return false;
                        }

                        // Price filter
                        final price = double.tryParse(prop.price ?? '0') ?? 0;
                        if (price < _priceRange.start || price > _priceRange.end) return false;

                        // BHK filter
                        final bhkStr = prop.bedRoom ?? '';
                        final bhkNum = int.tryParse(bhkStr) ?? 0;

                        if (selectedBHK.any((sel) => sel)) {
                          bool bhkMatch = false;
                          for (int i = 0; i < bhkOptions.length; i++) {
                            if (selectedBHK[i]) {
                              final opt = bhkOptions[i];
                              if (opt == "8+" && bhkNum >= 8) {
                                bhkMatch = true;
                                break;
                              }
                              if (bhkStr == opt) {
                                bhkMatch = true;
                                break;
                              }
                            }
                          }
                          if (!bhkMatch) return false;
                        }

                        return true;
                      }).toList();

                      if (filteredList.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              "No properties match your filters",
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
                          childAspectRatio: 0.58,
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
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }
}

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

  @override
  Widget build(BuildContext context) {
    final imageUrl = (property.uploadedPhotos != null && property.uploadedPhotos!.isNotEmpty)
        ? property.uploadedPhotos!.first
        : "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PerticulerPropertyPage(data: property),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
              child: Image.network(
                imageUrl,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${int.tryParse(property.bedRoom ?? '0') ?? '?'} BHK ${property.propertyType ?? ""}",
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 10.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "${property.localityArea ?? ""}, ${property.city ?? ""}",
                          style: GoogleFonts.inter(fontSize: 8.sp, color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "₹ ${_formatPrice(property.price)}",
                    style: GoogleFonts.inter(color: const Color(0xFF24ADD7), fontWeight: FontWeight.bold, fontSize: 10.sp),
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
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 10.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.only(left: 10.w, right: 10.w),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: const Color(0xff8A38F5),
                      ),
                      height: 25.h,
                      child: Center(
                        child: Text(
                          '${property.bedRoom} BHK',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 8.sp),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: const Color(0xff8A38F5),
                      ),
                      height: 25.h,
                      child: Center(
                        child: Text(
                          '${property.propertyType}',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 8.sp),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.only(left: 10.w, right: 10.w),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PerticulerPropertyPage(data: property),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 30.h,
                        child: Center(
                          child: Text(
                            "View",
                            style: GoogleFonts.inter(color: Colors.black, fontSize: 8.sp),
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
                            builder: (context) => PerticulerPropertyPage(data: property),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFF24ADD7),
                        ),
                        height: 30.h,
                        child: Center(
                          child: Text(
                            "Contact",
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 8.sp),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}*/

/*

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:realstate/Controller/getPropertyController.dart';
import 'package:realstate/Controller/getCityListController.dart';
import 'package:realstate/Model/Body/PropertyListBodyModel.dart';
import 'package:realstate/Model/getPropertyResponsemodel.dart';
import 'package:realstate/pages/perticulerProperty.page.dart';

// Hive constants
const String _cityBoxName = 'user_prefs';
const String _cityKey = 'user_city';

class SearchPropertyPage extends ConsumerStatefulWidget {
  final ListElement? initialData;

  const SearchPropertyPage({this.initialData, super.key});

  @override
  ConsumerState<SearchPropertyPage> createState() => _SearchPropertyPageState();
}

class _SearchPropertyPageState extends ConsumerState<SearchPropertyPage> {
  int currentPage = 1;
  late PropertyListBodyModel body;

  RangeValues _priceRange = const RangeValues(0, 7000000);
  final TextEditingController _minPriceCtrl = TextEditingController(text: "0");
  final TextEditingController _maxPriceCtrl = TextEditingController(text: "7000000");

  final List<String> bhkOptions = ["1", "2", "3", "4", "5", "6", "7", "8+"];
  late List<bool> selectedBHK;

  final List<String> items = [
    "1 BHK", "2 BHK", "3 BHK", "4 BHK", "5 BHK", "6 BHK", "7 BHK", "8+ BHK"
  ];
  late List<bool> selected;

  // Cities
  List<String> cityOptions = [];
  late List<bool> selectedCities;

  bool _citiesLoaded = false;
  String? _savedCityFromHive;

  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<ListElement> _loadedProperties = []; // ← Yahaan saari load hui properties store karenge

  @override
  void initState() {
    super.initState();
    selectedBHK = List<bool>.filled(bhkOptions.length, false);
    selected     = List<bool>.filled(items.length, false);

    _resetAllFilters(); // sab kuch reset + initial load
    _loadSavedCityFromHive();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _loadSavedCityFromHive() async {
    try {
      final box = await Hive.openBox(_cityBoxName);
      final saved = box.get(_cityKey) as String?;
      if (saved != null && saved.trim().isNotEmpty && mounted) {
        setState(() => _savedCityFromHive = saved.trim());
      }
    } catch (e) {
      debugPrint("Hive load error: $e");
    }
  }

  void _resetAllFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 7000000);
      _minPriceCtrl.text = "0";
      _maxPriceCtrl.text = "7000000";
      selectedBHK.fillRange(0, selectedBHK.length, false);
      selected.fillRange(0, selected.length, false);
      selectedCities = List<bool>.filled(cityOptions.length, false); // safe even if empty
      _searchController.clear();
      _searchQuery = '';
      currentPage = 1;

      body = PropertyListBodyModel(
        size: 20,
        pageNo: currentPage,
        sortBy: 'createdAt',
        sortOrder: 'desc',
      );
    });
  }

  String _formatPrice(num price) {
    if (price >= 10000000) return '${(price / 10000000).toStringAsFixed(2)} Cr';
    if (price >= 100000)   return '${(price / 100000).toStringAsFixed(1)} Lac';
    return price.toStringAsFixed(0);
  }

  void _applyStrictFilters() {
    setState(() {
      currentPage = 1;
      body = PropertyListBodyModel(
        size: 20,
        pageNo: currentPage,
        sortBy: 'createdAt',
        sortOrder: 'desc',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync = ref.watch(getPropertyController(body));
    final cityAsync = ref.watch(getCityController);

    final pageTitle = widget.initialData != null
        ? '${widget.initialData!.listingCategory?.toUpperCase() ?? ''} ${widget.initialData!.property?.toUpperCase() ?? ''} Properties'
        : 'Property Listing';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(pageTitle, style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 22.sp)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: cityAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stk) => Center(child: Text("Cities load failed: $err")),
        data: (cityResponse) {
          if (!_citiesLoaded && cityResponse?.data != null) {
            cityOptions = cityResponse.data!.map((d) => d.cityName ?? "").where((name) => name.isNotEmpty).toList();
            selectedCities = List<bool>.filled(cityOptions.length, false);

            // Hive / initial city select (optional – ab default off rakha)
            // Agar chahte ho to yeh logic wapas daal sakte ho

            _citiesLoaded = true;
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header same

                // Search bar – yeh ab live filter karega loaded properties pe
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 16.h),
                  child: Container(
                    height: 54.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 16, offset: const Offset(0, 8))],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search in loaded properties (city, BHK, price...)",
                        hintStyle: GoogleFonts.inter(color: Colors.grey[500], fontSize: 14.sp),
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[700]),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(icon: const Icon(Icons.clear), onPressed: _searchController.clear)
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                    ),
                  ),
                ),

                // Filter section (sirf button dabane pe apply hoga)
                // ... yahan price range, BHK, city checkboxes same rakh sakte ho ...

                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.w),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.filter_alt, color: Colors.white),
                      label: Text("Apply Price/BHK/City Filters", style: GoogleFonts.inter(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24ADD7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                      ),
                      onPressed: _applyStrictFilters,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Properties
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: propertyAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stk) => Center(child: Text("Error: $err")),
                    data: (res) {
                      final newProperties = res?.data?.list ?? [];

                      // Merge new properties (pagination ke liye future-proof)
                      final allLoaded = [..._loadedProperties, ...newProperties]
                          .toSet() // duplicates remove
                          .toList();

                      setState(() {
                        _loadedProperties = allLoaded;
                      });

                      // Ab filtering sirf _loadedProperties pe
                      final displayed = _loadedProperties.where((prop) {
                        // 1. Strict filters (price, BHK, city checkboxes) – sirf apply button dabane pe active
                        bool strictMatch = true;

                        // Price
                        final price = double.tryParse(prop.price ?? '0') ?? 0;
                        if (price < _priceRange.start || price > _priceRange.end) strictMatch = false;

                        // BHK
                        final bhkStr = prop.bedRoom ?? '';
                        final bhkNum = int.tryParse(bhkStr) ?? 0;
                        if (selectedBHK.any((sel) => sel)) {
                          bool bhkOk = false;
                          for (int i = 0; i < bhkOptions.length; i++) {
                            if (selectedBHK[i]) {
                              if (bhkOptions[i] == "8+" && bhkNum >= 8) bhkOk = true;
                              if (bhkStr == bhkOptions[i]) bhkOk = true;
                            }
                          }
                          if (!bhkOk) strictMatch = false;
                        }

                        // City checkboxes
                        final propCityLower = (prop.city ?? '').toLowerCase().trim();
                        if (selectedCities.any((sel) => sel)) {
                          bool cityOk = false;
                          for (int i = 0; i < cityOptions.length; i++) {
                            if (selectedCities[i] && propCityLower == cityOptions[i].toLowerCase().trim()) {
                              cityOk = true;
                              break;
                            }
                          }
                          if (!cityOk) strictMatch = false;
                        }

                        if (!strictMatch) return false;

                        // 2. Search query (live, har type pe chalega)
                        if (_searchQuery.isNotEmpty) {
                          final q = _searchQuery;
                          final cityMatch     = propCityLower.contains(q);
                          final localityMatch = (prop.localityArea ?? '').toLowerCase().contains(q);
                          final bhkMatch      = bhkStr.toLowerCase().contains(q) ||
                              "${bhkStr}bhk".contains(q) ||
                              "${bhkStr} bedroom".contains(q);
                          final priceStr      = _formatPrice(price).toLowerCase();
                          final priceMatch    = priceStr.contains(q) || (prop.price ?? '').contains(q);

                          if (! (cityMatch || localityMatch || bhkMatch || priceMatch) ) {
                            return false;
                          }
                        }

                        return true;
                      }).toList();

                      if (displayed.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              _searchQuery.isNotEmpty
                                  ? "No matching properties in loaded list"
                                  : "No properties found",
                              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.58,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: displayed.length,
                        itemBuilder: (context, index) => PropertyCard(property: displayed[index]),
                      );
                    },
                  ),
                ),

                SizedBox(height: 120.h),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }
}*/
// SearchPropertyPage.dart (updated & fixed version - search ab kaam karega)
// SearchPropertyPage.dart – Updated & Fixed (2025-01-31)
// - Search ab sahi se kaam karega (case-insensitive + space issue fix)
// - Saved city auto-apply ko optional banaya (comment kiya hai – agar zarurat ho to uncomment kar dena)
// - City checkbox filter ko search active hone par ignore kiya
// - Debug prints add kiye hain (production mein remove kar dena)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:realstate/Controller/getPropertyController.dart';
import 'package:realstate/Controller/getCityListController.dart';
import 'package:realstate/Model/Body/PropertyListBodyModel.dart';
import 'package:realstate/Model/getPropertyResponsemodel.dart';
import 'package:realstate/pages/perticulerProperty.page.dart';

const String _cityBoxName = 'user_prefs';
const String _cityKey = 'user_city';

class SearchPropertyPage extends ConsumerStatefulWidget {
  final ListElement? initialData;

  const SearchPropertyPage({this.initialData, super.key});

  @override
  ConsumerState<SearchPropertyPage> createState() => _SearchPropertyPageState();
}

class _SearchPropertyPageState extends ConsumerState<SearchPropertyPage> {
  int currentPage = 1;
  late PropertyListBodyModel body;

  RangeValues _priceRange = const RangeValues(0, 7000000);
  final TextEditingController _minPriceCtrl = TextEditingController(text: "0");
  final TextEditingController _maxPriceCtrl = TextEditingController(
    text: "7000000",
  );

  final List<String> bhkOptions = ["1", "2", "3", "4", "5", "6", "7", "8+"];
  late List<bool> selectedBHK;

  final List<String> items = [
    "1 BHK",
    "2 BHK",
    "3 BHK",
    "4 BHK",
    "5 BHK",
    "6 BHK",
    "7 BHK",
    "8+ BHK",
  ];
  late List<bool> selected;

  List<String> cityOptions = [];
  late List<bool> selectedCities;

  bool _citiesLoaded = false;
  bool _initialCityApplied = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<ListElement> _loadedProperties = [];

  @override
  void initState() {
    super.initState();
    selectedBHK = List<bool>.filled(bhkOptions.length, false);
    selected = List<bool>.filled(items.length, false);

    _resetAllFilters();

    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.trim().toLowerCase();
        });
      }
    });
  }

  void _resetAllFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 7000000);
      _minPriceCtrl.text = "0";
      _maxPriceCtrl.text = "7000000";
      selectedBHK.fillRange(0, selectedBHK.length, false);
      selected.fillRange(0, selected.length, false);
      if (_citiesLoaded) {
        selectedCities.fillRange(0, selectedCities.length, false);
      }
      _searchController.clear();
      _searchQuery = '';
      currentPage = 1;
      _loadedProperties.clear();

      body = PropertyListBodyModel(
        size: 20,
        pageNo: currentPage,
        sortBy: 'createdAt',
        sortOrder: 'desc',
      );
    });
  }

  String _formatPrice(num price) {
    if (price >= 10000000) return '${(price / 10000000).toStringAsFixed(2)} Cr';
    if (price >= 100000) return '${(price / 100000).toStringAsFixed(1)} Lac';
    return price.toStringAsFixed(0);
  }

  void _applyFilters() {
    setState(() {
      currentPage = 1;
      body = PropertyListBodyModel(
        size: 20,
        pageNo: currentPage,
        sortBy: 'createdAt',
        sortOrder: 'desc',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync = ref.watch(getPropertyController(body));
    final cityAsync = ref.watch(getCityController);

    final pageTitle = widget.initialData != null
        ? '${widget.initialData!.listingCategory?.toUpperCase() ?? ''} '
              '${widget.initialData!.property?.toUpperCase() ?? ''} Properties'
        : 'Property Listing';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          pageTitle,
          style: TextStyle(
            color: Color(0xFF24ADD7),
            fontWeight: FontWeight.bold,
            fontSize: 22.sp,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: cityAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stk) => Center(child: Text("Cities failed to load: $err")),
        data: (cityResponse) {
          if (!_citiesLoaded && cityResponse?.data != null) {
            cityOptions = cityResponse.data!
                .map((d) => d.cityName ?? "")
                .where((name) => name.isNotEmpty)
                .toList();

            selectedCities = List<bool>.filled(cityOptions.length, false);
            _citiesLoaded = true;

            if (!_initialCityApplied) {
              _applySavedCityFilter();
            }
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 25.w,
                    vertical: 16.h,
                  ),
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
                      controller: _searchController,
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
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: () => _searchController.clear(),
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

                // Apply Filters Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.filter_alt, color: Colors.white),
                      label: Text(
                        "Apply Filters",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24ADD7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      onPressed: _applyFilters,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: propertyAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stk) => Center(child: Text("Error: $err")),
                    data: (res) {
                      final newProperties = res?.data?.list ?? [];

                      final allLoaded = [
                        ..._loadedProperties,
                        ...newProperties,
                      ].toSet().toList();

                      if (_loadedProperties.length != allLoaded.length) {
                        setState(() => _loadedProperties = allLoaded);
                      }

                      final displayed = _loadedProperties.where((prop) {
                        // Debug print – production mein remove kar dena
                        print(
                          "Property: ${prop.city} | BHK: ${prop.bedRoom} | ₹${prop.price} | Query: '$_searchQuery'",
                        );

                        // Price filter
                        final price = double.tryParse(prop.price ?? '0') ?? 0;
                        if (price < _priceRange.start ||
                            price > _priceRange.end) {
                          print("  Rejected: Price out of range");
                          return false;
                        }

                        // BHK filter
                        final bhkStr = prop.bedRoom ?? '';
                        final bhkNum = int.tryParse(bhkStr) ?? 0;
                        if (selectedBHK.any((sel) => sel)) {
                          bool bhkMatch = false;
                          for (int i = 0; i < bhkOptions.length; i++) {
                            if (selectedBHK[i]) {
                              final opt = bhkOptions[i];
                              if (opt == "8+" && bhkNum >= 8) bhkMatch = true;
                              if (bhkStr == opt) bhkMatch = true;
                            }
                          }
                          if (!bhkMatch) {
                            print("  Rejected: BHK not matching");
                            return false;
                          }
                        }

                        // City checkbox filter – SEARCH ACTIVE HONE PAR IGNORE
                        final propCityLower = (prop.city ?? '')
                            .trim()
                            .toLowerCase();
                        if (_searchQuery.isEmpty &&
                            selectedCities.any((sel) => sel)) {
                          bool cityMatch = false;
                          for (int i = 0; i < cityOptions.length; i++) {
                            if (selectedCities[i] &&
                                propCityLower ==
                                    cityOptions[i].toLowerCase().trim()) {
                              cityMatch = true;
                              break;
                            }
                          }
                          if (!cityMatch) {
                            print(
                              "  Rejected: City checkbox filter - ${prop.city}",
                            );
                            return false;
                          }
                        }

                        // Search logic
                        if (_searchQuery.isNotEmpty) {
                          final q = _searchQuery.toLowerCase();

                          final cityLower = propCityLower;
                          final areaLower = (prop.localityArea ?? '')
                              .trim()
                              .toLowerCase();
                          final bhkLower = bhkStr.trim().toLowerCase();
                          final priceFormatted = _formatPrice(
                            price,
                          ).toLowerCase();
                          final rawPrice = (prop.price ?? '').toLowerCase();

                          final match =
                              cityLower.contains(q) ||
                              areaLower.contains(q) ||
                              bhkLower.contains(q) ||
                              "${bhkLower}bhk".contains(q) ||
                              priceFormatted.contains(q) ||
                              rawPrice.contains(q);

                          if (!match) {
                            print(
                              "  Rejected by search → $q not found in $cityLower / $areaLower",
                            );
                            return false;
                          }
                          print("  Accepted by search");
                        }

                        print("  → SHOWING THIS PROPERTY");
                        return true;
                      }).toList();

                      if (displayed.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              _searchQuery.isNotEmpty
                                  ? "No properties found for \"$_searchQuery\""
                                  : "No properties match current filters",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
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
                          childAspectRatio: 0.58,
                          mainAxisSpacing: 12.h,
                          crossAxisSpacing: 12.w,
                        ),
                        itemCount: displayed.length,
                        itemBuilder: (context, index) =>
                            PropertyCard(property: displayed[index]),
                      );
                    },
                  ),
                ),

                SizedBox(height: 120.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _applySavedCityFilter() async {
    if (_initialCityApplied) return;

    try {
      final box = await Hive.openBox(_cityBoxName);
      final saved = box.get(_cityKey) as String?;

      if (saved != null && saved.trim().isNotEmpty && mounted) {
        final normalized = saved.trim().toLowerCase();

        final idx = cityOptions
            .map((c) => c.toLowerCase().trim())
            .toList()
            .indexOf(normalized);

        if (idx != -1) {
          print("Auto-selecting saved city: $saved (index $idx)");
          setState(() {
            selectedCities.fillRange(0, selectedCities.length, false);
            selectedCities[idx] = true;
          });

          // Auto apply filter taaki sirf saved city ki properties dikhe
          _applyFilters();
        } else {
          print("Saved city '$saved' API cities list mein nahi mila");
        }
      } else {
        print("No saved city in Hive");
      }
    } catch (e) {
      debugPrint("Error applying saved city: $e");
    }

    _initialCityApplied = true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }
}
