import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:realstate/Controller/getMyPropertyController.dart';
import 'package:realstate/Controller/locationProvider.dart';
import 'package:realstate/Model/Body/UpdatePropertyBodyModel.dart';
import '../Controller/getCityListController.dart';
import '../Model/Body/CreatePropertyBodyModel.dart';
import '../Model/CityResponseModel.dart';
import '../Model/getPropertyResponsemodel.dart';
import '../core/network/api.state.dart';
import '../core/utils/preety.dio.dart';
import 'package:realstate/Controller/getPropertyCategoryProvider.dart';
import 'package:realstate/Model/getPropertyCategoryModel.dart' as cat_model;
import 'package:realstate/Model/Body/CreatePropertyBodyModel.dart'
    as createModel;
import 'package:realstate/Model/Body/UpdatePropertyBodyModel.dart'
    as updateModel;

class PropertySubTypeItem {
  final String title;
  final String value;
  const PropertySubTypeItem({required this.title, required this.value});
}

class CreatePropertyScreen extends ConsumerStatefulWidget {
  final ListElement? data;
  final bool fromBottomNav;
  final Function()? onSuccess;
  const CreatePropertyScreen(
    this.data, {
    super.key,
    this.fromBottomNav = false,
    this.onSuccess,
  });

  @override
  ConsumerState<CreatePropertyScreen> createState() =>
      _CreatePropertyScreenState();
}

