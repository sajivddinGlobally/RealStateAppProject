import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:realstate/Controller/loanServiceController.dart';
import 'package:realstate/Model/loanQueryBodyModel.dart';
import 'package:realstate/Model/loanServiceResModel.dart';
import 'package:realstate/pages/home.page.dart';

class LoanServiceDetailsPage extends StatefulWidget {
  final ListElement item;
  const LoanServiceDetailsPage({super.key, required this.item});

  @override
  State<LoanServiceDetailsPage> createState() => _LoanServiceDetailsPageState();
}

class LoanType {
  final String label;
  final String value;
  LoanType({required this.label, required this.value});
}

class _LoanServiceDetailsPageState extends State<LoanServiceDetailsPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final loanAmountController = TextEditingController();
  final interestController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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
  String? selectTensure;
  List<String> tensureList = [
    "10 Years",
    "15 Years",
    "20 Years",
    "25 Years",
    "30 Years",
  ];
  double interestRate = 0.0;
  @override
  void initState() {
    super.initState();
    if (tensureList.isNotEmpty) {
      selectTensure = tensureList.last;
    }

    /// ✅ Loan Amount (API)
    loanAmountController.text = widget.item.loandAmount?.toString() ?? "";

    /// ✅ Interest Rate (API)
    interestRate = double.tryParse(widget.item.interest ?? "0") ?? 0.0;

    /// ✅ Controller में set करो (important)
    interestController.text = interestRate.toStringAsFixed(2);
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.h,
            pinned: true,
            elevation: 0,
            backgroundColor: Color(0xFFFF6725),
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
                  child: Image.network(
                    widget.item.bankLogo ?? "",
                    // width: double.infinity,
                    // fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF6725),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => SizedBox.expand(
                      child: Container(
                        color: Colors.grey.shade300,
                        child: Center(child: const Icon(Icons.image, size: 60)),
                      ),
                    ),
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
                  Text(
                    "PROPERTYLOAN",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6725),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  _bulletText("Apply Home Loan Online at Magicbricks"),
                  _bulletText("Loan Offers from 34+ Banks"),
                  _bulletText("Dedicated RM for Property Search"),
                  _bulletText("Highest Loan Value & Lowest ROI"),
                  SizedBox(height: 12.h),
                  Text(
                    "Check Your Credit Score →",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF6725),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  /// 🔹 Heading
                  Row(
                    children: [
                      Text(
                        "Home Loan Offers",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          "New Schemes",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Get personalised home loan offers from top banks in just 2 mins.",
                    style: TextStyle(fontSize: 12.sp, color: Colors.black),
                  ),
                  SizedBox(height: 14.h),

                  /// 🔹 Info Chips
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _chip("Loan req. - ₹50,00,000"),
                      _chip("Credit Score - 820"),
                      _chip("Ongoing EMI - ₹10,000"),
                      _chip("Monthly income - ₹1,00,000"),
                    ],
                  ),
                  //SizedBox(height: 16.h),
                  // /// 🔹 Bank Card
                  // _bankOfferCard(
                  //   widget.item.name ?? "N/A",
                  //   widget.item.interest ?? "",
                  //   "₹${widget.item.loandAmount.toString()}",
                  //   "${widget.item.tenure.toString()}Years",
                  //   "₹${widget.item.monthlyEmi.toString()}",
                  //   "₹${widget.item.reward ?? ""} Cash Reward",
                  // ),
                  // SizedBox(height: 16.h),
                  /// 🔹 Explore Button
                  // Center(
                  //   child: Container(
                  //     height: 45.h,
                  //     width: 220.w,
                  //     decoration: BoxDecoration(
                  //       color: Colors.orange,
                  //       borderRadius: BorderRadius.circular(30.r),
                  //     ),
                  //     child: Center(
                  //       child: Text(
                  //         "Explore More Offer",
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 14.sp,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
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
                    child: Consumer(
                      builder: (context, ref, child) {
                        return Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Get your Best Loan offer!",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF6725),
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
                                    vertical: 10.h,
                                    horizontal: 10.w,
                                  ),
                                  hintText: "Enter Name",
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
                                    vertical: 10.h,
                                    horizontal: 10.w,
                                  ),
                                  hintText: "Enter Mobile Number",
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
                                items: loanList.map<DropdownMenuItem<LoanType>>(
                                  (e) {
                                    return DropdownMenuItem<LoanType>(
                                      value: e,
                                      child: Text(e.label),
                                    );
                                  },
                                ).toList(),
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
                                    vertical: 10.h,
                                    horizontal: 10.w,
                                  ),
                                  hintText: "Select Loan Type",

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
                              TextFormField(
                                controller: cityController,
                                keyboardType: TextInputType.text,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.h,
                                    horizontal: 10.w,
                                  ),
                                  hintText: "Enter City",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.r),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "City is required";
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 12.h),
                              SizedBox(
                                width: double.infinity,
                                height: 44.h,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.r),
                                    ),
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                          if (!_formKey.currentState!
                                              .validate())
                                            return;

                                          setState(() => isLoading = true);
                                          try {
                                            final body = LoanQueryBodyModel(
                                              phone: phoneController.text,
                                              city: cityController.text,
                                              loanType: selectLoanType!.value,
                                              name: nameController.text,
                                            );

                                            /// 🔥 FutureProvider ko direct call
                                            final response = await ref.read(
                                              loanQueryProvider(body).future,
                                            );
                                            if (response.code == 0 ||
                                                response.error == false) {
                                              /// ✅ API message show
                                              Fluttertoast.showToast(
                                                msg:
                                                    response.message ??
                                                    "Success",
                                              );
                                              _formKey.currentState!.reset();
                                              phoneController.clear();
                                              cityController.clear();
                                              nameController.clear();
                                              setState(() {
                                                selectLoanType = null;
                                              });
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
                        );
                      },
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
                              color: Colors.orange,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        "assets/Rectangle 559.png",
                        width: 158.w,
                        height: 159.h,
                        fit: BoxFit.cover,
                      ),
                      Image.asset(
                        "assets/Rectangle 560.png",
                        width: 158.w,
                        height: 159.h,
                        fit: BoxFit.cover,
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

                  /// 🔹 Explore Button
                  Center(
                    child: Container(
                      height: 45.h,
                      width: 220.w,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Center(
                        child: Text(
                          "Explore More Offer",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  /// 🔹 Offer Section
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
                            color: Color(0xFFFF6725),
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
                                vertical: 10.h,
                                horizontal: 10.w,
                              ),
                              labelText: "Enter Loan Amount",
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
                                vertical: 10.h,
                                horizontal: 10.w,
                              ),
                              labelText: "Loan Tenure",
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
                                      vertical: 4.h,
                                      horizontal: 10.w,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.r),
                                      borderSide: BorderSide(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    labelText: "Interest Rate % (P.a.)",
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
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                            onPressed: () {
                              calculateEMI();
                            },
                            child: Text(
                              "Calculate Your EMI",
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h),

                  if (showResult) ...[
                    SizedBox(height: 12.h),

                    Text(
                      "You are Eligible for EMI Amount ₹${emiResult.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 5),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Principal
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                color: Colors.teal,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Principal Amount: ₹${principalFormat(loanAmountController.text)}",
                              ),
                            ],
                          ),

                          SizedBox(height: 8),

                          /// Interest
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Interest Amount: ₹${totalInterest.toStringAsFixed(0)}",
                              ),
                            ],
                          ),

                          SizedBox(height: 8),

                          /// Total
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                color: Colors.deepOrange,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Total Amount Payable: ₹${totalAmount.toStringAsFixed(0)}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 20.h),

                  /// 🔹 Benefits
                  Text(
                    "Why Magicbricks?",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10.h),
                  _bulletText("Offers from 34+ Banks"),
                  _bulletText("Lowest Interest Rate"),
                  _bulletText("Highest Loan Value"),

                  SizedBox(height: 14.h),

                  SizedBox(
                    width: double.infinity,
                    height: 45.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      onPressed: () {},
                      child: Text("Check Bank Offers"),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  /// 🔹 FAQs
                  Text(
                    "Home Loan FAQs",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10.h),
                  SafeArea(
                    // top: false,           // ← Top safe area ignore karo (header already handle karta hai)
                    // minimum: EdgeInsets.zero,
                    child: Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6),
                        ],
                      ),
                      child: Column(
                        children: [
                          _faq("What are the key features?", context),
                          _faq("What are the different types?", context),
                          _faq(
                            "What are the factors you should consider?",
                            context,
                          ),
                          _faq(
                            "How does Credit score impact your interest rate?",
                            context,
                          ),
                          _faq(
                            "What's the benefit of having a female co-applicant?",
                            context,
                          ),
                        ],
                      ),
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
          const Icon(Icons.check, color: Color(0xFFFF6725), size: 16),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
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

  Widget _faq(String text, BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent, // 👈 border remove
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text(text, style: TextStyle(fontSize: 13.sp)),
        children: [
          Align(
            alignment: Alignment.centerLeft, // 👈 LEFT align
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Detailed explanation will appear here.",
                  textAlign: TextAlign.start, // 👈 safe side
                  style: TextStyle(fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
