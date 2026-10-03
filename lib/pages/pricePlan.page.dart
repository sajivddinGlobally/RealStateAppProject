import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:realstate/Controller/pricingPlanController.dart';
import 'package:realstate/Model/Body/createPlanBodyModel.dart';
import 'package:realstate/Model/Body/verifyPlanBodyModel.dart';
import 'package:realstate/Model/createPlanResModel.dart';
import 'package:realstate/Model/planResModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:realstate/pages/myPlan.page.dart';

import '../Model/Body/paymentFailedBodyModel.dart';

class PricePlanPage extends ConsumerStatefulWidget {
  const PricePlanPage({super.key});

  @override
  ConsumerState<PricePlanPage> createState() => _PricePlanPageState();
}

class _PricePlanPageState extends ConsumerState<PricePlanPage> {
  // Track expanded state for each plan card (showing >4 features)
  final Set<String> _expandedPlanIds = <String>{};

  late Razorpay _razorpay;
  Datum? _selectedPlan;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // final dio = createDio();
      // final res = await dio.post(
      //   'https://api.propertyleinnovation.com/api/v1/user/verifyPlanRazorpayPayment',
      //   data: {
      //     'razorpay_order_id': response.orderId,
      //     'razorpay_payment_id': response.paymentId,
      //     'razorpay_signature': response.signature,
      //     'planId': _selectedPlan?.id,
      //   },
      // );
      final body = VerifyPlanBodyModel(
        planId: _selectedPlan?.id,
        razorpayOrderId: response.orderId,
        razorpayPaymentId: response.paymentId,
        razorpaySignature: response.signature,
      );
      final service = APIStateNetwork(createDio());
      final res = await service.verifyPlanRazorpayPayment(body);