class _CreatePropertyScreenState extends ConsumerState<CreatePropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  String? get propertyId {
    if (widget.data != null) {
      if (widget.data is ListElement) {
        final id = (widget.data as ListElement).id;
        if (id != null && id.trim().isNotEmpty) return id.trim();
      } else if (widget.data is Map) {
        final m = widget.data as Map;
        final id =
            m['_id']?.toString() ?? m['id']?.toString() ?? m['sId']?.toString();
        if (id != null && id.trim().isNotEmpty) return id.trim();
      } else {
        try {
          final dynamic d = widget.data;
          final String? id =
              d.id?.toString() ??
              d.sId?.toString() ??
              d._id?.toString() ??
              d['_id']?.toString() ??
              d['id']?.toString();
          if (id != null && id.trim().isNotEmpty) return id.trim();
        } catch (_) {}
      }
    }
    return null;
  }

  bool get isEditMode => propertyId != null && propertyId!.isNotEmpty;

  int _currentStep = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      "label": "Basic Info",
      "desc": "Type & Category",
      "icon": Icons.home_work_outlined,
    },
    {
      "label": "Location",
      "desc": "City & Address",
      "icon": Icons.location_on_outlined,
    },
    {
      "label": "Specifications",
      "desc": "Area & Price",
      "icon": Icons.straighten_outlined,
    },
    {
      "label": "Amenities & Legal",
      "desc": "RERA & Features",
      "icon": Icons.verified_outlined,
    },
    {
      "label": "Media",
      "desc": "Photos & Description",
      "icon": Icons.photo_library_outlined,
    },
  ];

  bool get _isLastStep => _currentStep == _steps.length - 1;

  // Step 1: Basic Info
  int? selectedType; // 1 = Sell, 2 = Rent
  String? selectedListingCategory; // "sell", "rent"
  String? selectedPropertyType; // "Residential", "Commercial"
  String? selectedPropertySubType; // "apartment", "villa", etc.
  bool? isBroker;

  // Step 2: Location
  final TextEditingController _stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  final TextEditingController localityController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _propertyAddressController =
      TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  String? selectedCity;
  String? selectedCityId;
  String? selectedLocality;
  bool isCustomLocalityMode = false;
  List<String> localityList = [];
  bool _isLocationLoading = false;
  bool get isCitySelected => selectedCity != null && selectedCity!.isNotEmpty;
  int _cityResetKey = 0;
  int _stateResetKey = 0;

  // Step 3: Specifications
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _availableFromController =
      TextEditingController();
  final TextEditingController _customSecurityDepositController =
      TextEditingController();

  String? _selectedBhk;
  String? selectedSecurityDeposit = "None"; // None, 1 month, 2 month, Custom

  // Step 4: Amenities & Legal
  String? selectedRoom;
  String? selectedGuestRoom = "None";
  String? _selectBathroom;
  String? _selectkitchen;
  String? _selectBalcony;
  String? _selectParking;
  String? selectedFurnishing;

  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _kitchenController = TextEditingController();
  final TextEditingController _balconyController = TextEditingController();
  final TextEditingController _parkingController = TextEditingController();

  final TextEditingController _permitNoController = TextEditingController();
  final TextEditingController _reraController = TextEditingController();
  final TextEditingController _dedController = TextEditingController();
  final TextEditingController _brnController = TextEditingController();

  final TextEditingController _projectAreaController = TextEditingController();
  final TextEditingController _unitSizesController = TextEditingController();
  final TextEditingController _projectSizeController = TextEditingController();
  final TextEditingController _launchDateController = TextEditingController();
  final TextEditingController _possessionDateController =
      TextEditingController();

  // Furnishing Items
  final List<String> standardFurnishingItems = [
    "Air Conditioner",
    "Bed",
    "Wardrobe",
    "TV",
    "Refrigerator",
    "Sofa",
    "Dining Table",
    "Microwave",
    "Washing Machine",
    "Water Purifier",
    "Geyser",
    "Stove",
    "Modular Kitchen",
    "Curtains",
    "Fan",
    "Exhaust Fan",
  ];
  List<String> appliance = [];
  List<String> customFurnishingItems = [];
  final TextEditingController applianceController = TextEditingController();

  // Amenities
  final List<String> allAmenities = [
    "Swimming Pool",
    "Gym",
    "Fitness Center",
    "Yoga Studio",
    "Sauna",
    "Spa",
    "Parking",
    "Covered Parking",
    "EV Charging Station",
    "Lift/Elevator",
    "Power Backup",
    "Security",
    "24/7 Security",
    "Controlled Access/Gated",
    "CCTV Surveillance",
    "Garden",
    "Landscaped Gardens",
    "BBQ/Picnic Area",
    "Playground",
    "Children's Play Area",
    "Clubhouse",
    "Community Hall",
    "Business Center",
    "Conference Room",
    "Library",
    "Theater Room",
    "Game Room",
    "Tennis Court",
    "Basketball Court",
    "Jogging Track",
    "Laundry Room",
    "In-Unit Laundry",
    "High-Speed Internet",
    "Wi-Fi Included",
    "On-Site Maintenance",
    "Package Lockers",
    "Bike Storage",
    "Storage Units",
    "Roof Deck/Terrace",
    "Concierge Service",
    "Pet-Friendly (Dog Park)",
    "Non-Smoking Building",
    "Wheelchair Accessible",
    "Air Conditioning",
    "Central Heating",
    "Balcony/Patio",
    "Walk-in Closet",
    "Dishwasher",
    "Microwave",
    "Stainless Steel Appliances",
    "Garbage Disposal",
  ];
  List<String> selectedAmenities = [];
  List<String> customAmenitiesList = [];
  final TextEditingController _customAmenityController =
      TextEditingController();

  // Around Project
  List<Map<String, dynamic>> aroundProjectList = [];

  // Step 5: Media & Description
  List<dynamic> propertyImages = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();

  bool showAllPropertySubTypes = false;
  bool showAllAmenities = false;
  bool showAllFurnishingItems = false;
  bool _isLoading = false;

  final List<String> indianStates = [
    "Andaman and Nicobar Islands",
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chandigarh",
    "Chhattisgarh",
    "Dadra and Nagar Haveli and Daman and Diu",
    "Delhi",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jammu and Kashmir",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Ladakh",
    "Lakshadweep",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Puducherry",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
  ];

  @override
  void initState() {
    super.initState();
    addAroundProjectRow();
    if (isEditMode && widget.data != null) {
      showAllPropertySubTypes = true;
      showAllAmenities = true;
      showAllFurnishingItems = true;
      _preFillData(widget.data!);
    }
  }

  void _preFillData(ListElement data) {
    setState(() {
      selectedPropertyType = _capitalize(data.property);
      selectedPropertySubType = data.propertyType?.toLowerCase();
      selectedListingCategory = _normalizeListingCategory(data.listingCategory);

      if (selectedListingCategory == "Sell") {
        selectedType = 1;
      } else if (selectedListingCategory == "Rent") {
        selectedType = 2;
      }

      selectedCity = data.city?.trim();
      cityController.text = selectedCity ?? "";
      selectedLocality = data.localityArea?.trim();
      localityController.text = selectedLocality ?? "";
      isCustomLocalityMode = false;
      _cityResetKey++;
      _stateResetKey++;
      selectedFurnishing = _normalize(data.furnishing);

      _houseNumberController.text = data.houseNumber ?? '';
      final fullAddr = data.propertyAddress ?? '';
      _propertyAddressController.text = fullAddr;

      // Extract Pincode: use data.pincode if present, otherwise extract 6-digit pin from propertyAddress
      String pincode = (data.pincode != null && data.pincode!.trim().isNotEmpty)
          ? data.pincode!.trim()
          : '';
      if (pincode.isEmpty && fullAddr.isNotEmpty) {
        final pinMatch = RegExp(r'\b[1-9][0-9]{5}\b').firstMatch(fullAddr);
        if (pinMatch != null) {
          pincode = pinMatch.group(0)!;
        }
      }
      _pincodeController.text = pincode;

      // Extract State: match from indianStates list in propertyAddress
      String stateVal = '';
      if (fullAddr.isNotEmpty) {
        for (final st in indianStates) {
          if (RegExp(
            r'\b' + RegExp.escape(st) + r'\b',
            caseSensitive: false,
          ).hasMatch(fullAddr)) {
            stateVal = st;
            break;
          }
        }
      }
      _stateController.text = stateVal;
      _priceController.text = data.price ?? '';
      _areaController.text = data.area ?? '';

      String? bedRoomValue = data.bedRoom;
      if (bedRoomValue != null &&
          bedRoomValue.isNotEmpty &&
          !bedRoomValue.contains("BHK")) {
        bedRoomValue = "$bedRoomValue BHK";
      }
      _bedroomsController.text = bedRoomValue ?? '';
      _selectedBhk = bedRoomValue ?? "";

      _availableFromController.text = data.availableFrom ?? '';
      selectedSecurityDeposit =
          (data.securityDeposit != null && data.securityDeposit!.isNotEmpty)
          ? data.securityDeposit!
          : "None";
      _customSecurityDepositController.text = data.customSecurityDeposit ?? '';

      selectedRoom = data.room ?? '';
      selectedGuestRoom = (data.guestRoom != null && data.guestRoom!.isNotEmpty)
          ? data.guestRoom!
          : "None";

      _bathroomsController.text = data.bathrooms ?? '';
      _selectBathroom = data.bathrooms ?? "";
      _selectBalcony = data.balcony ?? "";
      _balconyController.text = data.balcony ?? "";
      _selectParking = data.parking ?? "";
      _parkingController.text = data.parking ?? "";
      _selectkitchen = data.kitchen ?? "";
      _kitchenController.text = data.kitchen ?? "";

      _permitNoController.text = data.permitNo ?? '';
      _reraController.text = data.rera ?? '';
      _dedController.text = data.ded ?? '';
      _brnController.text = data.brn ?? '';
      _descriptionController.text = data.description ?? '';

      isBroker = (data.isBroker == "1" || data.isBroker == "yes");

      final overview = data.aveneuOverView;
      if (overview != null) {
        _projectAreaController.text = overview.projectArea?.toString() ?? '';
        _unitSizesController.text = overview.size?.toString() ?? '';
        _projectSizeController.text = overview.projectSize?.toString() ?? '';
        _launchDateController.text = overview.launchDate?.toString() ?? '';
        _possessionDateController.text =
            overview.possessionStart?.toString() ?? '';
      }

      if (data.amenities != null && data.amenities!.isNotEmpty) {
        selectedAmenities = List<String>.from(data.amenities!);
        for (final a in selectedAmenities) {
          if (!allAmenities.contains(a)) {
            allAmenities.insert(0, a);
            customAmenitiesList.add(a);
          }
        }
      }
      if (data.furnishingItems != null && data.furnishingItems!.isNotEmpty) {
        appliance = List<String>.from(data.furnishingItems!);
        for (final f in appliance) {
          if (!standardFurnishingItems.contains(f)) {
            customFurnishingItems.add(f);
          }
        }
      }
      if (data.uploadedPhotos != null && data.uploadedPhotos!.isNotEmpty) {
        propertyImages.addAll(data.uploadedPhotos!);
      }

      aroundProjectList.clear();
      if (data.aroundProject != null && data.aroundProject!.isNotEmpty) {
        for (final item in data.aroundProject!) {
          final det = item.details ?? '';
          String unit = "meter";
          String dist = "";
          if (det.toLowerCase().contains("km")) {
            unit = "km";
            dist = det.replaceAll(RegExp(r'[^0-9.]'), '').trim();
          } else if (det.toLowerCase().contains("meter") ||
              det.toLowerCase().contains("m")) {
            unit = "meter";
            dist = det.replaceAll(RegExp(r'[^0-9.]'), '').trim();
          } else {
            dist = det;
          }

          aroundProjectList.add({
            'place': TextEditingController(text: item.name ?? ''),
            'distance': TextEditingController(text: dist),
            'unit': unit,
          });
        }
      }
      if (aroundProjectList.isEmpty) addAroundProjectRow();
    });
  }

  String? _normalizeListingCategory(String? value) {
    if (value == null) return null;
    final lower = value.toLowerCase().trim();
    if (lower.contains('rent')) return 'Rent';
    if (lower.contains('buy') || lower.contains('sell')) return 'Sell';
    return value;
  }

  String? _normalize(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    switch (value.trim().toLowerCase()) {
      case "furnished":
        return "Furnished";
      case "semi-furnished":
      case "semi furnished":
        return "Semi-Furnished";
      case "unfurnished":
        return "Unfurnished";
      default:
        return null;
    }
  }

  String? _capitalize(String? value) {
    if (value == null || value.isEmpty) return null;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  void addAroundProjectRow() {
    setState(() {
      aroundProjectList.add({
        'place': TextEditingController(),
        'distance': TextEditingController(),
        'unit': 'meter',
      });
    });
  }

  void removeAroundProjectRow(int index) {
    if (aroundProjectList.length > 1) {
      setState(() {
        (aroundProjectList[index]['place'] as TextEditingController?)
            ?.dispose();
        (aroundProjectList[index]['distance'] as TextEditingController?)
            ?.dispose();
        aroundProjectList.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least 1 nearby place is required!')),
      );
    }
  }

  void toggleFurnishingItem(String item) {
    setState(() {
      if (appliance.contains(item)) {
        appliance.remove(item);
        customFurnishingItems.remove(item);
      } else {
        appliance.add(item);
      }
    });
  }

  void addCustomAppliance() {
    final text = applianceController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      if (!appliance.contains(text)) {
        appliance.add(text);
      }
      if (!customFurnishingItems.contains(text)) {
        customFurnishingItems.add(text);
      }
      applianceController.clear();
    });
  }

  void addCustomAmenity() {
    final text = _customAmenityController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      if (!allAmenities.contains(text)) {
        allAmenities.insert(0, text);
      }
      if (!selectedAmenities.contains(text)) {
        selectedAmenities.add(text);
      }
      if (!customAmenitiesList.contains(text)) {
        customAmenitiesList.add(text);
      }
      _customAmenityController.clear();
    });
  }

  @override
  void dispose() {
    _stateController.dispose();
    cityController.dispose();
    localityController.dispose();
    _houseNumberController.dispose();
    _pincodeController.dispose();
    _propertyAddressController.dispose();
    _priceController.dispose();
    _bedroomsController.dispose();
    _areaController.dispose();
    _availableFromController.dispose();
    _customSecurityDepositController.dispose();
    _bathroomsController.dispose();
    _kitchenController.dispose();
    _balconyController.dispose();
    _parkingController.dispose();
    _permitNoController.dispose();
    _reraController.dispose();
    _dedController.dispose();
    _brnController.dispose();
    _descriptionController.dispose();
    _projectAreaController.dispose();
    _unitSizesController.dispose();
    _projectSizeController.dispose();
    _launchDateController.dispose();
    _possessionDateController.dispose();
    applianceController.dispose();
    _customAmenityController.dispose();

    for (var element in aroundProjectList) {
      (element['place'] as TextEditingController?)?.dispose();
      (element['distance'] as TextEditingController?)?.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF24ADD7)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formatted =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      setState(() => controller.text = formatted);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocationLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String stateName = '';
      String cityName = '';
      String postalCode = '';
      String localityName = '';
      String addressStr = '';

      // 1. Nominatim Reverse Geocoding (matches website logic)
      try {
        final dio = Dio();
        final res = await dio.get(
          'https://nominatim.openstreetmap.org/reverse',
          queryParameters: {
            'format': 'json',
            'lat': position.latitude,
            'lon': position.longitude,
          },
          options: Options(
            headers: {'User-Agent': 'RealStateAppProject/1.0'},
            sendTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8),
          ),
        );
        if (res.statusCode == 200 &&
            res.data != null &&
            res.data['address'] != null) {
          final addr = Map<String, dynamic>.from(res.data['address']);
          stateName = (addr['state'] ?? '').toString().trim();
          cityName =
              (addr['city'] ??
                      addr['town'] ??
                      addr['district'] ??
                      addr['city_district'] ??
                      '')
                  .toString()
                  .trim();
          postalCode = (addr['postcode'] ?? '').toString().trim();
          localityName =
              (addr['suburb'] ??
                      addr['neighbourhood'] ??
                      addr['residential'] ??
                      addr['city_district'] ??
                      '')
                  .toString()
                  .trim();
          final road = (addr['road'] ?? '').toString().trim();
          addressStr = [
            road,
            localityName,
            cityName,
            stateName,
            if (postalCode.isNotEmpty) postalCode,
          ].where((e) => e.isNotEmpty).join(", ");
        }
      } catch (e) {
        debugPrint("Nominatim error: $e");
      }

      // 2. Fallback to placemarkFromCoordinates if any field is empty
      if (stateName.isEmpty || cityName.isEmpty || postalCode.isEmpty) {
        try {
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            if (stateName.isEmpty) {
              stateName = (place.administrativeArea ?? "").trim();
            }
            if (cityName.isEmpty) {
              cityName =
                  (place.locality ??
                          place.subAdministrativeArea ??
                          place.administrativeArea ??
                          "")
                      .trim();
            }
            if (postalCode.isEmpty) {
              postalCode = (place.postalCode ?? "").trim();
            }
            if (localityName.isEmpty) {
              localityName = (place.subLocality ?? place.locality ?? "").trim();
            }
            if (addressStr.isEmpty) {
              addressStr = [
                place.name,
                place.street,
                place.subLocality,
                place.locality,
                place.administrativeArea,
                if (postalCode.isNotEmpty) postalCode,
                place.country,
              ].where((e) => e != null && e.trim().isNotEmpty).join(", ");
            }
          }
        } catch (e) {
          log("Placemark error: $e");
        }
      }

      await ref
          .read(locationProvider.notifier)
          .save(city: cityName, locality: localityName, address: addressStr);

      final cityResponse = await ref.read(getCityController.future);
      String matchedCity = cityName;
      String? matchedCityId;
      List<String> areas = [];

      if (cityResponse.data != null && cityName.isNotEmpty) {
        try {
          final cityData = cityResponse.data!.firstWhere(
            (e) =>
                (e.cityName ?? "").trim().toLowerCase() ==
                cityName.toLowerCase(),
          );
          matchedCity = cityData.cityName ?? cityName;
          matchedCityId = cityData.id;
          areas = List<String>.from(cityData.areas ?? []);
        } catch (_) {
          // City not in backend dropdown list
        }
      }

      setState(() {
        _cityResetKey++;
        _stateResetKey++;
        _stateController.text = stateName;
        _pincodeController.text = postalCode;
        selectedCity = matchedCity;
        selectedCityId = matchedCityId;
        cityController.text = matchedCity;
        localityList = areas;
        selectedLocality = localityName.isNotEmpty ? localityName : null;
        localityController.text = localityName;
        isCustomLocalityMode = !areas.any(
          (a) => a.toLowerCase() == localityName.toLowerCase(),
        );
        if (postalCode.isNotEmpty) {
          _pincodeController.text = postalCode;
        }
        if (addressStr.isNotEmpty) {
          _propertyAddressController.text = addressStr;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cityName.isNotEmpty
                ? "Location detected: $cityName, $stateName"
                : "Location updated",
          ),
          backgroundColor: const Color(0xFF24ADD7),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching location: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLocationLoading = false);
    }
  }

  Future<void> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        propertyImages.addAll(images.map((e) => File(e.path)).toList());
      });
    }
  }

  void removeImage(int index) {
    setState(() => propertyImages.removeAt(index));
  }

  bool _validateStep(int step) {
    // 1. Form key validation
    final formValid = _formKey.currentState?.validate() ?? true;

    // 2. Explicit website-identical validation rules (ev())
    if (step == 0) {
      if (selectedType == null &&
          (selectedListingCategory == null ||
              selectedListingCategory!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Listing Category is required"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      if (selectedPropertyType == null || selectedPropertyType!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Property Sector is required"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      if (selectedPropertySubType == null || selectedPropertySubType!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Specific Property Type is required"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      if (isBroker == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please specify if you are a broker"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } else if (step == 1) {
      if (_stateController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("State is required"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      if (selectedCity == null || selectedCity!.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("City is required"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      if (_pincodeController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pincode is required"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      if (!isEditMode && _houseNumberController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("House number is required"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      if (_propertyAddressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Address is required"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      if ((selectedLocality == null ||
              selectedLocality!.trim().isEmpty ||
              selectedLocality == "__no_localities__") &&
          localityController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Locality is required"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } else if (step == 2) {
      final priceVal = double.tryParse(
        _priceController.text.trim().replaceAll(',', ''),
      );
      if (priceVal == null || priceVal <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Valid price required"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      final areaVal = double.tryParse(
        _areaController.text.trim().replaceAll(',', ''),
      );
      if (areaVal == null || areaVal <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Valid area required"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      final isLand =
          selectedPropertySubType?.toLowerCase().contains("land") ?? false;
      if (!isLand && (_selectedBhk == null || _selectedBhk!.trim().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bedrooms required"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      final isRent =
          selectedType == 2 || selectedListingCategory?.toLowerCase() == "rent";
      if (isRent && _availableFromController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Available From date is required"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } else if (step == 3) {
      final isLand =
          selectedPropertySubType?.toLowerCase().contains("land") ?? false;
      if (!isLand &&
          (selectedFurnishing == null || selectedFurnishing!.trim().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Furnishing is required"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      if (isBroker == true && _reraController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("RERA number is required"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } else if (step == 4) {
      if (propertyImages.length < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Upload at least 1 photo"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    return formValid;
  }

  void _handleNextStep() {
    if (!_validateStep(_currentStep)) return;

    if (_isLastStep) {
      _submitProperty();
    } else {
      setState(() => _currentStep++);
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitProperty() async {
    if (_isLoading) return;

    for (int step = 0; step < 5; step++) {
      if (!_validateStep(step)) {
        setState(() => _currentStep = step);
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final service = APIStateNetwork(createDio());

      List<String> finalImageUrls = propertyImages.whereType<String>().toList();
      final newFiles = propertyImages.whereType<File>().toList();

      if (newFiles.isNotEmpty) {
        final uploadRes = await service.uploadImageMultiple(newFiles);
        if (uploadRes.error == false && uploadRes.data != null) {
          final newUrls = uploadRes.data!
              .map((e) => e.imageUrl ?? '')
              .where((url) => url.isNotEmpty)
              .toList();
          finalImageUrls.addAll(newUrls);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Image upload failed"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (finalImageUrls.length < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Upload at least 1 photo"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Format aroundProject with distance & unit (Meter / KM)
      final aroundProjects = aroundProjectList
          .map((map) {
            final place =
                (map['place'] as TextEditingController?)?.text.trim() ?? '';
            final dist =
                (map['distance'] as TextEditingController?)?.text.trim() ?? '';
            final unit = (map['unit'] as String?) == 'km' ? 'KM' : 'Meter';
            final details = dist.isNotEmpty ? "$dist $unit" : "";
            return createModel.AroundProject(name: place, details: details);
          })
          .where((ap) => ap.name?.isNotEmpty == true)
          .toList();

      final aveneu = createModel.AveneuOverView(
        projectArea: _projectAreaController.text.trim(),
        size: _unitSizesController.text.trim(),
        projectSize: _projectSizeController.text.trim(),
        launchDate: _launchDateController.text.trim(),
        possessionStart: _possessionDateController.text.trim(),
      );

      final body = CreatePropertyBodyModel(
        localityArea: selectedLocality,
        property: selectedPropertyType?.toLowerCase(),
        propertyType: selectedPropertySubType?.toLowerCase() == 'home'
            ? 'Home'
            : selectedPropertySubType,
        listingCategory: selectedType == 1 ? "sell" : "rent",
        city: selectedCity ?? "",
        houseNumber: _houseNumberController.text.trim(),
        pincode: _pincodeController.text.trim(),
        propertyAddress: _propertyAddressController.text.trim(),
        price: _priceController.text.trim(),
        area: _areaController.text.trim(),
        bedRoom: _bedroomsController.text.replaceAll(" BHK", "").trim(),
        availableFrom: _availableFromController.text.trim(),
        securityDeposit: selectedSecurityDeposit,
        customSecurityDeposit: _customSecurityDepositController.text.trim(),
        room: selectedRoom,
        guestRoom: selectedGuestRoom,
        bathrooms: _selectBathroom ?? _bathroomsController.text.trim(),
        kitchen: _selectkitchen ?? _kitchenController.text.trim(),
        balcony: _selectBalcony ?? _balconyController.text.trim(),
        parking: _selectParking ?? _parkingController.text.trim(),
        furnishing: selectedFurnishing?.toLowerCase(),
        amenities: selectedAmenities,
        furnishingItems: appliance,
        aroundProject: aroundProjects,
        permitNo: _permitNoController.text.trim(),
        rera: _reraController.text.trim(),
        ded: _dedController.text.trim(),
        brn: _brnController.text.trim(),
        description: _descriptionController.text.trim(),
        aveneuOverView: aveneu,
        uploadedPhotos: finalImageUrls,
        isBroker: isBroker == true ? "yes" : "no",
      );

      dynamic response;
      if (isEditMode && propertyId != null && propertyId!.isNotEmpty) {
        final updateAround = aroundProjectList
            .map((map) {
              final place =
                  (map['place'] as TextEditingController?)?.text.trim() ?? '';
              final dist =
                  (map['distance'] as TextEditingController?)?.text.trim() ??
                  '';
              final unit = (map['unit'] as String?) == 'km' ? 'KM' : 'Meter';
              final details = dist.isNotEmpty ? "$dist $unit" : "";
              return updateModel.AroundProject(name: place, details: details);
            })
            .where((ap) => ap.name?.isNotEmpty == true)
            .toList();

        final updateAveneu = updateModel.AveneuOverView(
          projectArea: _projectAreaController.text.trim(),
          size: _unitSizesController.text.trim(),
          projectSize: _projectSizeController.text.trim(),
          launchDate: _launchDateController.text.trim(),
          possessionStart: _possessionDateController.text.trim(),
        );

        response = await service.updateProperty(
          UpdatePropertyBodyModel(
            id: propertyId,
            localityArea: selectedLocality,
            property: selectedPropertyType!.toLowerCase(),
            propertyType: selectedPropertySubType?.toLowerCase() == 'home'
                ? 'Home'
                : selectedPropertySubType,
            listingCategory: selectedType == 1 ? "sell" : "rent",
            city: selectedCity ?? "",
            houseNumber: _houseNumberController.text.trim(),
            pincode: _pincodeController.text.trim(),
            propertyAddress: _propertyAddressController.text.trim(),
            price: _priceController.text.trim(),
            area: _areaController.text.trim(),
            bedRoom: _bedroomsController.text.replaceAll(" BHK", "").trim(),
            availableFrom: _availableFromController.text.trim(),
            securityDeposit: selectedSecurityDeposit,
            customSecurityDeposit: _customSecurityDepositController.text.trim(),
            room: selectedRoom,
            guestRoom: selectedGuestRoom,
            bathrooms: _selectBathroom ?? _bathroomsController.text.trim(),
            kitchen: _selectkitchen ?? _kitchenController.text.trim(),
            balcony: _selectBalcony ?? _balconyController.text.trim(),
            parking: _selectParking ?? _parkingController.text.trim(),
            furnishing: selectedFurnishing?.toLowerCase(),
            amenities: selectedAmenities,
            furnishingItems: appliance,
            aroundProject: updateAround,
            permitNo: _permitNoController.text.trim(),
            rera: _reraController.text.trim(),
            ded: _dedController.text.trim(),
            brn: _brnController.text.trim(),
            description: _descriptionController.text.trim(),
            aveneuOverView: updateAveneu,
            uploadedPhotos: finalImageUrls,
            isBroker: isBroker == true ? "yes" : "no",
          ),
        );
      } else {
        response = await service.createProperty(body);
      }

      if (response != null && response.error == false) {
        ref.invalidate(getMyPropertyController);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? "Property Updated Successfully!"
                  : "Property Upload Successfully.",
            ),
            backgroundColor: const Color(0xFF17C69B),
          ),
        );

        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } else {
        final errMsg = response?.message ?? "Property submission failed";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      log("Error submitting property: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cityAsync = ref.watch(getCityController);
    final categoryAsync = ref.watch(getPropertyCategoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF24ADD7),
        elevation: 0,
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
            children: [
              const TextSpan(
                text: "Property",
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: "Le",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              ),
              TextSpan(
                text: isEditMode ? " | Edit Property" : " | Add Property",
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        leading: !widget.fromBottomNav
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top 5-Step Stepper Navigation Bar
              _buildStepperHeader(),

              SizedBox(height: 14.h),

              // Current step form widget
              Container(
                key: ValueKey(_currentStep),
                child: _buildCurrentStep(cityAsync, categoryAsync),
              ),

              SizedBox(height: 18.h),

              // Navigation Buttons (Back & Save / Publish)
              _buildNavigationButtons(),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  // ────── Bottom Navigation Buttons ──────
  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // BACK Button (uppercase tracking-widest text button)
        if (_currentStep > 0)
          TextButton(
            onPressed: _goToPreviousStep,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            child: Text(
              'BACK',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: Colors.grey.shade500,
                letterSpacing: 1.2,
              ),
            ),
          )
        else
          const SizedBox.shrink(),

        // SAVE & CONTINUE or PUBLISH PROPERTY
        SizedBox(
          height: 48.h,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleNextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isLastStep
                  ? const Color(0xFF17C69B) // emerald green on step 5
                  : const Color(0xFF24ADD7), // cyan/blue on steps 1-4
              foregroundColor: Colors.white,
              elevation: 2,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : Text(
                    _isLastStep
                        ? (isEditMode ? 'UPDATE PROPERTY' : 'PUBLISH PROPERTY')
                        : 'SAVE & CONTINUE',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ────── Modern 5-Step Stepper Header ──────
  Widget _buildStepperHeader() {
    final progress = (_currentStep + 1) / _steps.length;
    final percent = (progress * 100).round();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar & % Complete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$percent% COMPLETE",
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                "STEP ${_currentStep + 1} OF ${_steps.length}",
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF24ADD7),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5.h,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF24ADD7)),
            ),
          ),
          SizedBox(height: 14.h),

          // 5 Step Nodes (Scrollable horizontally)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(_steps.length, (index) {
                final isCurrent = index == _currentStep;
                final isPassed = index < _currentStep;
                final label = _steps[index]['label'] as String;
                final desc = _steps[index]['desc'] as String;

                return GestureDetector(
                  onTap: () {
                    if (isPassed) {
                      setState(() => _currentStep = index);
                    } else if (index > _currentStep) {
                      if (_validateStep(_currentStep)) {
                        setState(() => _currentStep = index);
                      }
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index < _steps.length - 1 ? 14.w : 0,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFFEBF8FC)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28.w,
                          height: 28.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent || isPassed
                                ? const Color(0xFF24ADD7)
                                : const Color(0xFFF9FAFB),
                            border: Border.all(
                              color: isCurrent || isPassed
                                  ? const Color(0xFF24ADD7)
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: isPassed
                                ? const Icon(
                                    Icons.check,
                                    size: 15,
                                    color: Colors.white,
                                  )
                                : Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                      color: isCurrent
                                          ? Colors.white
                                          : Colors.grey.shade400,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w900,
                                color: isCurrent
                                    ? const Color(0xFF111827)
                                    : (isPassed
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade400),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              desc.toUpperCase(),
                              style: TextStyle(
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade400,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ────── Step View Selector ──────
  Widget _buildCurrentStep(
    AsyncValue<CityResponseModel> cityAsync,
    AsyncValue<cat_model.GetPropertyCategoriyModel> categoryAsync,
  ) {
    switch (_currentStep) {
      case 0:
        return _buildStep1BasicInfo(categoryAsync);
      case 1:
        return _buildStep2Location(cityAsync);
      case 2:
        return _buildStep3Specifications();
      case 3:
        return _buildStep4AmenitiesLegal();
      case 4:
        return _buildStep5MediaDescription();
      default:
        return const SizedBox();
    }
  }

  // ══════════════════════════════════════════
  // STEP 1: BASIC INFO (Type & Category)
  // ══════════════════════════════════════════
  Widget _buildStep1BasicInfo(
    AsyncValue<cat_model.GetPropertyCategoriyModel> categoryAsync,
  ) {
    final fallbackResidential = const [
      PropertySubTypeItem(title: "Apartment", value: "apartment"),
      PropertySubTypeItem(title: "Townhouse", value: "townhouse"),
      PropertySubTypeItem(title: "Villa Compound", value: "villa-compound"),
      PropertySubTypeItem(title: "Land", value: "land"),
      PropertySubTypeItem(title: "Building", value: "building"),
      PropertySubTypeItem(title: "Villa", value: "villa"),
      PropertySubTypeItem(title: "Home", value: "home"),
      PropertySubTypeItem(title: "Penthouse", value: "penthouse"),
      PropertySubTypeItem(title: "Hotel Apartment", value: "hotel-apartment"),
      PropertySubTypeItem(title: "Floor", value: "floor"),
      PropertySubTypeItem(title: "Studio", value: "studio"),
      PropertySubTypeItem(title: "Condos", value: "condos"),
    ];
    final fallbackCommercial = const [
      PropertySubTypeItem(title: "Office", value: "office"),
      PropertySubTypeItem(title: "Warehouse", value: "warehouse"),
      PropertySubTypeItem(title: "Industrial Land", value: "industrial-land"),
      PropertySubTypeItem(title: "Showroom", value: "showroom"),
      PropertySubTypeItem(title: "Shop", value: "shop"),
      PropertySubTypeItem(title: "Labour Camp", value: "labour-camp"),
      PropertySubTypeItem(title: "Bulk Unit", value: "bulk-unit"),
      PropertySubTypeItem(title: "Factory", value: "factory"),
      PropertySubTypeItem(title: "Mixed Use Land", value: "mixed-use-land"),
      PropertySubTypeItem(title: "Other Commercial", value: "other-commercial"),
      PropertySubTypeItem(title: "Floor", value: "floor"),
      PropertySubTypeItem(title: "Building", value: "building"),
      PropertySubTypeItem(title: "Villa", value: "villa"),
    ];

    final dynamicCategories =
        categoryAsync.whenOrNull(data: (catData) => catData.data?.list) ?? [];

    final isCommercial = selectedPropertyType == "Commercial";
    final targetSector = isCommercial
        ? cat_model.PropertySector.COMMERCIAL
        : cat_model.PropertySector.RESIDENTIAL;

    final dynamicOptions = dynamicCategories
        .where((cat) {
          final notDeleted = cat.isDeleted != true;
          final notDisabled = cat.isDisable != true;
          final matchesSector = cat.propertySector == targetSector;
          return notDeleted &&
              notDisabled &&
              matchesSector &&
              cat.name != null &&
              cat.name!.trim().isNotEmpty;
        })
        .map((cat) {
          final title = cat.name!.trim();
          final value =
              (cat.propertyTypeKey != null &&
                  cat.propertyTypeKey!.trim().isNotEmpty)
              ? cat.propertyTypeKey!.trim()
              : title.toLowerCase().replaceAll(' ', '-');
          return PropertySubTypeItem(title: title, value: value);
        })
        .toList();

    final List<PropertySubTypeItem> currentOptions = dynamicOptions.isNotEmpty
        ? dynamicOptions
        : (isCommercial ? fallbackCommercial : fallbackResidential);

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeaderTitle("Basic Details"),

          // 1. Listing Purpose (Sell / Rent Out)
          FormField<int>(
            key: ValueKey(selectedType),
            initialValue: selectedType,
            validator: (_) {
              if (selectedType == null) {
                return "Please select Listing Purpose (Sell / Rent Out)";
              }
              return null;
            },
            builder: (fieldState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel("Listing Purpose", isRequired: true),
                  Container(
                    height: 48.h,
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: fieldState.hasError
                            ? Colors.red
                            : const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedType = 1;
                                selectedListingCategory = "sell";
                              });
                              fieldState.didChange(1);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                color: selectedType == 1
                                    ? const Color(0xFF24ADD7)
                                    : Colors.transparent,
                                boxShadow: selectedType == 1
                                    ? [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF24ADD7,
                                          ).withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'SELL',
                                style: TextStyle(
                                  color: selectedType == 1
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12.5.sp,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedType = 2;
                                selectedListingCategory = "rent";
                              });
                              fieldState.didChange(2);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                color: selectedType == 2
                                    ? const Color(0xFF24ADD7)
                                    : Colors.transparent,
                                boxShadow: selectedType == 2
                                    ? [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF24ADD7,
                                          ).withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'RENT OUT',
                                style: TextStyle(
                                  color: selectedType == 2
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12.5.sp,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (fieldState.hasError)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h, left: 4.w),
                      child: Text(
                        fieldState.errorText!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 11.5.sp,
                          height: 1.1,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(height: 16.h),

          // 2. Property Sector (Residential / Commercial)
          _buildDropdown(
            'Property Sector',
            selectedPropertyType,
            ["Residential", "Commercial"],
            (v) => setState(() {
              selectedPropertyType = v;
              selectedPropertySubType = null;
            }),
            isRequired: true,
          ),
          SizedBox(height: 16.h),

          // 3. Specific Property Type (Grid of pills)
          if (selectedPropertyType != null)
            FormField<String>(
              key: ValueKey(selectedPropertySubType),
              initialValue: selectedPropertySubType,
              validator: (_) {
                if (selectedPropertySubType == null ||
                    selectedPropertySubType!.isEmpty) {
                  return "Please select Specific Property Type";
                }
                return null;
              },
              builder: (fieldState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      "Specific Property Type",
                      isRequired: true,
                    ),
                    Container(
                      decoration: fieldState.hasError
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.red, width: 1.2),
                            )
                          : null,
                      padding: fieldState.hasError
                          ? EdgeInsets.all(4.r)
                          : EdgeInsets.zero,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentOptions.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8.h,
                          crossAxisSpacing: 8.w,
                          mainAxisExtent: 44.h,
                        ),
                        itemBuilder: (context, index) {
                          final item = currentOptions[index];
                          final isSelected =
                              selectedPropertySubType != null &&
                              (selectedPropertySubType!.toLowerCase() ==
                                      item.value.toLowerCase() ||
                                  selectedPropertySubType!.toLowerCase() ==
                                      item.title.toLowerCase() ||
                                  selectedPropertySubType!
                                          .toLowerCase()
                                          .replaceAll('-', ' ') ==
                                      item.title.toLowerCase());

                          return GestureDetector(
                            onTap: () {
                              setState(
                                () => selectedPropertySubType = item.value,
                              );
                              fieldState.didChange(item.value);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFEBF8FC)
                                    : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF24ADD7)
                                      : const Color(0xFFE5E7EB),
                                  width: isSelected ? 2.0 : 1.5,
                                ),
                              ),
                              child: Text(
                                item.title.toUpperCase(),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11.5.sp,
                                  color: isSelected
                                      ? const Color(0xFF24ADD7)
                                      : const Color(0xFF4B5563),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (fieldState.hasError)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h, left: 4.w),
                        child: Text(
                          fieldState.errorText!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 11.5.sp,
                            height: 1.1,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

          SizedBox(height: 16.h),

          // 4. Are you a broker?
          FormField<bool>(
            key: ValueKey(isBroker),
            initialValue: isBroker,
            validator: (_) {
              if (isBroker == null) {
                return "Please specify if you are a broker";
              }
              return null;
            },
            builder: (fieldState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel("Are You A Broker?", isRequired: true),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => isBroker = true);
                            fieldState.didChange(true);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: isBroker == true
                                  ? const Color(0xFF24ADD7)
                                  : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: fieldState.hasError
                                    ? Colors.red
                                    : (isBroker == true
                                          ? const Color(0xFF24ADD7)
                                          : const Color(0xFFE5E7EB)),
                                width: isBroker == true ? 2 : 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "YES",
                                style: TextStyle(
                                  color: isBroker == true
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12.5.sp,
                                  letterSpacing: 0.6,
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
                            setState(() => isBroker = false);
                            fieldState.didChange(false);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: isBroker == false
                                  ? const Color(0xFF24ADD7)
                                  : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: fieldState.hasError
                                    ? Colors.red
                                    : (isBroker == false
                                          ? const Color(0xFF24ADD7)
                                          : const Color(0xFFE5E7EB)),
                                width: isBroker == false ? 2 : 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "NO",
                                style: TextStyle(
                                  color: isBroker == false
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12.5.sp,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (fieldState.hasError)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h, left: 4.w),
                      child: Text(
                        fieldState.errorText!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 11.5.sp,
                          height: 1.1,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // STEP 2: LOCATION (City & Address)
  // ══════════════════════════════════════════
  Widget _buildStep2Location(AsyncValue<CityResponseModel> cityAsync) {
    final cities = cityAsync.value?.data ?? [];
    if (selectedCity != null && cities.isNotEmpty) {
      try {
        final match = cities.firstWhere(
          (c) =>
              (c.cityName ?? '').trim().toLowerCase() ==
              selectedCity!.trim().toLowerCase(),
        );
        localityList = List<String>.from(match.areas ?? []);
      } catch (_) {
        localityList = [];
      }
    } else if (selectedCity == null || selectedCity!.trim().isEmpty) {
      localityList = [];
    }

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeaderTitle("Property Location"),

          // Use current location button (Matches website prominent cyan button)
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: _isLocationLoading ? null : _useCurrentLocation,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF24ADD7),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF24ADD7).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLocationLoading)
                      SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      Icon(Icons.my_location, size: 16.sp, color: Colors.white),
                    SizedBox(width: 8.w),
                    Text(
                      _isLocationLoading
                          ? "Detecting location..."
                          : "Use my current location",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // State * (Website field)
          _buildStateField(),
          SizedBox(height: 14.h),

          // City * (Website field)
          _buildCityDropdown(cityAsync),
          SizedBox(height: 14.h),

          // Pincode * (Website field)
          _buildTextField(
            'Pincode',
            _pincodeController,
            hint: 'e.g. 474001',
            type: TextInputType.number,
            isRequired: true,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Pincode is required';
              }
              return null;
            },
          ),
          SizedBox(height: 14.h),

          // House No / Tower / Block (Website field - optional in edit mode)
          _buildTextField(
            'House No / Tower / Block',
            _houseNumberController,
            hint: 'e.g. A-101',
            isRequired: !isEditMode,
            validator: (val) {
              if (!isEditMode && (val == null || val.trim().isEmpty)) {
                return 'House number is required';
              }
              return null;
            },
          ),
          SizedBox(height: 14.h),

          // Address (building, street, etc.) * (Website field)
          _buildTextField(
            'Address (building, street, etc.)',
            _propertyAddressController,
            hint: 'Detailed address...',
            maxLines: 2,
            isRequired: true,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Address is required';
              }
              return null;
            },
          ),
          SizedBox(height: 14.h),

          // Locality / Area Dropdown (From getCityList or "No localities available")
          _buildLocalityDropdownField(),
        ],
      ),
    );
  }

  Widget _buildLocalityDropdownField() {
    final hasSelected =
        selectedLocality != null && selectedLocality!.trim().isNotEmpty;
    final currentValue = hasSelected ? selectedLocality!.trim() : "";

    final List<DropdownMenuItem<String>> dropdownItems = [];

    // Header default option matching image
    dropdownItems.add(
      DropdownMenuItem<String>(
        value: "",
        child: Text(
          "Select Locality / Area",
          style: TextStyle(
            fontSize: 13.5.sp,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

    if (localityList.isNotEmpty) {
      for (final area in localityList) {
        final trimmed = area.trim();
        if (trimmed.isEmpty) continue;
        if (!dropdownItems.any((item) => item.value == trimmed)) {
          dropdownItems.add(
            DropdownMenuItem<String>(
              value: trimmed,
              child: Text(
                trimmed,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }
      }
    } else {
      // Exactly matching image: "No localities available"
      dropdownItems.add(
        DropdownMenuItem<String>(
          value: "__no_localities__",
          child: Text(
            "No localities available",
            style: TextStyle(
              fontSize: 13.5.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Preserve existing selection if prefilled (e.g. edit mode)
    if (currentValue.isNotEmpty &&
        !dropdownItems.any((item) => item.value == currentValue)) {
      dropdownItems.add(
        DropdownMenuItem<String>(
          value: currentValue,
          child: Text(
            currentValue,
            style: TextStyle(
              fontSize: 13.5.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final safeValue = dropdownItems.any((item) => item.value == currentValue)
        ? currentValue
        : "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Locality / Area", isRequired: true),
        if (!isCustomLocalityMode) ...[
          DropdownButtonFormField<String>(
            key: ValueKey("${safeValue}_${localityList.length}_$selectedCity"),
            initialValue: safeValue,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.black87,
              size: 22.sp,
            ),
            menuMaxHeight: 300.h,
            dropdownColor: Colors.white,
            style: TextStyle(
              fontSize: 13.5.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 13.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(
                  color: Color(0xFF24ADD7),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(
                  color: Color(0xFF24ADD7),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(
                  color: Color(0xFF24ADD7),
                  width: 1.8,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: Colors.red, width: 1.8),
              ),
            ),
            items: dropdownItems,
            onChanged: (val) {
              if (val == "__no_localities__") {
                setState(() {
                  isCustomLocalityMode = true;
                });
                return;
              }
              setState(() {
                selectedLocality = (val == null || val.isEmpty) ? null : val;
                localityController.text = selectedLocality ?? "";
              });
            },
            validator: (val) {
              if (val == null ||
                  val.trim().isEmpty ||
                  val == "__no_localities__") {
                return 'Locality is required';
              }
              return null;
            },
          ),
          SizedBox(height: 6.h),
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                setState(() {
                  isCustomLocalityMode = true;
                });
              },
              borderRadius: BorderRadius.circular(6.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 15.sp,
                      color: const Color(0xFF24ADD7),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      "Area not listed? Add locality area",
                      style: TextStyle(
                        color: const Color(0xFF24ADD7),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else ...[
          // Custom text input mode
          TextFormField(
            controller: localityController,
            style: TextStyle(
              fontSize: 13.5.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            onChanged: (value) {
              selectedLocality = value;
            },
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Locality is required';
              }
              return null;
            },
            decoration: _inputDecoration(
              hint: 'Enter Locality / Area (e.g. Bani Park)',
            ),
          ),
          SizedBox(height: 6.h),
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                setState(() {
                  isCustomLocalityMode = false;
                });
              },
              borderRadius: BorderRadius.circular(6.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.list_alt_rounded,
                      size: 15.sp,
                      color: const Color(0xFF24ADD7),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      "Select from locality list instead",
                      style: TextStyle(
                        color: const Color(0xFF24ADD7),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════
  // STEP 3: SPECIFICATIONS (Area & Price)
  // ══════════════════════════════════════════
  Widget _buildStep3Specifications() {
    final isRent = selectedType == 2 || selectedListingCategory == "rent";
    final isLand = selectedPropertySubType?.contains("land") ?? false;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeaderTitle("Specifications"),

          // Price (Rent vs Sell label dynamic)
          _buildTextField(
            isRent ? 'Monthly Rent (₹)' : 'Sell Price (₹)',
            _priceController,
            hint: isRent ? 'e.g. 25000' : 'e.g. 500000',
            type: TextInputType.number,
            isRequired: true,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Valid price required';
              }
              final numVal = double.tryParse(v.trim().replaceAll(',', ''));
              if (numVal == null || numVal <= 0) {
                return 'Valid price required';
              }
              return null;
            },
          ),
          SizedBox(height: 14.h),

          // BHK (hidden if land)
          if (!isLand) ...[
            _buildDropdown(
              'BHK',
              _selectedBhk,
              [
                "1 BHK",
                "2 BHK",
                "3 BHK",
                "4 BHK",
                "5 BHK",
                "6 BHK",
                "7 BHK",
                "8 BHK",
              ],
              (v) {
                setState(() {
                  _selectedBhk = v;
                  _bedroomsController.text = v ?? "";
                });
              },
              isRequired: true,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Bedrooms required';
                }
                return null;
              },
            ),
            SizedBox(height: 14.h),
          ],

          // Area (sq.ft)
          _buildTextField(
            'Area (Sqft)',
            _areaController,
            hint: 'e.g. 1500',
            type: TextInputType.number,
            isRequired: true,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Valid area required';
              }
              final numVal = double.tryParse(v.trim().replaceAll(',', ''));
              if (numVal == null || numVal <= 0) {
                return 'Valid area required';
              }
              return null;
            },
          ),
          SizedBox(height: 14.h),

          // Rent-specific fields (Available From & Security Deposit)
          if (isRent) ...[
            _buildTextField(
              'Available From',
              _availableFromController,
              hint: "DD/MM/YYYY",
              readOnly: true,
              onTap: () => _selectDate(_availableFromController),
              suffixIcon: Icon(
                Icons.calendar_today,
                color: const Color(0xFF24ADD7),
                size: 16.sp,
              ),
              isRequired: true,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Available From date is required';
                }
                return null;
              },
            ),
            SizedBox(height: 14.h),

            _buildFieldLabel("SECURITY DEPOSIT"),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: ["None", "1 month", "2 month", "Custom"].map((dep) {
                final isSelected = selectedSecurityDeposit == dep;
                return GestureDetector(
                  onTap: () => setState(() => selectedSecurityDeposit = dep),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF24ADD7)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF24ADD7)
                            : const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF24ADD7,
                                ).withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      dep,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade800,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (selectedSecurityDeposit == "Custom") ...[
              SizedBox(height: 14.h),
              _buildTextField(
                'Enter Custom Amount (₹)',
                _customSecurityDepositController,
                hint: 'e.g. 50000',
                type: TextInputType.number,
                isRequired: true,
                validator: (v) {
                  if (selectedSecurityDeposit == "Custom" &&
                      (v == null || v.trim().isEmpty)) {
                    return 'Custom security deposit is required';
                  }
                  return null;
                },
              ),
            ],
            SizedBox(height: 14.h),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // STEP 4: AMENITIES & LEGAL (RERA & Features)
  // ══════════════════════════════════════════
  Widget _buildStep4AmenitiesLegal() {
    final isLand = selectedPropertySubType?.contains("land") ?? false;
    final isFurnished =
        selectedFurnishing?.toLowerCase() == "furnished" ||
        selectedFurnishing?.toLowerCase() == "semi-furnished";

    final displayFurnishingItems = showAllFurnishingItems
        ? standardFurnishingItems
        : standardFurnishingItems.take(8).toList();

    return Column(
      children: [
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepHeaderTitle("Amenities & Legal"),

              // Room & Facilities Grid (if not land)
              if (!isLand) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        'Rooms',
                        selectedRoom,
                        ["1", "2", "3", "4", "5", "6+"],
                        (v) => setState(() => selectedRoom = v),
                        isRequired: false,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildDropdown(
                        'Guest Room',
                        selectedGuestRoom,
                        ["None", "1", "2", "3+"],
                        (v) => setState(() => selectedGuestRoom = v),
                        isRequired: false,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        'Bathrooms',
                        _selectBathroom,
                        ["1", "2", "3", "4", "5", "6+"],
                        (v) {
                          setState(() {
                            _selectBathroom = v;
                            _bathroomsController.text = v ?? "";
                          });
                        },
                        isRequired: false,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildDropdown(
                        'Kitchen',
                        _selectkitchen,
                        ["1", "2", "3", "4+"],
                        (v) {
                          setState(() {
                            _selectkitchen = v;
                            _kitchenController.text = v ?? "";
                          });
                        },
                        isRequired: false,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        'Balcony',
                        _selectBalcony,
                        ["1", "2", "3", "4+"],
                        (v) {
                          setState(() {
                            _selectBalcony = v;
                            _balconyController.text = v ?? "";
                          });
                        },
                        isRequired: false,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildDropdown(
                        'Parking',
                        _selectParking,
                        ["1", "2", "3", "4+"],
                        (v) {
                          setState(() {
                            _selectParking = v;
                            _parkingController.text = v ?? "";
                          });
                        },
                        isRequired: false,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
              ],

              // Key Amenities
              _buildFieldLabel("Select Key Amenities"),
              _buildMultiSelectAmenities(),
              SizedBox(height: 12.h),

              // Custom Amenity Adder
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ADD OTHER / CUSTOM AMENITY:",
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _customAmenityController,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: _inputDecoration(
                            hint:
                                'Type custom amenity (e.g. Solar Panels, Servant Quarter)...',
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton(
                        onPressed: addCustomAmenity,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24ADD7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 13.h,
                          ),
                        ),
                        child: Text(
                          "+ Add",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (customAmenitiesList.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: customAmenitiesList.map((item) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF24ADD7),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    customAmenitiesList.remove(item);
                                    selectedAmenities.remove(item);
                                    allAmenities.remove(item);
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 14.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 20.h),

              // Around The Project
              Row(
                children: [
                  Container(
                    width: 24.w,
                    height: 3.h,
                    color: const Color(0xFF24ADD7),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "AROUND THE PROJECT",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF24ADD7),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              ...List.generate(aroundProjectList.length, (idx) {
                final currentUnit =
                    aroundProjectList[idx]['unit'] as String? ?? 'meter';
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 28.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel("Place Name"),
                            TextFormField(
                              controller:
                                  aroundProjectList[idx]['place']
                                      as TextEditingController?,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: _inputDecoration(
                                hint: 'e.g. Metro Station, Hospital',
                              ),
                            ),
                            SizedBox(height: 10.h),

                            _buildFieldLabel("Distance & Unit"),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller:
                                        aroundProjectList[idx]['distance']
                                            as TextEditingController?,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: _inputDecoration(
                                      hint: currentUnit == 'km'
                                          ? 'e.g. 2.5'
                                          : 'e.g. 500',
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => setState(
                                          () => aroundProjectList[idx]['unit'] =
                                              'meter',
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 8.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: currentUnit == 'meter'
                                                ? const Color(0xFF24ADD7)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              10.r,
                                            ),
                                            border: Border.all(
                                              color: currentUnit == 'meter'
                                                  ? const Color(0xFF24ADD7)
                                                  : const Color(0xFFE5E7EB),
                                            ),
                                          ),
                                          child: Text(
                                            "M",
                                            style: TextStyle(
                                              color: currentUnit == 'meter'
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      GestureDetector(
                                        onTap: () => setState(
                                          () => aroundProjectList[idx]['unit'] =
                                              'km',
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 8.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: currentUnit == 'km'
                                                ? const Color(0xFF24ADD7)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              10.r,
                                            ),
                                            border: Border.all(
                                              color: currentUnit == 'km'
                                                  ? const Color(0xFF24ADD7)
                                                  : const Color(0xFFE5E7EB),
                                            ),
                                          ),
                                          child: Text(
                                            "KM",
                                            style: TextStyle(
                                              color: currentUnit == 'km'
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (aroundProjectList.length > 1)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => removeAroundProjectRow(idx),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: addAroundProjectRow,
                  icon: const Icon(Icons.add, color: Color(0xFF24ADD7)),
                  label: const Text(
                    '+ Add Nearby Place',
                    style: TextStyle(
                      color: Color(0xFF24ADD7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              // RERA Number * (Only visible and required if isBroker == true)
              if (isBroker == true) ...[
                _buildTextField(
                  'RERA NUMBER',
                  _reraController,
                  hint: 'P521000...',
                  isRequired: true,
                  validator: (v) {
                    if (isBroker == true && (v == null || v.trim().isEmpty)) {
                      return 'RERA number is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
              ],

              if (isEditMode) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'PERMIT NO',
                        _permitNoController,
                        hint: 'Permit No',
                        isRequired: false,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildTextField(
                        'DED NO',
                        _dedController,
                        hint: 'DED No',
                        isRequired: false,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildTextField(
                        'BRN NO',
                        _brnController,
                        hint: 'BRN No',
                        isRequired: false,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],

              // Furnishing Status * (if not land)
              if (!isLand) ...[
                _buildDropdown(
                  'Furnishing',
                  selectedFurnishing,
                  ["Furnished", "Semi-Furnished", "Unfurnished"],
                  (v) => setState(() => selectedFurnishing = v),
                  isRequired: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Furnishing is required';
                    }
                    return null;
                  },
                ),

                // Furnishing Items (if furnished / semi-furnished)
                if (isFurnished) ...[
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFieldLabel("Select Furnishing Items"),
                      Text(
                        "${appliance.length} selected",
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: const Color(0xFF24ADD7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: displayFurnishingItems.map((item) {
                      final isSelected = appliance.contains(item);
                      return GestureDetector(
                        onTap: () => toggleFurnishingItem(item),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF24ADD7)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF24ADD7)
                                  : const Color(0xFFE5E7EB),
                              width: 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF24ADD7,
                                      ).withValues(alpha: 0.25),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            item,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (standardFurnishingItems.length > 8)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            showAllFurnishingItems = !showAllFurnishingItems;
                          });
                        },
                        child: Text(
                          showAllFurnishingItems
                              ? "View Less ▲"
                              : "View More ▼",
                          style: TextStyle(
                            color: const Color(0xFF24ADD7),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 8.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ADD OTHER / CUSTOM FURNISHING ITEM:",
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.6,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: applianceController,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: _inputDecoration(
                                hint: 'Type custom furnishing item...',
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          ElevatedButton(
                            onPressed: addCustomAppliance,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF24ADD7),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 13.h,
                              ),
                            ),
                            child: Text(
                              "+ Add",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (customFurnishingItems.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 6.h,
                          children: customFurnishingItems.map((item) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF24ADD7),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        customFurnishingItems.remove(item);
                                        appliance.remove(item);
                                      });
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 14.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
        if (isEditMode) ...[SizedBox(height: 16.h), _buildAvenueOverviewCard()],
      ],
    );
  }

  // ──────────────────────────────────────────
  // AVENUE OVERVIEW CARD (EDIT MODE ONLY)
  // ──────────────────────────────────────────
  Widget _buildAvenueOverviewCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Avenue Overview",
            style: TextStyle(
              color: const Color(0xFF24ADD7),
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 14.h),

          // Row 1: Project Area, Size, Project Size
          Row(
            children: [
              Expanded(
                child: _buildAvenueField(
                  label: "Project Area",
                  controller: _projectAreaController,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildAvenueField(
                  label: "Size",
                  controller: _unitSizesController,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildAvenueField(
                  label: "Project Size",
                  controller: _projectSizeController,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Row 2: Launch Date, Possession Start
          Row(
            children: [
              Expanded(
                child: _buildAvenueDateField(
                  label: "Launch Date",
                  controller: _launchDateController,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildAvenueDateField(
                  label: "Possession Start",
                  controller: _possessionDateController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvenueField({
    required String label,
    required TextEditingController controller,
    String hint = "",
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: 12.5.sp,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(
                color: Color(0xFF1F2937),
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(
                color: Color(0xFF1F2937),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(
                color: Color(0xFF24ADD7),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvenueDateField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: 6.h),
        InkWell(
          onTap: () => _selectAvenueDate(controller),
          borderRadius: BorderRadius.circular(10.r),
          child: IgnorePointer(
            child: TextFormField(
              controller: controller,
              readOnly: true,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: "mm/dd/yyyy",
                hintStyle: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: 12.5.sp,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    size: 18.sp,
                    color: Colors.black87,
                  ),
                ),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 24.w,
                  minHeight: 24.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(
                    color: Color(0xFF1F2937),
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(
                    color: Color(0xFF1F2937),
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(
                    color: Color(0xFF24ADD7),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectAvenueDate(TextEditingController controller) async {
    DateTime initial = DateTime.now();
    if (controller.text.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(controller.text.trim());
      if (parsed != null) initial = parsed;
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF24ADD7),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() => controller.text = formatted);
    }
  }

  // ══════════════════════════════════════════
  // STEP 5: MEDIA & DESCRIPTION
  // ══════════════════════════════════════════
  Widget _buildStep5MediaDescription() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeaderTitle("Photos & Media"),
          Text(
            "CLICK ANY BOX TO UPLOAD · AT LEAST 1 PHOTO REQUIRED",
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w900,
              color: propertyImages.length < 1
                  ? Colors.red.shade700
                  : Colors.grey.shade400,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 14.h),

          FormField<List>(
            key: ValueKey(propertyImages.length),
            validator: (_) {
              if (propertyImages.length < 1) {
                return "Upload at least 1 photo";
              }
              return null;
            },
            builder: (fieldState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: propertyImages.length + 1,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      if (index < propertyImages.length) {
                        final img = propertyImages[index];
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: const Color(
                                    0xFF24ADD7,
                                  ).withValues(alpha: 0.35),
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14.r),
                                child: img is File
                                    ? Image.file(img, fit: BoxFit.cover)
                                    : Image.network(
                                        img.toString(),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF24ADD7),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  "Photo ${index + 1}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  removeImage(index);
                                  fieldState.didChange(propertyImages);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF24ADD7),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      // Upload Button Slot
                      return GestureDetector(
                        onTap: () async {
                          await pickImages();
                          fieldState.didChange(propertyImages);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: fieldState.hasError
                                  ? Colors.red
                                  : Colors.grey.shade300,
                              width: 1.8,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 44.w,
                                height: 44.w,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 24.sp,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "PHOTO ${propertyImages.length + 1}",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey.shade400,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  if (fieldState.hasError)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h, left: 4.w),
                      child: Text(
                        fieldState.errorText!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(height: 8.h),
          Text(
            "${propertyImages.length} / ∞ PHOTOS UPLOADED",
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              color: Colors.grey.shade400,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 20.h),

          // Deep Property Description
          _buildFieldLabel("Deep Property Description"),
          TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            style: TextStyle(
              fontSize: 13.5.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            decoration: _inputDecoration(
              hint:
                  "Write detailed description about your property, amenities, nearby landmarks, furnishing...",
              isMultiline: true,
            ),
          ),
        ],
      ),
    );
  }

  // ────── Common Form Helpers ──────

  Widget _buildStepHeaderTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 19.sp,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF111827),
          letterSpacing: -0.4,
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: RichText(
        text: TextSpan(
          text: label.toUpperCase(),
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1F2937),
            letterSpacing: 0.6,
          ),
          children: isRequired
              ? [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w900,
                      fontSize: 12.sp,
                    ),
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    Widget? suffixIcon,
    bool isMultiline = false,
  }) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFF9CA3AF),
        fontSize: 13.sp,
        fontWeight: FontWeight.normal,
      ),
      errorStyle: TextStyle(
        fontSize: 11.5.sp,
        height: 1.1,
        color: Colors.red.shade700,
      ),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
      suffixIconConstraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: isMultiline ? 12.h : 13.h,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFF24ADD7), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Colors.red, width: 1.8),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    TextInputType? type,
    VoidCallback? onTap,
    bool readOnly = false,
    bool isRequired = true,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired: isRequired),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: type ?? TextInputType.text,
          readOnly: readOnly,
          onTap: onTap,
          style: TextStyle(
            fontSize: 13.5.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          validator:
              validator ??
              (isRequired
                  ? (val) {
                      if (val == null || val.trim().isEmpty) {
                        return '$label is required';
                      }
                      return null;
                    }
                  : null),
          decoration: _inputDecoration(
            hint: hint,
            suffixIcon: suffixIcon,
            isMultiline: maxLines > 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("State", isRequired: true),
        Autocomplete<String>(
          key: ValueKey(_stateResetKey),
          initialValue: TextEditingValue(text: _stateController.text),
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return indianStates;
            }
            return indianStates.where(
              (s) =>
                  s.toLowerCase().contains(textEditingValue.text.toLowerCase()),
            );
          },
          onSelected: (selection) {
            _stateController.text = selection;
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(
                fontSize: 13.5.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              onChanged: (v) {
                _stateController.text = v;
              },
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'State is required';
                }
                return null;
              },
              decoration: _inputDecoration(
                hint: 'Type state...',
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF6B7280),
                  size: 22.sp,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    bool isRequired = true,
    String? Function(String?)? validator,
  }) {
    String? safeValue = items.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired: isRequired),
        DropdownButtonFormField<String>(
          key: ValueKey(safeValue),
          initialValue: safeValue,
          isExpanded: true,
          style: TextStyle(
            fontSize: 13.5.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          hint: Text(
            'Select $label',
            style: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: 13.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey.shade600,
            size: 20.sp,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator:
              validator ??
              (isRequired
                  ? (val) => (val == null || val.isEmpty)
                        ? 'Please select $label'
                        : null
                  : null),
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  Widget _buildCityDropdown(AsyncValue<CityResponseModel> cityAsync) {
    return cityAsync.when(
      data: (cityRes) {
        final cities = cityRes.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel("City", isRequired: true),
            Autocomplete<String>(
              key: ValueKey(_cityResetKey),
              initialValue: TextEditingValue(
                text: selectedCity ?? cityController.text,
              ),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return cities
                      .map((e) => e.cityName ?? "")
                      .where((e) => e.trim().isNotEmpty);
                }
                return cities
                    .map((e) => e.cityName ?? "")
                    .where(
                      (city) => city.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ),
                    );
              },
              onSelected: (String city) {
                setState(() {
                  selectedCity = city;
                  cityController.text = city;
                  selectedLocality = null;
                  localityController.clear();
                  isCustomLocalityMode = false;

                  try {
                    final selectedCityObj = cities.firstWhere(
                      (c) =>
                          (c.cityName ?? "").toLowerCase() ==
                          city.toLowerCase(),
                    );
                    selectedCityId = selectedCityObj.id;
                    localityList = List<String>.from(
                      selectedCityObj.areas ?? [],
                    );
                  } catch (_) {
                    selectedCityId = null;
                    localityList = [];
                  }
                });
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onChanged: (value) {
                        selectedCity = value;
                        cityController.text = value;
                        try {
                          final match = cities.firstWhere(
                            (c) =>
                                (c.cityName ?? "").toLowerCase() ==
                                value.trim().toLowerCase(),
                          );
                          selectedCityId = match.id;
                          localityList = List<String>.from(match.areas ?? []);
                        } catch (_) {
                          selectedCityId = null;
                          localityList = [];
                        }
                      },
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'City is required';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        hint: 'Select or Enter City',
                        suffixIcon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFF6B7280),
                          size: 22.sp,
                        ),
                      ),
                    );
                  },
            ),
          ],
        );
      },
      loading: () => const CupertinoActivityIndicator(),
      error: (_, __) => const Text(
        "Failed to load cities",
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildMultiSelectAmenities() {
    final displayAmenities = showAllAmenities
        ? allAmenities
        : allAmenities.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: displayAmenities.map((amenity) {
            final selected = selectedAmenities.contains(amenity);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (selected) {
                    selectedAmenities.remove(amenity);
                    customAmenitiesList.remove(amenity);
                  } else {
                    selectedAmenities.add(amenity);
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF24ADD7) : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF24ADD7)
                        : const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF24ADD7,
                            ).withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  amenity,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (allAmenities.length > 8)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  showAllAmenities = !showAllAmenities;
                });
              },
              child: Text(
                showAllAmenities ? "View Less ▲" : "View More ▼",
                style: TextStyle(
                  color: const Color(0xFF24ADD7),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
