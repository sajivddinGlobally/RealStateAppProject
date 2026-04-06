
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

const String _cityBoxName = 'user_prefs';
const String _cityKey = 'user_city';

final searchQueryProvider = StateProvider<String>((ref) => '');

class ListingPage extends ConsumerStatefulWidget {
  final ListElement? initialData;

  const ListingPage({this.initialData, super.key});

  @override
  ConsumerState<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends ConsumerState<ListingPage> {
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
  List<bool> selectedCities = [];

  bool _citiesLoaded = false;
  String? _savedCityFromHive;

  @override
  void initState() {
    super.initState();
    selectedBHK = List<bool>.filled(bhkOptions.length, false);
    selected = List<bool>.filled(items.length, false);

    _resetFilters();
    _applyFilters(); // initial load

    _loadSavedCityFromHive();
  }

  Future<void> _loadSavedCityFromHive() async {
    try {
      final box = await Hive.openBox(_cityBoxName);
      final saved = box.get(_cityKey) as String?;

      debugPrint("ListingPage: Hive saved city → $saved");

      if (saved != null && saved.trim().isNotEmpty && mounted) {
        setState(() {
          _savedCityFromHive = saved.trim();
        });
      }
    } catch (e) {
      debugPrint("Hive load error: $e");
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
    final selectedCityFromHome = ref.watch(currentCityProvider);

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

            if (selectedCityFromHome != null) {
              final normalized = selectedCityFromHome.toLowerCase().trim();

              final idx = cityOptions
                  .map((c) => c.toLowerCase().trim())
                  .toList()
                  .indexOf(normalized);

              if (idx != -1) {
                selectedCities[idx] = true;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _applyFilters();
                });
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 25.w,
                    vertical: 20.h,
                  ),
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

                // Search bar ── updated
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
                      onChanged: (value) {
                        ref.read(searchQueryProvider.notifier).state = value
                            .trim()
                            .toLowerCase();
                      },
                      decoration: InputDecoration(
                        hintText: "Search by city, BHK, price...",
                        hintStyle: GoogleFonts.inter(
                          color: Colors.grey.shade500,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xffFF6A2A),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                // Banner (unchanged)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 25.w,
                    vertical: 20.h,
                  ),
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

                // Filter section (unchanged)
                Container(
                  height: 45.h,
                  margin: EdgeInsets.symmetric(horizontal: 25.w),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xffFF6A2A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Filter",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 25.w),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.r),
                      bottomRight: Radius.circular(20.r),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Price Range",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _minPriceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Min Price",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              onChanged: (val) {
                                final min =
                                    double.tryParse(val.replaceAll(',', '')) ??
                                    0;
                                setState(() {
                                  _priceRange = RangeValues(
                                    min.clamp(0, _priceRange.end),
                                    _priceRange.end,
                                  );
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
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              onChanged: (val) {
                                final max =
                                    double.tryParse(val.replaceAll(',', '')) ??
                                    7000000;
                                setState(() {
                                  _priceRange = RangeValues(
                                    _priceRange.start,
                                    max.clamp(_priceRange.start, 7000000),
                                  );
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 12,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 24,
                          ),
                          trackHeight: 6,
                        ),
                        child: RangeSlider(
                          values: _priceRange,
                          min: 0,
                          max: 7000000,
                          divisions: 70,
                          activeColor: const Color(0xffFF6A2A),
                          inactiveColor: Colors.grey.shade300,
                          labels: RangeLabels(
                            _formatPrice(_priceRange.start),
                            _formatPrice(_priceRange.end),
                          ),
                          onChanged: (RangeValues values) {
                            setState(() {
                              _priceRange = values;
                              _minPriceCtrl.text = values.start.toStringAsFixed(
                                0,
                              );
                              _maxPriceCtrl.text = values.end.toStringAsFixed(
                                0,
                              );
                            });
                          },
                        ),
                      ),
                      const Divider(height: 40, thickness: 1.5),
                      Text(
                        "Bedroom",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        itemCount: items.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                                activeColor: const Color(0xffFF6A2A),
                                onChanged: (value) {
                                  setState(() {
                                    selected[index] = value!;
                                    final bhkVal = items[index].split(" ")[0];
                                    final bhkIdx = bhkOptions.indexOf(bhkVal);
                                    if (bhkIdx != -1)
                                      selectedBHK[bhkIdx] = value;
                                  });
                                },
                              ),
                              Text(
                                items[index],
                                style: GoogleFonts.inter(fontSize: 14.sp),
                              ),
                            ],
                          );
                        },
                      ),
                      const Divider(height: 40, thickness: 1.5),
                      Text(
                        "City",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
                              activeColor: const Color(0xffFF6A2A),
                              title: Text(
                                cityOptions[index],
                                style: GoogleFonts.inter(fontSize: 14.sp),
                              ),
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
                          label: Text(
                            "Apply Filters",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffFF6A2A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                          ),
                          onPressed: _applyFilters,
                        ),
                      ),
                    ],
                  ),
                ),

                // Properties ── main filtering logic updated
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: propertyAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stk) => Center(child: Text("Error: $err")),
                    data: (res) {
                      final allProperties = res?.data?.list ?? [];

                      final searchQuery = ref.watch(searchQueryProvider);

                      final filteredList = allProperties.where((prop) {
                        // 1. Fixed filters from initialData
                        if (widget.initialData != null) {
                          final expProp =
                              widget.initialData!.property?.toLowerCase() ?? '';
                          final expCat =
                              widget.initialData!.listingCategory
                                  ?.toLowerCase() ??
                              '';
                          if ((prop.property?.toLowerCase() ?? '') != expProp ||
                              (prop.listingCategory?.toLowerCase() ?? '') !=
                                  expCat) {
                            return false;
                          }
                        }

                        // 2. City checkbox filter
                        final propCityLower = (prop.city ?? '')
                            .toLowerCase()
                            .trim();
                        if (selectedCities.any((sel) => sel)) {
                          bool cityMatch = false;
                          for (int i = 0; i < cityOptions.length; i++) {
                            if (selectedCities[i] &&
                                propCityLower ==
                                    cityOptions[i].toLowerCase().trim()) {
                              cityMatch = true;
                              break;
                            }
                          }
                          if (!cityMatch) return false;
                        }

                        // 3. Price range filter
                        final price = double.tryParse(prop.price ?? '0') ?? 0;
                        if (price < _priceRange.start ||
                            price > _priceRange.end)
                          return false;

                        // 4. BHK checkbox filter
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

                        // 5. Search bar filter (independent – only applied if query exists)
                        if (searchQuery.isNotEmpty) {
                          final q = searchQuery.toLowerCase();

                          // City contains
                          if (propCityLower.contains(q)) return true;

                          // BHK / bedroom
                          final bhkDigits = q.replaceAll(
                            RegExp(r'[^0-9+]'),
                            '',
                          );
                          if (bhkDigits.isNotEmpty) {
                            if (bhkStr == bhkDigits) return true;
                            if (q.contains('bhk') && bhkStr == bhkDigits)
                              return true;
                          }

                          // Price – raw number or formatted (lac / cr)
                          final priceFormatted = _formatPrice(
                            price,
                          ).toLowerCase();
                          if (priceFormatted.contains(q) ||
                              (prop.price ?? '').contains(q)) {
                            return true;
                          }

                          // No match in search → hide
                          return false;
                        }

                        // If no search query → show if passed above filters
                        return true;
                      }).toList();

                      if (filteredList.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              searchQuery.isNotEmpty
                                  ? "No properties found for \"$searchQuery\""
                                  : "No properties match your filters",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey,
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

// PropertyCard remains unchanged (your original version)
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
    final imageUrl =
        (property.uploadedPhotos != null && property.uploadedPhotos!.isNotEmpty)
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
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "${property.localityArea ?? ""}, ${property.city ?? ""}",
                          style: GoogleFonts.inter(
                            fontSize: 8.sp,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "₹ ${_formatPrice(property.price)}",
                    style: GoogleFonts.inter(
                      color: const Color(0xffFF6A2A),
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
                        borderRadius: BorderRadius.circular(30),
                        color: const Color(0xff8A38F5),
                      ),
                      height: 25.h,
                      child: Center(
                        child: Text(
                          '${property.propertyType}',
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
              padding: EdgeInsets.only(left: 10.w, right: 10.w),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PerticulerPropertyPage(data: property),
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
                                PerticulerPropertyPage(data: property),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xffFF6A2A),
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
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}