      if (res.code == 0 && res.error == false) {
        Fluttertoast.showToast(
          msg: '${_selectedPlan?.name ?? "Plan"} Activated Successfully! 🎉',
          backgroundColor: const Color(0xFF24ADD7),
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => MyPlanPage()),
        );
      } else {
        Fluttertoast.showToast(
          msg: res.message ?? 'Payment verification failed!',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: '${_selectedPlan?.name ?? "Plan"} Payment Successful! 🎉',
        backgroundColor: const Color(0xFF24ADD7),
        textColor: Colors.white,
      );
      ref.invalidate(pricingPlanController);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    try {
      // final dio = createDio();
      // await dio.post(
      //   'https://api.propertyleinnovation.com/api/v1/user/paymentFailed',
      //   data: {
      //     'razorpay_order_id': response.message,
      //     'razorpay_payment_id': '',
      //   },
      // );
      final body = PaymentFailedBodyModel(
        razorpayOrderId: response.message,
        razorpayPaymentId: '',
      );
      final service = APIStateNetwork(createDio());
      final res = await service.paymentFailed(body);
      if (res.code == 0 && res.error == false) {
        Fluttertoast.showToast(
          msg: '${_selectedPlan?.name ?? "Plan"} Payment Failed! 🎉',
          backgroundColor: const Color(0xFF24ADD7),
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
        ref.invalidate(pricingPlanController);
      } else {
        Fluttertoast.showToast(
          msg: res.message ?? 'Payment Failed! 🎉',
          backgroundColor: const Color(0xFF24ADD7),
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (_) {}

    Fluttertoast.showToast(
      msg: 'Payment Failed: ${response.message ?? "Transaction Cancelled"}',
      backgroundColor: Colors.red,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: 'External Wallet: ${response.walletName ?? ""}',
      backgroundColor: const Color(0xFF24ADD7),
      textColor: Colors.white,
    );
  }

  void _openRazorpayCheckout(Data? orderData, Datum plan) {
    try {
      final box = Hive.box("userdata");
      final userEmail = box.get("email")?.toString() ?? "";
      final userPhone = box.get("phone")?.toString() ?? "";
      final userName = box.get("name")?.toString() ?? "";

      final int amountInPaise =
          (orderData?.amount != null && orderData!.amount! > 0)
          ? orderData.amount!
          : ((plan.discountPrice ?? plan.price ?? 0) * 100);

      var options = {
        'key': orderData?.keyId ?? '',
        'amount': amountInPaise,
        'name': 'PropertyLe',
        'description': 'Purchase ${plan.name ?? ""} Subscription Plan',
        'order_id': orderData?.orderId,
        'currency': orderData?.currency ?? 'INR',
        'prefill': {
          if (userPhone.isNotEmpty) 'contact': userPhone,
          if (userEmail.isNotEmpty) 'email': userEmail,
          if (userName.isNotEmpty) 'name': userName,
        },
        'theme': {'color': '#24ADD7'},
      };

      _razorpay.open(options);
    } catch (e) {
      log("Razorpay Open Error: $e");
      Fluttertoast.showToast(
        msg: "Failed to open payment gateway: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _toggleExpanded(String planId) {
    setState(() {
      if (_expandedPlanIds.contains(planId)) {
        _expandedPlanIds.remove(planId);
      } else {
        _expandedPlanIds.add(planId);
      }
    });
  }

  void _onSelectPlan(BuildContext context, Datum plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PlanConfirmationSheet(
        plan: plan,
        onConfirmed: () async {
          try {
            _selectedPlan = plan;
            final service = APIStateNetwork(createDio());
            final res = await service.createPaln(
              CreatePlanBodyModel(planId: plan.id),
            );
            if (res.error == false || res.code == 0) {
              Navigator.pop(ctx);
              _openRazorpayCheckout(res.data, plan);
            } else {
              Fluttertoast.showToast(
                msg: res.message ?? "Could not initiate plan payment",
                backgroundColor: Colors.red,
                textColor: Colors.white,
              );
            }
          } catch (e) {
            Fluttertoast.showToast(
              msg: "Error: ${e.toString()}",
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pricingPlanState = ref.watch(pricingPlanController);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 16.sp,
              color: const Color(0xFF111827),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pricing Plans',
          style: GoogleFonts.inter(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF24ADD7),
        onRefresh: () async {
          ref.invalidate(pricingPlanController);
        },
        child: pricingPlanState.when(
          data: (data) {
            final plans = data.data ?? [];
            if (plans.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 120.h),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 54.sp,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No Plans Available',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Please check back later for exciting offers.',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: plans.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeader();
                }

                final plan = plans[index - 1];
                final planId = plan.id ?? index.toString();
                final isExpanded = _expandedPlanIds.contains(planId);

                return _buildPlanCard(
                  plan: plan,
                  planId: planId,
                  isExpanded: isExpanded,
                );
              },
            );
          },
          error: (error, stackTrace) {
            log(stackTrace.toString());
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 140.h),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 52.sp,
                          color: Colors.redAccent,
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          'Failed to load pricing plans',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.invalidate(pricingPlanController);
                          },
                          icon: Icon(Icons.refresh, size: 18.sp),
                          label: Text(
                            'Try Again',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF24ADD7),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 10.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF24ADD7)),
          ),
        ),
      ),
    );
  }

  // Header matching web:
  // "CHOOSE YOUR SUCCESS PLAN" + "Simple pricing for everyone. Upgrade as you grow."
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'CHOOSE YOUR ',
                  style: GoogleFonts.inter(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF111827),
                    letterSpacing: -0.3,
                  ),
                ),
                TextSpan(
                  text: 'SUCCESS PLAN',
                  style: GoogleFonts.inter(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF24ADD7),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Simple pricing for everyone. Upgrade as you grow.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  // Plan Card matching web design
  Widget _buildPlanCard({
    required Datum plan,
    required String planId,
    required bool isExpanded,
  }) {
    final bool isPopular = plan.isPopular ?? false;
    final List<Point> allPoints = plan.points ?? [];
    final List<Point> displayedPoints = isExpanded
        ? allPoints
        : allPoints.take(4).toList();
    final bool hasMorePoints = allPoints.length > 4;

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isPopular ? const Color(0xFF24ADD7) : const Color(0xFFE5E7EB),
          width: isPopular ? 2.w : 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: isPopular
                ? const Color(0xFF24ADD7).withValues(alpha: 0.14)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Popular badge banner at the very top (just like website)
          if (isPopular)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 7.h),
              decoration: BoxDecoration(
                color: const Color(0xFF24ADD7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Center(
                child: Text(
                  'MOST POPULAR CHOICE',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ),

          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Plan Name & Description
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      (plan.name ?? 'PLAN').toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (plan.description != null &&
                        plan.description!.trim().isNotEmpty) ...[
                      SizedBox(height: 5.h),
                      Text(
                        plan.description!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 18.h),

                // Price Box Container (matches web bg-gray-50 rounded-2xl border)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFFF3F4F6),
                      width: 1.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹${plan.discountPrice ?? plan.price ?? 0}',
                            style: GoogleFonts.inter(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF111827),
                              letterSpacing: -0.8,
                            ),
                          ),
                          if (plan.discountPrice != null &&
                              plan.price != null &&
                              plan.price! > plan.discountPrice!) ...[
                            SizedBox(width: 8.w),
                            Text(
                              '₹${plan.price}',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF9CA3AF),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'VALID FOR ${plan.durationDays ?? 0} DAYS',
                        style: GoogleFonts.inter(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Features Checklist
                Column(
                  children: List.generate(displayedPoints.length, (i) {
                    final point = displayedPoints[i];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 2.h),
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF24ADD7,
                              ).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 13.sp,
                              color: const Color(0xFF24ADD7),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  point.name ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                    height: 1.3,
                                  ),
                                ),
                                if (point.value != null &&
                                    point.value!.trim().isNotEmpty &&
                                    point.value != '0') ...[
                                  SizedBox(height: 2.h),
                                  Text(
                                    'SAVE ${point.value}% EXTRA',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF24ADD7),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                // Expand / Collapse features toggle button (matching web)
                if (hasMorePoints)
                  Center(
                    child: InkWell(
                      onTap: () => _toggleExpanded(planId),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isExpanded
                                  ? 'LESS FEATURES'
                                  : '+${allPoints.length - 4} MORE FEATURES',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF24ADD7),
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 16.sp,
                              color: const Color(0xFF24ADD7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                SizedBox(height: 16.h),

                // Select Plan Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () => _onSelectPlan(context, plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular
                          ? const Color(0xFF24ADD7)
                          : const Color(0xFF111827),
                      foregroundColor: Colors.white,
                      elevation: isPopular ? 4 : 1,
                      shadowColor: isPopular
                          ? const Color(0xFF24ADD7).withValues(alpha: 0.4)
                          : Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Text(
                      'SELECT PLAN',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Plan Details & Confirmation Bottom Sheet with integrated loading state
class _PlanConfirmationSheet extends StatefulWidget {
  final Datum plan;
  final Future<void> Function() onConfirmed;

  const _PlanConfirmationSheet({required this.plan, required this.onConfirmed});

  @override
  State<_PlanConfirmationSheet> createState() => _PlanConfirmationSheetState();
}

class _PlanConfirmationSheetState extends State<_PlanConfirmationSheet> {
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await widget.onConfirmed();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final finalPrice = plan.discountPrice ?? plan.price ?? 0;
    final originalPrice = plan.price ?? 0;
    final hasDiscount =
        plan.discountPrice != null && originalPrice > finalPrice;
    final discountAmount = originalPrice - finalPrice;

    return PopScope(
      canPop: !_isLoading,
      child: GestureDetector(
        onVerticalDragUpdate: _isLoading ? (_) {} : null,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 18.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),

                // Plan Title & Badge
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (plan.name ?? 'SUBSCRIPTION PLAN').toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Validity: ${plan.durationDays ?? 0} Days',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF24ADD7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (plan.isPopular == true)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF24ADD7,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'POPULAR',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF24ADD7),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Price Details Summary Card
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Plan Base Price',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '₹$originalPrice',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                              decoration: hasDiscount
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                      if (hasDiscount) ...[
                        SizedBox(height: 6.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Plan Discount',
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            Text(
                              '- ₹$discountAmount',
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ],
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: const Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payable Amount',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          Text(
                            '₹$finalPrice',
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF24ADD7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Plan Highlights
                if ((plan.points ?? []).isNotEmpty) ...[
                  Text(
                    'Plan Benefits Included:',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 140.h),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: plan.points!.length,
                      itemBuilder: (context, i) {
                        final pt = plan.points![i];
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 3.h),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 15.sp,
                                color: const Color(0xFF24ADD7),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  pt.name ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF4B5563),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 18.h),
                ],

                // Confirm Button with loading progress indicator inside bottom sheet
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24ADD7),
                      disabledBackgroundColor: const Color(
                        0xFF24ADD7,
                      ).withValues(alpha: 0.7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      elevation: _isLoading ? 0 : 2,
                    ),
                    child: _isLoading
                        ? Center(
                            child: SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        : Text(
                            'CONFIRM & PROCEED',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
