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
  bool get isEditMode =>
      widget.data != null && (widget.data?.id?.isNotEmpty ?? false);
  String? get propertyId => widget.data?.id;

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
  bool isLocalityFromDropdown = false;
  List<String> localityList = [];
  bool _isLocationLoading = false;
  bool get isCitySelected => selectedCity != null && selectedCity!.isNotEmpty;

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
      isLocalityFromDropdown = true;
      selectedFurnishing = _normalize(data.furnishing);

      _houseNumberController.text = data.houseNumber ?? '';
      _pincodeController.text = data.pincode ?? '';
      _propertyAddressController.text = data.propertyAddress ?? '';
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
      _projectAreaController.text = overview?.projectArea ?? '';
      _unitSizesController.text = overview?.size ?? '';
      _projectSizeController.text = overview?.projectSize ?? '';
      _launchDateController.text = overview?.launchDate ?? '';
      _possessionDateController.text = overview?.possessionStart ?? '';

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
    });
    applianceController.clear();
  }

  void removeCustomAppliance(String item) {
    setState(() {
      appliance.remove(item);
      customFurnishingItems.remove(item);
    });
  }

  void addCustomAmenity() {
    final custom = _customAmenityController.text.trim();
    if (custom.isEmpty) return;
    setState(() {
      if (!allAmenities.contains(custom)) {
        allAmenities.insert(0, custom);
      }
      if (!selectedAmenities.contains(custom)) {
        selectedAmenities.add(custom);
      }
      if (!customAmenitiesList.contains(custom)) {
        customAmenitiesList.add(custom);
      }
    });
    _customAmenityController.clear();
  }

  void removeCustomAmenity(String amenity) {
    setState(() {
      selectedAmenities.remove(amenity);
      customAmenitiesList.remove(amenity);
      allAmenities.remove(amenity);
    });
  }

  @override
  void dispose() {
    _stateController.dispose();
    localityController.dispose();
    _houseNumberController.dispose();
    _propertyAddressController.dispose();
    _pincodeController.dispose();

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

    _projectAreaController.dispose();
    _unitSizesController.dispose();
    _projectSizeController.dispose();
    _launchDateController.dispose();
    _possessionDateController.dispose();

    applianceController.dispose();
    _customAmenityController.dispose();
    _descriptionController.dispose();

    for (var ctrlMap in aroundProjectList) {
      (ctrlMap['place'] as TextEditingController?)?.dispose();
      (ctrlMap['distance'] as TextEditingController?)?.dispose();
    }
    super.dispose();
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
        _stateController.text = stateName;
        _pincodeController.text = postalCode;
        selectedCity = matchedCity;
        selectedCityId = matchedCityId;
        cityController.text = matchedCity;
        localityList = areas;
        selectedLocality = localityName.isNotEmpty ? localityName : null;
        localityController.text = localityName;
        isLocalityFromDropdown = areas.any(
          (a) => a.toLowerCase() == localityName.toLowerCase(),
        );
        if (addressStr.isNotEmpty) {
          _propertyAddressController.text = addressStr;
        }
      });
    } catch (e) {
      debugPrint("Location Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to fetch current location")),
      );
    } finally {
      if (mounted) setState(() => _isLocationLoading = false);
    }
  }

  Future<void> pickImages() async {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Add Property Photos'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final picked = await _picker.pickMultiImage(imageQuality: 75);
              if (picked.isNotEmpty) {
                setState(() {
                  propertyImages.addAll(picked.map((x) => File(x.path)));
                });
              }
            },
            child: const Text('Gallery'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final file = await _picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 75,
              );
              if (file != null) {
                setState(() => propertyImages.add(File(file.path)));
              }
            },
            child: const Text('Camera'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void removeImage(int index) {
    setState(() => propertyImages.removeAt(index));
  }

  bool _validateStep(int step) {
    if (step == 0) {
      if (selectedType == null) {
        _showError("Please select Listing Purpose (Sell / Rent Out)");
        return false;
      }
      if (selectedPropertyType == null) {
        _showError("Please select Property Sector (Residential / Commercial)");
        return false;
      }
      if (selectedPropertySubType == null || selectedPropertySubType!.isEmpty) {
        _showError("Please select Specific Property Type");
        return false;
      }
      if (isBroker == null) {
        _showError("Please specify if you are a broker");
        return false;
      }
    } else if (step == 1) {
      if (selectedCity == null || selectedCity!.trim().isEmpty) {
        _showError("City is required");
        return false;
      }
      if (selectedLocality == null || selectedLocality!.trim().isEmpty) {
        _showError("Locality / Area is required");
        return false;
      }
      if (_houseNumberController.text.trim().isEmpty) {
        _showError("House / Flat Number is required");
        return false;
      }
      if (_propertyAddressController.text.trim().isEmpty) {
        _showError("Property Address is required");
        return false;
      }
      if (_pincodeController.text.trim().isEmpty) {
        _showError("Pincode is required");
        return false;
      }
    } else if (step == 2) {
      if (_priceController.text.trim().isEmpty) {
        _showError("Valid price is required");
        return false;
      }
      if (_areaController.text.trim().isEmpty) {
        _showError("Valid area is required");
        return false;
      }
      final isLand = selectedPropertySubType?.contains("land") ?? false;
      if (!isLand && (_selectedBhk == null || _selectedBhk!.isEmpty)) {
        _showError("BHK is required");
        return false;
      }
      if (selectedType == 2 && _availableFromController.text.trim().isEmpty) {
        _showError("Available From date is required for Rent");
        return false;
      }
    } else if (step == 3) {
      final isLand = selectedPropertySubType?.contains("land") ?? false;
      if (!isLand &&
          (selectedFurnishing == null || selectedFurnishing!.isEmpty)) {
        _showError("Furnishing status is required");
        return false;
      }
      if (isEditMode &&
          isBroker == true &&
          _reraController.text.trim().isEmpty) {
        _showError("RERA registration number is required for brokers");
        return false;
      }
    } else if (step == 4) {
      if (propertyImages.length < 3) {
        _showError("Upload at least 3 photos of your property");
        return false;
      }
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleNextStep() {
    if (!isEditMode && !_validateStep(_currentStep)) return;

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

    if (!_validateStep(0) ||
        !_validateStep(1) ||
        !_validateStep(2) ||
        !_validateStep(3) ||
        !_validateStep(4)) {
      return;
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

      if (finalImageUrls.length < 3) {
        _showError("Upload at least 3 photos of your property");
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
            aroundProject: updateAround,
            permitNo: _permitNoController.text.trim(),
            rera: _reraController.text.trim(),
            ded: _dedController.text.trim(),
            brn: _brnController.text.trim(),
            description: _descriptionController.text.trim(),
            aveneuOverView: updateAveneu,
            uploadedPhotos: finalImageUrls,
            isBroker: isBroker == true ? "yes" : "no",
            furnishingItems: appliance,
          ),
        );
      } else {
        response = await service.createProperty(body);
      }

      if (!mounted) return;

      if (response.error == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message ??
                  (isEditMode
                      ? "Property updated successfully!"
                      : "Property uploaded successfully!"),
            ),
            backgroundColor: Colors.green,
          ),
        );

        if (!widget.fromBottomNav) {
          Navigator.pop(context, true);
          ref.invalidate(getMyPropertyController);
          return;
        } else {
          widget.onSuccess?.call();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? "Failed to save property."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, st) {
      log("Submit error: $e\n$st");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF24ADD7),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      controller.text =
          "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final cityAsync = ref.watch(getCityController);
    final categoryAsync = ref.watch(getPropertyCategoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF24ADD7),
        foregroundColor: Colors.white,
        elevation: 1,
        title: Text(
          isEditMode ? 'Edit Property' : 'Create Property Listing',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top 5-Step Stepper Navigation Bar
              _buildStepperHeader(),

              const SizedBox(height: 16),

              // Current step form widget
              Container(
                key: ValueKey(_currentStep),
                child: _buildCurrentStep(cityAsync, categoryAsync),
              ),

              const SizedBox(height: 30),

              // Original Navigation Buttons (BACK & SAVE & CONTINUE)
              _buildOriginalNavigationButtons(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ────── Original Navigation Buttons (Restored as requested) ──────
  Widget _buildOriginalNavigationButtons() {
    return Row(
      children: [
        // BACK Button
        if (_currentStep > 0)
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 50.h,
              child: ElevatedButton(
                onPressed: _goToPreviousStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: const Color(0xFF24ADD7),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFF24ADD7)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'BACK',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

        if (_currentStep > 0) SizedBox(width: 12.w),
        Expanded(
          flex: _currentStep > 0 ? 2 : 1,
          child: SizedBox(
            height: 50.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF24ADD7),
                foregroundColor: Colors.white,
                disabledIconColor: const Color(
                  0xFF24ADD7,
                ).withValues(alpha: 0.5),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF5722),
                          strokeWidth: 1,
                        ),
                      ),
                    )
                  : Text(
                      _isLastStep
                          ? (isEditMode ? 'Update Property' : 'Submit Property')
                          : 'SAVE & CONTINUE',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ────── Modern 5-Step Stepper Header ──────
  Widget _buildStepperHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_steps.length, (index) {
          final isCurrent = index == _currentStep;
          final isPassed = index < _currentStep;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (isEditMode || isPassed || _validateStep(_currentStep)) {
                  setState(() => _currentStep = index);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent
                          ? const Color(0xFF24ADD7)
                          : (isPassed
                                ? const Color(
                                    0xFF24ADD7,
                                  ).withValues(alpha: 0.18)
                                : Colors.grey.shade100),
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFF24ADD7)
                            : (isPassed
                                  ? const Color(0xFF24ADD7)
                                  : Colors.grey.shade300),
                        width: isCurrent ? 2 : 1.2,
                      ),
                    ),
                    child: Center(
                      child: isPassed
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Color(0xFF24ADD7),
                            )
                          : Icon(
                              _steps[index]['icon'] as IconData,
                              size: 15.sp,
                              color: isCurrent
                                  ? Colors.white
                                  : Colors.grey.shade500,
                            ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _steps[index]['label'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isCurrent
                          ? const Color(0xFF24ADD7)
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
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

    final displayCount = showAllPropertySubTypes
        ? currentOptions.length
        : (currentOptions.length > 6 ? 6 : currentOptions.length);

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Listing Category (Sell / Rent Out)
          Text(
            "Listing Purpose *",
            style: TextStyle(
              fontSize: 13.5.sp,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 46.h,
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(12.r),
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
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: selectedType == 1
                            ? const Color(0xFF24ADD7)
                            : Colors.transparent,
                      ),
                      child: Text(
                        'SELL',
                        style: TextStyle(
                          color: selectedType == 1
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
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
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: selectedType == 2
                            ? const Color(0xFF24ADD7)
                            : Colors.transparent,
                      ),
                      child: Text(
                        'RENT OUT',
                        style: TextStyle(
                          color: selectedType == 2
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

          // 3. Specific Property Type
          Text(
            "Specific Property Type *",
            style: TextStyle(
              fontSize: 13.5.sp,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.h,
              crossAxisSpacing: 8.w,
              mainAxisExtent: 42.h,
            ),
            itemBuilder: (context, index) {
              final item = currentOptions[index];
              final isSelected =
                  selectedPropertySubType != null &&
                  (selectedPropertySubType!.toLowerCase() ==
                          item.value.toLowerCase() ||
                      selectedPropertySubType!.toLowerCase() ==
                          item.title.toLowerCase() ||
                      selectedPropertySubType!.toLowerCase().replaceAll(
                            '-',
                            ' ',
                          ) ==
                          item.title.toLowerCase());

              return GestureDetector(
                onTap: () =>
                    setState(() => selectedPropertySubType = item.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF24ADD7)
                        : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF24ADD7)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    item.title.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5.sp,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF344054),
                    ),
                  ),
                ),
              );
            },
          ),
          if (currentOptions.length > 6)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: ButtonStyle(
                  padding: WidgetStatePropertyAll(EdgeInsets.zero),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  setState(() {
                    showAllPropertySubTypes = !showAllPropertySubTypes;
                  });
                },
                child: Text(
                  showAllPropertySubTypes ? "View Less" : "View All",
                  style: TextStyle(
                    color: const Color(0xFF24ADD7),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          SizedBox(height: 6.h),

          // 4. Are you a broker?
          Text(
            "Are You A Broker? *",
            style: TextStyle(
              fontSize: 13.5.sp,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isBroker = true),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isBroker == true
                          ? const Color(0xFF24ADD7)
                          : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isBroker == true
                            ? const Color(0xFF24ADD7)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Yes",
                        style: TextStyle(
                          color: isBroker == true
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isBroker = false),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isBroker == false
                          ? const Color(0xFF24ADD7)
                          : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isBroker == false
                            ? const Color(0xFF24ADD7)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "No",
                        style: TextStyle(
                          color: isBroker == false
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // STEP 2: LOCATION (City & Address)
  // ══════════════════════════════════════════
  Widget _buildStep2Location(AsyncValue<CityResponseModel> cityAsync) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Use current location button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: ButtonStyle(
                padding: WidgetStatePropertyAll(EdgeInsets.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: _isLocationLoading ? null : _useCurrentLocation,
              icon: _isLocationLoading
                  ? SizedBox(
                      width: 14.w,
                      height: 14.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF24ADD7),
                      ),
                    )
                  : const Icon(
                      Icons.my_location,
                      size: 16,
                      color: Color(0xFF24ADD7),
                    ),
              label: Text(
                "Use Current Location",
                style: TextStyle(
                  color: const Color(0xFF24ADD7),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),

          // State (Website field: State)
          _buildTextField(
            'State',
            _stateController,
            hint: 'e.g. Rajasthan, Madhya Pradesh',
            isRequired: false,
          ),
          SizedBox(height: 14.h),

          // City
          _buildCityDropdown(cityAsync),
          SizedBox(height: 14.h),

          // Locality / Area
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Locality / Area *',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              AbsorbPointer(
                absorbing: !isCitySelected,
                child: Opacity(
                  opacity: isCitySelected ? 1 : 0.5,
                  child: Autocomplete<String>(
                    key: ValueKey(selectedCity),
                    initialValue: TextEditingValue(
                      text: selectedLocality ?? "",
                    ),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (!isCitySelected)
                        return const Iterable<String>.empty();
                      if (textEditingValue.text.isEmpty) return localityList;
                      return localityList.where((option) {
                        return option.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        );
                      });
                    },
                    onSelected: (String selection) {
                      setState(() {
                        selectedLocality = selection;
                        isLocalityFromDropdown = true;
                      });
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            onChanged: (value) {
                              selectedLocality = value;
                              isLocalityFromDropdown = false;
                            },
                            decoration: _inputDecoration(
                              hint: isCitySelected
                                  ? 'e.g. Malviya Nagar'
                                  : 'Select City first',
                            ),
                          );
                        },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // House / Flat / Plot Number (Website field: houseNumber)
          _buildTextField(
            'House No / Tower / Block',
            _houseNumberController,
            hint: 'e.g. A-101, Royal Residency',
            isRequired: true,
          ),
          SizedBox(height: 14.h),

          // Property Address
          _buildTextField(
            'Address (building, street, etc.)',
            _propertyAddressController,
            hint: 'Detailed street address, landmarks...',
            maxLines: 2,
            isRequired: true,
          ),
          SizedBox(height: 14.h),

          // Pincode (Website field: pincode)
          _buildTextField(
            'Pincode',
            _pincodeController,
            hint: 'e.g. 474001',
            type: TextInputType.number,
            isRequired: true,
          ),
        ],
      ),
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
          // Price
          _buildTextField(
            isRent ? 'Monthly Rent (₹) *' : 'Sell Price (₹) *',
            _priceController,
            hint: isRent ? 'e.g. 25000' : 'e.g. 7500000',
            type: TextInputType.number,
            isRequired: true,
          ),
          SizedBox(height: 14.h),

          // Area (sq.ft)
          _buildTextField(
            'Area (Sqft) *',
            _areaController,
            hint: 'e.g. 1500',
            type: TextInputType.number,
            isRequired: true,
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
                "8+ BHK",
              ],
              (v) {
                setState(() {
                  _selectedBhk = v;
                  _bedroomsController.text = v ?? "";
                });
              },
              isRequired: true,
            ),
            SizedBox(height: 14.h),
          ],

          // Rent-specific fields (Available From & Security Deposit)
          if (isRent) ...[
            _buildTextField(
              'Available From *',
              _availableFromController,
              hint: "DD/MM/YYYY",
              readOnly: true,
              onTap: () => _selectDate(_availableFromController),
              suffixIcon: Icon(
                Icons.calendar_today,
                color: const Color(0xFF24ADD7),
                size: 18.sp,
              ),
              isRequired: true,
            ),
            SizedBox(height: 14.h),

            Text(
              "Security Deposit",
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: ["None", "1 month", "2 month", "Custom"].map((dep) {
                final isSelected = selectedSecurityDeposit == dep;
                return ChoiceChip(
                  label: Text(
                    dep,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF24ADD7),
                  backgroundColor: const Color(0xFFF8F9FA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF24ADD7)
                          : Colors.grey.shade300,
                    ),
                  ),
                  onSelected: (val) {
                    setState(() => selectedSecurityDeposit = dep);
                  },
                );
              }).toList(),
            ),
            if (selectedSecurityDeposit == "Custom") ...[
              SizedBox(height: 14.h),
              _buildTextField(
                'Custom Security Deposit (₹)',
                _customSecurityDepositController,
                hint: 'e.g. 50000',
                type: TextInputType.number,
                isRequired: true,
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
        selectedFurnishing == "Furnished" ||
        selectedFurnishing == "Semi-Furnished";
    final displayFurnishingItems = showAllFurnishingItems
        ? standardFurnishingItems
        : standardFurnishingItems.take(8).toList();

    return Column(
      children: [
        // 1. Rooms & Facilities Card
        if (!isLand)
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Room & Facility Details",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
                SizedBox(height: 12.h),

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
                        ["None", "1", "2", "3", "4+"],
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
                        ["None", "1", "2", "3", "4+"],
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
                SizedBox(height: 14.h),

                // Furnishing
                _buildDropdown(
                  'Furnishing Status',
                  selectedFurnishing,
                  ["Furnished", "Semi-Furnished", "Unfurnished"],
                  (v) => setState(() => selectedFurnishing = v),
                  isRequired: true,
                ),

                // Predefined Furnishing Items (Website Feature)
                if (isFurnished) ...[
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Furnishing Items",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                  SizedBox(height: 8.h),

                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: displayFurnishingItems.map((item) {
                      final isSelected = appliance.contains(item);
                      return FilterChip(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 4.h,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        showCheckmark: true,
                        labelPadding: EdgeInsets.symmetric(
                          horizontal: 1.w,
                          vertical: -4.h,
                        ),
                        label: Text(
                          item,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: isSelected
                                ? const Color(0xFF24ADD7)
                                : Colors.grey.shade800,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(
                          0xFF24ADD7,
                        ).withValues(alpha: 0.14),
                        checkmarkColor: const Color(0xFF24ADD7),
                        backgroundColor: const Color(0xFFF8F9FA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF24ADD7)
                                : Colors.grey.shade300,
                          ),
                        ),
                        onSelected: (_) => toggleFurnishingItem(item),
                      );
                    }).toList(),
                  ),
                  if (standardFurnishingItems.length > 8)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.zero),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          setState(() {
                            showAllFurnishingItems = !showAllFurnishingItems;
                          });
                        },
                        child: Text(
                          showAllFurnishingItems
                              ? "View Less"
                              : "View All Items",
                          style: TextStyle(
                            color: const Color(0xFF24ADD7),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: applianceController,
                          decoration: _inputDecoration(
                            hint: "Add other furnishing item...",
                          ),
                          onFieldSubmitted: (_) => addCustomAppliance(),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        onPressed: addCustomAppliance,
                        icon: const Icon(
                          Icons.add_circle,
                          color: Color(0xFF24ADD7),
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  if (customFurnishingItems.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: customFurnishingItems.map((item) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF24ADD7,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: const Color(0xFF24ADD7)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item,
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  color: const Color(0xFF24ADD7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              GestureDetector(
                                onTap: () => removeCustomAppliance(item),
                                child: const Icon(
                                  Icons.close,
                                  size: 15,
                                  color: Color(0xFF24ADD7),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ],
            ),
          ),
        SizedBox(height: 14.h),

        // 2. Legal Details Card & 3. Project / Avenue Overview Card (Only in Edit Mode)
        if (isEditMode) ...[
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Legal & Approvals",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
                SizedBox(height: 12.h),

                _buildTextField(
                  isBroker == true
                      ? 'RERA Registration No. *'
                      : 'RERA Registration No.',
                  _reraController,
                  hint: 'e.g. RAJ/P/2023/1234',
                  isRequired: isBroker == true,
                ),
                SizedBox(height: 12.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Permit No.',
                        _permitNoController,
                        hint: 'Optional',
                        isRequired: false,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildTextField(
                        'DED No.',
                        _dedController,
                        hint: 'Optional',
                        isRequired: false,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                _buildTextField(
                  'BRN No.',
                  _brnController,
                  hint: 'Optional',
                  isRequired: false,
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // 3. Project / Avenue Overview Card
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Avenue / Project Overview",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
                SizedBox(height: 12.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Project Area',
                        _projectAreaController,
                        hint: 'e.g. 5 Acres',
                        isRequired: false,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildTextField(
                        'Unit Size',
                        _unitSizesController,
                        hint: 'e.g. 1200-2400',
                        isRequired: false,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                _buildTextField(
                  'Project Size',
                  _projectSizeController,
                  hint: 'e.g. 400 Units',
                  isRequired: false,
                ),
                SizedBox(height: 12.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Launch Date',
                        _launchDateController,
                        hint: 'DD/MM/YYYY',
                        readOnly: true,
                        onTap: () => _selectDate(_launchDateController),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          size: 16.sp,
                          color: const Color(0xFF24ADD7),
                        ),
                        isRequired: false,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildTextField(
                        'Possession Start',
                        _possessionDateController,
                        hint: 'DD/MM/YYYY',
                        readOnly: true,
                        onTap: () => _selectDate(_possessionDateController),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          size: 16.sp,
                          color: const Color(0xFF24ADD7),
                        ),
                        isRequired: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
        ],

        // 4. Amenities Grid Card
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Amenities & Features",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  Text(
                    "${selectedAmenities.length} selected",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF24ADD7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              _buildMultiSelectAmenities(),
              SizedBox(height: 10.h),

              // Add Custom Amenity
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _customAmenityController,
                      decoration: _inputDecoration(
                        hint: "Add custom amenity...",
                      ),
                      onFieldSubmitted: (_) => addCustomAmenity(),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    onPressed: addCustomAmenity,
                    icon: const Icon(
                      Icons.add_circle,
                      color: Color(0xFF24ADD7),
                      size: 32,
                    ),
                  ),
                ],
              ),
              if (customAmenitiesList.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: customAmenitiesList.map((amenity) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF24ADD7).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFF24ADD7)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            amenity,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: const Color(0xFF24ADD7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          GestureDetector(
                            onTap: () => removeCustomAmenity(amenity),
                            child: const Icon(
                              Icons.close,
                              size: 15,
                              color: Color(0xFF24ADD7),
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
        ),
        SizedBox(height: 14.h),

        // 5. Around The Project Card (with Distance & Unit Radio matching website)
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Around The Project (Nearby Places)",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
              SizedBox(height: 12.h),

              ...aroundProjectList.asMap().entries.map((entry) {
                final idx = entry.key;
                final itemMap = entry.value;
                final placeCtrl = itemMap['place'] as TextEditingController;
                final distCtrl = itemMap['distance'] as TextEditingController;
                final currentUnit = itemMap['unit'] as String? ?? 'meter';

                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              'Place Name',
                              placeCtrl,
                              hint: 'e.g. Metro Station, Airport, School',
                              isRequired: false,
                            ),
                            SizedBox(height: 10.h),

                            Text(
                              "Distance & Unit",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: distCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDecoration(
                                      hint: 'e.g. 500',
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      ChoiceChip(
                                        label: const Text("M"),
                                        selected: currentUnit == 'meter',
                                        selectedColor: const Color(0xFF24ADD7),
                                        backgroundColor: Colors.white,
                                        labelStyle: TextStyle(
                                          color: currentUnit == 'meter'
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp,
                                        ),
                                        onSelected: (val) {
                                          setState(
                                            () =>
                                                aroundProjectList[idx]['unit'] =
                                                    'meter',
                                          );
                                        },
                                      ),
                                      SizedBox(width: 6.w),
                                      ChoiceChip(
                                        label: const Text("KM"),
                                        selected: currentUnit == 'km',
                                        selectedColor: const Color(0xFF24ADD7),
                                        backgroundColor: Colors.white,
                                        labelStyle: TextStyle(
                                          color: currentUnit == 'km'
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp,
                                        ),
                                        onSelected: (val) {
                                          setState(
                                            () =>
                                                aroundProjectList[idx]['unit'] =
                                                    'km',
                                          );
                                        },
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
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                              size: 22,
                            ),
                            onPressed: () => removeAroundProjectRow(idx),
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
                    'Add More Nearby Place',
                    style: TextStyle(
                      color: Color(0xFF24ADD7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // STEP 5: MEDIA & DESCRIPTION
  // ══════════════════════════════════════════
  Widget _buildStep5MediaDescription() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Photos & Media *",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "Upload at least 3 photos of your property (exterior, interior, rooms)",
            style: TextStyle(
              fontSize: 12.sp,
              color: propertyImages.length < 3
                  ? Colors.red.shade600
                  : Colors.grey.shade600,
              fontWeight: propertyImages.length < 3
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
          SizedBox(height: 14.h),

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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: img is File
                          ? Image.file(img, fit: BoxFit.cover)
                          : Image.network(img.toString(), fit: BoxFit.cover),
                    ),
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF24ADD7),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          "Photo ${index + 1}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
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
                onTap: pickImages,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF24ADD7).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFF24ADD7),
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 32.sp,
                        color: const Color(0xFF24ADD7),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Upload Photos",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF24ADD7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20.h),

          // Deep Property Description
          Text(
            "Deep Property Description",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          SizedBox(height: 6.h),
          TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: _inputDecoration(
              hint:
                  "Describe your property highlights, nearby landmarks, furnishing, community features...",
            ),
          ),
        ],
      ),
    );
  }

  // ────── Common Form Helpers ──────

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      suffixIcon: suffixIcon,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFF24ADD7), width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? " *" : ""),
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: type ?? TextInputType.text,
          readOnly: readOnly,
          onTap: onTap,
          decoration: _inputDecoration(hint: hint, suffixIcon: suffixIcon),
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
  }) {
    String? safeValue = items.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? " *" : ""),
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          value: safeValue,
          isExpanded: true,
          hint: Text(
            'Select $label',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
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
                  child: Text(item, style: TextStyle(fontSize: 13.5.sp)),
                ),
              )
              .toList(),
          onChanged: onChanged,
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
            Text(
              "City *",
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
            Autocomplete<String>(
              key: ValueKey(selectedCity),
              initialValue: TextEditingValue(text: selectedCity ?? ""),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return cities
                      .map((e) => e.cityName ?? "")
                      .where((e) => e.isNotEmpty);
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
                  selectedLocality = null;

                  final selectedCityObj = cities.firstWhere(
                    (c) =>
                        (c.cityName ?? "").toLowerCase() == city.toLowerCase(),
                    orElse: () => cities.first,
                  );

                  selectedCityId = selectedCityObj.id;
                  localityList = List<String>.from(selectedCityObj.areas ?? []);
                });
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: (value) {
                        setState(() {
                          selectedCity = value;
                          selectedCityId = null;
                        });
                      },
                      decoration: _inputDecoration(
                        hint: 'Select or Enter City',
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
            return FilterChip(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              showCheckmark: true,
              labelPadding: EdgeInsets.symmetric(
                horizontal: 1.w,
                vertical: -4.h,
              ),
              label: Text(
                amenity,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: selected
                      ? const Color(0xFF24ADD7)
                      : Colors.grey.shade800,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: selected,
              selectedColor: const Color(0xFF24ADD7).withValues(alpha: 0.14),
              checkmarkColor: const Color(0xFF24ADD7),
              backgroundColor: const Color(0xFFF8F9FA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
                side: BorderSide(
                  color: selected
                      ? const Color(0xFF24ADD7)
                      : Colors.grey.shade300,
                ),
              ),
              onSelected: (sel) {
                setState(() {
                  if (sel) {
                    selectedAmenities.add(amenity);
                  } else {
                    selectedAmenities.remove(amenity);
                    customAmenitiesList.remove(amenity);
                  }
                });
              },
            );
          }).toList(),
        ),
        if (allAmenities.length > 8)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: ButtonStyle(
                padding: WidgetStatePropertyAll(EdgeInsets.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),

              onPressed: () {
                setState(() {
                  showAllAmenities = !showAllAmenities;
                });
              },
              child: Text(
                showAllAmenities ? "View Less" : "View All Amenities",
                style: TextStyle(
                  color: const Color(0xFF24ADD7),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
