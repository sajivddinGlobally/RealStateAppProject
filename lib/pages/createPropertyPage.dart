import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:realstate/Controller/getMyPropertyController.dart';
import 'package:realstate/Model/Body/UpdatePropertyBodyModel.dart';
import '../Model/getMyPropertyResModel.dart';
import '../Controller/getCityListController.dart';
import '../Model/Body/CreatePropertyBodyModel.dart';
import '../Model/CityResponseModel.dart';
import '../core/network/api.state.dart';
import '../core/utils/preety.dio.dart';
import 'package:realstate/Model/Body/CreatePropertyBodyModel.dart'
    as createModel;
import 'package:realstate/Model/Body/UpdatePropertyBodyModel.dart'
    as updateModel;

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
  final _formKey = GlobalKey<FormState>(); // ← Added for validation

  bool get isEditMode =>
      widget.data != null && (widget.data?.id?.isNotEmpty ?? false);
  String? get propertyId => widget.data?.id;

  String? selectedPropertyType;
  String? selectedListingCategory;
  String? selectedFurnishing;
  String? selectedPropertySubType;
  String? selectedCity;

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
  List<Map<String, TextEditingController>> aroundProjectList = [];
  List<dynamic> propertyImages = [];

  final ImagePicker _picker = ImagePicker();

  // Controllers
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
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
  final TextEditingController _propertyAddressController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  String? selectedLocality;
  List<String> localityList = [];

  @override
  void initState() {
    super.initState();
    addAroundProjectRow();
    if (isEditMode && widget.data != null) {
      _preFillData(widget.data!);
    }
  }

  String? _capitalize(String? value) {
    if (value == null || value.isEmpty) return null;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  void _preFillData(ListElement data) {
    setState(() {
      selectedPropertyType = _capitalize(data.property);
      selectedPropertySubType = data.propertyType;

      selectedListingCategory = _normalizeListingCategory(data.listingCategory);

      /// ✅ fir mapping karo
      if (selectedListingCategory == "Sell") {
        selectedType = 1;
      } else if (selectedListingCategory == "Rent") {
        selectedType = 2;
      }
      selectedCity = data.city?.trim();
      selectedLocality = data.localityArea?.trim();
      selectedFurnishing = _normalizeFurnishing(data.furnishing);
      _priceController.text = data.price ?? '';
      _bedroomsController.text = data.bedRoom ?? '';
      _bathroomsController.text = data.bathrooms ?? '';
      _areaController.text = data.area ?? '';
      _permitNoController.text = data.permitNo ?? '';
      _reraController.text = data.rera ?? '';
      _dedController.text = data.ded ?? '';
      _brnController.text = data.brn ?? '';
      _propertyAddressController.text = data.propertyAddress ?? '';
      _descriptionController.text = data.description ?? '';

      final overview = data.aveneuOverView;
      _projectAreaController.text = overview?.projectArea ?? '';
      _unitSizesController.text = overview?.size ?? '';
      _projectSizeController.text = overview?.projectSize ?? '';
      _launchDateController.text = overview?.launchDate ?? '';
      _possessionDateController.text = overview?.possessionStart ?? '';

      if (data.amenities != null && data.amenities!.isNotEmpty) {
        selectedAmenities = List<String>.from(data.amenities!);
      }

      if (data.uploadedPhotos != null && data.uploadedPhotos!.isNotEmpty) {
        propertyImages.addAll(data.uploadedPhotos!);
      }

      aroundProjectList.clear();
      if (data.aroundProject != null && data.aroundProject!.isNotEmpty) {
        for (final item in data.aroundProject!) {
          aroundProjectList.add({
            'place': TextEditingController(text: item.name ?? ''),
            'details': TextEditingController(text: item.details ?? ''),
          });
        }
      }
      if (aroundProjectList.isEmpty) addAroundProjectRow();
    });
  }

  String? _normalizeListingCategory(String? value) {
    if (value == null) return null;

    final lower = value.toLowerCase().trim();

    if (lower.contains('rent')) return 'Rent'; // ✅ FIX
    if (lower.contains('buy') || lower.contains('sell')) return 'Sell'; // ✅ FIX

    return value;
  }

  String? _normalizeFurnishing(String? value) {
    if (value == null) return null;
    final lower = value.toLowerCase().trim();

    if (lower.contains('furnished')) return 'Furnished';
    if (lower.contains('semi-furnished')) return 'Semi-Furnished';
    if (lower.contains('unfurnished')) return 'Unfurnished';
    return value;
  }

  void addAroundProjectRow() {
    setState(() {
      aroundProjectList.add({
        'place': TextEditingController(),
        'details': TextEditingController(),
      });
    });
  }

  void removeAroundProjectRow(int index) {
    if (aroundProjectList.length > 1) {
      setState(() {
        aroundProjectList[index]['place']?.dispose();
        aroundProjectList[index]['details']?.dispose();
        aroundProjectList.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least 1 nearby place is required!')),
      );
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _areaController.dispose();
    _permitNoController.dispose();
    _reraController.dispose();
    _dedController.dispose();
    _brnController.dispose();
    _projectAreaController.dispose();
    _unitSizesController.dispose();
    _projectSizeController.dispose();
    _launchDateController.dispose();
    _possessionDateController.dispose();
    _propertyAddressController.dispose();
    _descriptionController.dispose();

    for (var ctrlMap in aroundProjectList) {
      ctrlMap['place']?.dispose();
      ctrlMap['details']?.dispose();
    }
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
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
            child: const Text('Gallery (Multiple)'),
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

  Future<void> _submitProperty() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Photo Validation
    if (propertyImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("At least 1 photo is required"),
          backgroundColor: Colors.red,
        ),
      );
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

      if (finalImageUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("At least 1 photo is required"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final aroundProjects = aroundProjectList
          .map(
            (map) => createModel.AroundProject(
              name: map['place']!.text.trim(),
              details: map['details']!.text.trim(),
            ),
          )
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
        propertyType: selectedPropertySubType,
        listingCategory: selectedType == 1 ? "sell" : "rent",
        city: selectedCity ?? "",
        price: _priceController.text.trim(),
        area: _areaController.text.trim(),
        bedRoom: _bedroomsController.text.trim(),
        bathrooms: _bathroomsController.text.trim(),
        furnishing: selectedFurnishing?.toLowerCase(),
        amenities: selectedAmenities,
        aroundProject: aroundProjects,
        permitNo: _permitNoController.text.trim(),
        rera: _reraController.text.trim(),
        ded: _dedController.text.trim(),
        brn: _brnController.text.trim(),
        description: _descriptionController.text.trim(),
        aveneuOverView: aveneu,
        propertyAddress: _propertyAddressController.text.trim(),
        uploadedPhotos: finalImageUrls,
      );

      dynamic response;
      if (isEditMode && propertyId != null && propertyId!.isNotEmpty) {
        final aroundProjects = aroundProjectList
            .map(
              (map) => updateModel.AroundProject(
                name: map['place']!.text.trim(),
                details: map['details']!.text.trim(),
              ),
            )
            .where((ap) => ap.name?.isNotEmpty == true)
            .toList();

        final aveneu = updateModel.AveneuOverView(
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
            propertyType: selectedPropertySubType,
            listingCategory: selectedListingCategory!.toLowerCase(),
            city: selectedCity ?? "",
            price: _priceController.text.trim(),
            area: _areaController.text.trim(),
            bedRoom: _bedroomsController.text.trim(),
            bathrooms: _bathroomsController.text.trim(),
            furnishing: selectedFurnishing!.toLowerCase(),
            amenities: selectedAmenities,
            aroundProject: aroundProjects,
            permitNo: _permitNoController.text.trim(),
            rera: _reraController.text.trim(),
            ded: _dedController.text.trim(),
            brn: _brnController.text.trim(),
            description: _descriptionController.text.trim(),
            aveneuOverView: aveneu,
            propertyAddress: _propertyAddressController.text.trim(),
            uploadedPhotos: finalImageUrls,
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
                      ? "Updated successfully!"
                      : "Created successfully!"),
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

  int? selectedType;
  int _currentStep = 0;
  final List<String> _stepTitles = [
    "Basic Details",
    "Property Location",
    "Specification",
    "Amenities & Legal",
    "Around The Project",
    "Photos & Media",
    "Deep Property Description",
  ];

  // Helper to get current step title
  String _getStepTitle() {
    return _stepTitles[_currentStep];
  }

  // Check if it's the last step
  bool get _isLastStep => _currentStep == _stepTitles.length - 1;

  // Handle Next Step
  void _handleNextStep() {
    if (!_formKey.currentState!.validate()) return;

    if (_isLastStep) {
      _submitProperty();
    } else {
      setState(() {
        _currentStep++;
      });
    }
  }

  // Go to Previous Step
  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cityAsync = ref.watch(getCityController);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Color(0xffFF6A2A),
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

      // body: Form(
      //   key: _formKey,
      //   child: SingleChildScrollView(
      //     padding: const EdgeInsets.all(16),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         _buildSectionTitle("Basic Details"),
      //         const SizedBox(height: 12),
      //         _buildCard(
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               Text(
      //                 "Listing Purpose",
      //                 style: TextStyle(
      //                   fontSize: 13.5.sp,
      //                   color: Colors.grey,
      //                   fontWeight: FontWeight.w500,
      //                 ),
      //               ),
      //               FormField(
      //                 validator: (value) {
      //                   if (selectedType == null) {
      //                     return "Listing Category is Required";
      //                   }
      //                   return null;
      //                 },
      //                 builder: (FormFieldState<int> state) {
      //                   return Column(
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     children: [
      //                       Container(
      //                         margin: EdgeInsets.only(top: 10.h),
      //                         height: 45.h,
      //                         decoration: BoxDecoration(
      //                           color: const Color(0xFFF1F3F5),
      //                           borderRadius: BorderRadius.circular(12.r),
      //                         ),
      //                         child: Row(
      //                           children: [
      //                             Expanded(
      //                               child: GestureDetector(
      //                                 onTap: () =>
      //                                     setState(() => selectedType = 1),
      //                                 child: Container(
      //                                   alignment: Alignment.center,
      //                                   decoration: BoxDecoration(
      //                                     borderRadius: BorderRadius.circular(
      //                                       12.r,
      //                                     ),
      //                                     color: selectedType == 1
      //                                         ? const Color(0xFFFF5722)
      //                                         : Colors.transparent,
      //                                   ),
      //                                   child: Text(
      //                                     'SELL',
      //                                     style: TextStyle(
      //                                       color: selectedType == 1
      //                                           ? Colors.white
      //                                           : Colors.grey,
      //                                       fontWeight: FontWeight.bold,
      //                                       fontSize: 14.sp,
      //                                     ),
      //                                   ),
      //                                 ),
      //                               ),
      //                             ),
      //                             /// RENT
      //                             Expanded(
      //                               child: GestureDetector(
      //                                 onTap: () =>
      //                                     setState(() => selectedType = 2),
      //                                 child: Container(
      //                                   alignment: Alignment.center,
      //                                   decoration: BoxDecoration(
      //                                     borderRadius: BorderRadius.circular(
      //                                       12.r,
      //                                     ),
      //                                     color: selectedType == 2
      //                                         ? const Color(0xFFFF5722)
      //                                         : Colors.transparent,
      //                                   ),
      //                                   child: Text(
      //                                     'RENT OUT',
      //                                     style: TextStyle(
      //                                       color: selectedType == 2
      //                                           ? Colors.white
      //                                           : Colors.grey,
      //                                       fontWeight: FontWeight.bold,
      //                                       fontSize: 14.sp,
      //                                     ),
      //                                   ),
      //                                 ),
      //                               ),
      //                             ),
      //                           ],
      //                         ),
      //                       ),
      //                       /// ERROR TEXT
      //                       if (state.hasError)
      //                         Padding(
      //                           padding: const EdgeInsets.only(top: 5, left: 5),
      //                           child: Text(
      //                             state.errorText!,
      //                             style: TextStyle(
      //                               color: Colors.red,
      //                               fontSize: 12,
      //                             ),
      //                           ),
      //                         ),
      //                     ],
      //                   );
      //                 },
      //               ),
      //               // _buildDropdown(
      //               //   'Listing Category',
      //               //   selectedListingCategory,
      //               //   ['Rent', 'Sell'],
      //               //   (v) => setState(() => selectedListingCategory = v),
      //               //   isRequired: true,
      //               // ),
      //               const SizedBox(height: 12),
      //               _buildDropdown(
      //                 'Property',
      //                 selectedPropertyType,
      //                 ["Residential", "Commercial"],
      //                 (v) => setState(() => selectedPropertyType = v),
      //                 isRequired: true,
      //               ),
      //               const SizedBox(height: 12),
      //               // _buildDropdown(
      //               //   'Property Type',
      //               //   selectedPropertySubType,
      //               //   selectedPropertyType == "Residential"
      //               //       ? [
      //               //           "apartment",
      //               //           "townhouse",
      //               //           "villa-compound",
      //               //           "land",
      //               //           "villa",
      //               //           "penthouse",
      //               //           "studio",
      //               //         ]
      //               //       : [
      //               //           "office",
      //               //           "warehouse",
      //               //           "showroom",
      //               //           "shop",
      //               //           "factory",
      //               //           "other-commercial",
      //               //         ],
      //               //   (v) => setState(() => selectedPropertySubType = v),
      //               //   isRequired: true,
      //               // ),
      //               if (selectedPropertyType != null)
      //                 FormField<String>(
      //                   validator: (value) {
      //                     if (selectedPropertySubType == null ||
      //                         selectedPropertySubType!.isEmpty) {
      //                       return "Property type is required";
      //                     }
      //                     return null;
      //                   },
      //                   builder: (FormFieldState<String> state) {
      //                     return Column(
      //                       crossAxisAlignment: CrossAxisAlignment.start,
      //                       children: [
      //                         Text(
      //                           "Specific Property Type",
      //                           style: TextStyle(
      //                             fontWeight: FontWeight.bold,
      //                             letterSpacing: 1,
      //                             fontSize: 14.sp,
      //                           ),
      //                         ),
      //                         SizedBox(height: 12.h),
      //                         Container(
      //                           decoration: BoxDecoration(
      //                             borderRadius: BorderRadius.circular(14.r),
      //                           ),
      //                           child: GridView.builder(
      //                             shrinkWrap: true,
      //                             physics: NeverScrollableScrollPhysics(),
      //                             itemCount:
      //                                 (selectedPropertyType == "Residential"
      //                                         ? [
      //                                             "apartment",
      //                                             "townhouse",
      //                                             "villa-compound",
      //                                             "land",
      //                                             "building",
      //                                             "villa",
      //                                             "penthouse",
      //                                             "hotel-apartment",
      //                                             "floor",
      //                                             "studio",
      //                                           ]
      //                                         : [
      //                                             "office",
      //                                             "warehouse",
      //                                             "showroom",
      //                                             "shop",
      //                                             "factory",
      //                                             "other-commercial",
      //                                           ])
      //                                     .length,
      //                             gridDelegate:
      //                                 SliverGridDelegateWithFixedCrossAxisCount(
      //                                   crossAxisCount: 2,
      //                                   mainAxisSpacing: 10.h,
      //                                   crossAxisSpacing: 10.w,
      //                                   mainAxisExtent: 45.h,
      //                                 ),
      //                             itemBuilder: (context, index) {
      //                               final options =
      //                                   selectedPropertyType == "Residential"
      //                                   ? [
      //                                       "apartment",
      //                                       "townhouse",
      //                                       "villa-compound",
      //                                       "land",
      //                                       "building",
      //                                       "villa",
      //                                       "penthouse",
      //                                       "hotel-apartment",
      //                                       "floor",
      //                                       "studio",
      //                                     ]
      //                                   : [
      //                                       "office",
      //                                       "warehouse",
      //                                       "showroom",
      //                                       "shop",
      //                                       "factory",
      //                                       "other-commercial",
      //                                     ];
      //                               final item = options[index];
      //                               final isSelected =
      //                                   selectedPropertySubType == item;
      //                               return GestureDetector(
      //                                 onTap: () {
      //                                   setState(
      //                                     () => selectedPropertySubType = item,
      //                                   );
      //                                   state.didChange(item);
      //                                 },
      //                                 child: AnimatedContainer(
      //                                   duration: const Duration(
      //                                     milliseconds: 200,
      //                                   ),
      //                                   alignment: Alignment.center,
      //                                   padding: EdgeInsets.symmetric(
      //                                     horizontal: 8.w,
      //                                   ),
      //                                   decoration: BoxDecoration(
      //                                     color: isSelected
      //                                         ? const Color(0xffFF6A2A)
      //                                         : const Color(0xFFF1F3F5),
      //                                     borderRadius: BorderRadius.circular(
      //                                       14.r,
      //                                     ),
      //                                     border: Border.all(
      //                                       color: isSelected
      //                                           ? const Color(0xffFF6A2A)
      //                                           : Colors.grey.shade300,
      //                                     ),
      //                                   ),
      //                                   child: Text(
      //                                     item
      //                                         .replaceAll("-", " ")
      //                                         .toUpperCase(),
      //                                     textAlign: TextAlign.center,
      //                                     maxLines: 2,
      //                                     overflow: TextOverflow.ellipsis,
      //                                     style: TextStyle(
      //                                       fontWeight: FontWeight.w600,
      //                                       fontSize: 12.sp,
      //                                       color: isSelected
      //                                           ? Colors.white
      //                                           : const Color(0xFF344054),
      //                                     ),
      //                                   ),
      //                                 ),
      //                               );
      //                             },
      //                           ),
      //                         ),
      //                         /// ERROR TEXT
      //                         if (state.hasError)
      //                           Padding(
      //                             padding: EdgeInsets.only(
      //                               top: 10.h,
      //                               left: 5.w,
      //                             ),
      //                             child: Text(
      //                               state.errorText!,
      //                               style: TextStyle(
      //                                 color: Colors.red,
      //                                 fontSize: 12.sp,
      //                               ),
      //                             ),
      //                           ),
      //                       ],
      //                     );
      //                   },
      //                 ),
      //               const SizedBox(height: 12),
      //               SizedBox(
      //                 width: double.infinity,
      //                 height: 50.h,
      //                 child: ElevatedButton(
      //                   onPressed: () {
      //                     if (_formKey.currentState!.validate()) {
      //                       return;
      //                     }
      //                     log("Submit");
      //                   },
      //                   style: ElevatedButton.styleFrom(
      //                     backgroundColor: const Color(
      //                       0xFFFF5722,
      //                     ), // Matching your orange theme
      //                     foregroundColor: Colors.white,
      //                     elevation: 2,
      //                     shape: RoundedRectangleBorder(
      //                       borderRadius: BorderRadius.circular(12),
      //                     ),
      //                   ),
      //                   child: Text(
      //                     'SAVE & CONTINUE',
      //                     style: TextStyle(
      //                       fontSize: 14.sp,
      //                       fontWeight: FontWeight.bold,
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //               const SizedBox(height: 12),
      //               _buildSectionTitle("Property Location"),
      //               const SizedBox(height: 10),
      //               _buildCityDropdown(cityAsync),
      //               const SizedBox(height: 12),
      //               _buildDropdown(
      //                 'Locality / Area',
      //                 selectedLocality,
      //                 localityList,
      //                 (v) {
      //                   setState(() {
      //                     selectedLocality = v;
      //                   });
      //                 },
      //               ),
      //               const SizedBox(height: 12),
      //               _buildTextField(
      //                 'Property  Address',
      //                 _propertyAddressController,
      //                 maxLines: 2,
      //                 isRequired: true,
      //               ),
      //               const SizedBox(height: 12),
      //               Row(
      //                 children: [
      //                   /// BACK (small width)
      //                   Expanded(
      //                     flex: 1, // ✅ smaller
      //                     child: SizedBox(
      //                       height: 50.h,
      //                       child: ElevatedButton(
      //                         onPressed: () {
      //                           Navigator.pop(context);
      //                         },
      //                         style: ElevatedButton.styleFrom(
      //                           backgroundColor:
      //                               Colors.transparent, // ❌ no fill
      //                           foregroundColor: const Color(0xFFFF5722),
      //                           elevation: 0,
      //                           side: const BorderSide(
      //                             color: Color(0xFFFF5722),
      //                           ), // ✅ border
      //                           shape: RoundedRectangleBorder(
      //                             borderRadius: BorderRadius.circular(12.r),
      //                           ),
      //                         ),
      //                         child: Text(
      //                           'BACK',
      //                           style: TextStyle(
      //                             fontSize: 14.sp,
      //                             fontWeight: FontWeight.bold,
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                   SizedBox(width: 12.w),
      //                   /// SAVE & CONTINUE (bigger width)
      //                   Expanded(
      //                     flex: 2, // ✅ bigger
      //                     child: SizedBox(
      //                       height: 50.h,
      //                       child: ElevatedButton(
      //                         onPressed: () {
      //                           if (!_formKey.currentState!.validate()) return;
      //                           log("Submit");
      //                         },
      //                         style: ElevatedButton.styleFrom(
      //                           backgroundColor: const Color(0xFFFF5722),
      //                           foregroundColor: Colors.white,
      //                           elevation: 2,
      //                           shape: RoundedRectangleBorder(
      //                             borderRadius: BorderRadius.circular(12.r),
      //                           ),
      //                         ),
      //                         child: Text(
      //                           'SAVE & CONTINUE',
      //                           style: TextStyle(
      //                             fontSize: 14.sp,
      //                             fontWeight: FontWeight.bold,
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //               const SizedBox(height: 12),
      //               _buildSectionTitle("Specification"),
      //               const SizedBox(height: 12),
      //               _buildTextField(
      //                 'Price (₹)',
      //                 _priceController,
      //                 type: TextInputType.number,
      //                 isRequired: true,
      //               ),
      //               const SizedBox(height: 12),
      //               Row(
      //                 children: [
      //                   Expanded(
      //                     child: _buildTextField(
      //                       'BHK',
      //                       _bedroomsController,
      //                       type: TextInputType.number,
      //                       isRequired: true,
      //                     ),
      //                   ),
      //                   const SizedBox(width: 12),
      //                   Expanded(
      //                     child: _buildTextField(
      //                       'Bathrooms',
      //                       _bathroomsController,
      //                       type: TextInputType.number,
      //                       isRequired: true,
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //               const SizedBox(height: 12),
      //               _buildTextField(
      //                 'Area (sq.ft)',
      //                 _areaController,
      //                 type: TextInputType.number,
      //                 isRequired: true,
      //               ),
      //               const SizedBox(height: 12),
      //               Row(
      //                 children: [
      //                   /// BACK (small width)
      //                   Expanded(
      //                     flex: 1, // ✅ smaller
      //                     child: SizedBox(
      //                       height: 50.h,
      //                       child: ElevatedButton(
      //                         onPressed: () {
      //                           Navigator.pop(context);
      //                         },
      //                         style: ElevatedButton.styleFrom(
      //                           backgroundColor:
      //                               Colors.transparent, // ❌ no fill
      //                           foregroundColor: const Color(0xFFFF5722),
      //                           elevation: 0,
      //                           side: const BorderSide(
      //                             color: Color(0xFFFF5722),
      //                           ), // ✅ border
      //                           shape: RoundedRectangleBorder(
      //                             borderRadius: BorderRadius.circular(12.r),
      //                           ),
      //                         ),
      //                         child: Text(
      //                           'BACK',
      //                           style: TextStyle(
      //                             fontSize: 14.sp,
      //                             fontWeight: FontWeight.bold,
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                   SizedBox(width: 12.w),
      //                   /// SAVE & CONTINUE (bigger width)
      //                   Expanded(
      //                     flex: 2, // ✅ bigger
      //                     child: SizedBox(
      //                       height: 50.h,
      //                       child: ElevatedButton(
      //                         onPressed: () {
      //                           if (!_formKey.currentState!.validate()) return;
      //                           log("Submit");
      //                         },
      //                         style: ElevatedButton.styleFrom(
      //                           backgroundColor: const Color(0xFFFF5722),
      //                           foregroundColor: Colors.white,
      //                           elevation: 2,
      //                           shape: RoundedRectangleBorder(
      //                             borderRadius: BorderRadius.circular(12.r),
      //                           ),
      //                         ),
      //                         child: Text(
      //                           'SAVE & CONTINUE',
      //                           style: TextStyle(
      //                             fontSize: 14.sp,
      //                             fontWeight: FontWeight.bold,
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ],
      //           ),
      //         ),
      //         const SizedBox(height: 12),
      //         _buildSectionTitle("Amenities & Legel"),
      //         _buildCard(child: _buildMultiSelectAmenities()),
      //         const SizedBox(height: 24),
      //         _buildSectionTitle("Around The Project"),
      //         const SizedBox(height: 12),
      //         _buildCard(
      //           child: Column(
      //             children: [
      //               ...aroundProjectList.asMap().entries.map((entry) {
      //                 final idx = entry.key;
      //                 final ctrls = entry.value;
      //                 return Padding(
      //                   padding: const EdgeInsets.only(bottom: 16),
      //                   child: Stack(
      //                     children: [
      //                       Column(
      //                         children: [
      //                           _buildTextField(
      //                             'Place Name',
      //                             ctrls['place']!,
      //                             isRequired: false,
      //                           ),
      //                           const SizedBox(height: 12),
      //                           _buildTextField(
      //                             'Details',
      //                             ctrls['details']!,
      //                             isRequired: false,
      //                           ),
      //                         ],
      //                       ),
      //                       if (aroundProjectList.length > 1)
      //                         Positioned(
      //                           top: -14,
      //                           right: -8,
      //                           child: IconButton(
      //                             icon: Icon(
      //                               Icons.close,
      //                               color: Colors.red,
      //                               size: 25,
      //                             ),
      //                             onPressed: () => removeAroundProjectRow(idx),
      //                           ),
      //                         ),
      //                     ],
      //                   ),
      //                 );
      //               }),
      //               Align(
      //                 alignment: Alignment.centerLeft,
      //                 child: TextButton.icon(
      //                   onPressed: addAroundProjectRow,
      //                   icon: const Icon(Icons.add, color: Color(0xFFFF5722)),
      //                   label: const Text(
      //                     'Add More Nearby Place',
      //                     style: TextStyle(color: Color(0xFFFF5722)),
      //                   ),
      //                 ),
      //               ),
      //               _buildTextField(
      //                 'RERA Number',
      //                 _reraController,
      //                 hint: '',
      //                 type: TextInputType.number,
      //                 isRequired: true,
      //               ),
      //               const SizedBox(height: 12),
      //               _buildDropdown(
      //                 'Furnishing',
      //                 selectedFurnishing,
      //                 ["Furnished", "Semi-Furnished", "Unfurnished"],
      //                 (v) => setState(() => selectedFurnishing = v),
      //                 isRequired: true,
      //               ),
      //               const SizedBox(height: 12),
      //               Row(
      //                 children: [
      //                   /// BACK (small width)
      //                   Expanded(
      //                     flex: 1, // ✅ smaller
      //                     child: SizedBox(
      //                       height: 50.h,
      //                       child: ElevatedButton(
      //                         onPressed: () {
      //                           Navigator.pop(context);
      //                         },
      //                         style: ElevatedButton.styleFrom(
      //                           backgroundColor:
      //                               Colors.transparent, // ❌ no fill
      //                           foregroundColor: const Color(0xFFFF5722),
      //                           elevation: 0,
      //                           side: const BorderSide(
      //                             color: Color(0xFFFF5722),
      //                           ), // ✅ border
      //                           shape: RoundedRectangleBorder(
      //                             borderRadius: BorderRadius.circular(12.r),
      //                           ),
      //                         ),
      //                         child: Text(
      //                           'BACK',
      //                           style: TextStyle(
      //                             fontSize: 14.sp,
      //                             fontWeight: FontWeight.bold,
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                   SizedBox(width: 12.w),
      //                   /// SAVE & CONTINUE (bigger width)
      //                   Expanded(
      //                     flex: 2, // ✅ bigger
      //                     child: SizedBox(
      //                       height: 50.h,
      //                       child: ElevatedButton(
      //                         onPressed: () {
      //                           if (!_formKey.currentState!.validate()) return;
      //                           log("Submit");
      //                         },
      //                         style: ElevatedButton.styleFrom(
      //                           backgroundColor: const Color(0xFFFF5722),
      //                           foregroundColor: Colors.white,
      //                           elevation: 2,
      //                           shape: RoundedRectangleBorder(
      //                             borderRadius: BorderRadius.circular(12.r),
      //                           ),
      //                         ),
      //                         child: Text(
      //                           'SAVE & CONTINUE',
      //                           style: TextStyle(
      //                             fontSize: 14.sp,
      //                             fontWeight: FontWeight.bold,
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ],
      //           ),
      //         ),
      //         const SizedBox(height: 24),
      //         _buildSectionTitle("Photos & Media"),
      //         const SizedBox(height: 12),
      //         _buildCard(
      //           child: Column(
      //             children: [
      //               ElevatedButton.icon(
      //                 onPressed: pickImages,
      //                 icon: const Icon(Icons.add_photo_alternate),
      //                 label: const Text('Add Photos'),
      //                 style: ElevatedButton.styleFrom(
      //                   backgroundColor: const Color(0xFFFF5722),
      //                   foregroundColor: Colors.white,
      //                   minimumSize: const Size(double.infinity, 52),
      //                   shape: RoundedRectangleBorder(
      //                     borderRadius: BorderRadius.circular(12),
      //                   ),
      //                 ),
      //               ),
      //               const SizedBox(height: 16),
      //               if (propertyImages.isEmpty)
      //                 const Padding(
      //                   padding: EdgeInsets.symmetric(vertical: 10),
      //                   child: Text(
      //                     'No photos selected',
      //                     style: TextStyle(color: Colors.grey),
      //                   ),
      //                 )
      //               else
      //                 GridView.builder(
      //                   shrinkWrap: true,
      //                   physics: const NeverScrollableScrollPhysics(),
      //                   gridDelegate:
      //                       const SliverGridDelegateWithFixedCrossAxisCount(
      //                         crossAxisCount: 3,
      //                         crossAxisSpacing: 10,
      //                         mainAxisSpacing: 10,
      //                         childAspectRatio: 1,
      //                       ),
      //                   itemCount: propertyImages.length,
      //                   itemBuilder: (_, i) {
      //                     final img = propertyImages[i];
      //                     return ClipRRect(
      //                       borderRadius: BorderRadius.circular(12),
      //                       child: Stack(
      //                         fit: StackFit.expand,
      //                         children: [
      //                           img is File
      //                               ? Image.file(img, fit: BoxFit.cover)
      //                               : Image.network(img, fit: BoxFit.cover),
      //                           Positioned(
      //                             top: 6,
      //                             right: 6,
      //                             child: GestureDetector(
      //                               onTap: () => removeImage(i),
      //                               child: const CircleAvatar(
      //                                 radius: 14,
      //                                 backgroundColor: Colors.black54,
      //                                 child: Icon(
      //                                   Icons.close,
      //                                   size: 16,
      //                                   color: Colors.white,
      //                                 ),
      //                               ),
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                     );
      //                   },
      //                 ),
      //             ],
      //           ),
      //         ),
      //         const SizedBox(height: 24),
      //         _buildSectionTitle("Deep Porperty Description"),
      //         const SizedBox(height: 12),
      //         _buildCard(
      //           child: _buildTextField(
      //             'Describe your property...',
      //             _descriptionController,
      //             maxLines: 5,
      //             isRequired: false,
      //           ),
      //         ),
      //         // const SizedBox(height: 24),
      //         // _buildSectionTitle("Project Overview"),
      //         // const SizedBox(height: 12),
      //         // _buildCard(
      //         //   child: Column(
      //         //     crossAxisAlignment: CrossAxisAlignment.start,
      //         //     children: [
      //         //       _buildTextField(
      //         //         'Project Area (Acre)',
      //         //         _projectAreaController,
      //         //         hint: 'e.g. 0.89 Acres',
      //         //         type: TextInputType.number,
      //         //         isRequired: true,
      //         //       ),
      //         //       const SizedBox(height: 12),
      //         //       _buildTextField(
      //         //         'Unit Sizes (sq.ft)',
      //         //         _unitSizesController,
      //         //         hint: 'e.g. 431 - 460',
      //         //         type: TextInputType.number,
      //         //         isRequired: true,
      //         //       ),
      //         //       const SizedBox(height: 12),
      //         //       _buildTextField(
      //         //         'Total Project Units',
      //         //         _projectSizeController,
      //         //         hint: '',
      //         //         type: TextInputType.number,
      //         //         isRequired: false,
      //         //       ),
      //         //       const SizedBox(height: 12),
      //         //       _buildTextField(
      //         //         'Launch Date',
      //         //         _launchDateController,
      //         //         hint: "Select launch date",
      //         //         readOnly: true,
      //         //         onTap: () => _selectDate(_launchDateController),
      //         //         isRequired: true,
      //         //       ),
      //         //       const SizedBox(height: 12),
      //         //       _buildTextField(
      //         //         'Possession Start Date',
      //         //         _possessionDateController,
      //         //         hint: "Select possession date",
      //         //         readOnly: true,
      //         //         onTap: () => _selectDate(_possessionDateController),
      //         //         isRequired: true,
      //         //       ),
      //         //     ],
      //         //   ),
      //         // ),
      //         // const SizedBox(height: 24),
      //         // _buildSectionTitle("Property Address"),
      //         // const SizedBox(height: 12),
      //         // _buildCard(
      //         //   child: _buildTextField(
      //         //     'Full Address',
      //         //     _propertyAddressController,
      //         //     maxLines: 3,
      //         //     isRequired: true,
      //         //   ),
      //         // ),
      //         const SizedBox(height: 40),
      //         SafeArea(
      //           top: false,
      //           child: SizedBox(
      //             width: double.infinity,
      //             height: 56,
      //             child: ElevatedButton(
      //               onPressed: _isLoading ? null : _submitProperty,
      //               style: ElevatedButton.styleFrom(
      //                 backgroundColor: const Color(0xFFFF5722),
      //                 foregroundColor: Colors.white,
      //                 shape: RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(30),
      //                 ),
      //                 elevation: 2,
      //               ),
      //               child: _isLoading
      //                   ? const CircularProgressIndicator(color: Colors.white)
      //                   : Text(
      //                       isEditMode ? 'Update Property' : 'Submit Property',
      //                       style: const TextStyle(
      //                         fontSize: 18,
      //                         fontWeight: FontWeight.bold,
      //                       ),
      //                     ),
      //             ),
      //           ),
      //         ),
      //         const SizedBox(height: 30),
      //       ],
      //     ),
      //   ),
      // ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step Title
              _buildSectionTitle(_getStepTitle()),

              const SizedBox(height: 16),

              // Show only current step content
              _buildCurrentStep(cityAsync),

              const SizedBox(height: 30),

              // Navigation Buttons
              Row(
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
                            foregroundColor: const Color(0xFFFF5722),
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFFFF5722)),
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

                  // SAVE & CONTINUE / SUBMIT Button
                  Expanded(
                    flex: _currentStep > 0 ? 2 : 1,
                    child: SizedBox(
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleNextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF5722),
                          foregroundColor: Colors.white,
                          disabledIconColor: Color(0xFFFF5722).withOpacity(0.5),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
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
                                    ? (isEditMode
                                          ? 'Update Property'
                                          : 'Submit Property')
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
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(AsyncValue<CityResponseModel> cityAsync) {
    switch (_currentStep) {
      case 0: // Basic Details
        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Listing Purpose",
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              FormField(
                validator: (value) {
                  if (selectedType == null)
                    return "Listing Category is Required";
                  return null;
                },
                builder: (FormFieldState<int> state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 10.h),
                        height: 45.h,
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
                                  state.didChange(selectedType);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    color: selectedType == 1
                                        ? const Color(0xFFFF5722)
                                        : Colors.transparent,
                                  ),
                                  child: Text(
                                    'SELL',
                                    style: TextStyle(
                                      color: selectedType == 1
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
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
                                  state.didChange(selectedType);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    color: selectedType == 2
                                        ? const Color(0xFFFF5722)
                                        : Colors.transparent,
                                  ),
                                  child: Text(
                                    'RENT OUT',
                                    style: TextStyle(
                                      color: selectedType == 2
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 5, left: 5),
                          child: Text(
                            state.errorText!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                'Property',
                selectedPropertyType,
                ["Residential", "Commercial"],
                (v) => setState(() => selectedPropertyType = v),
                isRequired: true,
              ),
              const SizedBox(height: 12),

              if (selectedPropertyType != null)
                FormField<String>(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Property type is required";
                    }
                    return null;
                  },
                  builder: (FormFieldState<String> state) {
                    // ✅ Sync karo jab rebuild ho
                    if (state.value != selectedPropertySubType) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        state.didChange(selectedPropertySubType);
                      });
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Specific Property Type",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                (selectedPropertyType == "Residential"
                                        ? [
                                            "apartment",
                                            "townhouse",
                                            "villa-compound",
                                            "land",
                                            "building",
                                            "villa",
                                            "penthouse",
                                            "hotel-apartment",
                                            "floor",
                                            "studio",
                                          ]
                                        : [
                                            "office",
                                            "warehouse",
                                            "showroom",
                                            "shop",
                                            "factory",
                                            "other-commercial",
                                          ])
                                    .length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10.h,
                                  crossAxisSpacing: 10.w,
                                  mainAxisExtent: 45.h,
                                ),
                            itemBuilder: (context, index) {
                              final options =
                                  selectedPropertyType == "Residential"
                                  ? [
                                      "apartment",
                                      "townhouse",
                                      "villa-compound",
                                      "land",
                                      "building",
                                      "villa",
                                      "penthouse",
                                      "hotel-apartment",
                                      "floor",
                                      "studio",
                                    ]
                                  : [
                                      "office",
                                      "warehouse",
                                      "showroom",
                                      "shop",
                                      "factory",
                                      "other-commercial",
                                    ];

                              final item = options[index];
                              final isSelected =
                                  selectedPropertySubType == item;

                              return GestureDetector(
                                onTap: () {
                                  setState(
                                    () => selectedPropertySubType = item,
                                  );
                                  state.didChange(item);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xffFF6A2A)
                                        : const Color(0xFFF1F3F5),
                                    borderRadius: BorderRadius.circular(14.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xffFF6A2A)
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    item.replaceAll("-", " ").toUpperCase(),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF344054),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (state.hasError)
                          Padding(
                            padding: EdgeInsets.only(top: 10.h, left: 5.w),
                            child: Text(
                              state.errorText!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.sp,
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

      case 1: // Property Location
        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCityDropdown(cityAsync),
              const SizedBox(height: 12),
              _buildDropdown(
                'Locality / Area',
                selectedLocality,
                localityList,
                (v) => setState(() => selectedLocality = v),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'Property Address',
                _propertyAddressController,
                maxLines: 2,
                isRequired: true,
              ),
            ],
          ),
        );

      case 2: // Specification
        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                'Price (₹)',
                _priceController,
                type: TextInputType.number,
                isRequired: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'BHK',
                      _bedroomsController,
                      type: TextInputType.number,
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      'Bathrooms',
                      _bathroomsController,
                      type: TextInputType.number,
                      isRequired: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'Area (sq.ft)',
                _areaController,
                type: TextInputType.number,
                isRequired: true,
              ),
            ],
          ),
        );

      case 3: // Amenities & Legal
        return _buildCard(child: _buildMultiSelectAmenities());

      case 4: // Around The Project
        return _buildCard(
          child: Column(
            children: [
              ...aroundProjectList.asMap().entries.map((entry) {
                final idx = entry.key;
                final ctrls = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          _buildTextField(
                            'Place Name',
                            ctrls['place']!,
                            isRequired: false,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'Details',
                            ctrls['details']!,
                            isRequired: false,
                          ),
                        ],
                      ),
                      if (aroundProjectList.length > 1)
                        Positioned(
                          top: -14,
                          right: -8,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 25,
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
                  icon: const Icon(Icons.add, color: Color(0xFFFF5722)),
                  label: const Text(
                    'Add More Nearby Place',
                    style: TextStyle(color: Color(0xFFFF5722)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'RERA Number',
                _reraController,
                type: TextInputType.number,
                isRequired: true,
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                'Furnishing',
                selectedFurnishing,
                ["Furnished", "Semi-Furnished", "Unfurnished"],
                (v) => setState(() => selectedFurnishing = v),
                isRequired: true,
              ),
            ],
          ),
        );

      case 5: // Photos & Media
        return _buildCard(
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Photos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (propertyImages.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'No photos selected',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: propertyImages.length,
                  itemBuilder: (_, i) {
                    final img = propertyImages[i];
                    return Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.none,
                      children: [
                        img is File
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(img, fit: BoxFit.cover),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(img, fit: BoxFit.cover),
                              ),
                        Positioned(
                          top: -6,
                          right: -4,
                          child: GestureDetector(
                            onTap: () => removeImage(i),
                            child: const CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
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

      case 6: // Deep Property Description
        return _buildCard(
          child: _buildTextField(
            'Describe your property...',
            _descriptionController,
            maxLines: 5,
            isRequired: false,
          ),
        );

      default:
        return const SizedBox();
    }
  }

  // ────── Helper Widgets ──────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.black,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      controller.text =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    }
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? " *" : ""),
          style: const TextStyle(
            fontSize: 13.5,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          // Changed to TextFormField
          controller: controller,
          maxLines: maxLines,
          keyboardType: type ?? TextInputType.text,
          readOnly: readOnly,
          onTap: onTap,
          validator: isRequired
              ? (value) => _validateRequired(value, label)
              : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF5722),
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),

            errorStyle: TextStyle(fontSize: 12.sp, color: Colors.red),
          ),
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
            fontSize: 13.5.sp,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: 6.h),

        DropdownButtonFormField<String>(
          value: safeValue,
          isExpanded: true,

          hint: Text(
            'Select $label',
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),

          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey,
            size: 22.sp,
          ),

          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: TextStyle(fontSize: 14.sp)),
                ),
              )
              .toList(),

          onChanged: onChanged,

          validator: isRequired
              ? (value) =>
                    value == null || value.isEmpty ? '$label is required' : null
              : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8F9FA),

            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),

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
              borderSide: const BorderSide(
                color: Color(0xFFFF5722),
                width: 1.8,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),

            errorStyle: TextStyle(fontSize: 12.sp, color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildCityDropdown(AsyncValue<CityResponseModel> cityAsync) {
    return cityAsync.when(
      data: (cityRes) {
        final cities = cityRes.data ?? [];

        if (selectedCity != null && cities.isNotEmpty) {
          final matchedCity = cities.cast<dynamic>().firstWhere(
            (c) =>
                (c.cityName ?? "").toString().trim().toLowerCase() ==
                selectedCity!.trim().toLowerCase(),
            orElse: () => null,
          );

          if (matchedCity != null && matchedCity.areas != null) {
            if (localityList.length != matchedCity.areas!.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    localityList = List<String>.from(matchedCity.areas!);
                  });
                }
              });
            }
          }
        }

        return _buildDropdown(
          'City',
          selectedCity,
          cities.map((c) => c.cityName ?? "").toList(),
          (v) {
            setState(() {
              selectedCity = v;
              selectedLocality = null;
              final selectedCityObj = cities.cast<dynamic>().firstWhere(
                (c) =>
                    (c.cityName ?? "").toString().trim().toLowerCase() ==
                    (v ?? "").trim().toLowerCase(),
                orElse: () => null,
              );

              if (selectedCityObj != null) {
                localityList = List<String>.from(selectedCityObj.areas ?? []);
              } else {
                localityList = [];
              }
            });
          },
          isRequired: true,
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: CupertinoActivityIndicator(),
        ),
      ),
      error: (_, __) => const Text(
        "Failed to load cities",
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildMultiSelectAmenities() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allAmenities.map((amenity) {
        final selected = selectedAmenities.contains(amenity);
        return FilterChip(
          label: Text(amenity, style: const TextStyle(fontSize: 13)),
          selected: selected,
          selectedColor: const Color(0xFFFF5722).withOpacity(0.15),
          checkmarkColor: const Color(0xFFFF5722),
          backgroundColor: Colors.grey.shade100,
          onSelected: (sel) {
            setState(() {
              if (sel) {
                selectedAmenities.add(amenity);
              } else {
                selectedAmenities.remove(amenity);
              }
            });
          },
        );
      }).toList(),
    );
  }
}
