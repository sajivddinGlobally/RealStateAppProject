import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:realstate/Controller/contactUsController.dart';
import 'package:realstate/Controller/getCityListController.dart';
import 'package:realstate/Controller/getHeroBannerProvider.dart';
import 'package:realstate/Controller/getMyPropertyController.dart';
import 'package:realstate/Controller/getPropertyCategoryProvider.dart';
import 'package:realstate/Model/Body/updateDesablePropertyBodyModel.dart';
import 'package:realstate/Model/getPropertyCategoryModel.dart' as cat_model;
import 'package:realstate/Controller/homeServiceCategoryController.dart';
import 'package:realstate/Controller/likePropertyController.dart';
import 'package:realstate/Controller/loanServiceController.dart';
import 'package:realstate/Controller/notificationController.dart';
import 'package:realstate/Controller/userProfileController.dart';
import 'package:realstate/Model/commonLoanModel.dart';
import 'package:realstate/Model/contactUsBodyModel.dart';
import 'package:realstate/Model/getLikeProperyResModel.dart';
import 'package:realstate/Model/getPropertyResponsemodel.dart';
import 'package:realstate/Model/myListingPropertyDeleteBodyModel.dart';
import 'package:realstate/Model/propertyDetailModel.dart';
import 'package:realstate/Model/saveServiceBodyModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:realstate/pages/MyPropertyRequest.dart';
import 'package:realstate/pages/homeServiceDetails.page.dart';
import 'package:realstate/pages/loanServiceDetails.page.dart';
import 'package:realstate/pages/myLoanRequest.dart';
import 'package:realstate/pages/myPropertyDetals.page.dart';
import 'package:realstate/pages/myRequest.page.dart';
import 'package:realstate/pages/notification.page.dart';
import 'package:realstate/pages/perticulerProperty.page.dart';
import 'package:realstate/pages/pricePlan.page.dart';
import 'package:realstate/pages/propertyCat.page.dart';
import 'package:realstate/pages/listingPage.dart';
import 'package:realstate/pages/search_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../CityProvider.dart';
import '../Model/commanLoanModel.dart';
import '../Model/getMyPropertyResModel.dart';
import 'SearchProperty.dart';
import 'createPropertyPage.dart';
import 'drawer.dart';

class RealEstateHomePage extends ConsumerStatefulWidget {
  const RealEstateHomePage({super.key});
  @override
  ConsumerState<RealEstateHomePage> createState() => _RealEstateHomePageState();
}

