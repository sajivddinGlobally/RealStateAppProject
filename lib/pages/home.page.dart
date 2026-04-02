import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
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
import 'package:realstate/Controller/getMyPropertyController.dart';
import 'package:realstate/Controller/homeServiceCategoryController.dart';
import 'package:realstate/Controller/likePropertyController.dart';
import 'package:realstate/Controller/loanServiceController.dart';
import 'package:realstate/Controller/userProfileController.dart';
import 'package:realstate/Model/contactUsBodyModel.dart';
import 'package:realstate/Model/getLikeProperyResModel.dart';
import 'package:realstate/pages/homeServiceDetails.page.dart';
import 'package:realstate/pages/loanServiceDetails.page.dart';
import 'package:realstate/pages/myPropertyDetals.page.dart';
import 'package:realstate/pages/propertyCat.page.dart';
import 'package:realstate/pages/savedDetails.page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../CityProvider.dart';
import '../Model/getMyPropertyResModel.dart';
import 'SearchProperty.dart';
import 'createPropertyPage.dart';
import 'drawer.dart';

class RealEstateHomePage extends ConsumerStatefulWidget {
  const RealEstateHomePage({super.key});
  @override
  ConsumerState<RealEstateHomePage> createState() => _RealEstateHomePageState();
}

class _RealEstateHomePageState extends ConsumerState<RealEstateHomePage> {
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
    _loadSavedCity();
    _fetchAndSaveCurrentCity();
  }

  Future<void> _loadSavedCity() async {
    final saved = await ref.read(savedCityProvider.future);
    if (saved != null && mounted) {
      setState(() {
        _currentCity = saved;
      });
      ref.read(currentCityProvider.notifier).state = saved;
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
            selectedCity = city; // ✅ yaha set kar diya
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
        phone: '+91 9876543210',
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

  @override
  Widget build(BuildContext context) {
    final city = ref.watch(currentCityProvider) ?? _currentCity;
    final profileController = ref.watch(userProfileController);
    final cityListState = ref.watch(getCityController);
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
            backgroundColor: const Color(0xffFF6A2A),
            shape: const CircleBorder(),
            onPressed: () {
              setState(() {
                bottomIndex = 2;
              });
            },
            child: Icon(Icons.add, size: 22.sp, color: Colors.white),
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
                  buildNavItem(Icons.description_outlined, 'Add\nProperty', 2),
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
                          ? const Color(0xffFF6A2A)
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
    return SafeArea(
      top: false,
      child: Builder(
        builder: (BuildContext context) {
          // नया context जो Scaffold के अंदर है
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
                  color: const Color(0xffFF6A2A),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),

                        /// Search Box
                        Expanded(
                          child: TextField(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SearchPropertyPage(),
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
                        const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                        ),

                        /// City Location
                        SizedBox(width: 8.w),
                        cityListState.when(
                          data: (cityList) {
                            if (selectedCity == null &&
                                cityList.data!.isNotEmpty) {
                              selectedCity =
                                  city ?? cityList.data!.first.cityName;
                            }
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  padding: EdgeInsets.zero,
                                  value: selectedCity,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.orange,
                                    size: 18.sp,
                                  ),
                                  isDense: true,
                                  dropdownColor: Colors.white,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                    fontSize: 13.sp,
                                  ),

                                  items: cityList.data!
                                      .map<DropdownMenuItem<String>>((value) {
                                        return DropdownMenuItem<String>(
                                          value: value.cityName,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 14.sp,
                                                color: Colors.orange,
                                              ),
                                              SizedBox(width: 4.w),
                                              Text(value.cityName.toString()),
                                            ],
                                          ),
                                        );
                                      })
                                      .toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedCity = newValue;
                                      _currentCity = newValue;
                                    });
                                    ref
                                            .read(currentCityProvider.notifier)
                                            .state =
                                        newValue!;
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
                CarouselSlider(
                  options: CarouselOptions(
                    height: 260.h,
                    viewportFraction: 1,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration: const Duration(
                      milliseconds: 800,
                    ),
                    enlargeCenterPage: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentBannerIndex = index;
                      });
                    },
                  ),
                  items: bannerImages.map((image) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Stack(
                          children: [
                            /// Image
                            Image.asset(
                              image,
                              height: 260.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
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

                            /// Text Content
                            Positioned(
                              left: 16.w,
                              bottom: 20.h,
                              right: 16.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Chip(
                                    label: const Text("Top rated"),
                                    backgroundColor: const Color.fromARGB(
                                      178,
                                      255,
                                      255,
                                      255,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40.r),
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    "Sea Facing Villa, Miami\nBeach Property",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(height: 4.h),

                                  Text(
                                    "24 XYZ, Miami Beach, Florida",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 0,
                              left: 0,
                              bottom: 6,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  bannerImages.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                    ),
                                    width: currentBannerIndex == index
                                        ? 12.w
                                        : 8.w,
                                    height: currentBannerIndex == index
                                        ? 12.h
                                        : 8.h,
                                    decoration: BoxDecoration(
                                      color: currentBannerIndex == index
                                          ? const Color(0xffFF6A2A)
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
                    );
                  }).toList(),
                ),

                // MARQUEE
                Container(
                  width: double.infinity,
                  height: 40.h,
                  color: const Color(0xffFF6A2A),
                  child: Marquee(
                    text:
                        "CALL US TODAY AT +91-8899556644 FOR PROPERTY INQUERY",
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                    scrollAxis: Axis.horizontal,
                    velocity: 40,
                    blankSpace: 50,
                    startPadding: 10,
                  ),
                ),

                SizedBox(height: 15.h),

                // TABS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      _tab("Buy & Rent Property", 0),
                      _tab("Home Services", 1),
                      _tab("Loan Service", 2),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // TAB CONTENT
                if (selectIndex == 0)
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: GridView.count(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _gridItem("assets/png/home.png", "Buy House"),
                        _gridItem("assets/png/apartment.png", "Rent Studio"),
                        _gridItem("assets/png/buyFlat.png", "Buy Flats"),
                        _gridItem("assets/png/buyPlot.png", "Buy Plots"),
                        _gridItem("assets/png/commercial.png", "Commercial"),
                        _gridItem("assets/png/buyHotel.png", "residential"),
                        _gridItem("assets/png/rentCondos.png", "Rent Condos"),
                        _gridItem("assets/png/buyDuplex.png", "Buy Duplex"),
                        _gridItem("assets/png/rentHouse.png", "Rent House"),
                      ],
                    ),
                  )
                else if (selectIndex == 1)
                  const HomeService()
                else if (selectIndex == 2)
                  const LoanService(),

                SizedBox(height: 80.h),
              ],
            ),
          );
        },
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
          Container(
            height: 90.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            color: const Color(0xffFF6A2A),
            child: Padding(
              padding: EdgeInsets.only(top: 25.h),
              child: Row(
                children: [
                  Text(
                    "My Property Manage",
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
              onRefresh: () async {
                // सबसे साफ तरीका
                await ref.refresh(getMyPropertyController.future);
                // या
                // ref.invalidate(getMyPropertyController);
              },
              child: getMyPropertyProvider.when(
                data: (snap) {
                  if (snap.data!.list!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_outlined,
                              size: 80.sp,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              "No properties listed yet",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "Start by adding your first property to manage listings easily.",
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
                                  bottomIndex = 2;
                                });
                              },
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text(
                                "Add Property",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5722),
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
                    itemCount: snap.data!.list!.length,
                    itemBuilder: (context, index) {
                      return PropertyCard(data: snap.data!.list![index]);
                    },
                  );
                },
                error: (error, stackTrace) {
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

  Widget CallUsScreen() {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          // Orange App Bar (same as others)
          Container(
            height: 90.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            color: const Color(0xffFF6A2A),
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

          // Expanded(
          //   child: SingleChildScrollView(
          //     padding: EdgeInsets.all(24.w),
          //     child: Column(
          //       children: [
          //         Form(
          //           key: _formKeyContactUs,
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               const Text(
          //                 "Enter Your Email",
          //                 style: TextStyle(
          //                   fontSize: 14,
          //                   fontWeight: FontWeight.w600,
          //                   color: Color(0xff0E1A35),
          //                 ),
          //               ),
          //               const SizedBox(height: 10),
          //               TextFormField(
          //                 controller: emailController,
          //                 keyboardType: TextInputType.emailAddress,
          //                 decoration: InputDecoration(
          //                   prefixIcon: Icon(
          //                     Icons.mail_outline,
          //                     color: Colors.grey,
          //                   ),
          //                   hintStyle: TextStyle(fontSize: 14.sp),
          //                   hintText: "Email",
          //                   filled: true,
          //                   fillColor: Colors.white,
          //                   enabledBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(14.r),
          //                     borderSide: BorderSide(
          //                       color: Colors.grey.shade300,
          //                     ),
          //                   ),
          //                   focusedBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(14.r),
          //                     borderSide: BorderSide(
          //                       color: Colors.grey.shade300,
          //                     ),
          //                   ),
          //                   errorBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(14.r),
          //                     borderSide: BorderSide(
          //                       color: Colors.red.shade300,
          //                     ),
          //                   ),
          //                 ),
          //                 validator: (value) {
          //                   if (value == null || value.isEmpty) {
          //                     return "Email is required";
          //                   }
          //                   return null;
          //                 },
          //               ),
          //               const SizedBox(height: 15),
          //               const Text(
          //                 "Enter Your Name",
          //                 style: TextStyle(
          //                   fontSize: 14,
          //                   fontWeight: FontWeight.w600,
          //                   color: Color(0xff0E1A35),
          //                 ),
          //               ),
          //               const SizedBox(height: 10),
          //               TextFormField(
          //                 controller: nameController,
          //                 keyboardType: TextInputType.name,
          //                 decoration: InputDecoration(
          //                   prefixIcon: Icon(Icons.person, color: Colors.grey),
          //                   hintStyle: TextStyle(fontSize: 14.sp),
          //                   hintText: "Name",
          //                   filled: true,
          //                   fillColor: Colors.white,
          //                   enabledBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(14.r),
          //                     borderSide: BorderSide(
          //                       color: Colors.grey.shade300,
          //                     ),
          //                   ),
          //                   focusedBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(14.r),
          //                     borderSide: BorderSide(
          //                       color: Colors.grey.shade300,
          //                     ),
          //                   ),
          //                   errorBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(14.r),
          //                     borderSide: BorderSide(
          //                       color: Colors.red.shade300,
          //                     ),
          //                   ),
          //                 ),
          //                 validator: (value) {
          //                   if (value == null || value.isEmpty) {
          //                     return "Name is required";
          //                   }
          //                   return null;
          //                 },
          //               ),
          //               const SizedBox(height: 15),
          //               const Text(
          //                 "Mobile Number",
          //                 style: TextStyle(
          //                   fontSize: 14,
          //                   fontWeight: FontWeight.w600,
          //                   color: Color(0xff0E1A35),
          //                 ),
          //               ),
          //               const SizedBox(height: 10),
          //               TextFormField(
          //                 maxLength: 10,
          //                 controller: phoneController,
          //                 keyboardType: TextInputType.number,
          //                 decoration: InputDecoration(
          //                   prefixIcon: Icon(
          //                     Icons.call_outlined,
          //                     color: Colors.grey,
          //                   ),
          //                   counterText: "",
          //                   hintStyle: TextStyle(fontSize: 14.sp),
          //                   hintText: "Mobile Number",
          //                   filled: true,
          //                   fillColor: Colors.white,
          //                   enabledBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(14.r),
          //                     borderSide: BorderSide(
          //                       color: Colors.grey.shade300,
          //                     ),
          //                   ),
          //                   focusedBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(14.r),
          //                     borderSide: BorderSide(
          //                       color: Colors.grey.shade300,
          //                     ),
          //                   ),
          //                   errorBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(14.r),
          //                     borderSide: BorderSide(
          //                       color: Colors.red.shade300,
          //                     ),
          //                   ),
          //                 ),
          //                 validator: (value) {
          //                   if (value == null || value.isEmpty) {
          //                     return "Mobile Number is required";
          //                   }
          //                   return null;
          //                 },
          //               ),
          //               const SizedBox(height: 15),
          //               const Text(
          //                 "Subject",
          //                 style: TextStyle(
          //                   fontSize: 14,
          //                   fontWeight: FontWeight.w600,
          //                   color: Color(0xff0E1A35),
          //                 ),
          //               ),
          //               const SizedBox(height: 10),
          //               TextFormField(
          //                 controller: subjectController,
          //                 keyboardType: TextInputType.text,
          //                 decoration: InputDecoration(
          //                   prefixIcon: Icon(
          //                     Icons.subject_outlined,
          //                     color: Colors.grey,
          //                   ),
          //                   hintStyle: TextStyle(fontSize: 14.sp),
          //                   hintText: "Subject",
          //                   filled: true,
          //                   fillColor: Colors.white,
          //                   enabledBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(14.r),
          //                     borderSide: BorderSide(
          //                       color: Colors.grey.shade300,
          //                     ),
          //                   ),
          //                   focusedBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(14.r),
          //                     borderSide: BorderSide(
          //                       color: Colors.grey.shade300,
          //                     ),
          //                   ),
          //                   errorBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(14.r),
          //                     borderSide: BorderSide(
          //                       color: Colors.red.shade300,
          //                     ),
          //                   ),
          //                 ),
          //                 validator: (value) {
          //                   if (value == null || value.isEmpty) {
          //                     return "Subject is required";
          //                   }
          //                   return null;
          //                 },
          //               ),
          //               const SizedBox(height: 15),
          //               const Text(
          //                 "Message",
          //                 style: TextStyle(
          //                   fontSize: 14,
          //                   fontWeight: FontWeight.w600,
          //                   color: Color(0xff0E1A35),
          //                 ),
          //               ),
          //               const SizedBox(height: 10),
          //               TextFormField(
          //                 controller: messageController,
          //                 keyboardType: TextInputType.text,
          //                 decoration: InputDecoration(
          //                   prefixIcon: Icon(
          //                     Icons.messenger_outline,
          //                     color: Colors.grey,
          //                   ),
          //                   filled: true,
          //                   fillColor: Colors.white,
          //                   enabledBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(14.r),
          //                     borderSide: BorderSide(
          //                       color: Colors.grey.shade300,
          //                     ),
          //                   ),
          //                   focusedBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(14.r),
          //                     borderSide: BorderSide(
          //                       color: Colors.grey.shade300,
          //                     ),
          //                   ),
          //                   errorBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(14.r),
          //                     borderSide: BorderSide(
          //                       color: Colors.red.shade300,
          //                     ),
          //                   ),
          //                   hintStyle: TextStyle(fontSize: 14.sp),
          //                   hintText: "Message",
          //                 ),
          //                 validator: (value) {
          //                   if (value == null || value.isEmpty) {
          //                     return "Message is required";
          //                   }
          //                   return null;
          //                 },
          //               ),
          //               const SizedBox(height: 15),
          //               const Text(
          //                 "Location",
          //                 style: TextStyle(
          //                   fontSize: 14,
          //                   fontWeight: FontWeight.w600,
          //                   color: Color(0xff0E1A35),
          //                 ),
          //               ),
          //               const SizedBox(height: 10),
          //               SizedBox(width: 10),
          //               TextFormField(
          //                 controller: locationController,
          //                 keyboardType: TextInputType.text,
          //                 decoration: InputDecoration(
          //                   filled: true,
          //                   fillColor: Colors.white,
          //                   enabledBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(14.r),
          //                     borderSide: BorderSide(
          //                       color: Colors.grey.shade300,
          //                     ),
          //                   ),
          //                   focusedBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(14.r),
          //                     borderSide: BorderSide(
          //                       color: Colors.grey.shade300,
          //                     ),
          //                   ),
          //                   errorBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(14.r),
          //                     borderSide: BorderSide(
          //                       color: Colors.red.shade300,
          //                     ),
          //                   ),
          //                   hintStyle: TextStyle(fontSize: 14.sp),
          //                   hintText: "Location",
          //                   prefixIcon: Icon(
          //                     Icons.location_on_outlined,
          //                     color: Colors.grey,
          //                   ),
          //                 ),
          //                 validator: (value) {
          //                   if (value == null || value.isEmpty) {
          //                     return "Location is required";
          //                   }
          //                   return null;
          //                 },
          //               ),
          //               const SizedBox(height: 20),
          //               /// ==== SIGN IN BUTTON ====
          //               Center(
          //                 child: GestureDetector(
          //                   onTap: isLoading
          //                       ? null
          //                       : () async {
          //                           if (!_formKeyContactUs.currentState!
          //                               .validate()) {
          //                             return;
          //                           }
          //                           setState(() {
          //                             isLoading = true;
          //                           });
          //                           final body = ContactUsBodyModel(
          //                             email: emailController.text,
          //                             name: nameController.text,
          //                             phone: phoneController.text,
          //                             subject: subjectController.text,
          //                             message: messageController.text,
          //                             location: locationController.text,
          //                           );
          //                           try {
          //                             final response = await ref.read(
          //                               contactUsController(body).future,
          //                             );
          //                             if (response.code == 0 ||
          //                                 response.error == false) {
          //                               Fluttertoast.showToast(
          //                                 msg: response.message,
          //                               );
          //                               emailController.clear();
          //                               nameController.clear();
          //                               phoneController.clear();
          //                               subjectController.clear();
          //                               messageController.clear();
          //                               locationController.clear();
          //                             } else {
          //                               Fluttertoast.showToast(
          //                                 msg: response.message,
          //                               );
          //                             }
          //                           } catch (e) {
          //                             log(e.toString());
          //                           } finally {
          //                             setState(() {
          //                               isLoading = false;
          //                             });
          //                           }
          //                         },
          //                   child: Container(
          //                     height: 50,
          //                     width: double.infinity,
          //                     decoration: BoxDecoration(
          //                       color: Color(0xffE86A34),
          //                       borderRadius: BorderRadius.circular(40),
          //                     ),
          //                     child: Center(
          //                       child: isLoading
          //                           ? Center(
          //                               child: CircularProgressIndicator(
          //                                 color: Colors.white,
          //                               ),
          //                             )
          //                           : Text(
          //                               "Submit",
          //                               style: TextStyle(
          //                                 color: Colors.white,
          //                                 fontSize: 17.sp,
          //                                 fontWeight: FontWeight.w600,
          //                               ),
          //                             ),
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //         const SizedBox(height: 22),
          //       ],
          //     ),
          //   ),
          // ),
          SizedBox(height: 50.h),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Icon
              Container(
                width: 110.w,
                height: 110.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.support_agent,
                  color: const Color(0xffFF6A2A),
                  size: 55.sp,
                ),
              ),
              SizedBox(height: 25.h),

              /// Title
              Text(
                "Need Help?",
                style: GoogleFonts.inter(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),

              /// Subtitle
              Text(
                "Our support team is here to help you.\nContact us via Call or WhatsApp.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 35.h),

              /// Buttons Row
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                child: Row(
                  children: [
                    /// Call Button
                    Expanded(
                      child: SizedBox(
                        height: 50.h,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffFF6A2A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                          ),
                          onPressed: () async {
                            String phone = "9876543210";
                            final Uri url = Uri.parse("tel:$phone");

                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                          icon: Icon(
                            Icons.call,
                            size: 20.sp,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Call",
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    /// WhatsApp Button
                    Expanded(
                      child: SizedBox(
                        height: 50.h,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff25D366),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                          ),
                          onPressed: () async {
                            String phone = "9876543210";
                            final Uri url = Uri.parse("https://wa.me/$phone");

                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                          icon: Icon(
                            Icons.chat,
                            size: 20.sp,
                            color: Colors.white,
                          ),
                          label: Text(
                            "WhatsApp",
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25.h),

              /// Phone Text
              Text(
                "Support: +91 9876543210",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
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
            color: const Color(0xffFF6A2A),
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
                                backgroundColor: const Color(0xFFFF5722),
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

  // TAB
  Widget _tab(String title, int index) {
    final select = selectIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          selectIndex = index;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 10.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: select ? const Color(0xffFF6A2A) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xffFF6A2A)),
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            color: select ? Colors.white : const Color(0xffFF6A2A),
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  // GRID ITEM
  Widget _gridItem(String icon, String title) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => PropertyPageCat(property: title),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, height: 50.h),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
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
class PropertyCard extends StatelessWidget {
  final ListElement data;
  const PropertyCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFFFF5722);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= IMAGE =================
          Stack(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) =>
                          MyPropertyDetalsPage(propetyId: data.slug ?? ""),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                  child: Image.network(
                    (data.uploadedPhotos != null &&
                            data.uploadedPhotos!.isNotEmpty)
                        ? data.uploadedPhotos!.first
                        : '',
                    height: 190.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 190.h,
                        width: double.infinity,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 1),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 190.h,
                      color: Colors.grey.shade300,
                      child: Center(child: const Icon(Icons.image, size: 40)),
                    ),
                  ),
                ),
              ),

              // BUY / RENT CHIP
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        (data.listingCategory ?? '').toUpperCase(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreatePropertyScreen(
                              data,
                              fromBottomNav: false,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // PRICE
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "₹ ${data.price}",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ================= DETAILS =================
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE
                Text(
                  "${data.bedRoom} BHK ${data.propertyType}",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 4.h),

                // LOCATION
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        "${data.localityArea}, ${data.city}",
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // SPECS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _spec(Icons.king_bed, "${data.bedRoom} Beds"),
                    _spec(Icons.bathtub, "${data.bathrooms} Baths"),
                    _spec(Icons.square_foot, "${data.area} sqft"),
                    _spec(Icons.chair, data.furnishing ?? ''),
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

  // ================= HELPERS (SAME CLASS) =================
  Widget _spec(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        SizedBox(height: 4.h),
        Text(text, style: TextStyle(fontSize: 12.sp)),
      ],
    );
  }
}

class PropertyCardSaved extends StatelessWidget {
  final Datum data; // Aapka model class yaha aayega
  const PropertyCardSaved({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xffFF6A2A);

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
                      builder: (context) => SavedDetailsPage(savedData: data),
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
  final List<Map<String, String>> categories = const [
    {
      'label': 'ELECTRICIAN',
      'url':
          'https://media.istockphoto.com/id/1049775258/photo/smiling-handsome-electrician-repairing-electrical-box-with-pliers-in-corridor-and-looking-at.jpg?s=612x612&w=0&k=20&c=stdWozouV2XsrHk2xXD3C31nT90BG7ydZvcpAn1Fx7I=',
    }, // Replace with actual
    {
      'label': 'CARPENTER',
      'url':
          'https://s3-media0.fl.yelpcdn.com/bphoto/y2N9GweV0RhaXx9dYbXHTA/l.jpg',
    },
    {
      'label': 'PAINTER',
      'url':
          'https://www.shutterstock.com/image-vector/worker-repair-service-plumber-handyman-260nw-2234725577.jpg',
    },
    {
      'label': 'PLUMBER',
      'url':
          'https://cdn.prod.website-files.com/5e593fb060cf877cf875dd1f/679085ac60c170e5ebba4b34_recBrwtY2JtNJji6k_image_1.webp',
    },
    {
      'label': 'CLEANING',
      'url':
          'https://www.shutterstock.com/shutterstock/videos/3684051321/thumb/4.jpg?ip=x480',
    },
    {
      'label': 'INTERIOR',
      'url':
          'https://s3-media0.fl.yelpcdn.com/bphoto/tuGs0mGEDRuE8omqeINuKQ/l.jpg',
    },
    {
      'label': 'RENOVATION',
      'url':
          'https://cdn.prod.website-files.com/5e593fb060cf877cf875dd1f/677c007c62c5db1e8a3b1317_handyman-webflow-template.png',
    },
    {
      'label': 'PEST CONTROL',
      'url':
          'https://img.freepik.com/free-photo/people-disinfecting-together-dangerous-area_23-2148848569.jpg?semt=ais_hybrid&w=740&q=80',
    },
  ];

  final List<Map<String, String>> services = const [
    {
      'icon': 'Toilet Repair',
      'title': 'Toilet Repair',
      'desc':
          'Fast, reliable toilet fixes that restore comfort and functionality.',
    },
    {
      'icon': 'Faucet Installation',
      'title': 'Faucet Installation',
      'desc': 'Expert faucet installation and repair for every style.',
    },
    {
      'icon': 'Sewer Inspection',
      'title': 'Sewer Inspection',
      'desc': 'Advanced camera inspections to prevent damage.',
    },
    {
      'icon': 'Sewer Inspection',
      'title': 'Sewer Inspection',
      'desc': 'Advanced camera inspections to prevent damage.',
    }, // Duplicate in screenshot, adjust if needed
  ];

  @override
  Widget build(BuildContext context) {
    final homeServiceProvider = ref.watch(homeServiceCategoryController);
    return homeServiceProvider.when(
      data: (service) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              //itemCount: categories.length,
              itemCount: service.data!.list!.length,
              itemBuilder: (context, index) {
                final item = service.data!.list![index];
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => HomeServiceDetailsPage(
                              // service: item,
                              id: item.id.toString(),
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          // categories[index]['url']!,
                          item.image ??
                              "https://s3-media0.fl.yelpcdn.com/bphoto/y2N9GweV0RhaXx9dYbXHTA/l.jpg",
                          width: 80.w,
                          height: 80.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      //  categories[index]['label']!,
                      item.name ?? "N/A",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),

            // We Provide Quality Services
            Center(
              child: Text(
                'What We Offer',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Center(
              child: Text(
                'We Provide Quality Services',
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Services Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: const [
                ServiceCard(
                  title: 'Toilet Repair',
                  desc:
                      'Fast, reliable toilet fixes that restore proper function.',
                  imageUrl:
                      'https://media.gettyimages.com/id/2192255408/vector/plumbing-line-icon-set-group-of-object-pipe-bathtub-boiler-faucet-repair.jpg?s=612x612&w=gi&k=20&c=IgKlfAmPPCWSHJy7L_KlG4bjVyB_If33cqFTI8X51Ng=',
                ),
                ServiceCard(
                  title: 'Faucet Installation',
                  desc: 'Expert faucet fitting that ensures smooth water flow.',
                  imageUrl:
                      'https://media.istockphoto.com/id/1140334314/vector/plumber-master-with-wrench-fixing-kitchen-faucet.jpg?s=612x612&w=0&k=20&c=5XTiydIT32QfXU-x8WVM6rSeWpy6TopGU66RNfPunw4=',
                ),
                ServiceCard(
                  title: 'Sewer Inspection',
                  desc: 'Advanced sewer checks to detect issues early.',
                  imageUrl:
                      'https://media.istockphoto.com/id/2194903933/vector/plumbers-and-plumbing-thin-line-icons-editable-stroke-icons-include-plumbing-pipes-leaky.jpg?s=612x612&w=0&k=20&c=V2EAWro2g_Xk72Bl9c0LJ78ylpTxzZaZcyct56nqwCc=',
                ),
                ServiceCard(
                  title: 'Drain Cleaning',
                  desc: 'Prevent damage with professional drain cleaning.',
                  imageUrl:
                      'https://media.istockphoto.com/id/1363041172/vector/water-tank-pipe-pipeline-and-sewerage-cleaning-service-by-cleaner.jpg?s=612x612&w=0&k=20&c=OPh5837hpAV13c5fsr3daJrrzFK1E4HjSEhiDdgZwN0=',
                ),
              ],
            ),

            // Why We Are / Easy Solutions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Who We Are',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Easy Solutions For Plumbing and Home Repair Needs',
                    style: GoogleFonts.inter(fontSize: 16.sp),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Chip(
                        padding: EdgeInsets.zero,
                        label: Text(
                          'Tech Expertise',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                      Chip(
                        padding: EdgeInsets.zero,
                        label: Text(
                          'Advanced Tools',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                      Chip(
                        padding: EdgeInsets.zero,
                        label: Text(
                          'Smart Solutions',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Hire Experts'),
                  ),
                ],
              ),
            ),

            // Plumber Image
            Image.network(
              'https://as1.ftcdn.net/jpg/05/94/89/64/1000_F_594896473_PmXb07nS8Odld7O3op4E5Vi2USzODYYc.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
            ),

            // Affordable Pricing
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  Icon(Icons.price_check, size: 40, color: Colors.orange),
                  Text(
                    'Affordable Pricing',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Quality service doesn\'t have to be costly. We offer transparent, fair pricing on every job.',
                  ),
                ],
              ),
            ),

            // Featured Projects
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Projects',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See Full Gallery >',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  FeaturedProject(
                    imageUrl:
                        'https://images.finehomebuilding.com/app/uploads/2016/04/09114955/021181bs116-01_xlg.jpg',
                    title: 'Drain Overhaul',
                    subtitle: 'Complete drain system upgrade',
                  ),
                  FeaturedProject(
                    imageUrl:
                        'https://www.thespruce.com/thmb/e-MxaOBy4AKp4JW1XFZGbrkDaIw=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/how-to-install-a-sink-drain-2718789_hero_5078-64538f6f90d545c7af0728e4bf8f894e.jpg',
                    title: 'Sink Installation',
                    subtitle: 'New kitchen sink setup',
                  ),
                  FeaturedProject(
                    imageUrl:
                        'https://gharpedia.com/_next/image/?url=https%3A%2F%2Fcloudfrontgharpediabucket.gharpedia.com%2Fuploads%2F2021%2F12%2FBest-Way-to-Install-a-Bathroom-Sink-Drain-01-0504130013.jpg&w=3840&q=75',
                    title: 'Drain Overhaul',
                    subtitle: 'Complete drain system upgrade',
                  ),
                ],
              ),
            ),

            // Latest Insights
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Our Latest Insights',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Image.network(
                    'https://wg.scene7.com/is/image/wrenchgroup/insulate-pipes-info-ps22wi001wg?&wid=362',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'How to Protect Your Pipes During Cold Weather',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Read More >',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        );
      },
      error: (error, stackTrace) {
        log(stackTrace.toString());
        return Center(child: Text(error.toString()));
      },
      loading: () {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: 6, // shimmer items
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.80,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Image placeholder
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),

                    SizedBox(height: 8.h),

                    /// Text placeholder
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 75.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 20.h),
            Center(
              child: Column(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: 100.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: 200.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: 4, // shimmer items
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.80,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Image placeholder
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 200.w,
                        height: 100.h,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),

                    SizedBox(height: 8.h),

                    /// Text placeholder
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 75.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
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
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text(title),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.white)),
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
  @override
  Widget build(BuildContext context) {
    final loanServiceProvider = ref.watch(loanServiceController);
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Title
          Text(
            "Top Loan Bank Partners",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),

          /// 🔹 Loan Grid
          loanServiceProvider.when(
            data: (loan) {
              final list = loan.data?.list ?? [];

              if (list.isEmpty) {
                return const Center(child: Text("No loan services found"));
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                // itemCount: loanList.length,
                itemCount: list.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.70,
                ),
                itemBuilder: (context, index) {
                  final item = loan.data!.list![index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                              LoanServiceDetailsPage(item: item),
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
                          // Icon(
                          //   loanList[index].icon,
                          //   size: 36.sp,
                          //   color: Colors.blue,
                          // ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: Image.network(
                              item.bankLogo ?? "",
                              width: 100.w,
                              height: 55.h,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            // loanList[index].title,
                            item.name ?? "N/A",
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
                              color: Color(0xFFFF6725),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Center(
                              child: Text(
                                "Call Now",
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
              );
            },
            error: (error, stackTrace) {
              log(stackTrace.toString());
              return Center(child: Text(error.toString()));
            },
            loading: () => Center(child: CircularProgressIndicator()),
          ),

          SizedBox(height: 24.h),
        ],
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
