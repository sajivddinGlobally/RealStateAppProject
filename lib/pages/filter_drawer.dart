import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realstate/Controller/getCityListController.dart';
import 'package:realstate/Model/Body/PropertyListBodyModel.dart';
import 'package:realstate/Model/CityResponseModel.dart';

class FilterDrawer extends ConsumerStatefulWidget {
  final PropertyListBodyModel currentFilters;
  final Function(PropertyListBodyModel) onApply;

  const FilterDrawer({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  @override
  ConsumerState<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends ConsumerState<FilterDrawer> {
  String? _selectedCity;
  List<Datum> _allCities = [];
  List<String> _localitiesForCity = [];
  String _localitySearch = "";
  final List<String> _selectedLocalities = [];

  String? _selectedBedroom;
  String? _selectedBathroom;
  String? _selectedKitchen;
  String? _selectedBalcony;
  String? _selectedParking;
  String? _selectedFurnishing;

  String? _propertyAction; // "sell" or "rent"

  String _sortByLabel = "Match By Popularity";
  final List<String> _sortByOptions = [
    "Match By Popularity",
    "Match By Newest First",
    "Price: Low to High",
    "Price: High to Low",
  ];

  final TextEditingController _minPriceCtrl = TextEditingController();
  final TextEditingController _maxPriceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initFiltersFromModel(widget.currentFilters);
  }

  void _initFiltersFromModel(PropertyListBodyModel model) {
    _selectedCity = (model.city != null && model.city!.isNotEmpty)
        ? model.city
        : null;
    if (model.locality != null) {
      _selectedLocalities.addAll(model.locality!);
    }
    _selectedBedroom = (model.bedroom != null && model.bedroom!.isNotEmpty)
        ? model.bedroom!.first
        : null;
    _selectedBathroom = (model.bathrooms != null && model.bathrooms!.isNotEmpty)
        ? model.bathrooms!.first
        : null;
    _selectedKitchen = (model.kitchen != null && model.kitchen!.isNotEmpty)
        ? model.kitchen!.first
        : null;
    _selectedBalcony = (model.balcony != null && model.balcony!.isNotEmpty)
        ? model.balcony!.first
        : null;
    _selectedParking = (model.parking != null && model.parking!.isNotEmpty)
        ? model.parking!.first
        : null;

    _propertyAction =
        (model.listingCategory != null && model.listingCategory!.isNotEmpty)
        ? model.listingCategory
        : null;

    _minPriceCtrl.text = model.minPrice ?? "";
    _maxPriceCtrl.text = model.maxPrice ?? "";

    if (model.sortBy == "price" && model.sortOrder == "asc") {
      _sortByLabel = "Price: Low to High";
    } else if (model.sortBy == "price" && model.sortOrder == "desc") {
      _sortByLabel = "Price: High to Low";
    } else if (model.sortBy == "createdAt" && model.sortOrder == "desc") {
      _sortByLabel = "Match By Newest First";
    } else {
      _sortByLabel = "Match By Popularity";
    }
  }

  void _updateLocalities() {
    if (_selectedCity == null) {
      _localitiesForCity = [];
      return;
    }
    try {
      final cityData = _allCities.firstWhere(
        (c) => c.cityName?.toLowerCase() == _selectedCity?.toLowerCase(),
      );
      _localitiesForCity = cityData.areas ?? [];
    } catch (_) {
      _localitiesForCity = [];
    }
    // Remove selected localities that don't belong to this city
    _selectedLocalities.removeWhere((loc) => !_localitiesForCity.contains(loc));
  }

  void _applyFilters() {
    String sortBy = "createdAt";
    String sortOrder = "desc";

    if (_sortByLabel == "Price: Low to High") {
      sortBy = "price";
      sortOrder = "asc";
    } else if (_sortByLabel == "Price: High to Low") {
      sortBy = "price";
      sortOrder = "desc";
    } else if (_sortByLabel == "Match By Newest First") {
      sortBy = "createdAt";
      sortOrder = "desc";
    }

    final newBody = PropertyListBodyModel(
      size: 20,
      pageNo: 1,
      sortBy: sortBy,
      sortOrder: sortOrder,
      minPrice: _minPriceCtrl.text.isNotEmpty ? _minPriceCtrl.text : "",
      maxPrice: _maxPriceCtrl.text.isNotEmpty ? _maxPriceCtrl.text : "",
      bedroom: _selectedBedroom != null && _selectedBedroom != "Any BHK"
          ? [_selectedBedroom!]
          : [],
      city: _selectedCity ?? "",
      listingCategory:
          _propertyAction ?? widget.currentFilters.listingCategory ?? "",
      propertyType: widget.currentFilters.propertyType ?? "",
      keyWord: widget.currentFilters.keyWord ?? "",
      balcony: _selectedBalcony != null && _selectedBalcony != "Any Balcony"
          ? [_selectedBalcony!]
          : [],
      bathrooms:
          _selectedBathroom != null && _selectedBathroom != "Any Bathroom"
          ? [_selectedBathroom!]
          : [],
      kitchen: _selectedKitchen != null && _selectedKitchen != "Any Kitchen"
          ? [_selectedKitchen!]
          : [],
      locality: _selectedLocalities,
      parking: _selectedParking != null && _selectedParking != "Any Parking"
          ? [_selectedParking!]
          : [],
    );

    widget.onApply(newBody);
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedCity = null;
      _localitiesForCity.clear();
      _selectedLocalities.clear();
      _localitySearch = "";
      _selectedBedroom = null;
      _selectedBathroom = null;
      _selectedKitchen = null;
      _selectedBalcony = null;
      _selectedParking = null;
      _selectedFurnishing = null;
      _propertyAction = null;
      _sortByLabel = "Match By Popularity";
      _minPriceCtrl.clear();
      _maxPriceCtrl.clear();
    });
  }