class _RealEstateHomePageState extends ConsumerState<RealEstateHomePage>
    with TickerProviderStateMixin, RouteAware {
  late TabController _tabController;
  int bottomIndex = 0;
  int selectIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? selectedCity;
  List<Property> properties = [];
  String? _currentCity;
  bool _isFetchingLocation = false;
  @override
  void initState() {
    super.initState();
    _addDummyProperties();
    Future.microtask(() {
      ref.read(userProfileController);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedCity();
    });
    _fetchAndSaveCurrentCity();
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              selectIndex = _tabController.index;
              currentBannerIndex = 0;
            });
          }
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadSavedCity(); // screen par wapas aate hi call hoga
  }

  Future<void> _loadSavedCity() async {
    final saved = await ref.read(savedCityProvider.future);
    if (saved != null && mounted) {
      if (_currentCity == null) {
        setState(() {
          _currentCity = saved;
          selectedCity = saved;
        });
        ref.read(currentCityProvider.notifier).state = saved;
      }
    }
  }

  Future<void> _fetchAndSaveCurrentCity() async {
    if (_isFetchingLocation) return;
    setState(() => _isFetchingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location services disabled")),
          );
        }
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        String? city =
            placemarks.first.locality ?? placemarks.first.subAdministrativeArea;
        if (city != null && city.isNotEmpty) {
          setState(() {
            _currentCity = city;
            selectedCity = city;
          });
          ref.read(currentCityProvider.notifier).state = city;
          await saveCity(city);
          Fluttertoast.showToast(
            msg: "Location set to $city",
            gravity: ToastGravity.BOTTOM,
          );
        }
      }
    } catch (e) {
      debugPrint("Location fetch error: $e");
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  void _addDummyProperties() {
    properties = [
      Property(
        propertyType: 'Apartment/Flat',
        propertyCategory: 'Residential',
        listingCategory: 'Sale',
        city: 'Mumbai',
        locality: 'Andheri West',
        price: '2.5 Cr',
        bedrooms: '3',
        bathrooms: '3',
        area: '1200',
        furnishing: 'Semi-Furnished',
        amenities: [
          'Gymnasium',
          'Swimming Pool',
          'Lift',
          'Security',
          'Parking',
        ],
        aroundProject: [
          {'place': 'Metro Station', 'details': '2 mins walk'},
          {'place': 'School', 'details': 'International School - 1 km'},
        ],
        fullName: 'Rahul Sharma',
        email: 'rahul@example.com',
        phone: '+91 9171719060',
        address: 'Palm Grove Apartments, Andheri West, Mumbai',
        description: 'Luxurious 3 BHK with sea view...',
      ),
      Property(
        propertyType: 'Independent House/Villa',
        propertyCategory: 'Residential',
        listingCategory: 'Rent/Lease',
        city: 'Delhi',
        locality: 'Greater Kailash',
        price: '1.2 Lac/month',
        bedrooms: '4',
        bathrooms: '4',
        area: '2500',
        furnishing: 'Furnished',
        amenities: ['Garden', 'Parking', 'Power Backup', 'Security'],
        aroundProject: [
          {'place': 'Market', 'details': 'GK Market - 500m'},
          {'place': 'Hospital', 'details': 'Max Hospital - 3km'},
        ],
        fullName: 'Priya Singh',
        email: 'priya@example.com',
        phone: '+91 8765432109',
        address: 'E-Block, Greater Kailash, New Delhi',
        description: 'Beautiful independent villa with lawn...',
      ),
      Property(
        propertyType: 'Shop/Showroom',
        propertyCategory: 'Commercial',
        listingCategory: 'Sale',
        city: 'Bangalore',
        locality: 'Koramangala',
        price: '3.8 Cr',
        bedrooms: '0',
        bathrooms: '2',
        area: '800',
        furnishing: 'Unfurnished',
        amenities: ['Parking', 'Lift', 'Security'],
        aroundProject: [
          {'place': 'Forum Mall', 'details': 'Walking distance'},
        ],
        fullName: 'Amit Patel',
        email: 'amit@example.com',
        phone: '+91 7654321098',
        address: 'Main Road, Koramangala, Bangalore',
        description: 'Prime location showroom...',
      ),
      Property(
        propertyType: 'Plot/Land',
        propertyCategory: 'Residential',
        listingCategory: 'Sale',
        city: 'Pune',
        locality: 'Hinjewadi',
        price: '85 Lac',
        bedrooms: '0',
        bathrooms: '0',
        area: '2000',
        furnishing: 'Unfurnished',
        amenities: [],
        aroundProject: [
          {'place': 'IT Park', 'details': 'Phase 1 - 2km'},
          {'place': 'School', 'details': 'Vibgyor - 1.5km'},
        ],
        fullName: 'Neha Gupta',
        email: 'neha@example.com',
        phone: '+91 6543210987',
        address: 'Rajiv Gandhi Infotech Park, Hinjewadi, Pune',
        description: 'Ready to construct residential plot...',
      ),
      Property(
        propertyType: 'Office Space',
        propertyCategory: 'Commercial',
        listingCategory: 'Rent/Lease',
        city: 'Gurgaon',
        locality: 'Cyber City',
        price: '2.5 Lac/month',
        bedrooms: '0',
        bathrooms: '4',
        area: '3000',
        furnishing: 'Furnished',
        amenities: ['Lift', 'Parking', 'Power Backup', 'Security', 'Gymnasium'],
        aroundProject: [
          {'place': 'Metro', 'details': 'Cyber City Metro - 100m'},
          {'place': 'Cafe', 'details': 'Starbucks - Ground floor'},
        ],
        fullName: 'Vikram Singh',
        email: 'vikram@example.com',
        phone: '+91 5432109876',
        address: 'DLF Cyber Hub, Gurgaon',
        description: 'Fully furnished premium office space...',
      ),
    ];
  }

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();
  final locationController = TextEditingController();
  bool isLoading = false;
  final _formKeyContactUs = GlobalKey<FormState>();
  DateTime? lastPressedAt;
  final List<String> bannerImages = [
    "assets/home (3).png",
    "assets/home (3).png",
    "assets/home (3).png",
  ];
  int currentBannerIndex = 0;
  final List<String> propertyImages = [
    "assets/property1.jpg",
    "assets/property2.jfif",
    "assets/property3.jfif",
  ];
  final List<String> homeServiceImages = [
    "assets/home1.webp",
    "assets/home2.jfif",
    "assets/home3.jfif",
  ];
  final List<String> loanImages = [
    "assets/loan1.jpg",
    "assets/loan2.jfif",
    "assets/loan3.jpg",
  ];
  List<String> get currentImages {
    if (selectIndex == 0) {
      return propertyImages;
    } else if (selectIndex == 1) {
      return homeServiceImages;
    } else {
      return loanImages;
    }
  }

  final TextEditingController _citySearchController = TextEditingController();

  // @override
  // void dispose() {
  //   _tabController.dispose();
  //   _citySearchController.dispose();
  //   super.dispose();
  // }
  String searchListing = '';
  @override
  Widget build(BuildContext context) {
    final city = ref.watch(currentCityProvider) ?? _currentCity;
    final profileController = ref.watch(userProfileController);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          Navigator.pop(context);
          return;
        }
        if (bottomIndex != 0) {
          setState(() {
            bottomIndex = 0;
          });
          return;
        }
        final now = DateTime.now();
        final backButtonHasNotBeenPressedRecently =
            lastPressedAt == null ||
            now.difference(lastPressedAt!) > const Duration(seconds: 2);

        if (backButtonHasNotBeenPressedRecently) {
          lastPressedAt = now;
          Fluttertoast.showToast(
            msg: "Press back again to exit",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black87,
            textColor: Colors.white,
          );
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        drawer: AppDrawer(
          onItemSelected: (index) {
            setState(() {
              bottomIndex = index;
            });
          },
          profileController: profileController,
        ),
        backgroundColor: const Color(0xffF5F7FA),
        body: <Widget>[
          HomeScreen(city),
          MyListingsScreen(),
          CreatePropertyScreen(
            fromBottomNav: true,
            ListElement(),
            onSuccess: () {
              setState(() {
                bottomIndex = 1;
              });
              ref.invalidate(getMyPropertyController);
            },
          ),
          CallUsScreen(),
          SavedScreen(),
        ][bottomIndex],
        floatingActionButton: SizedBox(
          height: 46.h,
          width: 46.w,
          child: FloatingActionButton(
            elevation: 6,
            backgroundColor: const Color(0xFF24ADD7),
            shape: const CircleBorder(),
            onPressed: () {
              if (selectIndex == 2) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const VendorRegistrationBottomSheet(),
                );
              } else {
                setState(() {
                  bottomIndex = 2;
                });
              }
            },
            child: Icon(
              // Icons.add,
              selectIndex == 2 ? Icons.person_add : Icons.add,
              size: 22.sp,
              color: Colors.white,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: BottomAppBar(
            padding: EdgeInsets.zero,
            color: Colors.white,
            elevation: 8,
            height: 70.h, // reduced from 90.h
            shape: const CircularNotchedRectangle(),
            notchMargin: 6.r,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Row(
                children: [
                  buildNavItem(Icons.home_outlined, 'Home', 0),
                  buildNavItem(Icons.description_outlined, 'My Listings', 1),
                  buildNavItem(
                    Icons.description_outlined,
                    //  'Add\nProperty',
                    selectIndex == 1 ? 'Add\nVendor' : 'Add\nProperty',
                    2,
                  ),
                  buildNavItem(Icons.call_outlined, 'Call us', 3),
                  buildNavItem(Icons.bookmark_border, 'Saved', 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNavItem(IconData icon, String label, int index) {
    final isSelected = bottomIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => bottomIndex = index);

          /// Refresh controllers
          if (index == 1) {
            ref.invalidate(getMyPropertyController);
          } else if (index == 3) {
            ref.invalidate(likePropertyController);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Space for FAB
            index == 2
                ? SizedBox(height: 18.h)
                : AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(5.r),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF24ADD7)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 20.sp,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF838299),
                    ),
                  ),
            SizedBox(height: 3.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: isSelected ? Colors.black : const Color(0xFF838299),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HOME SCREEN ====================
  Widget HomeScreen(String? city) {
    final cityListState = ref.watch(getCityController);

    final notificationState = ref.watch(notificationController);
    final unreadCount = notificationState.maybeWhen(
      data: (data) =>
          data.data?.where((item) => item.isRead == false).length ?? 0,
      orElse: () => 0,
    );
    final getBannerState = ref.watch(getHeroBannerProvider);
    final getProeprtyCategoryState = ref.watch(getPropertyCategoryProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 8.h,
              bottom: 8.h,
            ),
            color: const Color(0xFF24ADD7),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    child: Icon(Icons.menu, color: Colors.white, size: 22.sp),
                  ),
                  SizedBox(width: 10.w),

                  Expanded(
                    child: TextField(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SearchResultScreen(selectedCity),
                          ),
                        );
                      },
                      style: GoogleFonts.inter(color: Colors.white),
                      cursorColor: Colors.white,
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.25),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide: BorderSide.none,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8.h,
                          horizontal: 10.w,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minHeight: 30.h,
                          minWidth: 40.w,
                        ),
                        hintText: "Search",
                        hintStyle: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => NotificationPage(),
                        ),
                      ).then((value) {
                        ref.invalidate(notificationController);
                      });
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(Icons.notifications_none, color: Colors.white),
                        if (unreadCount > 0)
                          Positioned(
                            right: 0,
                            top: -2,
                            child: Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: Text(
                                unreadCount > 99
                                    ? "99+"
                                    : unreadCount.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  cityListState.when(
                    data: (cityList) {
                      final cityNames = cityList.data!
                          .map((e) => e.cityName.toString())
                          .toSet()
                          .toList();

                      final effectiveCity =
                          selectedCity ?? _currentCity ?? city;

                      if (selectedCity == null && effectiveCity != null) {
                        selectedCity = effectiveCity;
                      }

                      // Check if selectedCity matches any city in backend cityNames
                      String? matchedValue;
                      try {
                        matchedValue = cityNames.firstWhere(
                          (c) => c.toLowerCase() == selectedCity?.toLowerCase(),
                        );
                      } catch (_) {
                        matchedValue = null;
                      }

                      // ✅ FIX: Dropdown ko responsive parent size dene ke liye aur design matching ke liye Container lagaya hai
                      return Container(
                        height: 34.h,
                        width: 120.w,
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            isDense: true,

                            value: matchedValue,
                            hint: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14.sp,
                                  color: const Color(0xFF24ADD7),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    _isFetchingLocation
                                        ? "Fetching..."
                                        : (selectedCity ??
                                              _currentCity ??
                                              "Select"),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: const Color(0xFF24ADD7),
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            iconStyleData: IconStyleData(
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: const Color(0xFF24ADD7),
                                size: 16.sp,
                              ),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 280.h,
                              width: 180.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: Colors.white,
                              ),
                            ),
                            items: cityNames.map((cityName) {
                              return DropdownMenuItem<String>(
                                value: cityName,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14.sp,
                                      color: const Color(0xFF24ADD7),
                                    ),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        cityName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 13.sp),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) async {
                              if (newValue == null) return;

                              setState(() {
                                selectedCity = newValue;
                                _currentCity = newValue;
                              });
                              ref.read(currentCityProvider.notifier).state =
                                  newValue;
                              await saveCity(newValue);
                            },
                            dropdownSearchData: DropdownSearchData<String>(
                              searchController: _citySearchController,
                              searchInnerWidgetHeight: 45.h,
                              searchInnerWidget: Container(
                                height: 45.h,
                                padding: EdgeInsets.only(
                                  top: 6.h,
                                  bottom: 4.h,
                                  left: 8.w,
                                  right: 8.w,
                                ),
                                child: TextFormField(
                                  controller: _citySearchController,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 8.h,
                                    ),
                                    hintText: 'Search city...',
                                    hintStyle: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.grey,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      size: 14.sp,
                                      color: Colors.grey,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF24ADD7),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              searchMatchFn: (item, searchValue) {
                                return item.value
                                    .toString()
                                    .toLowerCase()
                                    .contains(searchValue.toLowerCase());
                              },
                            ),
                            onMenuStateChange: (isOpen) {
                              if (!isOpen) {
                                _citySearchController.clear();
                              }
                            },
                          ),
                        ),
                      );
                    },
                    error: (error, stackTrace) {
                      return Center(child: Text(error.toString()));
                    },
                    loading: () => Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Builder(
            builder: (context) {
              // 1. Determine target tab category according to selectIndex
              String targetCategory = "Buy Property";
              if (selectIndex == 0) {
                targetCategory = "Buy Property";
              } else if (selectIndex == 1) {
                targetCategory = "Rent Property";
              } else if (selectIndex == 2) {
                targetCategory = "Home Services";
              } else {
                targetCategory = "Loan Services";
              }

              return getBannerState.when(
                data: (bannerData) {
                  final allBanners = bannerData.data?.list ?? [];

                  // Filter banners by tab category
                  final filteredBanners = allBanners.where((banner) {
                    final cat = (banner.tabCategory ?? "").trim().toLowerCase();
                    final target = targetCategory.toLowerCase();
                    final isActive = banner.isActive ?? true;
                    final notDeleted = banner.isDeleted != true;
                    return isActive &&
                        notDeleted &&
                        (cat == target ||
                            cat.contains(target.split(" ").first));
                  }).toList();

                  final hasDynamicBanners = filteredBanners.isNotEmpty;
                  final bannerCount = hasDynamicBanners
                      ? filteredBanners.length
                      : currentImages.length;
                  final activeDotIndex = bannerCount > 0
                      ? (currentBannerIndex % bannerCount)
                      : 0;

                  return Stack(
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 260.h,
                          viewportFraction: 1,
                          autoPlay: bannerCount > 1,
                          autoPlayInterval: const Duration(seconds: 3),
                          autoPlayAnimationDuration: const Duration(
                            milliseconds: 800,
                          ),
                          onPageChanged: (index, reason) {
                            setState(() {
                              currentBannerIndex = index;
                            });
                          },
                        ),
                        items: hasDynamicBanners
                            ? filteredBanners.map((banner) {
                                return GestureDetector(
                                  onTap: () async {
                                    if (banner.link != null &&
                                        banner.link!.trim().isNotEmpty) {
                                      final uri = Uri.tryParse(
                                        banner.link!.trim(),
                                      );
                                      if (uri != null &&
                                          await canLaunchUrl(uri)) {
                                        await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      }
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        banner.img ?? "",
                                        height: 260.h,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Container(
                                                height: 260.h,
                                                width: double.infinity,
                                                color: Colors.grey.shade200,
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Color(
                                                          0xFF24ADD7,
                                                        ),
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              );
                                            },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Image.asset(
                                                currentImages.first,
                                                height: 260.h,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                      ),

                                      /// Gradient
                                      Container(
                                        height: 260.h,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.black.withOpacity(0.6),
                                              Colors.transparent,
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                        ),
                                      ),

                                      /// TEXT CONTENT
                                      Positioned(
                                        left: 16.w,
                                        bottom: 30.h,
                                        right: 16.w,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Chip(
                                              labelPadding: EdgeInsets.zero,
                                              label: Text(
                                                selectIndex == 0
                                                    ? "Buy Property"
                                                    : selectIndex == 1
                                                    ? "Rent Property"
                                                    : selectIndex == 2
                                                    ? "Best Service"
                                                    : "Easy Loan",
                                              ),
                                              backgroundColor: Colors.white
                                                  .withOpacity(0.8),
                                            ),
                                            SizedBox(height: 6.h),
                                            Text(
                                              (banner.title != null &&
                                                      banner.title!
                                                          .trim()
                                                          .isNotEmpty)
                                                  ? banner.title!
                                                  : (selectIndex == 0
                                                        ? "Find Your Dream Property"
                                                        : selectIndex == 1
                                                        ? "Find Rental Homes"
                                                        : selectIndex == 2
                                                        ? "Best Home Services"
                                                        : "Get Instant Loan"),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              (banner.highlight != null &&
                                                      banner.highlight!
                                                          .trim()
                                                          .isNotEmpty)
                                                  ? banner.highlight!
                                                  : (selectIndex == 0
                                                        ? "Buy properties"
                                                        : selectIndex == 1
                                                        ? "Rent properties"
                                                        : selectIndex == 2
                                                        ? "Cleaning, Plumbing, Electrician & more"
                                                        : "Home, Personal & Business Loan Available"),
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList()
                            : currentImages.map((image) {
                                return Stack(
                                  children: [
                                    Image.asset(
                                      image,
                                      height: 260.h,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                    Container(
                                      height: 260.h,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withOpacity(0.6),
                                            Colors.transparent,
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 16.w,
                                      bottom: 30.h,
                                      right: 16.w,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Chip(
                                            labelPadding: EdgeInsets.zero,
                                            label: Text(
                                              selectIndex == 0
                                                  ? "Top Property"
                                                  : selectIndex == 1
                                                  ? "Best Service"
                                                  : "Easy Loan",
                                            ),
                                            backgroundColor: Colors.white
                                                .withOpacity(0.8),
                                          ),
                                          SizedBox(height: 6.h),
                                          Text(
                                            selectIndex == 0
                                                ? "Find Your Dream Property"
                                                : selectIndex == 1
                                                ? "Best Home Services"
                                                : "Get Instant Loan",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            selectIndex == 0
                                                ? "Buy properties"
                                                : selectIndex == 1
                                                ? "Rent properties"
                                                : selectIndex == 2
                                                ? "Cleaning, Plumbing, Electrician & more"
                                                : "Home, Personal & Business Loan Available",
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                      ),

                      /// 🔥 FIXED DOT INDICATOR
                      if (bannerCount > 1)
                        Positioned(
                          bottom: 10.h,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              bannerCount,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.symmetric(horizontal: 4.w),
                                width: activeDotIndex == index ? 12.w : 8.w,
                                height: activeDotIndex == index ? 12.h : 8.h,
                                decoration: BoxDecoration(
                                  color: activeDotIndex == index
                                      ? const Color(0xFF24ADD7)
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                error: (error, stackTrace) {
                  return Stack(
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 260.h,
                          viewportFraction: 1,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          autoPlayAnimationDuration: const Duration(
                            milliseconds: 800,
                          ),
                          onPageChanged: (index, reason) {
                            setState(() {
                              currentBannerIndex = index;
                            });
                          },
                        ),
                        items: currentImages.map((image) {
                          return Stack(
                            children: [
                              Image.asset(
                                image,
                                height: 260.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                height: 260.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.6),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      Positioned(
                        bottom: 10.h,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            currentImages.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              width:
                                  (currentBannerIndex % currentImages.length) ==
                                      index
                                  ? 12.w
                                  : 8.w,
                              height:
                                  (currentBannerIndex % currentImages.length) ==
                                      index
                                  ? 12.h
                                  : 8.h,
                              decoration: BoxDecoration(
                                color:
                                    (currentBannerIndex %
                                            currentImages.length) ==
                                        index
                                    ? const Color(0xFF24ADD7)
                                    : Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () {
                  return Container(
                    height: 260.h,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF24ADD7),
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // BUTTONS
          Container(
            width: double.infinity,
            height: 50.h,
            color: const Color(0xFF24ADD7),
            child: Builder(
              builder: (context) {
                if (selectIndex == 0 || selectIndex == 1) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              bottomIndex = 2;
                            });
                            ref.invalidate(getMyPropertyController);
                          },
                          child: Container(
                            height: 40.h,
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.white),
                            ),
                            child: Center(
                              child: Text(
                                '+ Add Property',
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (selectIndex == 2) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => PricePlanPage(),
                                ),
                              );
                            },
                            child: Container(
                              height: 40.h,
                              // padding: EdgeInsets.symmetric(horizontal: 15.w),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: Colors.white),
                              ),
                              child: Center(
                                child: Text(
                                  'PRICING PLANS',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15.w),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) =>
                                    const VendorRegistrationBottomSheet(),
                              );
                            },
                            child: Container(
                              height: 40.h,
                              // padding: EdgeInsets.symmetric(horizontal: 10.w),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: Colors.white),
                              ),
                              child: Center(
                                child: Text(
                                  '+ Add Vendor Registration',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => LoanServiceDetailsPage(),
                              ),
                            );
                          },
                          child: Container(
                            height: 40.h,
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.white),
                            ),
                            child: Center(
                              child: Text(
                                'Apply for Loan',
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          SizedBox(height: 15.h),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.only(left: 0, right: 0),
            child: TabBar(
              labelPadding: EdgeInsets.zero,
              indicatorPadding: EdgeInsets.zero,
              splashBorderRadius: BorderRadius.circular(20.r),
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              padding: EdgeInsets.zero,
              indicator: const BoxDecoration(),
              tabs: [
                _buildTab("Buy Property", 0),
                _buildTab("Rent Property", 1),
                _buildTab("Home Service", 2),
                _buildTab("Loan Service", 3),
              ],
            ),
          ),
          ExpandablePageView(
            controller: _tabController,
            children: [
              _buildPropertyCategoryTab(
                isBuy: true,
                categoryState: getProeprtyCategoryState,
              ),
              _buildPropertyCategoryTab(
                isBuy: false,
                categoryState: getProeprtyCategoryState,
              ),
              HomeService(),
              LoanService(),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== MY LISTINGS SCREEN ====================
  Widget MyListingsScreen() {
    final getMyPropertyProvider = ref.watch(getMyPropertyController);
    return SafeArea(
      top: false,
      child: Column(
        children: [
          // Header (Website Style Adapted for Mobile)
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10.h,
              left: 16.w,
              right: 16.w,
              bottom: 14.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "My Properties",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF1E293B),
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Manage listings, update & track status",
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade500,
                          fontSize: 11.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      bottomIndex = 2; // Add Property Tab
                    });
                  },
                  borderRadius: BorderRadius.circular(20.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF24ADD7),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF24ADD7).withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 15.sp),
                        SizedBox(width: 4.w),
                        Text(
                          "List New",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          if (getMyPropertyProvider.valueOrNull?.data?.list?.isNotEmpty ==
              true) ...[
            Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 12.h,
                bottom: 8.h,
              ),
              child: Container(
                height: 44.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchListing = value.toLowerCase();
                    });
                  },
                  style: GoogleFonts.inter(fontSize: 13.sp),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 12.w,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18.sp,
                      color: const Color(0xFF24ADD7),
                    ),
                    border: InputBorder.none,
                    hintText: "Search your listings...",
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // List / Empty State / Loading
          Expanded(
            child: RefreshIndicator(
              backgroundColor: const Color(0xFF24ADD7),
              color: Colors.white,
              onRefresh: () async {
                await ref.refresh(getMyPropertyController.future);
              },
              child: getMyPropertyProvider.when(
                data: (snap) {
                  final allProperties = snap.data?.list ?? [];
                  final filteredProperties = allProperties.where((property) {
                    final propertyType =
                        property.propertyType?.toLowerCase() ?? '';
                    final listingCategory =
                        property.listingCategory?.toLowerCase() ?? '';
                    final bedroom = property.bedRoom?.toLowerCase() ?? "";
                    final localityArea =
                        property.localityArea?.toLowerCase() ?? "";
                    final city = property.city?.toLowerCase() ?? "";

                    return propertyType.contains(searchListing) ||
                        listingCategory.contains(searchListing) ||
                        bedroom.contains(searchListing) ||
                        localityArea.contains(searchListing) ||
                        city.contains(searchListing);
                  }).toList();

                  // Empty State matching website
                  if (allProperties.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80.r,
                                height: 80.r,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFF7ED), // Orange-50 tint
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.home_work_outlined,
                                    size: 40.sp,
                                    color: const Color(0xFF24ADD7),
                                  ),
                                ),
                              ),
                              SizedBox(height: 18.h),
                              Text(
                                "No Properties Listed Yet",
                                style: GoogleFonts.inter(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "You haven't listed any properties yet. Start your journey by listing your first property today.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade500,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: 24.h),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    bottomIndex = 2;
                                  });
                                },
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  "List New Property",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF24ADD7),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                    vertical: 12.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.r),
                                  ),
                                  elevation: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  if (filteredProperties.isEmpty) {
                    return Center(
                      child: Text(
                        "No Property Found for \"$searchListing\"",
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade500,
                          fontSize: 14.sp,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      top: 8.h,
                      bottom: 24.h,
                    ),
                    itemCount: filteredProperties.length,
                    itemBuilder: (context, index) {
                      return PropertyCard(data: filteredProperties[index]);
                    },
                  );
                },
                error: (error, stackTrace) {
                  log(stackTrace.toString());
                  return Center(child: Text("Error: $error"));
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF24ADD7)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget CallUsScreen() {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Container(
            height: 90.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            color: const Color(0xFF24ADD7),
            child: Padding(
              padding: EdgeInsets.only(top: 25.h),
              child: Row(
                children: [
                  Text(
                    "Call Us",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Send us a ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: "Message",
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 6.h),

                    /// SUBTITLE
                    Text(
                      "Find our contact info to reach out to us",
                      style: TextStyle(color: Colors.black54, fontSize: 13.sp),
                    ),

                    SizedBox(height: 16.h),

                    /// CARD
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xffE8D6CC),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// WHERE WE WORK
                          Text(
                            "WHERE WE WORK FROM",
                            style: TextStyle(
                              fontSize: 12.sp,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 10.h),

                          Text(
                            "PropertyLe Innovation – One Call, One Click, Anytime.",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13.sp,
                            ),
                          ),

                          SizedBox(height: 8.h),

                          /// ✅ FIXED ALIGNMENT
                          Text(
                            "B Raj Dhaakad: 66 Kailash Vihar City Centre",
                            style: TextStyle(fontSize: 13.sp, height: 1.4),
                          ),
                          Text(
                            "Gwalior, Madhya Pradesh",
                            style: TextStyle(fontSize: 13.sp, height: 1.4),
                          ),
                          Text(
                            "Pin 474012",
                            style: TextStyle(fontSize: 13.sp, height: 1.4),
                          ),

                          SizedBox(height: 16.h),

                          /// CALL + EMAIL
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// CALL
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final Uri url = Uri(
                                      scheme: 'tel',
                                      path: '9171719060',
                                    );
                                    await launchUrl(url);
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "CALL / TEXT",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "+91-9171719060",
                                        style: TextStyle(fontSize: 13.sp),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(width: 20.w),

                              /// EMAIL
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "EMAIL US",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      "Info@property.com",
                                      style: TextStyle(fontSize: 13.sp),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16.h),

                          /// SOCIALS
                          Text(
                            "OUR SOCIALS",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 10.h),

                          Row(
                            children: [
                              /// INSTAGRAM
                              GestureDetector(
                                onTap: () async {
                                  final url =
                                      "https://www.instagram.com/propertyleindia?igsh=MWJ4eG8yendnODg1Mw%3D%3D&utm_source=qr";
                                  await launchUrl(
                                    Uri.parse(url),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10.w),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [Colors.pink, Colors.orange],
                                        ),
                                      ),
                                      child: Image.asset(
                                        "assets/insta.png",
                                        height: 18.h,
                                        width: 18.w,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      "Instagram",
                                      style: TextStyle(fontSize: 13.sp),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: 20.w),
                              GestureDetector(
                                onTap: () async {
                                  final String msg =
                                      "Hi, I am interested in your property services.";
                                  final Uri url = Uri.parse(
                                    "whatsapp://send?phone=919171719060&text=${Uri.encodeComponent(msg)}",
                                  );
                                  try {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } catch (e) {
                                    final Uri webUrl = Uri.parse(
                                      "https://wa.me/919171719060?text=${Uri.encodeComponent(msg)}",
                                    );
                                    await launchUrl(
                                      webUrl,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10.w),
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          "assets/Svg/whatsapp.svg",
                                          width: 20.w,
                                          height: 20.h,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      "WhatsApp",
                                      style: TextStyle(fontSize: 13.sp),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          GestureDetector(
                            onTap: () async {
                              final Uri url = Uri(
                                scheme: 'tel',
                                path: '9171719060',
                              );
                              await launchUrl(url);
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.call,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text("Call", style: TextStyle(fontSize: 13.sp)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Form(
                      key: _formKeyContactUs,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Send Enquiry",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff0E1A35),
                            ),
                          ),
                          SizedBox(height: 15.h),
                          Text(
                            "Enter Your Email",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff0E1A35),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.mail_outline,
                                color: Colors.grey,
                              ),
                              hintStyle: TextStyle(fontSize: 14.sp),
                              hintText: "Email",
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.red.shade300,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.red.shade300,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email is required";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15.h),
                          Text(
                            "Enter Your Name",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff0E1A35),
                            ),
                          ),

                          SizedBox(height: 10.h),

                          TextFormField(
                            controller: nameController,
                            keyboardType: TextInputType.name,

                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.grey,
                              ),
                              hintStyle: TextStyle(fontSize: 14.sp),
                              hintText: "Name",
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.red.shade300,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.red.shade300,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Name is required";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15.h),
                          Text(
                            "Mobile Number",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff0E1A35),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          TextFormField(
                            maxLength: 10,
                            controller: phoneController,
                            keyboardType: TextInputType.number,

                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.call_outlined,
                                color: Colors.grey,
                              ),
                              counterText: "",
                              hintStyle: TextStyle(fontSize: 14.sp),
                              hintText: "Mobile Number",
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.red.shade300,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.red.shade300,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Mobile Number is required";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15.h),
                          Text(
                            "Subject",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff0E1A35),
                            ),
                          ),

                          SizedBox(height: 10.h),

                          TextFormField(
                            controller: subjectController,
                            keyboardType: TextInputType.text,

                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.subject_outlined,
                                color: Colors.grey,
                              ),
                              hintStyle: TextStyle(fontSize: 14.sp),
                              hintText: "Subject",
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.red.shade300,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.red.shade300,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Subject is required";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15.h),
                          Text(
                            "Message",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff0E1A35),
                            ),
                          ),

                          SizedBox(height: 10.h),

                          TextFormField(
                            controller: messageController,
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 5,

                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.messenger_outline,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.red.shade300,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.red.shade300,
                                ),
                              ),
                              hintStyle: TextStyle(fontSize: 14.sp),
                              hintText: "Message",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Message is required";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15.h),
                          Text(
                            "Location",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff0E1A35),
                            ),
                          ),

                          SizedBox(height: 10.h),
                          TextFormField(
                            controller: locationController,
                            keyboardType: TextInputType.text,

                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.red.shade300,
                                ),
                              ),
                              hintStyle: TextStyle(fontSize: 14.sp),
                              hintText: "Location",
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: Colors.grey,
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(
                                  color: Colors.red.shade300,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Location is required";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),

                          /// ==== SIGN IN BUTTON ====
                          Center(
                            child: GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () async {
                                      if (!_formKeyContactUs.currentState!
                                          .validate()) {
                                        return;
                                      }
                                      setState(() {
                                        isLoading = true;
                                      });
                                      final body = ContactUsBodyModel(
                                        email: emailController.text,
                                        name: nameController.text,
                                        phone: phoneController.text,
                                        subject: subjectController.text,
                                        message: messageController.text,
                                        location: locationController.text,
                                      );
                                      try {
                                        final response = await ref.read(
                                          contactUsController(body).future,
                                        );
                                        if (response.code == 0 ||
                                            response.error == false) {
                                          Fluttertoast.showToast(
                                            msg: response.message,
                                          );

                                          emailController.clear();
                                          nameController.clear();
                                          phoneController.clear();
                                          subjectController.clear();
                                          messageController.clear();
                                          locationController.clear();
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: response.message,
                                          );
                                        }
                                      } catch (e) {
                                        log(e.toString());
                                      } finally {
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    },
                              child: Container(
                                height: 50.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Color(0xFF24ADD7),
                                  borderRadius: BorderRadius.circular(40.r),
                                ),
                                child: Center(
                                  child: isLoading
                                      ? Center(
                                          child: SizedBox(
                                            height: 20.h,
                                            width: 20.w,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          "Submit",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget SavedScreen() {
    final likeProvider = ref.watch(likePropertyController);
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Container(
            height: 90.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            color: const Color(0xFF24ADD7),
            child: Padding(
              padding: EdgeInsets.only(top: 25.h),
              child: Row(
                children: [
                  Text(
                    "Saved Property",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              backgroundColor: Color(0xFF24ADD7),
              color: Colors.white,
              onRefresh: () async {
                // सबसे साफ तरीका
                await ref.refresh(likePropertyController.future);
                // या
                // ref.invalidate(getMyPropertyController);
              },
              child: likeProvider.when(
                data: (snap) {
                  if (snap.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: 80.sp,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16.h),

                            Text(
                              "No saved properties",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            SizedBox(height: 8.h),

                            Text(
                              "You haven’t saved any properties yet.\nTap the bookmark icon to save your favorites.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                            ),

                            SizedBox(height: 20.h),

                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  bottomIndex = 0;
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SearchResultScreen(selectedCity),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Explore Properties",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF24ADD7),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 12.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snap.data!.length,
                    itemBuilder: (context, index) {
                      return PropertyCardSaved(data: snap.data![index]);
                    },
                  );
                },
                error: (error, stackTrace) {
                  log(stackTrace.toString());
                  log(error.toString());
                  return Center(child: Text(error.toString()));
                },
                loading: () => Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _tabController.index == index;
    return Container(
      margin: EdgeInsets.only(right: 0, left: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF24ADD7) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isSelected
              ? Colors.white.withOpacity(0.25)
              : Color(0xFF24ADD7),
          width: 0.95.w,
        ),
      ),
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: isSelected ? Colors.white : const Color(0xFF24ADD7),
          fontSize: 12.sp,
        ),
      ),
    );
  }

  // ==================== PROPERTY CATEGORIES (WEBSITE STYLE) ====================
  Widget _buildPropertyCategoryTab({
    required bool isBuy,
    required AsyncValue<cat_model.GetPropertyCategoriyModel> categoryState,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        children: [
          // MY PROPERTIES BUTTON (matching website header)
          InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () {
              setState(() {
                bottomIndex = 1;
              });
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 13.h),
              decoration: BoxDecoration(
                color: const Color(0xFF24ADD7),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF24ADD7).withOpacity(0.32),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_work_outlined,
                    size: 20.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "MY PROPERTIES",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 14.h),

          // Categories Grid
          categoryState.when(
            data: (data) {
              final allItems = data.data?.list ?? [];
              final filtered = allItems.where((item) {
                if (item.status == false ||
                    item.isDisable == true ||
                    item.isDeleted == true) {
                  return false;
                }
                final type =
                    (item.rawCategoryType ?? item.categoryType?.name ?? '')
                        .toLowerCase();
                if (isBuy) {
                  return type == 'buy' ||
                      type == 'sell' ||
                      type == 'both' ||
                      type.isEmpty;
                } else {
                  return type == 'rent' || type == 'both' || type.isEmpty;
                }
              }).toList();

              final displayList = filtered.isNotEmpty
                  ? filtered
                  : _getDefaultCategoryItems(isBuy);

              return _buildCategoryGrid(displayList, isBuy);
            },
            loading: () => _buildCategoryLoadingGrid(),
            error: (_, __) =>
                _buildCategoryGrid(_getDefaultCategoryItems(isBuy), isBuy),
          ),

          SizedBox(height: 14.h),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(List<cat_model.ListElement> items, bool isBuy) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.98,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildPropertyCategoryCard(items[index], isBuy);
      },
    );
  }

  Widget _buildPropertyCategoryCard(cat_model.ListElement item, bool isBuy) {
    final name = (item.name ?? "").trim();
    final imageUrl = item.image ?? "";
    final isNetwork =
        imageUrl.startsWith("http://") || imageUrl.startsWith("https://");

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () {
        final propName = name.isNotEmpty
            ? name
            : (item.propertyTypeKey ?? "Property");
        String propKey =
            (item.propertyTypeKey != null && item.propertyTypeKey!.isNotEmpty)
            ? item.propertyTypeKey!
            : propName.toLowerCase();
        if (propKey == "house") propKey = "Home";
        if (propKey == "flats" ||
            propKey == "appartment" ||
            propKey == "apartment") {
          propKey = "apartment";
        }
        if (propKey == "plots") propKey = "land";

        final rawCity =
            selectedCity ?? _currentCity ?? ref.read(currentCityProvider) ?? "";

        // Check if rawCity exists in available city list (getCityController)
        String validCity = "";
        final citiesData = ref.read(getCityController).value?.data ?? [];
        try {
          final found = citiesData.firstWhere(
            (c) =>
                c.cityName?.trim().toLowerCase() ==
                rawCity.trim().toLowerCase(),
          );
          validCity = found.cityName ?? "";
        } catch (_) {
          validCity = "";
        }

        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ListingPage(
              initialData: ListElement(
                property: propName.toLowerCase() == "commercial"
                    ? "commercial"
                    : "residential",
                propertyType: propKey,
                listingCategory: isBuy ? "buy" : "rent",
                city: validCity,
              ),
            ),
          ),
        );

        // Navigator.push(
        //   context,
        //   CupertinoPageRoute(
        //     builder: (context) => PropertyPageCat(property: property),
        //   ),
        // );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Card Image
              if (isNetwork)
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            color: const Color(0xFF24ADD7),
                            strokeWidth: 1.5.w,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFE8F6FA),
                      child: Center(
                        child: Icon(
                          Icons.apartment_rounded,
                          color: const Color(0xFF24ADD7),
                          size: 32.sp,
                        ),
                      ),
                    );
                  },
                )
              else if (imageUrl.isNotEmpty)
                Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFE8F6FA),
                      child: Center(
                        child: Icon(
                          Icons.apartment_rounded,
                          color: const Color(0xFF24ADD7),
                          size: 32.sp,
                        ),
                      ),
                    );
                  },
                )
              else
                Container(
                  color: const Color(0xFFE8F6FA),
                  child: Center(
                    child: Icon(
                      Icons.apartment_rounded,
                      color: const Color(0xFF24ADD7),
                      size: 32.sp,
                    ),
                  ),
                ),

              // Dark Gradient Overlay (website style)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.25),
                      Colors.black.withOpacity(0.85),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.35, 0.65, 1.0],
                  ),
                ),
              ),

              // Bottom Title and Contact button
              Positioned(
                left: 10.w,
                right: 10.w,
                bottom: 10.h,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        name.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF24ADD7),
                        borderRadius: BorderRadius.circular(6.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF24ADD7).withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        "Contact",
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryLoadingGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.98,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        );
      },
    );
  }

  List<cat_model.ListElement> _getDefaultCategoryItems(bool isBuy) {
    return [
      cat_model.ListElement(
        name: "House",
        image:
            "https://propertyleinnovation.com/_next/image?url=%2Fassets%2Fhome%2Fbrings1.png&w=1080&q=75",
      ),
      cat_model.ListElement(
        name: "Apartment",
        image:
            "https://propertyleinnovation.com/_next/image?url=%2Fassets%2Fhome%2Fbrings2.png&w=1080&q=75",
      ),
      cat_model.ListElement(
        name: "TownHouse",
        image:
            "https://propertyleinnovation.com/_next/image?url=%2Fassets%2Fhome%2Fbrings3.png&w=1080&q=75",
      ),
      cat_model.ListElement(
        name: "Plots",
        image:
            "https://propertyleinnovation.com/_next/image?url=%2Fassets%2Fhome%2Fbrings4.png&w=1080&q=75",
      ),
      cat_model.ListElement(
        name: "Commercial",
        image:
            "https://propertyleinnovation.com/_next/image?url=%2Fassets%2Fhome%2Fbrings5.png&w=1080&q=75",
      ),
      cat_model.ListElement(
        name: "PentHouse",
        image:
            "https://propertyleinnovation.com/_next/image?url=%2Fassets%2Fhome%2Fbrings6.png&w=1080&q=75",
      ),
      cat_model.ListElement(
        name: "Condos",
        image:
            "https://propertyleinnovation.com/_next/image?url=%2Fassets%2Fhome%2Fbrings7.png&w=1080&q=75",
      ),
      cat_model.ListElement(
        name: "Studio",
        image:
            "https://propertyleinnovation.com/_next/image?url=%2Fassets%2Fhome%2Fbrings8.png&w=1080&q=75",
      ),
      cat_model.ListElement(
        name: "Villa",
        image:
            "https://propertyleinnovation.com/_next/image?url=%2Fassets%2Fhome%2Fbrings9.png&w=1080&q=75",
      ),
    ];
  }
}

// ==================== PROPERTY MODEL ====================
class Property {
  final String propertyType;
  final String propertyCategory;
  final String listingCategory;
  final String city;
  final String locality;
  final String price;
  final String bedrooms;
  final String bathrooms;
  final String area;
  final String furnishing;
  final List<String> amenities;
  final List<Map<String, String>> aroundProject;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String description;

  Property({
    required this.propertyType,
    required this.propertyCategory,
    required this.listingCategory,
    required this.city,
    required this.locality,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.furnishing,
    required this.amenities,
    required this.aroundProject,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.description,
  });
}

// ==================== PROPERTY CARD ====================
// ==================== PROPERTY CARD (WEBSITE STYLE FOR MOBILE) ====================
class PropertyCard extends ConsumerStatefulWidget {
  final ListElement data;
  const PropertyCard({super.key, required this.data});

  @override
  ConsumerState<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends ConsumerState<PropertyCard> {
  bool isDeleting = false;
  bool isTogglingVisibility = false;

  String _formatPrice(String? priceStr) {
    if (priceStr == null || priceStr.isEmpty) return "Price on Request";
    final cleanStr = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
    final t = double.tryParse(cleanStr);
    if (t == null) return "₹$priceStr";
    if (t >= 10000000) {
      return "₹${(t / 10000000).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')} Cr";
    } else if (t >= 100000) {
      return "₹${(t / 100000).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')} L";
    } else if (t >= 1000) {
      return "₹${(t / 1000).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')} K";
    } else {
      return "₹${t.toInt()}";
    }
  }

  Future<void> _toggleVisibility() async {
    final status = (widget.data.status ?? "").toLowerCase();
    if (status == "pending" || status == "rejected") {
      Fluttertoast.showToast(
        msg: "Cannot change visibility while under review or rejected.",
      );
      return;
    }

    setState(() => isTogglingVisibility = true);
    try {
      final body = UpdateDesablePropertyBodyModel(id: widget.data.id);
      final service = APIStateNetwork(createDio());
      final res = await service.updatePropertyDisable(body);

      if (res.error == false || res.code == 0) {
        Fluttertoast.showToast(msg: "Property status updated successfully!");
        ref.invalidate(getMyPropertyController);
      } else {
        Fluttertoast.showToast(msg: "Failed to update status.");
      }
    } catch (e) {
      log("updatePropertyDisable error: $e");
    } finally {
      if (mounted) setState(() => isTogglingVisibility = false);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              "Delete Property",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to delete this property?",
          style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              setState(() => isDeleting = true);
              try {
                final body = MyListingProperyDeleteBodyModel(
                  id: widget.data.id.toString(),
                );
                final service = APIStateNetwork(createDio());
                final res = await service.myListingPropertyDelete(body);
                if (res.code == 0 && res.error == false) {
                  Fluttertoast.showToast(
                    msg: res.message ?? "Property deleted successfully!",
                  );
                  ref.invalidate(getMyPropertyController);
                } else {
                  Fluttertoast.showToast(
                    msg: res.message ?? "Failed to delete property.",
                  );
                }
              } catch (e) {
                log("deleteProperty error: $e");
                Fluttertoast.showToast(msg: "Failed to delete property.");
              } finally {
                if (mounted) setState(() => isDeleting = false);
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = (widget.data.status ?? "pending").toLowerCase();
    final bool isDisabled = widget.data.isDisable == true;
    final bool isRejected = status == "rejected";
    final bool isPending = status == "pending";

    // Matching Website status badge logic
    String badgeLabel;
    Color badgeBg;
    Color badgeTextColor;
    IconData badgeIcon;

    if (isDisabled) {
      badgeLabel = "INACTIVE";
      badgeBg = Colors.grey.shade100;
      badgeTextColor = Colors.grey.shade600;
      badgeIcon = Icons.visibility_off_outlined;
    } else {
      switch (status) {
        case "active":
        case "approved":
          badgeLabel = "ACTIVE";
          badgeBg = const Color(0xFFDCFCE7); // green-50
          badgeTextColor = const Color(0xFF16A34A); // green-600
          badgeIcon = Icons.check_circle_outline;
          break;
        case "pending":
          badgeLabel = "UNDER REVIEW";
          badgeBg = const Color(0xFFFEF9C3); // yellow-50
          badgeTextColor = const Color(0xFFCA8A04); // yellow-600
          badgeIcon = Icons.access_time_rounded;
          break;
        case "rejected":
          badgeLabel = "REJECTED";
          badgeBg = const Color(0xFFFEE2E2); // red-50
          badgeTextColor = const Color(0xFFDC2626); // red-600
          badgeIcon = Icons.cancel_outlined;
          break;
        case "sold":
          badgeLabel = "SOLD OUT";
          badgeBg = const Color(0xFFDBEAFE); // blue-50
          badgeTextColor = const Color(0xFF2563EB); // blue-600
          badgeIcon = Icons.sell_outlined;
          break;
        default:
          badgeLabel = status.toUpperCase();
          badgeBg = Colors.grey.shade100;
          badgeTextColor = Colors.grey.shade600;
          badgeIcon = Icons.info_outline;
      }
    }

    final String title =
        "${widget.data.bedRoom != null && widget.data.bedRoom!.isNotEmpty ? '${widget.data.bedRoom} BHK ' : ''}${widget.data.propertyType ?? 'Property'} in ${widget.data.localityArea?.isNotEmpty == true ? widget.data.localityArea : widget.data.city ?? ''}";
    final String location =
        "${widget.data.localityArea ?? ''}, ${widget.data.city ?? ''}"
            .trim()
            .replaceAll(RegExp(r'^,\s*|,\s*$'), '');

    final bool isUpdateDisabled = isRejected || isDisabled;
    final bool isCustomer =
        widget.data.handelPropertyBy?.toLowerCase() == "customer";

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isRejected ? Colors.red.shade200 : Colors.grey.shade200,
          width: isRejected ? 1.5.w : 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= IMAGE STACK =================
          Stack(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => PerticulerPropertyPage(
                        propertyId: widget.data.slug.toString(),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(15.r),
                  ),
                  child: SizedBox(
                    height: 180.h,
                    width: double.infinity,
                    child:
                        (widget.data.uploadedPhotos != null &&
                            widget.data.uploadedPhotos!.isNotEmpty)
                        ? Image.network(
                            widget.data.uploadedPhotos!.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: Center(
                                child: Icon(
                                  Icons.home_outlined,
                                  size: 40.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Icon(
                                Icons.home_outlined,
                                size: 40.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                ),
              ),

              // Gradient Overlay for Asking Price
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(15.r),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.75),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Status Badge (Top-Left)
              Positioned(
                top: 10.h,
                left: 10.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: badgeBg.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: badgeTextColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 12.sp, color: badgeTextColor),
                      SizedBox(width: 4.w),
                      Text(
                        badgeLabel,
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: badgeTextColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Listing Category (Top-Right)
              Positioned(
                top: 10.h,
                right: 10.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF24ADD7),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    (widget.data.listingCategory ?? "BUY").toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Asking Price (Bottom-Left)
              Positioned(
                bottom: 10.h,
                left: 12.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Asking Price",
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      _formatPrice(widget.data.price),
                      style: GoogleFonts.inter(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ================= CARD BODY =================
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4.h),

                // Location
                if (location.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14.sp,
                        color: const Color(0xFF24ADD7),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                ],

                // Grid 2-chips (Type and Size)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 6.h,
                          horizontal: 8.w,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 6.r,
                              height: 6.r,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Flexible(
                              child: Text(
                                widget.data.bedRoom != null &&
                                        widget.data.bedRoom!.isNotEmpty
                                    ? "${widget.data.bedRoom} BHK"
                                    : (widget.data.propertyType ?? "Property"),
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 6.h,
                          horizontal: 8.w,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.square_foot,
                              size: 14.sp,
                              color: Colors.grey.shade500,
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                widget.data.area != null &&
                                        widget.data.area!.isNotEmpty
                                    ? "${widget.data.area} sqft"
                                    : "N/A",
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),
                Divider(height: 1, color: Colors.grey.shade200),
                SizedBox(height: 10.h),

                // ================= VISIBILITY TOGGLE (WEBSITE FEATURE) =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isDisabled
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 16.sp,
                          color: isDisabled
                              ? Colors.grey
                              : const Color(0xFF24ADD7),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "Visibility (Active / Inactive)",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                    if (isTogglingVisibility)
                      SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF24ADD7),
                        ),
                      )
                    else
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: !isDisabled,
                          activeColor: const Color(0xFF24ADD7),
                          onChanged: (isPending || isRejected)
                              ? null
                              : (_) => _toggleVisibility(),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 8.h),

                // ================= ACTION BUTTONS =================
                Row(
                  children: [
                    // UPDATE BUTTON
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 38.h,
                        child: ElevatedButton.icon(
                          onPressed: isUpdateDisabled
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CreatePropertyScreen(
                                            widget.data,
                                            fromBottomNav: false,
                                          ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isUpdateDisabled
                                ? Colors.grey.shade200
                                : const Color(0xFF24ADD7),
                            foregroundColor: isUpdateDisabled
                                ? Colors.grey.shade400
                                : Colors.white,
                            elevation: isUpdateDisabled ? 0 : 2,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          icon: Icon(Icons.edit_outlined, size: 14.sp),
                          label: Text(
                            "Update",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // QUERIES BUTTON (if Customer listed)
                    if (isCustomer) ...[
                      SizedBox(width: 8.w),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 38.h,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Fluttertoast.showToast(msg: "Queries feature");
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            icon: Icon(
                              Icons.question_answer_outlined,
                              size: 14.sp,
                              color: Colors.grey.shade700,
                            ),
                            label: Text(
                              "Queries",
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    SizedBox(width: 8.w),

                    // DELETE BUTTON
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 38.h,
                        child: ElevatedButton.icon(
                          onPressed: isDeleting ? null : _confirmDelete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          icon: isDeleting
                              ? SizedBox(
                                  width: 14.r,
                                  height: 14.r,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(Icons.delete_outline, size: 14.sp),
                          label: Text(
                            "Delete",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Rejected Needs Attention Warning
                if (isRejected) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.error_outline, size: 14.sp, color: Colors.red),
                      SizedBox(width: 4.w),
                      Text(
                        "Needs attention - Listing was rejected",
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PropertyCardSaved extends StatelessWidget {
  final Datum data; // Aapka model class yaha aayega
  const PropertyCardSaved({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF24ADD7);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image Section with Price Badge
          Stack(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => PerticulerPropertyPage(
                        propertyId: data.propertyId!.slug.toString(),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                  child: Image.network(
                    data.propertyId!.uploadedPhotos![0],
                    // API se image
                    height: 180.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 180.h,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                            strokeWidth: 1.w,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stack) => Container(
                      height: 180.h,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              ),
              // Price Badge
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "₹${data.propertyId!.price}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 2. Details Section
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      //property.propertyType!.toUpperCase(),
                      data.propertyId!.propertyType!.toUpperCase(),
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                    Text(
                      "Status: ${data.propertyId!.status}",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  //property.propertyAddress ?? "",
                  data.propertyId!.propertyAddress ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text(
                      "${data.propertyId!.city}",
                      style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                    ),
                  ],
                ),
                Divider(height: 20.h),
                // 3. Icons Row (Area, Bathrooms, Furnishing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIconDetail(
                      Icons.square_foot,
                      "${data.propertyId!.area} sqft",
                    ),
                    _buildIconDetail(
                      Icons.bathtub_outlined,
                      "${data.propertyId!.bathrooms} Bath",
                    ),
                    _buildIconDetail(Icons.chair_outlined, "Semi-Furnished"),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildIconDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey[600]),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
        ),
      ],
    );
  }
}

// ==================== MAIN STATE CLASS ====================
class HomeService extends ConsumerStatefulWidget {
  const HomeService({super.key});

  @override
  ConsumerState<HomeService> createState() => _HomeServiceState();
}

class _HomeServiceState extends ConsumerState<HomeService> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final homeServiceProvider = ref.watch(homeServiceCategoryController);
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: 20.h + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              style: TextStyle(fontSize: 14.sp),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12.h,
                  horizontal: 16.w,
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIconConstraints: BoxConstraints(
                  minWidth: 40.w,
                  minHeight: 30.h,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20.sp,
                  color: const Color(0xFF24ADD7),
                ),
                hintText: "Search Home Services...",
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade400,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.w,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                  borderSide: const BorderSide(
                    color: Color(0xFF24ADD7),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const MyrequestPage(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 13.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF24ADD7),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF24ADD7).withOpacity(0.32),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 20.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "MY REQUESTS",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 6.h),

          /// 🛠 SERVICES GRID
          homeServiceProvider.when(
            data: (service) {
              final filteredServices = (service.data?.list ?? []).where((item) {
                final name = (item.name ?? '').toLowerCase();
                return name.contains(searchQuery);
              }).toList();

              if (filteredServices.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48.sp,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "No Services Found",
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.95,
                  crossAxisSpacing: 14.w,
                  mainAxisSpacing: 14.h,
                ),
                itemCount: filteredServices.length,
                itemBuilder: (context, index) {
                  final item = filteredServices[index];
                  final hasRating = (item.averageRating ?? 0) > 0;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16.r),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                              HomeServiceDetailsPage(id: item.id.toString()),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            /// Card Image
                            Image.network(
                              item.image ?? "",
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: Center(
                                        child: SizedBox(
                                          height: 20.h,
                                          width: 20.w,
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF24ADD7),
                                            strokeWidth: 1.5.w,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade300,
                                  child: Center(
                                    child: Icon(
                                      Icons.handyman_outlined,
                                      color: Colors.grey,
                                      size: 30.sp,
                                    ),
                                  ),
                                );
                              },
                            ),

                            /// Dark Gradient Overlay (Matching Website Card)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.25),
                                    Colors.black.withOpacity(0.85),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.35, 0.65, 1.0],
                                ),
                              ),
                            ),

                            /// Top Rating Badge (if rating exists)
                            if (hasRating)
                              Positioned(
                                top: 8.h,
                                right: 8.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.white24,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 11,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        (item.averageRating ?? 0)
                                            .toStringAsFixed(1),
                                        style: GoogleFonts.inter(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            /// Bottom Bar: Title + "Contact" Button
                            Positioned(
                              left: 10.w,
                              right: 10.w,
                              bottom: 10.h,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    (item.name ?? "").toUpperCase(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.4,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.8),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if ((item.totalReviews ?? 0) > 0)
                                        Text(
                                          "${item.totalReviews} reviews",
                                          style: GoogleFonts.inter(
                                            fontSize: 9.sp,
                                            color: Colors.white70,
                                          ),
                                        )
                                      else
                                        const SizedBox.shrink(),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF24ADD7),
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF24ADD7,
                                              ).withOpacity(0.4),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          "Contact",
                                          style: GoogleFonts.inter(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
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
                    ),
                  );
                },
              );
            },
            error: (error, stackTrace) {
              log(stackTrace.toString());
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Text(
                    error.toString(),
                    style: TextStyle(color: Colors.red.shade400),
                  ),
                ),
              );
            },
            loading: () {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                itemCount: 4,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.95,
                  crossAxisSpacing: 14.w,
                  mainAxisSpacing: 14.h,
                ),
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget pricingCard() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xff111111),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: Text("\$", style: TextStyle(color: Colors.white)),
        ),
        SizedBox(height: 10),
        Text(
          'Affordable Pricing',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Quality service doesn’t have to be costly; we offer transparent, fair pricing on every job.',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    ),
  );
}

class ServiceCard extends StatelessWidget {
  final String title;
  final String desc;
  final String imageUrl;

  const ServiceCard({
    super.key,
    required this.title,
    required this.desc,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ICON / IMAGE
          SizedBox(
            height: 60,
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
          const SizedBox(height: 14),

          // TITLE
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),

          const SizedBox(height: 6),

          // DESCRIPTION
          Text(
            desc,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class FeaturedProject extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;

  const FeaturedProject({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Stack(
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(color: Colors.black54),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoanService extends ConsumerStatefulWidget {
  const LoanService({super.key});

  @override
  ConsumerState<LoanService> createState() => _LoanServiceState();
}

class _LoanServiceState extends ConsumerState<LoanService> {
  String searchLoan = '';

  final List<Map<String, String>> loanTypes = [
    {"title": "HOME LOAN", "image": "assets/png/home.jpeg"},
    {"title": "CAR LOAN", "image": "assets/png/car.jpeg"},
    {"title": "PERSONAL LOAN", "image": "assets/png/personal.jpeg"},
    {"title": "BUSINESS LOAN", "image": "assets/png/business.jpeg"},
    {"title": "EDUCATION LOAN", "image": "assets/png/education.jpeg"},
    {"title": "GOLD LOAN", "image": "assets/png/gold.jpeg"},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => MyLoanRequestsPage(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 45.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF24ADD7),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "MY LOAN REQUESTS",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: loanTypes.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.98,
              ),
              itemBuilder: (context, index) {
                final item = loanTypes[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => LoanServiceDetailsPage(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.grey.shade200,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          item["image"]!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: Colors.grey.shade300);
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 70.h,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10.h,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              Text(
                                item["title"]!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 24.w),
                                padding: EdgeInsets.symmetric(vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF24ADD7),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Contact",
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
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
          ],
        ),
      ),
    );
  }
}

/// 🔹 Model
class LoanModel {
  final String title;
  final IconData icon;

  LoanModel({required this.title, required this.icon});
}

/// 🔹 Data
final List<LoanModel> loanList = [
  LoanModel(title: "Home Loan", icon: Icons.home),
  LoanModel(title: "Car Loan", icon: Icons.directions_car),
  LoanModel(title: "Two-Wheeler Loan", icon: Icons.motorcycle),
  LoanModel(title: "Indian Bank", icon: Icons.account_balance),
  LoanModel(title: "Education Loan", icon: Icons.school),
  LoanModel(title: "Gold Loan", icon: Icons.currency_exchange),
  LoanModel(title: "Property Loan", icon: Icons.apartment),
  LoanModel(title: "Personal Loan", icon: Icons.person),
];

/// 🔹 Models
class WorkModel {
  final String title;
  final String desc;
  final IconData icon;

  WorkModel({required this.title, required this.desc, required this.icon});
}

/// 🔹 Data
final List<WorkModel> workSteps = [
  WorkModel(
    title: "Fill Online Form",
    desc: "Fill an online form to view the best offers.",
    icon: Icons.edit_document,
  ),
  WorkModel(
    title: "Expert Assistance",
    desc: "Our executive helps you choose best offer.",
    icon: Icons.support_agent,
  ),
  WorkModel(
    title: "Submit Documents",
    desc: "Pick up documents at your doorstep.",
    icon: Icons.file_copy,
  ),
  WorkModel(
    title: "Bank Approval",
    desc: "Bank reviews your application & confirms.",
    icon: Icons.verified,
  ),
];

/// 🔹 Models & Data
class InfoModel {
  final String title;
  final String desc;
  final String image;

  InfoModel(this.title, this.desc, this.image);
}

final List<InfoModel> topCards = [
  InfoModel(
    "Personalized Deals",
    "Discover home loan offers for your needs",
    "assets/Rectangle 113 (1).png",
  ),
  InfoModel(
    "Government Employees",
    "Special schemes for government staff",
    "assets/Rectangle 113 (2).png",
  ),

  InfoModel(
    "Self Employed",
    "Quick approval for self employed",
    "assets/Rectangle 113.png",
  ),

  InfoModel(
    "Cash Income",
    "Low documentation for cash income",
    "assets/Rectangle 113 (3).png",
  ),
];

class VendorRegistrationBottomSheet extends ConsumerStatefulWidget {
  const VendorRegistrationBottomSheet({super.key});

  @override
  ConsumerState<VendorRegistrationBottomSheet> createState() =>
      _VendorRegistrationBottomSheetState();
}

class _VendorRegistrationBottomSheetState
    extends ConsumerState<VendorRegistrationBottomSheet> {
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final expertiseController = TextEditingController();
  final expertiseFocusNode = FocusNode();

  final _formKeyVendor = GlobalKey<FormState>();

  bool isLoading = false;

  List<String> selectedExpertiseNames = [];
  List<String> selectedExpertiseIds = [];

  @override
  void initState() {
    super.initState();
    expertiseFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    expertiseController.dispose();
    expertiseFocusNode.dispose();
    emailController.dispose();
    phoneController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeServiceProvider = ref.watch(homeServiceCategoryController);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xffF4F6F9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKeyVendor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 45.w,
                    height: 5.h,
                    margin: EdgeInsets.only(bottom: 20.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Registration",
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Fill in your details below",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 25.h),

                /// NAME
                fieldTitle("Full Name"),
                buildField(
                  controller: nameController,
                  hint: "Enter full name",
                  keyboard: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Name is required";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 15.h),

                /// EMAIL
                fieldTitle("EMAIL ADDRESS"),
                buildField(
                  controller: emailController,
                  hint: "Enter email",
                  keyboard: TextInputType.emailAddress,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return "Email is required";
                  //   }
                  //   if (!RegExp(
                  //     r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  //   ).hasMatch(value)) {
                  //     return "Enter valid email";
                  //   }
                  //   return null;
                  // },
                ),

                SizedBox(height: 15.h),

                /// PHONE
                fieldTitle("WHATSAPP / MOBILE"),
                buildField(
                  controller: phoneController,
                  hint: "Enter phone number",
                  keyboard: TextInputType.phone,
                  counterText: "",
                  maxLength: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Phone number required";
                    }
                    if (value.length < 10) {
                      return "Enter valid number";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 15.h),

                /// DROPDOWN
                fieldTitle("YOUR EXPERTISE"),

                FormField(
                  validator: (value) {
                    if (selectedExpertiseNames.isEmpty) {
                      return "Expertise is required";
                    }
                    return null;
                  },

                  builder: (FormFieldState<String> state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        homeServiceProvider.when(
                          data: (data) {
                            final expertiseList =
                                data.data?.list
                                    ?.map((e) => e.name ?? "")
                                    .where((e) => e.isNotEmpty)
                                    .toList() ??
                                [];
                            final text = expertiseController.text.toLowerCase();
                            final filteredList = text.isEmpty
                                ? expertiseList
                                : expertiseList
                                      .where(
                                        (e) => e.toLowerCase().contains(text),
                                      )
                                      .toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (selectedExpertiseNames.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Wrap(
                                      spacing: 8.0,
                                      runSpacing: 4.0,
                                      children: List.generate(
                                        selectedExpertiseNames.length,
                                        (index) {
                                          return Chip(
                                            label: Text(
                                              selectedExpertiseNames[index],
                                            ),
                                            deleteIcon: const Icon(
                                              Icons.close,
                                              size: 16,
                                            ),
                                            onDeleted: () {
                                              setState(() {
                                                selectedExpertiseNames.removeAt(
                                                  index,
                                                );
                                                selectedExpertiseIds.removeAt(
                                                  index,
                                                );
                                              });
                                              state.didChange(
                                                selectedExpertiseNames.join(
                                                  ", ",
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                TextFormField(
                                  controller: expertiseController,
                                  focusNode: expertiseFocusNode,
                                  decoration: InputDecoration(
                                    hintText: selectedExpertiseNames.isEmpty
                                        ? "Select Your Expertise"
                                        : "Add more expertise...",
                                    filled: true,
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 12.sp,
                                    ),
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: state.hasError
                                            ? Colors.red
                                            : Colors.transparent,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: state.hasError
                                            ? Colors.red
                                            : Colors.blue,
                                      ),
                                    ),
                                    suffixIcon: const Icon(
                                      Icons.keyboard_arrow_down,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                                if (expertiseFocusNode.hasFocus)
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    constraints: const BoxConstraints(
                                      maxHeight: 200,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: filteredList.isNotEmpty
                                            ? filteredList.length
                                            : (text.isNotEmpty ? 1 : 0),
                                        itemBuilder: (context, index) {
                                          if (filteredList.isEmpty &&
                                              text.isNotEmpty) {
                                            return ListTile(
                                              title: Text('Add "$text"'),
                                              onTap: () {
                                                if (!selectedExpertiseNames
                                                    .contains(text)) {
                                                  setState(() {
                                                    selectedExpertiseNames.add(
                                                      text,
                                                    );
                                                    selectedExpertiseIds.add(
                                                      "",
                                                    );
                                                  });
                                                  state.didChange(
                                                    selectedExpertiseNames.join(
                                                      ", ",
                                                    ),
                                                  );
                                                }
                                                expertiseController.clear();
                                                expertiseFocusNode.unfocus();
                                              },
                                            );
                                          }

                                          final option = filteredList[index];
                                          return ListTile(
                                            title: Text(option),
                                            onTap: () {
                                              if (!selectedExpertiseNames
                                                  .contains(option)) {
                                                setState(() {
                                                  selectedExpertiseNames.add(
                                                    option,
                                                  );
                                                  final selectedItem = data
                                                      .data!
                                                      .list!
                                                      .firstWhere(
                                                        (item) =>
                                                            item.name == option,
                                                      );
                                                  selectedExpertiseIds.add(
                                                    selectedItem.id
                                                            ?.toString() ??
                                                        "",
                                                  );
                                                });
                                                state.didChange(
                                                  selectedExpertiseNames.join(
                                                    ", ",
                                                  ),
                                                );
                                              }
                                              expertiseController.clear();
                                              expertiseFocusNode.unfocus();
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                          error: (error, stackTrace) => Text(error.toString()),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                        ),

                        /// ERROR TEXT (same as your code)
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
                SizedBox(height: 25.h),

                /// BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.w,
                        vertical: 14.h,
                      ),
                      backgroundColor: Color(0xFF24ADD7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),

                    onPressed: isLoading
                        ? null
                        : () async {
                            if (!_formKeyVendor.currentState!.validate())
                              return;

                            setState(() {
                              isLoading = true;
                            });
                            // final serviceTypeValue =
                            //     (selectedExpertiseId != null &&
                            //         selectedExpertiseId!.isNotEmpty)
                            //     ? selectedExpertiseId
                            //     : selectedExpertise;

                            final List<String> customServices = [];
                            final List<String> standardServiceIds = [];

                            for (
                              int i = 0;
                              i < selectedExpertiseNames.length;
                              i++
                            ) {
                              if (selectedExpertiseIds[i].isEmpty) {
                                customServices.add(selectedExpertiseNames[i]);
                              } else {
                                standardServiceIds.add(selectedExpertiseIds[i]);
                              }
                            }

                            if (expertiseController.text.trim().isNotEmpty) {
                              customServices.add(
                                expertiseController.text.trim(),
                              );
                            }
                            final body = SaveServiceBodyModel(
                              email: emailController.text.trim(),
                              phone: phoneController.text.trim(),
                              name: nameController.text.trim(),
                              serviceType: standardServiceIds.isNotEmpty
                                  ? standardServiceIds.first
                                  : "other",
                              customServiceType: customServices.isNotEmpty
                                  ? customServices.join(",")
                                  : "",
                              serviceTypeArray: standardServiceIds.isNotEmpty
                                  ? standardServiceIds
                                  : (customServices.isNotEmpty
                                        ? customServices
                                        : []),
                            );
                            try {
                              final service = APIStateNetwork(createDio());
                              final response = await service.saveService(body);

                              if (response.code == 0 &&
                                  response.error == false) {
                                Navigator.of(context).pop();

                                // ✅ fir toast dikhao (thoda delay safe hai)
                                Future.delayed(Duration(milliseconds: 200), () {
                                  Fluttertoast.showToast(
                                    msg: response.message ?? "Register Success",
                                  );
                                });
                              } else {
                                Fluttertoast.showToast(
                                  msg:
                                      response.message ??
                                      "Something went wrong",
                                );
                              }
                            } catch (e, stackTrace) {
                              print("Error: $e");
                              print("StackTrace: $stackTrace");
                              Fluttertoast.showToast(msg: e.toString());
                            } finally {
                              if (context.mounted) {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          },
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 1.5,
                            ),
                          )
                        : Text(
                            "SUBMIT REGISTRATION",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget fieldTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
    int? maxLength,
    String? counterText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      maxLength: maxLength,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(fontSize: 15.sp, color: Colors.black),
      decoration: InputDecoration(
        errorStyle: TextStyle(color: Colors.red, fontSize: 12.sp),
        counterText: counterText,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp),
        filled: true,
        fillColor: Colors.white,

        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),

        // 👇 ADD THIS (important)
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF24ADD7), width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}

class ExpandablePageView extends StatefulWidget {
  final List<Widget> children;
  final TabController controller;

  const ExpandablePageView({
    Key? key,
    required this.children,
    required this.controller,
  }) : super(key: key);

  @override
  _ExpandablePageViewState createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late List<double> _heights;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _heights = List.filled(widget.children.length, 0.0);
    _currentPage = widget.controller.index;
    _pageController = PageController(initialPage: _currentPage);

    widget.controller.addListener(() {
      if (widget.controller.indexIsChanging) {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            widget.controller.index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
      if (_currentPage != widget.controller.index) {
        if (mounted) {
          setState(() {
            _currentPage = widget.controller.index;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      curve: Curves.easeInOutCubic,
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(
        begin: _heights.isNotEmpty ? _heights.first : 0.0,
        end: _heights[_currentPage] > 0 ? _heights[_currentPage] : 200,
      ),
      builder: (context, value, child) {
        return SizedBox(height: value, child: child);
      },
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (!widget.controller.indexIsChanging) {
            widget.controller.index = index;
          }
        },
        children: _sizeReportingChildren(),
      ),
    );
  }

  List<Widget> _sizeReportingChildren() {
    return widget.children
        .asMap()
        .map(
          (index, child) => MapEntry(
            index,
            OverflowBox(
              minHeight: 0,
              maxHeight: double.infinity,
              alignment: Alignment.topCenter,
              child: SizeReportingWidget(
                onSizeChange: (size) {
                  if (mounted && _heights[index] != size.height) {
                    setState(() => _heights[index] = size.height);
                  }
                },
                child: child,
              ),
            ),
          ),
        )
        .values
        .toList();
  }
}

class SizeReportingWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChange;

  const SizeReportingWidget({
    Key? key,
    required this.child,
    required this.onSizeChange,
  }) : super(key: key);

  @override
  _SizeReportingWidgetState createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return widget.child;
  }

  void _notifySize() {
    if (!mounted) return;
    final size = context.size;
    if (_oldSize != size && size != null) {
      _oldSize = size;
      widget.onSizeChange(size);
    }
  }
}
