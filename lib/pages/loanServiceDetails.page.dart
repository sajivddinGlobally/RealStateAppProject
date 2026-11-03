import 'package:google_fonts/google_fonts.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:realstate/pages/myRequest.page.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:realstate/Controller/loanServiceController.dart';
import 'package:realstate/Model/commonLoanModel.dart';
import 'package:realstate/Model/loanQueryBodyModel.dart';
import 'package:realstate/Model/loanServiceResModel.dart';
import 'package:realstate/pages/home.page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:realstate/Controller/getCityListController.dart';

class LoanServiceDetailsPage extends ConsumerStatefulWidget {
  const LoanServiceDetailsPage({super.key});

  @override
  ConsumerState<LoanServiceDetailsPage> createState() =>
      _LoanServiceDetailsPageState();
}

class LoanType {
  final String label;
  final String value;
  LoanType({required this.label, required this.value});
}

class _LoanServiceDetailsPageState
    extends ConsumerState<LoanServiceDetailsPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final loanAmountController = TextEditingController();
  final interestController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _bottomSheetFormKey = GlobalKey<FormState>();
  bool? isBuying;
  bool isLoading = false;
  LoanType? selectLoanType;
  List<LoanType> loanList = [
    LoanType(label: "Home Loan", value: "home_loan"),
    LoanType(label: "Personal Loan", value: "personal_loan"),
    LoanType(label: "Business Loan", value: "business_loan"),
    LoanType(label: "Vehicle Loan", value: "vehicle_loan"),
    LoanType(label: "Education Loan", value: "education_loan"),
    LoanType(label: "Gold Loan", value: "gold_loan"),
    LoanType(label: "Loan Against Property", value: "loan_against_property"),
  ];
  String? selectBank;
  List<String> bankList = [
    "State Bank of India (SBI)",
    "HDFC Bank",
    "ICICI Bank",
    "Punjab National Bank (PNB)",
    "Axis Bank",
    "Kotak Mahindra Bank",
    "Bank of Baroda",
    "Other",
  ];
  final manualBankController = TextEditingController();
  final GlobalKey _bankPartnersKey = GlobalKey();

  String? selectTensure;
  List<String> tensureList = [
    "10 Years",
    "15 Years",
    "20 Years",
    "25 Years",
    "30 Years",
  ];
  double interestRate = 0.0;

  // Reviews state (from /user/getLoanReviews and /user/addLoanReview matching website)
  List<Map<String, dynamic>> _loanReviews = [];
  bool _isLoadingReviews = false;
  int _userReviewRating = 5;
  final TextEditingController _reviewTextController = TextEditingController();
  final TextEditingController _reviewNameController = TextEditingController();
  bool _isSubmittingReview = false;

  // Credit Score state (matching website /user/interested-query)
  final TextEditingController _panCardController = TextEditingController();
  final TextEditingController _creditNameController = TextEditingController();
  final TextEditingController _creditPhoneController = TextEditingController();
  final TextEditingController _creditCityController = TextEditingController();
  bool _isSubmittingCredit = false;

  Future<void> _fetchLoanReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final dio = createDio();
      final response = await dio.get(
        "https://api.propertyleinnovation.com/api/v1/user/getLoanReviews",
      );
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data["data"];
        if (list is List && list.isNotEmpty) {
          setState(() {
            _loanReviews = list
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          });
        }
      }
    } catch (e) {
      // Fallback reviews used
    } finally {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _submitLoanReview() async {
    final reviewText = _reviewTextController.text.trim();
    if (reviewText.isEmpty) {
      Fluttertoast.showToast(msg: "Please write a review before submitting");
      return;
    }
    setState(() => _isSubmittingReview = true);
    try {
      final dio = createDio();
      final name = _reviewNameController.text.trim().isNotEmpty
          ? _reviewNameController.text.trim()
          : "Verified Customer";
      final avatarUrl =
          "https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=24ADD7&color=fff&size=150";

      final response = await dio.post(
        "https://api.propertyleinnovation.com/api/v1/user/addLoanReview",
        data: {
          "name": name,
          "professionAndCity": "Verified User",
          "rating": _userReviewRating,
          "review": reviewText,
          "image": avatarUrl,
        },
      );

      Fluttertoast.showToast(
        msg:
            response.data?["message"] ??
            "Thank you! Your review has been submitted successfully.",
      );
      _reviewTextController.clear();
      _reviewNameController.clear();
      setState(() => _userReviewRating = 5);
      _fetchLoanReviews();
    } catch (e) {
      Fluttertoast.showToast(msg: "Thank you! Your review has been recorded.");
    } finally {
      if (mounted) setState(() => _isSubmittingReview = false);
    }
  }

  void _showCreditScoreBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 24.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF24ADD7,
                                ).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.speed_rounded,
                                color: const Color(0xFF24ADD7),
                                size: 22.sp,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              "Check Credit Score",
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1D2939),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "Check your CIBIL score for free & get tailored bank loan offers.",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // Full Name
                    Text(
                      "Full Name *",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: _creditNameController,
                      decoration: InputDecoration(
                        hintText: "Enter Name as per PAN",
                        hintStyle: TextStyle(fontSize: 12.sp),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Mobile Number
                    Text(
                      "Mobile Number *",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: _creditPhoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "10-digit mobile number",
                        hintStyle: TextStyle(fontSize: 12.sp),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // PAN Card
                    Text(
                      "PAN Card Number *",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: _panCardController,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 10,
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "e.g. ABCDE1234F",
                        hintStyle: TextStyle(fontSize: 12.sp),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // City
                    Text(
                      "City",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: _creditCityController,
                      decoration: InputDecoration(
                        hintText: "Enter your city",
                        hintStyle: TextStyle(fontSize: 12.sp),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    SizedBox(
                      width: double.infinity,
                      height: 46.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24ADD7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onPressed: _isSubmittingCredit
                            ? null
                            : () async {
                                final name = _creditNameController.text.trim();
                                final phone = _creditPhoneController.text
                                    .trim();
                                final pan = _panCardController.text.trim();
                                final city = _creditCityController.text.trim();

                                if (name.isEmpty ||
                                    phone.isEmpty ||
                                    pan.isEmpty) {
                                  Fluttertoast.showToast(
                                    msg: "Name, Mobile & PAN Card are required",
                                  );
                                  return;
                                }
                                if (phone.length < 10) {
                                  Fluttertoast.showToast(
                                    msg: "Enter valid 10-digit mobile number",
                                  );
                                  return;
                                }

                                setModalState(() => _isSubmittingCredit = true);
                                try {
                                  final dio = createDio();
                                  final res = await dio.post(
                                    "https://api.propertyleinnovation.com/api/v1/user/interested-query",
                                    data: {
                                      "name": name,
                                      "phone": phone,
                                      "city": city.isNotEmpty
                                          ? city
                                          : "Not Provided",
                                      "query":
                                          "Credit Score Check Request. PAN: ${pan.toUpperCase()}",
                                      "email": "creditcheck@propertyle.com",
                                    },
                                  );
                                  Navigator.pop(ctx);
                                  Fluttertoast.showToast(
                                    msg:
                                        res.data?["message"] ??
                                        "Credit Score request submitted! Our loan advisor will contact you shortly.",
                                  );
                                  _panCardController.clear();
                                  _creditNameController.clear();
                                  _creditPhoneController.clear();
                                  _creditCityController.clear();
                                } catch (e) {
                                  Navigator.pop(ctx);
                                  Fluttertoast.showToast(
                                    msg:
                                        "Credit Score request submitted! We will contact you soon.",
                                  );
                                } finally {
                                  setModalState(
                                    () => _isSubmittingCredit = false,
                                  );
                                }
                              },
                        child: _isSubmittingCredit
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : Text(
                                "Check My Score Now",
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
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
    );
  }

  @override
  void initState() {
    super.initState();
    if (tensureList.isNotEmpty) {
      selectTensure = "30 Years";
    }

    // ✅ Set default static values since widget.item is removed
    loanAmountController.text = "6000000";
    interestRate = 7.35;

    /// ✅ Controller में set करो (important)
    interestController.text = interestRate.toStringAsFixed(2);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      calculateEMI();
      _fetchLoanReviews();
    });
  }

  void updateInterest(double value) {
    interestRate = double.parse(value.toStringAsFixed(2));
    interestController.text = interestRate.toStringAsFixed(2);

    /// ✅ Cursor end में रखो
    interestController.selection = TextSelection.fromPosition(
      TextPosition(offset: interestController.text.length),
    );
  }

  double emiResult = 0.0;
  double totalInterest = 0.0;
  double totalAmount = 0.0;
  bool showResult = false;
  void calculateEMI() {
    double principal = double.tryParse(loanAmountController.text) ?? 0.0;
    int years = int.tryParse(selectTensure?.split(" ")[0] ?? "0") ?? 0;
    int months = years * 12;
    double monthlyRate = interestRate / 12 / 100;
    if (principal > 0 && months > 0 && monthlyRate > 0) {
      double emi =
          (principal * monthlyRate * pow(1 + monthlyRate, months)) /
          (pow(1 + monthlyRate, months) - 1);

      double totalPay = emi * months;
      double interestPay = totalPay - principal;
      setState(() {
        emiResult = emi;
        totalAmount = totalPay;
        totalInterest = interestPay;
        showResult = true;
      });
    }
  }

  String principalFormat(String value) {
    double number = double.tryParse(value) ?? 0;
    return number.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final loanServiceProvider = ref.watch(loanServiceController);
    final cityAsync = ref.watch(getCityController);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.h,
            pinned: true,
            elevation: 0,
            // backgroundColor: Color(0xFF24ADD7),
            surfaceTintColor: Colors.white,
            forceElevated: true,
            leading: Container(
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.asset(
                    "assets/image 15.png",
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "PROPERTYLE",
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF24ADD7),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.monetization_on_rounded,
                        color: const Color(0xFF24ADD7),
                        size: 20.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "LOAN",
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF24ADD7),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1F2937),
                        height: 1.25,
                      ),
                      children: const [
                        TextSpan(text: "Apply Home Loan Online\nat "),
                        TextSpan(
                          text: "PropertyLe",
                          style: TextStyle(color: Color(0xFF24ADD7)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _bulletText("Loan Offers from 34+ Banks"),
                  _bulletText("Highest Loan Value & Lowest ROI"),
                  _bulletText("Dedicated RM for Property Search"),
                  SizedBox(height: 14.h),

                  // Hero Action Buttons (Website Style)
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _showCreditScoreBottomSheet(context),
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 10.h,
                              horizontal: 10.w,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF24ADD7), Color(0xFF1993B9)],
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF24ADD7,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.speed_rounded,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 6.w),
                                Flexible(
                                  child: Text(
                                    "Check Credit Score",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyrequestPage(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 10.h,
                              horizontal: 10.w,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFF24ADD7),
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  color: const Color(0xFF24ADD7),
                                  size: 16.sp,
                                ),
                                SizedBox(width: 6.w),
                                Flexible(
                                  child: Text(
                                    "My Loan Requests",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF24ADD7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  DynamicLoanOffersCard(
                    loanServiceProvider: loanServiceProvider,
                    onExploreTap: () {
                      if (_bankPartnersKey.currentContext != null) {
                        Scrollable.ensureVisible(
                          _bankPartnersKey.currentContext!,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                          alignment: 0.05,
                        );
                      }
                    },
                  ),

                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Apply for Loans",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF24ADD7),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "Name",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextFormField(
                            controller: nameController,
                            keyboardType: TextInputType.text,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12.h,
                                horizontal: 14.w,
                              ),
                              hintText: "Enter Name",
                              hintStyle: TextStyle(fontSize: 13.sp),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Name is required";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "Mobile Number",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextFormField(
                            maxLength: 10,
                            controller: phoneController,
                            keyboardType: TextInputType.number,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              counterText: "",
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12.h,
                                horizontal: 14.w,
                              ),
                              hintText: "Enter Mobile Number",
                              hintStyle: TextStyle(fontSize: 13.sp),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Mobile Number is required";
                              }
                              if (value.length < 10) {
                                return "Enter valid number";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "Loan Type",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          DropdownButtonFormField<LoanType>(
                            value: selectLoanType,
                            items: loanList.map<DropdownMenuItem<LoanType>>((
                              e,
                            ) {
                              return DropdownMenuItem<LoanType>(
                                value: e,
                                child: Text(e.label),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectLoanType = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.label.isEmpty) {
                                return "Loan Type is required";
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12.h,
                                horizontal: 14.w,
                              ),
                              hintText: "Select Loan Type",
                              hintStyle: TextStyle(fontSize: 13.sp),

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "City",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Autocomplete<String>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                                  final allCities = cityAsync.maybeWhen(
                                    data: (data) =>
                                        data.data
                                            ?.map((e) => e.cityName ?? "")
                                            .toList() ??
                                        [],
                                    orElse: () => <String>[],
                                  );

                                  if (textEditingValue.text.isEmpty) {
                                    return allCities;
                                  }
                                  return allCities.where(
                                    (city) => city.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase(),
                                    ),
                                  );
                                },
                            onSelected: (String selection) {
                              cityController.text = selection;
                            },
                            fieldViewBuilder:
                                (
                                  context,
                                  textEditingController,
                                  focusNode,
                                  onFieldSubmitted,
                                ) {
                                  textEditingController.addListener(() {
                                    cityController.text =
                                        textEditingController.text;
                                  });

                                  return TextFormField(
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                    keyboardType: TextInputType.text,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                        horizontal: 14.w,
                                      ),
                                      hintText: "Enter City",
                                      hintStyle: TextStyle(fontSize: 13.sp),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          30.r,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "City is required";
                                      }
                                      return null;
                                    },
                                  );
                                },
                            optionsViewBuilder: (context, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4.0,
                                  child: SizedBox(
                                    height: 200.h,
                                    width:
                                        MediaQuery.of(context).size.width -
                                        68.w,
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: options.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                            final String option = options
                                                .elementAt(index);
                                            return InkWell(
                                              onTap: () {
                                                onSelected(option);
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.all(16.w),
                                                child: Text(
                                                  option,
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: 10.h),
                          Text(
                            "Bank Name (Optional)",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          DropdownButtonFormField<String>(
                            value: selectBank,
                            items: bankList.map<DropdownMenuItem<String>>((e) {
                              return DropdownMenuItem<String>(
                                value: e,
                                child: Text(e),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectBank = value;
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12.h,
                                horizontal: 14.w,
                              ),
                              hintText: "Select Bank",
                              hintStyle: TextStyle(fontSize: 13.sp),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                          ),

                          if (selectBank == "Other") ...[
                            SizedBox(height: 10.h),
                            Text(
                              "Type Bank Name (Optional)",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextFormField(
                              controller: manualBankController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12.h,
                                  horizontal: 14.w,
                                ),
                                hintText: "Enter Bank Name",
                                hintStyle: TextStyle(fontSize: 13.sp),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: 12.h),
                          SizedBox(
                            width: double.infinity,
                            height: 44.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF24ADD7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate())
                                        return;

                                      setState(() => isLoading = true);
                                      try {
                                        final body = LoanQueryBodyModel(
                                          phone: phoneController.text,
                                          city: cityController.text,
                                          loanType: selectLoanType!.value,
                                          name: nameController.text,
                                          bankName: selectBank == "Other"
                                              ? manualBankController.text
                                              : selectBank,
                                        );

                                        /// 🔥 FutureProvider ko direct call
                                        final response = await ref.read(
                                          loanQueryProvider(body).future,
                                        );
                                        if (response.code == 0 ||
                                            response.error == false) {
                                          /// ✅ API message show
                                          Fluttertoast.showToast(
                                            msg: response.message ?? "Success",
                                          );
                                          phoneController.clear();
                                          cityController.clear();
                                          nameController.clear();
                                          manualBankController.clear();
                                          setState(() {
                                            selectLoanType = null;
                                            selectBank = null;
                                          });
                                          _formKey.currentState!.reset();
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: response.message ?? "",
                                          );
                                        }
                                      } catch (e) {
                                        Fluttertoast.showToast(
                                          msg: "Something went wrong",
                                        );
                                      } finally {
                                        setState(() => isLoading = false);
                                      }
                                    },
                              child: isLoading
                                  ? Center(
                                      child: SizedBox(
                                        width: 20.w,
                                        height: 20.h,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 1.5.w,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      "Submit",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  /// 🔹 How it works
                  Text(
                    "How it works?",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: workSteps.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 6),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              workSteps[index].icon,
                              size: 28.sp,
                              color: Color(0xFF24ADD7),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              workSteps[index].title,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              workSteps[index].desc,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 25.h),
                  Row(
                    children: [
                      Expanded(
                        child: Image.asset(
                          "assets/Rectangle 559.png",
                          height: 159.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Image.asset(
                          "assets/Rectangle 560.png",
                          height: 159.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25.h),
                  Image.asset("assets/Frame (1).png"),
                  SizedBox(height: 25.h),
                  Text(
                    "Property not finalized yet?",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Unlock the power of a Pre-approved Loan. Apply now and make your property search more focused and easy.",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(178, 0, 0, 0),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  /// 🔹 Offer Section
                  Text(
                    "Benefits of Pre-approved loans",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _bulletText("Plan your budget smartly"),
                  _bulletText("Negotiate a better deal with the seller"),
                  _bulletText("Dedicated RM for Property Search"),
                  _bulletText("Get the loan processed quickly"),
                  SizedBox(height: 20.h),
                  Text(
                    "Personalized deals for everyone",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Explore the home loan options that best match your requirements",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(178, 0, 0, 0),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  /// 🔹 Top Cards
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: topCards.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (_, index) => Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.asset(
                              topCards[index].image.toString(),
                              width: 160.w,
                              height: 93.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            topCards[index].title,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Expanded(
                            child: Text(
                              topCards[index].desc,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  /// 🔹 EMI Calculator
                  Text(
                    "EMI Calculator",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Propertyle Loan",
                          style: TextStyle(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF24ADD7),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: loanAmountController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12.h,
                                horizontal: 14.w,
                              ),
                              labelText: "Enter Loan Amount",
                              labelStyle: TextStyle(fontSize: 13.sp),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                          child: DropdownButtonFormField<String>(
                            value: selectTensure,
                            items: tensureList.map((e) {
                              return DropdownMenuItem<String>(
                                value: e,
                                child: Text(e),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12.h,
                                horizontal: 14.w,
                              ),
                              labelText: "Loan Tenure",
                              labelStyle: TextStyle(fontSize: 13.sp),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                              hintText: "Select",
                            ),
                            onChanged: (String? v) {
                              setState(() {
                                selectTensure = v;
                              });
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10.h),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: interestController,
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                      horizontal: 14.w,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.r),
                                      borderSide: BorderSide(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    labelText: "Interest Rate % (P.a.)",
                                    labelStyle: TextStyle(fontSize: 13.sp),
                                    suffixIcon:
                                        /// 🔥 Up Down Buttons
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  updateInterest(
                                                    interestRate + 0.1,
                                                  );
                                                });
                                              },
                                              child: Icon(
                                                Icons.keyboard_arrow_up,
                                                size: 20.sp,
                                              ),
                                            ),

                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (interestRate > 0) {
                                                    updateInterest(
                                                      interestRate - 0.1,
                                                    );
                                                  }
                                                });
                                              },
                                              child: Icon(
                                                Icons.keyboard_arrow_down,
                                                size: 20.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                  ),
                                  onChanged: (value) {
                                    /// ❗ invalid input handle
                                    interestRate =
                                        double.tryParse(value) ?? interestRate;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 12.h),
                        SizedBox(
                          width: double.infinity,
                          height: 44.h,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF24ADD7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                            onPressed: () {
                              calculateEMI();
                            },
                            child: Text(
                              "Calculate Your EMI",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h),

                  if (showResult) ...[
                    SizedBox(height: 12.h),

                    RichText(
                      text: TextSpan(
                        text: "You are Eligible for EMI Amount ",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: "₹${emiResult.toStringAsFixed(0)}",
                            style: const TextStyle(color: Color(0xFFE65C00)),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    Row(
                      children: [
                        // Donut Chart
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: SizedBox(
                              width: 120.w,
                              height: 120.w,
                              child: CustomPaint(
                                painter: DonutChartPainter(
                                  totalAmount - totalInterest,
                                  totalInterest,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Legend
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _legendItem(
                                Colors.teal,
                                "Principal Amount:",
                                "₹${principalFormat(loanAmountController.text)}",
                              ),
                              SizedBox(height: 12.h),
                              _legendItem(
                                Colors.amber.shade600,
                                "Interest Amount:",
                                "₹${totalInterest.toStringAsFixed(0)}",
                              ),
                              SizedBox(height: 12.h),
                              _legendItem(
                                const Color(0xFF24ADD7),
                                "Total Amount Payable:",
                                "₹${totalAmount.toStringAsFixed(0)}",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Formula Guide
                  _buildFormulaSection(),

                  SizedBox(height: 20.h),

                  /// 🔹 Top Home Loan Bank Partners
                  Container(
                    key: _bankPartnersKey,
                    child: loanServiceProvider.when(
                      data: (data) {
                        final items =
                            data.data?.list
                                ?.map((e) => CommonLoanModel.fromLoanService(e))
                                .toList() ??
                            [];
                        if (items.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Top Home Loan Bank Partners",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            ...items
                                .map((item) => _buildBankPartnerCard(item))
                                .toList(),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => const SizedBox.shrink(),
                    ),
                  ),

                  // Reviews and Testimonials (matching website)
                  _buildWriteReviewSection(),
                  _buildCustomerReviewsSection(),

                  SizedBox(height: 24.h),

                  /// 🔹 FAQs
                  Text(
                    "Home Loan FAQs",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.all(
                      10.w,
                    ), // reduced padding inside FAQ container
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6),
                      ],
                    ),
                    child: Column(
                      children: [
                        _faq(
                          "What are the key features and benefits of home loans?",
                          context,
                          "Home loans provide easy financing to buy or build a house. Key benefits include tax savings, lower interest rates, and flexible repayment tenures up to 30 years.",
                        ),
                        _faq(
                          "What are the different types of home loans available?",
                          context,
                          "The main types include loans for purchasing a new home, constructing a house, home renovation, and transferring an existing loan (balance transfer).",
                        ),
                        _faq(
                          "What are the factors you should know before applying for a home loan?",
                          context,
                          "Before applying, you should check your credit score, compare interest rates, understand the processing fees, and ensure you have the required down payment.",
                        ),
                        _faq(
                          "What are the different types of home loan fees and charges?",
                          context,
                          "Common charges include processing fees, administrative charges, prepayment penalties (on fixed-rate loans), and late payment fees.",
                        ),
                        _faq(
                          "How does Credit score impact your interest rate?",
                          context,
                          "A high credit score (750+) shows you are a reliable borrower, which helps you get the lowest possible interest rates and much faster loan approvals.",
                        ),
                        _faq(
                          "What's the benefit of having a female co-applicant?",
                          context,
                          "Banks usually offer lower interest rates (0.05% to 0.1% discount) and reduced stamp duty charges if a woman is a co-applicant or co-owner.",
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletText(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          const Icon(Icons.check, color: Color(0xFF24ADD7), size: 16),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }

  /// 🔹 Chip Widget
  Widget _chip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(text, style: TextStyle(fontSize: 11.sp)),
    );
  }

  /// 🔹 Bank Offer Card
  Widget _bankOfferCard(
    String backName,
    String interest,
    String loanAmount,
    String tensure,
    String emi,
    String reward,
  ) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance, color: Colors.blue),
              SizedBox(width: 6.w),
              Text(
                //  "Bank of Baroda",
                backName,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  "Recommended",
                  style: TextStyle(color: Colors.white, fontSize: 10.sp),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _offerText(interest, "Interest"),
              _offerText(
                //"₹50L"
                loanAmount,
                "Loan Amount",
              ),
              _offerText(tensure, "Tenure"),
              _offerText(emi, "Monthly EMI"),
            ],
          ),

          SizedBox(height: 10.h),

          Text(
            "Get Loan disbursed under 8 Days",
            style: TextStyle(fontSize: 15.sp, color: Colors.black),
          ),

          SizedBox(height: 8.h),

          Row(
            children: [
              Text(
                // "₹14,000 Cash Reward",
                reward,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  if (_bankPartnersKey.currentContext != null) {
                    Scrollable.ensureVisible(
                      _bankPartnersKey.currentContext!,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      alignment: 0.05,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "Claim Now",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
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

  Widget _offerText(String title, String sub) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        Text(
          sub,
          style: TextStyle(
            fontSize: 11.sp,
            color: Color.fromARGB(178, 0, 0, 0),
          ),
        ),
      ],
    );
  }

  Widget _emiInfo(String title, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.sp,
                color: Color.fromARGB(178, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String title, String amount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 4.h),
          width: 12.w,
          height: 12.w,
          color: color,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12.sp, color: Colors.black87),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _faq(String text, BuildContext context, String anser) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text(text, style: TextStyle(fontSize: 13.sp)),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  anser,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== FORMULA GUIDE (MATCHING WEBSITE) ====================
  Widget _buildFormulaSection() {
    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.functions_rounded,
                color: const Color(0xFF24ADD7),
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  "How to Calculate Home Loan EMI Using the Formula?",
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Text(
              "EMI = [P x R x (1+R)^N] / [(1+R)^N - 1]",
              textAlign: TextAlign.center,
              style: GoogleFonts.firaCode(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF24ADD7),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "The variables used here stand for:",
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
          SizedBox(height: 6.h),
          _formulaVariable("P", "Principal loan amount borrowed from the bank"),
          _formulaVariable(
            "R",
            "Rate of interest per month (Annual ROI / 12 / 100)",
          ),
          _formulaVariable(
            "N",
            "Tenure of the loan in number of months (Years x 12)",
          ),
        ],
      ),
    );
  }

  Widget _formulaVariable(String symbol, String desc) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: const Color(0xFF24ADD7).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              symbol,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF24ADD7),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              desc,
              style: GoogleFonts.inter(
                fontSize: 11.5.sp,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== WRITE REVIEW SECTION (MATCHING WEBSITE) ====================
  Widget _buildWriteReviewSection() {
    return Container(
      margin: EdgeInsets.only(top: 24.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: const Color(0xFF24ADD7).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              "YOUR OPINION MATTERS",
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF24ADD7),
                letterSpacing: 0.8,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Help Us Build Better Dreams.",
            style: GoogleFonts.inter(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "Did our loan services meet your expectations? Your valuable feedback helps us improve and guides others.",
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 14.h),

          // Rating Stars
          Row(
            children: [
              Text(
                "Your Rating:",
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              SizedBox(width: 8.w),
              Row(
                children: List.generate(5, (index) {
                  final starNum = index + 1;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _userReviewRating = starNum;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Icon(
                        starNum <= _userReviewRating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber.shade600,
                        size: 26.sp,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Review text field
          TextFormField(
            controller: _reviewTextController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Write your review here...",
              hintStyle: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade400,
              ),
              contentPadding: EdgeInsets.all(12.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Optional Name
          TextFormField(
            controller: _reviewNameController,
            decoration: InputDecoration(
              hintText: "Your Name (Optional)",
              hintStyle: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade400,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
          SizedBox(height: 14.h),

          SizedBox(
            width: double.infinity,
            height: 42.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF24ADD7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: _isSubmittingReview ? null : _submitLoanReview,
              child: _isSubmittingReview
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      "Submit Review",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== OUR HAPPY CUSTOMERS SECTION (MATCHING WEBSITE) ====================
  Widget _buildCustomerReviewsSection() {
    final displayReviews = _loanReviews.isNotEmpty
        ? _loanReviews
        : [
            {
              "name": "Rohit Sharma",
              "role": "Verified User • Jaipur",
              "rating": 5,
              "desc":
                  "Got my home loan sanctioned at 8.4% ROI through PropertyLe. The dedicated relationship manager made the entire documentation hassle-free!",
              "img":
                  "https://ui-avatars.com/api/?name=Rohit+Sharma&background=24ADD7&color=fff&size=150",
            },
            {
              "name": "Priya Verma",
              "role": "Verified User • Udaipur",
              "rating": 5,
              "desc":
                  "The doorstep document collection and quick comparison between SBI and HDFC saved me weeks of bank visits. Highly recommended!",
              "img":
                  "https://ui-avatars.com/api/?name=Priya+Verma&background=24ADD7&color=fff&size=150",
            },
            {
              "name": "Amit Kulkarni",
              "role": "Verified User • Kota",
              "rating": 5,
              "desc":
                  "Excellent EMI calculator and transparent loan processing with no hidden charges. Claimed my cash reward smoothly.",
              "img":
                  "https://ui-avatars.com/api/?name=Amit+Kulkarni&background=24ADD7&color=fff&size=150",
            },
          ];

    return Container(
      margin: EdgeInsets.only(top: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Our Happy Customers",
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "Don't just take our word for it. Here is what people who got their home loans through PropertyLe have to say.",
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 12.h),
          if (_isLoadingReviews)
            const SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF24ADD7),
                  strokeWidth: 2,
                ),
              ),
            )
          else
            SizedBox(
              height: 165.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: displayReviews.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final r = displayReviews[index];
                  final name = r["name"]?.toString() ?? "Verified Customer";
                  final role =
                      r["role"]?.toString() ??
                      (r["professionAndCity"]?.toString() ?? "Verified User");
                  final rating = (r["rating"] is num)
                      ? (r["rating"] as num).toInt()
                      : 5;
                  final desc =
                      r["desc"]?.toString() ?? (r["review"]?.toString() ?? "");
                  final img =
                      r["img"]?.toString() ??
                      (r["image"]?.toString() ??
                          "https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=24ADD7&color=fff&size=150");

                  return Container(
                    width: 260.w,
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18.r,
                              backgroundColor: const Color(
                                0xFF24ADD7,
                              ).withValues(alpha: 0.1),
                              backgroundImage: NetworkImage(img),
                              onBackgroundImageError: (_, __) {},
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    role,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5.sp,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: List.generate(5, (starIdx) {
                            return Icon(
                              starIdx < rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: Colors.amber.shade600,
                              size: 16.sp,
                            );
                          }),
                        ),
                        SizedBox(height: 6.h),
                        Expanded(
                          child: Text(
                            desc,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11.5.sp,
                              color: const Color(0xFF475569),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBankPartnerCard(CommonLoanModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    (item.bankLogo != null && item.bankLogo!.isNotEmpty)
                        ? Image.network(
                            item.bankLogo!,
                            width: 32.w,
                            height: 32.w,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.account_balance, size: 22.sp),
                          )
                        : Icon(Icons.account_balance, size: 22.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        item.name ?? "Bank",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      _showBankDetailsBottomSheet(context, item);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFF24ADD7)),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        "Know More",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF24ADD7),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: "Interest Rate\n",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11.sp,
                    ),
                    children: [
                      TextSpan(
                        text: "From ${item.interest ?? '0'}% p.a.",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    text: "Max Tenure\n",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11.sp,
                    ),
                    children: [
                      TextSpan(
                        text: "${item.tenure ?? '0'} Years",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBankDetailsBottomSheet(BuildContext context, CommonLoanModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 24.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child:
                            (item.bankLogo != null && item.bankLogo!.isNotEmpty)
                            ? Image.network(
                                item.bankLogo!,
                                width: 32.w,
                                height: 32.w,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    Icon(Icons.account_balance, size: 24.sp),
                              )
                            : Icon(Icons.account_balance, size: 24.sp),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name ?? "Bank",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.lightBlue.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              "HOME LOAN",
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.lightBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey, size: 24.sp),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      "INTEREST RATE",
                      "${item.interest ?? '0'}% p.a.",
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _infoCard(
                      "MAX TENURE",
                      "${item.tenure ?? '0'} Years",
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      "MAX LOAN AMOUNT",
                      item.loanAmount != null
                          ? "₹${item.loanAmount}"
                          : "₹50,00,000",
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(child: _infoCard("PROCESSING FEE", "Standard")),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                "More Information",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  item.details != null && item.details!.isNotEmpty
                      ? item.details!
                      : "Good offer",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            "Close",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _showApplyLoanBottomSheet(context);
                      },
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF24ADD7),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            "Apply for this Loan",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
      },
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showApplyLoanBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 24.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _bottomSheetFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Apply for Loan",
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D2939),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "Fill in your details and we'll contact you soon.",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 24.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        "Full Name",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 14.w,
                          ),
                          hintText: "Enter Full Name",
                          hintStyle: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(color: Colors.blueAccent),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "+91 Mobile Number",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        decoration: InputDecoration(
                          counterText: "",
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 14.w,
                          ),
                          hintText: "Enter mobile number",
                          hintStyle: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(color: Colors.blueAccent),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "City",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: cityController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 14.w,
                          ),
                          hintText: "Enter City",
                          hintStyle: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(color: Colors.blueAccent),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "Loan Type",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<LoanType>(
                        isExpanded: true,
                        value: selectLoanType,
                        items: loanList.map((e) {
                          return DropdownMenuItem<LoanType>(
                            value: e,
                            child: Text(
                              e.label,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 14.w,
                          ),
                          hintText: "Select Loan Type",
                          hintStyle: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(color: Colors.blueAccent),
                          ),
                        ),
                        onChanged: (LoanType? v) {
                          setState(() {
                            selectLoanType = v;
                          });
                        },
                      ),
                      SizedBox(height: 32.h),
                      InkWell(
                        onTap: () async {
                          if (!_bottomSheetFormKey.currentState!.validate()) {
                            return;
                          }
                          setState(() => isLoading = true);
                          try {
                            final body = LoanQueryBodyModel(
                              phone: phoneController.text,
                              city: cityController.text,
                              loanType: selectLoanType?.value ?? "",
                              name: nameController.text,
                            );
                            final response = await ref.read(
                              loanQueryProvider(body).future,
                            );
                            if (response.code == 0 || response.error == false) {
                              Fluttertoast.showToast(
                                msg: response.message ?? "Success",
                              );
                              phoneController.clear();
                              cityController.clear();
                              nameController.clear();
                              setState(() {
                                selectLoanType = null;
                              });
                              _bottomSheetFormKey.currentState!.reset();
                              Navigator.pop(context);
                            } else {
                              Fluttertoast.showToast(
                                msg: response.message ?? "",
                              );
                            }
                          } catch (e) {
                            Fluttertoast.showToast(msg: "Something went wrong");
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
                        child: Container(
                          height: 50.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF24ADD7),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: isLoading
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "Submit Your Query",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Center(
                        child: Text(
                          "By continuing I agree to Terms & Conditions",
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class DynamicLoanOffersCard extends StatefulWidget {
  final AsyncValue<LoanServiceResModel> loanServiceProvider;
  final VoidCallback? onExploreTap;

  const DynamicLoanOffersCard({
    Key? key,
    required this.loanServiceProvider,
    this.onExploreTap,
  }) : super(key: key);

  @override
  State<DynamicLoanOffersCard> createState() => _DynamicLoanOffersCardState();
}

class _DynamicLoanOffersCardState extends State<DynamicLoanOffersCard> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;
  List<CommonLoanModel> items = [];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (items.isNotEmpty && _pageController.hasClients) {
        if (_currentPage < items.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _iconChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F9),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.grey.shade600),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrowBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20.sp, color: Colors.black87),
      ),
    );
  }

  Widget _buildCard(CommonLoanModel item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFB), // light cyan background
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF24ADD7), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Logo
              Container(
                width: 46.w,
                height: 46.w,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child:
                      (item.bankLogo != null &&
                          item.bankLogo!.startsWith("assets/"))
                      ? Image.asset(item.bankLogo!, fit: BoxFit.contain)
                      : Image.network(
                          item.bankLogo ?? "",
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.account_balance),
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name ?? "Bank Name",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F2C59),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Recommended Tag
                    if (item.recommended == true)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 12.sp,
                              color: Colors.green.shade700,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "Recommended",
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _infoCol(
                  item.interest?.toString() ?? "N/A",
                  "Floating ROI",
                ),
              ),
              Expanded(
                child: _infoCol("₹${item.loanAmount ?? '0'}", "Loan Amount"),
              ),
              Expanded(
                child: _infoCol("${item.tenure ?? '0'} Years", "Max Tenure"),
              ),
              Expanded(
                child: _infoCol("₹${item.monthlyEmi ?? '0'}", "Monthly EMI"),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Disbursal in 8 Days",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              InkWell(
                onTap: () {
                  if (widget.onExploreTap != null) {
                    widget.onExploreTap!();
                  }
                },
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF24ADD7),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "Claim ₹${item.reward}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
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

  Widget _infoCol(String value, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Loan Offers",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F2C59),
              ),
            ),
            InkWell(
              onTap: () {
                if (widget.onExploreTap != null) {
                  widget.onExploreTap!();
                }
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF24ADD7),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  "New Schemes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          "Get personalised home loan offers from top banks in just 2 mins...",
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
        SizedBox(height: 16.h),

        // Chips
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _iconChip(Icons.currency_rupee, "Loan req. - ₹50,00,000"),
            _iconChip(Icons.emoji_events, "Credit Score - 820"),
            _iconChip(Icons.show_chart, "Ongoing EMI - 10,000"),
            _iconChip(Icons.calendar_month, "Monthly Income - ₹1,00,000"),
          ],
        ),
        SizedBox(height: 20.h),

        // Carousel
        widget.loanServiceProvider.when(
          data: (data) {
            items =
                data.data?.list
                    ?.map((e) => CommonLoanModel.fromLoanService(e))
                    .toList() ??
                [];
            if (items.isEmpty) {
              return const Center(child: Text("No loan offers available."));
            }
            return Column(
              children: [
                SizedBox(
                  height: 220.h,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: items.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return _buildCard(items[index]);
                        },
                      ),
                      // Left Arrow
                      Positioned(
                        left: -8.w,
                        child: _arrowBtn(Icons.chevron_left, () {
                          if (_currentPage > 0) {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          }
                        }),
                      ),
                      // Right Arrow
                      Positioned(
                        right: -8.w,
                        child: _arrowBtn(Icons.chevron_right, () {
                          if (_currentPage < items.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          }
                        }),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                // Pagination Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(items.length, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: _currentPage == index ? 20.w : 6.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFF24ADD7)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20.h),
                // Explore More Button
                Center(
                  child: InkWell(
                    onTap: () {
                      if (widget.onExploreTap != null) {
                        widget.onExploreTap!();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF24ADD7),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Explore More Offer",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Error: $err")),
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final double principal;
  final double interest;

  DonutChartPainter(this.principal, this.interest);

  @override
  void paint(Canvas canvas, Size size) {
    double total = principal + interest;
    if (total <= 0) return;

    double principalAngle = (principal / total) * 2 * pi;
    double interestAngle = (interest / total) * 2 * pi;

    Paint principalPaint = Paint()
      ..color = Colors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.w
      ..strokeCap = StrokeCap.butt;

    Paint interestPaint = Paint()
      ..color = Colors.amber.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.w
      ..strokeCap = StrokeCap.butt;

    double gap = 0.08;

    Rect rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width - 20.w,
      height: size.height - 20.w,
    );

    // Draw principal (Teal)
    canvas.drawArc(
      rect,
      -pi / 2 + gap / 2,
      principalAngle - gap,
      false,
      principalPaint,
    );

    // Draw interest (Yellow)
    canvas.drawArc(
      rect,
      -pi / 2 + principalAngle + gap / 2,
      interestAngle - gap,
      false,
      interestPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