  Widget _buildDropdown(
    String label,
    List<String> options,
    String? value,
    String anyLabel,
    ValueChanged<String?> onChanged,
  ) {
    List<String> items = [anyLabel, ...options];
    if (!items.contains(value) && value != null && value.isNotEmpty) {
      items.add(value);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          height: 40.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value ?? anyLabel,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black54,
              ),
              items: items.map((String v) {
                return DropdownMenuItem<String>(
                  value: v,
                  child: Text(v, style: GoogleFonts.inter(fontSize: 13.sp)),
                );
              }).toList(),
              onChanged: (val) {
                if (val == anyLabel) val = null;
                onChanged(val);
              },
            ),
          ),
        ),
        SizedBox(height: 14.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cityAsync = ref.watch(getCityController);

    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Filter Properties",
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF122D4D),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),

            // Scrollable Filters
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: 16.h,
                  bottom: 16.h + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // City Dropdown
                    cityAsync.when(
                      data: (res) {
                        _allCities = res.data ?? [];
                        if (_selectedCity != null &&
                            _localitiesForCity.isEmpty) {
                          try {
                            final cityData = _allCities.firstWhere(
                              (c) =>
                                  c.cityName?.toLowerCase() ==
                                  _selectedCity?.toLowerCase(),
                            );
                            _localitiesForCity = cityData.areas ?? [];
                          } catch (_) {}
                        }
                        final cNames = _allCities
                            .map((c) => c.cityName ?? "")
                            .where((c) => c.isNotEmpty)
                            .toList();
                        return _buildDropdown(
                          "City",
                          cNames,
                          _selectedCity,
                          "Select City",
                          (v) {
                            setState(() {
                              _selectedCity = v;
                              _updateLocalities();
                            });
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => const Text("Error loading cities"),
                    ),

                    // Locality checklist
                    if (_selectedCity != null) ...[
                      Text(
                        "Locality",
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      TextField(
                        onChanged: (v) =>
                            setState(() => _localitySearch = v.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: "Search by character, area, keyword",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 8.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          isDense: true,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 150.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: _localitiesForCity
                              .where(
                                (l) =>
                                    l.toLowerCase().contains(_localitySearch),
                              )
                              .map((loc) {
                                final isSelected = _selectedLocalities.contains(
                                  loc,
                                );
                                return CheckboxListTile(
                                  title: Text(
                                    loc,
                                    style: GoogleFonts.inter(fontSize: 12.sp),
                                  ),
                                  value: isSelected,
                                  activeColor: const Color(0xFF24ADD7),
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (bool? val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedLocalities.add(loc);
                                      } else {
                                        _selectedLocalities.remove(loc);
                                      }
                                    });
                                  },
                                );
                              })
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 14.h),
                    ],

                    _buildDropdown(
                      "Bedroom",
                      ["1", "2", "3", "4", "5+"],
                      _selectedBedroom,
                      "Any BHK",
                      (v) => setState(() => _selectedBedroom = v),
                    ),
                    _buildDropdown(
                      "Bathroom",
                      ["1", "2", "3", "4", "5+"],
                      _selectedBathroom,
                      "Any Bathroom",
                      (v) => setState(() => _selectedBathroom = v),
                    ),
                    _buildDropdown(
                      "Kitchen",
                      ["1", "2", "3+"],
                      _selectedKitchen,
                      "Any Kitchen",
                      (v) => setState(() => _selectedKitchen = v),
                    ),
                    _buildDropdown(
                      "Balcony",
                      ["1", "2", "3+"],
                      _selectedBalcony,
                      "Any Balcony",
                      (v) => setState(() => _selectedBalcony = v),
                    ),
                    _buildDropdown(
                      "Parking",
                      ["1", "2", "3+"],
                      _selectedParking,
                      "Any Parking",
                      (v) => setState(() => _selectedParking = v),
                    ),
                    _buildDropdown(
                      "Furnishing",
                      ["Furnished", "Semi-Furnished", "Unfurnished"],
                      _selectedFurnishing,
                      "Any Furnishing",
                      (v) => setState(() => _selectedFurnishing = v),
                    ),

                    // Property Action (Buy / Rent)
                    Text(
                      "Property",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(
                              "Buy",
                              style: GoogleFonts.inter(fontSize: 12.sp),
                            ),
                            value: "sell",
                            groupValue: _propertyAction,
                            activeColor: const Color(0xFF24ADD7),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            onChanged: (v) =>
                                setState(() => _propertyAction = v),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(
                              "Rent",
                              style: GoogleFonts.inter(fontSize: 12.sp),
                            ),
                            value: "rent",
                            groupValue: _propertyAction,
                            activeColor: const Color(0xFF24ADD7),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            onChanged: (v) =>
                                setState(() => _propertyAction = v),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Sort By
                    Text(
                      "Sort By",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Column(
                      children: _sortByOptions.map((option) {
                        return RadioListTile<String>(
                          title: Text(
                            option,
                            style: GoogleFonts.inter(fontSize: 12.sp),
                          ),
                          value: option,
                          groupValue: _sortByLabel,
                          activeColor: const Color(0xFF24ADD7),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          onChanged: (v) => setState(() => _sortByLabel = v!),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 14.h),

                    // Filter By Price Range
                    Text(
                      "Filter By Price Range",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minPriceCtrl,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.inter(fontSize: 12.sp),
                            decoration: InputDecoration(
                              hintText: "Min Price",
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 10.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: TextField(
                            controller: _maxPriceCtrl,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.inter(fontSize: 12.sp),
                            decoration: InputDecoration(
                              hintText: "Max Price",
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 10.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 40.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24ADD7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        onPressed: _applyFilters,
                        child: Text(
                          "Apply",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: double.infinity,
                      height: 40.h,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        onPressed: _clearFilters,
                        child: Text(
                          "Clear Filter | Sorting",
                          style: GoogleFonts.inter(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
