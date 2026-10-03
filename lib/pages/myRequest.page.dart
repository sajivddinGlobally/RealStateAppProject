import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:realstate/Model/Body/createRazorpayOrderBodyModel.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:realstate/Controller/myRequestBookingSerivceController.dart';
import 'package:realstate/Model/cancelServiceBookingBodyModel.dart';
import 'package:realstate/Model/reseduleServiceBookingBodyModel.dart';
import 'package:realstate/Model/Body/paymentFailedBodyModel.dart';
import 'package:realstate/Model/Body/serviceRatingBodyModel.dart';
import 'package:realstate/Model/myBookingServiceRequestResModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';

import '../Model/Body/verifyRazorpayPaymentBodyModel.dart';

/// Main My Requests Page - Responsive & 1:1 with website https://propertyleinnovation.com/service/my-requests
class MyrequestPage extends ConsumerStatefulWidget {
  const MyrequestPage({super.key});

  @override
  ConsumerState<MyrequestPage> createState() => _MyrequestPageState();
}

class _MyrequestPageState extends ConsumerState<MyrequestPage> {
  static const Color primaryCyan = Color(0xFF24ADD7);
  static const Color primaryDark = Color(0xFF111827);
  static const Color bgGrey = Color(0xFFF8F9FA);
  bool isPaymentLoading = false;

  late Razorpay _razorpay;
  String? _currentPayingBookingId;

  @override
  void initState() {
    super.initState();
    try {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    } catch (e) {
      log("Razorpay init error: $e");
    }
  }

  @override
  void dispose() {
    try {
      _razorpay.clear();
    } catch (_) {}
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_currentPayingBookingId == null) return;
    try {
      // final dio = createDio();
      // final res = await dio.post(
      //   "/user/verifyRazorpayPayment",
      //   data: {
      //     'razorpay_order_id': response.orderId,
      //     'razorpay_payment_id': response.paymentId,
      //     'razorpay_signature': response.signature,
      //     'bookingId': _currentPayingBookingId,
      //   },
      // );
      final body = VerifyRazorpayPaymentBodyModel(
        bookingId: _currentPayingBookingId,
        razorpayOrderId: response.orderId,
        razorpayPaymentId: response.paymentId,
        razorpaySignature: response.signature,
      );
      final service = APIStateNetwork(createDio());
      final res = await service.verfiyRazorpayPayment(body);
      final isSuccess = res.code == 0 && (res.error == false);
      if (isSuccess) {
        Fluttertoast.showToast(
          msg: "Payment Successful! Service Completed 🎉",
          backgroundColor: const Color(0xFF24ADD7),
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
        ref.invalidate(myRequestBookingServiceContorller);
      } else {
        Fluttertoast.showToast(
          msg: res.message ?? 'Payment verification failed!',
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Payment Successful! 🎉",
        backgroundColor: const Color(0xFF24ADD7),
        textColor: Colors.white,
      );
      ref.invalidate(myRequestBookingServiceContorller);
    } finally {
      _currentPayingBookingId = null;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    try {
      final body = PaymentFailedBodyModel(
        razorpayOrderId: response.message,
        razorpayPaymentId: '',
      );
      final service = APIStateNetwork(createDio());
      final res = await service.paymentFailed(body);
      if (res.code == 0 && res.error == false) {
        Fluttertoast.showToast(
          msg: 'Payment Failed! 🎉',
          backgroundColor: const Color(0xFF24ADD7),
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
        ref.invalidate(myRequestBookingServiceContorller);
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
    _currentPayingBookingId = null;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: 'External Wallet: ${response.walletName ?? ""}',
      backgroundColor: const Color(0xFF24ADD7),
      textColor: Colors.white,
    );
  }

  void _openRazorpayCheckout(
    dynamic orderData,
    ListElement item,
    int totalAmount,
  ) {
    try {
      final box = Hive.box("userdata");
      final userEmail = box.get("email")?.toString() ?? "";
      final userPhone = box.get("phone")?.toString() ?? "";
      final userName = box.get("name")?.toString() ?? "";

      int amountInPaise = totalAmount * 100;
      String keyId = '';
      String? orderId;
      String currency = 'INR';

      if (orderData != null) {
        if (orderData is Map) {
          final amt = orderData['amount'];
          if (amt != null && amt is int && amt > 0) {
            amountInPaise = amt;
          }
          keyId =
              orderData['keyId']?.toString() ??
              orderData['key']?.toString() ??
              '';
          orderId =
              orderData['orderId']?.toString() ?? orderData['id']?.toString();
          currency = orderData['currency']?.toString() ?? 'INR';
        } else {
          try {
            if (orderData.amount != null && orderData.amount > 0) {
              amountInPaise = orderData.amount;
            }
          } catch (_) {}
          try {
            keyId = orderData.keyId?.toString() ?? '';
          } catch (_) {}
          try {
            orderId = orderData.orderId?.toString();
          } catch (_) {}
          try {
            currency = orderData.currency?.toString() ?? 'INR';
          } catch (_) {}
        }
      }

      var options = {
        'key': keyId,
        'amount': amountInPaise,
        'name': 'PropertyLe',
        'description':
            'Payment for Service Booking ID: ${item.bookingId ?? ""}',
        if (orderId != null && orderId.isNotEmpty) 'order_id': orderId,
        'currency': currency,
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

  Future<void> _payWithRazorpay(ListElement item, int totalAmount) async {
    setState(() {
      isPaymentLoading = true;
    });
    try {
      // final dio = createDio();
      // final res = await dio.post(
      //   "/user/createRazorpayOrder",
      //   data: {"bookingId": item.id},
      // );

      final service = APIStateNetwork(createDio());
      final res = await service.createRazorpayOrder(
        CreateRazorpayOrderBodyModel(bookingId: item.id),
      );

      if (res.data != null && (res.error == false || res.code == 0)) {
        final data = res.data;
        _currentPayingBookingId = item.id;
        setState(() {
          isPaymentLoading = false;
        });
        _openRazorpayCheckout(data, item, totalAmount);
      } else {
        setState(() {
          isPaymentLoading = false;
        });
        Fluttertoast.showToast(
          msg: res.message ?? "Could not initiate payment",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      log("Razorpay Checkout Error: $e");
      setState(() {
        isPaymentLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Payment error: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        isPaymentLoading = false;
      });
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Fluttertoast.showToast(msg: "Could not open dialer for $phone");
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(color: Colors.transparent),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: Colors.black,
                ),
                clipBehavior: Clip.antiAlias,
                child: PhotoView(
                  tightMode: true,
                  imageProvider: NetworkImage(imageUrl),
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2.5,
                  loadingBuilder: (context, event) => const Center(
                    child: CircularProgressIndicator(color: primaryCyan),
                  ),
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 50.sp,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40.h,
              right: 20.w,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 22.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, ListElement item) {
    bool isCancelling = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red.shade500,
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  "Cancel Booking?",
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: primaryDark,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Are you sure you want to cancel this booking? This action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          backgroundColor: Colors.grey.shade100,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: isCancelling
                            ? null
                            : () => Navigator.pop(ctx),
                        child: Text(
                          "No, Keep It",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          backgroundColor: Colors.red.shade500,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: isCancelling
                            ? null
                            : () async {
                                setDialogState(() => isCancelling = true);
                                try {
                                  final service = APIStateNetwork(createDio());
                                  final body = CancelServiceBookingBodyModel(
                                    bookingId: item.bookingId,
                                  );
                                  final res = await service
                                      .cancelServiceBooking(body);
                                  Navigator.pop(ctx);
                                  if (res.code == 0 && res.error == false) {
                                    Fluttertoast.showToast(
                                      msg:
                                          res.message ??
                                          "Booking Cancelled Successfully",
                                      backgroundColor: Colors.green,
                                    );
                                    ref.invalidate(
                                      myRequestBookingServiceContorller,
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: res.message ?? "Cancel failed",
                                      backgroundColor: Colors.red,
                                    );
                                  }
                                } catch (e) {
                                  Navigator.pop(ctx);
                                  Fluttertoast.showToast(
                                    msg: "Something went wrong",
                                  );
                                }
                              },
                        child: isCancelling
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Yes, Cancel",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRescheduleModal(BuildContext context, ListElement item) {
    DateTime? selectedDate = item.serviceDate ?? DateTime.now();
    String? selectedSlot = item.serviceTimeSlot;
    bool isSubmitting = false;

    final standardSlots = [
      "09:00 AM - 11:00 AM",
      "11:00 AM - 01:00 PM",
      "01:00 PM - 03:00 PM",
      "03:00 PM - 05:00 PM",
      "05:00 PM - 07:00 PM",
      "07:00 PM - 09:00 PM",
    ];

    bool isSlotPast(DateTime date, String slot) {
      final now = DateTime.now();
      final isToday =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
      if (!isToday) return false;

      final startPart = slot.split(" - ")[0].trim();
      final tokens = startPart.split(" ");
      if (tokens.length < 2) return false;
      final timeParts = tokens[0].split(":");
      int hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      final period = tokens[1].toUpperCase();

      if (period == "PM" && hour != 12) hour += 12;
      if (period == "AM" && hour == 12) hour = 0;

      final slotTime = DateTime(now.year, now.month, now.day, hour, minute);
      return now.isAfter(slotTime);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Reschedule Booking",
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: primaryDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Divider(height: 1, color: Colors.grey.shade200),
              SizedBox(height: 16.h),
              Text(
                "SELECT NEW DATE",
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8.h),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    setModalState(() {
                      selectedDate = picked;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: bgGrey,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate == null
                            ? "Select Date"
                            : DateFormat("dd MMM yyyy").format(selectedDate!),
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: primaryDark,
                        ),
                      ),
                      Icon(
                        Icons.calendar_month,
                        color: primaryCyan,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                "SELECT NEW TIME SLOT",
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 10.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: standardSlots.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.2,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                ),
                itemBuilder: (context, idx) {
                  final slot = standardSlots[idx];
                  final isSelected = selectedSlot == slot;
                  final isPast =
                      selectedDate != null && isSlotPast(selectedDate!, slot);

                  return InkWell(
                    onTap: isPast
                        ? null
                        : () {
                            setModalState(() {
                              selectedSlot = slot;
                            });
                          },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isPast
                            ? Colors.grey.shade100
                            : isSelected
                            ? primaryCyan
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isPast
                              ? Colors.grey.shade200
                              : isSelected
                              ? primaryCyan
                              : Colors.grey.shade300,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        slot,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: isPast
                              ? Colors.grey.shade400
                              : isSelected
                              ? Colors.white
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryCyan,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  onPressed:
                      (selectedDate != null &&
                          selectedSlot != null &&
                          !isSubmitting)
                      ? () async {
                          setModalState(() => isSubmitting = true);
                          try {
                            final service = APIStateNetwork(createDio());
                            final body = RescheduleServiceBookingBodyModel(
                              bookingId: item.bookingId,
                              serviceDate: selectedDate,
                              serviceTimeSlot: selectedSlot,
                            );
                            final res = await service.rescheduleServiceBooking(
                              body,
                            );
                            Navigator.pop(ctx);
                            if (res.code == 0 && res.error == false) {
                              Fluttertoast.showToast(
                                msg:
                                    res.message ??
                                    "Booking Rescheduled Successfully",
                                backgroundColor: Colors.green,
                              );
                              ref.invalidate(myRequestBookingServiceContorller);
                            } else {
                              Fluttertoast.showToast(
                                msg: res.message ?? "Reschedule failed",
                                backgroundColor: Colors.red,
                              );
                            }
                          } catch (e) {
                            Navigator.pop(ctx);
                            Fluttertoast.showToast(msg: "Something went wrong");
                          }
                        }
                      : null,
                  child: isSubmitting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Confirm Reschedule",
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myRequestAsync = ref.watch(myRequestBookingServiceContorller);

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
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
              color: primaryDark,
            ),
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Requests",
              style: GoogleFonts.inter(
                color: primaryDark,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              "Manage and track your service bookings",
              style: GoogleFonts.inter(
                color: Colors.grey.shade500,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.w),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(
              Icons.handyman_outlined,
              color: primaryCyan,
              size: 20.sp,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryCyan,
          onRefresh: () async {
            ref.invalidate(myRequestBookingServiceContorller);
          },
          child: myRequestAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: primaryCyan),
            ),
            error: (err, stack) => Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      size: 48.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Failed to load requests",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryDark,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      err.toString(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () =>
                          ref.invalidate(myRequestBookingServiceContorller),
                      child: Text(
                        "Retry",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (response) {
              final list = response.data?.list ?? [];

              if (list.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  return _ServiceBookingCard(
                    key: ValueKey(
                      item.id ?? item.bookingId ?? index.toString(),
                    ),
                    item: item,
                    isPaymentLoading: isPaymentLoading,
                    onPayNow: (amount) => _payWithRazorpay(item, amount),
                    onPhoneCall: (phone) => _makePhoneCall(phone),
                    onShowImage: (url) => _showFullScreenImage(context, url),
                    onCancel: () => _showCancelDialog(context, item),
                    onReschedule: () => _showRescheduleModal(context, item),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: 100.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.handyman_outlined,
                  color: Colors.grey.shade400,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "No Booking Found",
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: primaryDark,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "You haven't requested any services yet.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryCyan,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () => Navigator.maybePop(context),
                child: Text(
                  "Book New Service",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Single Service Booking Card
class _ServiceBookingCard extends ConsumerStatefulWidget {
  final ListElement item;
  final Function(int totalAmount) onPayNow;
  final Function(String phone) onPhoneCall;
  final Function(String url) onShowImage;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;
  final bool isPaymentLoading;

  const _ServiceBookingCard({
    super.key,
    required this.item,
    required this.onPayNow,
    required this.onPhoneCall,
    required this.onShowImage,
    required this.onCancel,
    required this.onReschedule,
    required this.isPaymentLoading,
  });

  @override
  ConsumerState<_ServiceBookingCard> createState() =>
      _ServiceBookingCardState();
}

class _ServiceBookingCardState extends ConsumerState<_ServiceBookingCard> {
  static const Color primaryCyan = Color(0xFF24ADD7);
  static const Color primaryDark = Color(0xFF111827);

  // Review Draft State
  int _ratingStars = 0;
  final TextEditingController _reviewController = TextEditingController();
  File? _reviewImage;
  bool _isSubmittingReview = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  int get _visitingFee {
    int fee = 0;
    for (final it in widget.item.items ?? []) {
      if ((it.serviceFee ?? 0) > fee) {
        fee = it.serviceFee!;
      }
    }
    return fee;
  }

  int get _itemsTotal {
    return (widget.item.items ?? []).fold<int>(
      0,
      (sum, el) => sum + (el.price ?? 0),
    );
  }

  int get _calculatedTotal {
    return _itemsTotal + _visitingFee;
  }

  int _getStepIndex(String status, String? paymentStatus, String? beforeImage) {
    final s = status.toLowerCase();
    final isPaid = paymentStatus?.toLowerCase() == 'paid';
    if (s == 'pending') return 0;
    if (s == 'assigned' || s == 'on_the_way' || s == 'on_way') return 1;
    if (s == 'in_progress' || s == 'working') {
      return beforeImage != null ? 2 : 1;
    }
    if (s == 'waiting_for_payment' ||
        s == 'wating_for_payment' ||
        s == 'waiting_for_approval' ||
        s == 'complete' ||
        s == 'completed') {
      return isPaid ? 4 : 3;
    }
    return 0;
  }

  Future<void> _pickReviewImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (file != null) {
      setState(() {
        _reviewImage = File(file.path);
      });
    }
  }

  void _showImagePickerSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text("Attach Photo"),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _pickReviewImage(ImageSource.camera);
            },
            child: const Text("Camera"),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _pickReviewImage(ImageSource.gallery);
            },
            child: const Text("Gallery"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("Cancel"),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_ratingStars == 0) {
      Fluttertoast.showToast(msg: "Please select a rating!");
      return;
    }

    setState(() => _isSubmittingReview = true);
    try {
      String imageUrl = "";
      final service = APIStateNetwork(createDio());

      if (_reviewImage != null) {
        final uploadRes = await service.uploadImage(_reviewImage!);
        if (uploadRes.code == 0 &&
            uploadRes.error == false &&
            uploadRes.data?.imageUrl != null) {
          imageUrl = uploadRes.data!.imageUrl!;
        }
      }

      final body = ServiceRatingBodyModel(
        serviceBooking: widget.item.id,
        rating: _ratingStars,
        review: _reviewController.text.trim(),
        image: imageUrl,
      );

      final res = await service.createServiceRating(body);
      if (res.code == 0 && res.error == false) {
        Fluttertoast.showToast(
          msg: "Review submitted successfully!",
          backgroundColor: Colors.green,
        );
        setState(() {
          _ratingStars = 0;
          _reviewController.clear();
          _reviewImage = null;
        });
        ref.invalidate(myRequestBookingServiceContorller);
      } else {
        Fluttertoast.showToast(msg: res.message ?? "Failed to submit review");
      }
    } catch (e) {
      log("Review submit error: $e");
      Fluttertoast.showToast(msg: "Failed to submit review");
    } finally {
      setState(() => _isSubmittingReview = false);
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return "N/A";
    return DateFormat("dd MMM yyyy").format(dt);
  }

  String _formatArrivalTime(String? iso) {
    if (iso == null || iso.isEmpty) return "";
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat("hh:mm a").format(dt);
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final status = (item.status ?? "pending").toLowerCase();
    final isCancelled = status == 'cancelled' || status == 'rejected';
    final isPaid = item.paymentStatus?.toLowerCase() == 'paid';
    final isPaymentPending =
        !isPaid &&
        (status == 'waiting_for_payment' ||
            status == 'wating_for_payment' ||
            status == 'waiting_for_approval' ||
            status == 'complete' ||
            status == 'completed');
    final hasRatings = item.ratings != null && item.ratings!.isNotEmpty;
    final firstRating = hasRatings ? item.ratings![0] : null;

    final serviceName = item.serviceType?.name ?? "Service Request";
    final serviceImage = item.serviceType?.image;

    final stepIndex = _getStepIndex(
      status,
      item.paymentStatus,
      item.beforeImage,
    );

    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Booking ID + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  border: Border.all(color: const Color(0xFFFFEDD5)),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  "ID: ${item.bookingId ?? 'N/A'}",
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: primaryCyan,
                  ),
                ),
              ),
              Row(
                children: [
                  if (status == 'complete' &&
                      hasRatings &&
                      firstRating != null) ...[
                    // Row(
                    //   children: List.generate(5, (starIdx) {
                    //     final isFilled = starIdx < (firstRating.rating ?? 0);
                    //     return Icon(
                    //       Icons.star_rounded,
                    //       size: 16.sp,
                    //       color: isFilled
                    //           ? const Color(0xFFFBBF24)
                    //           : Colors.grey.shade300,
                    //     );
                    //   }),
                    // ),
                    SizedBox(width: 8.w),
                  ],
                  _buildStatusChip(status, isPaid, isPaymentPending),
                ],
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // 2. Service Summary Row (Thumbnail + Title + Details Badges)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Thumbnail
              GestureDetector(
                onTap: () {
                  if (serviceImage != null && serviceImage.isNotEmpty) {
                    widget.onShowImage(serviceImage);
                  }
                },
                child: Container(
                  width: 76.w,
                  height: 76.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: serviceImage != null && serviceImage.isNotEmpty
                      ? Image.network(
                          serviceImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.home_repair_service,
                            color: primaryCyan,
                            size: 32.sp,
                          ),
                        )
                      : Icon(
                          Icons.home_repair_service,
                          color: primaryCyan,
                          size: 32.sp,
                        ),
                ),
              ),

              SizedBox(width: 12.w),

              // Title & Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: primaryDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: [
                        _buildInfoPill(
                          icon: Icons.calendar_today_outlined,
                          text: _formatDate(item.serviceDate),
                        ),
                        if (item.serviceTimeSlot != null &&
                            item.serviceTimeSlot!.isNotEmpty)
                          _buildInfoPill(
                            icon: Icons.access_time_outlined,
                            text: item.serviceTimeSlot!,
                          ),
                        if (item.address != null && item.address!.isNotEmpty)
                          _buildInfoPill(
                            icon: Icons.location_on_outlined,
                            text: item.address!,
                            isAddress: true,
                          ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: const Color(0xFFDCFCE7)),
                          ),
                          child: Text(
                            "₹$_visitingFee",
                            style: GoogleFonts.inter(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? const Color(0xFFF0FDF4)
                                : const Color(0xFFFEF9C3),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: isPaid
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEF08A),
                            ),
                          ),
                          child: Text(
                            "Payment ${item.paymentStatus ?? 'Pending'}",
                            style: GoogleFonts.inter(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w700,
                              color: isPaid
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFF854D0E),
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

          // 3. Service Partner Card (if assigned)
          if (item.serviceBoy != null && !isCancelled) ...[
            SizedBox(height: 14.h),
            _buildServicePartnerCard(item),
          ],

          // 4. Pending Action Buttons (Reschedule / Cancel)
          if (status == 'pending') ...[
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: primaryCyan, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: widget.onReschedule,
                    child: Text(
                      "Reschedule Time",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryCyan,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.red.shade400, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: widget.onCancel,
                    child: Text(
                      "Cancel Booking",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 14.h),

          // 5. Problem Reported Section
          _buildProblemReportedSection(item),

          // 6. Payment Pending Banner (if applicable)
          if (isPaymentPending) ...[
            SizedBox(height: 14.h),
            _buildPaymentPendingBanner(item, widget.isPaymentLoading),
          ],

          // 7. Review / Feedback Section
          if (status == 'complete' ||
              status == 'completed' ||
              status == 'waiting_for_approval' ||
              item.afterImage != null) ...[
            SizedBox(height: 14.h),
            _buildReviewFeedbackSection(item),
          ],

          SizedBox(height: 16.h),

          // 8. Bottom Stepper or Cancelled Banner
          Divider(height: 1, color: Colors.grey.shade200),
          SizedBox(height: 14.h),
          if (isCancelled)
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFFEE2E2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    color: Colors.red.shade600,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "Service Cancelled",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            _buildStatusStepper(stepIndex),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isPaid, bool isPaymentPending) {
    if (isPaymentPending) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Text(
          "Payment Pending",
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFD97706),
          ),
        ),
      );
    }

    if ((status == 'complete' || status == 'completed') && isPaid) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Text(
          "Complete",
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF16A34A),
          ),
        ),
      );
    }

    // Default status pill
    final displayStatus = status.replaceAll("_", " ");
    final capitalized = displayStatus.isNotEmpty
        ? displayStatus[0].toUpperCase() + displayStatus.substring(1)
        : "Pending";

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Text(
        capitalized,
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2563EB),
        ),
      ),
    );
  }

  Widget _buildInfoPill({
    required IconData icon,
    required String text,
    bool isAddress = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: primaryCyan),
          SizedBox(width: 4.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isAddress ? 160.w : 140.w),
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicePartnerCard(ListElement item) {
    final partner = item.serviceBoy!;
    final arrivalTime = _formatArrivalTime(item.serviceProviderArrivalTime);
    final isAssigned = item.status?.toLowerCase() == 'assigned';
    final hasOtp =
        item.verificationOtp != null && item.verificationOtp!.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: () {
                  if (partner.image != null && partner.image!.isNotEmpty) {
                    widget.onShowImage(partner.image!);
                  }
                },
                child: Stack(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: partner.image != null && partner.image!.isNotEmpty
                          ? Image.network(
                              partner.image!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.person,
                                color: Colors.grey.shade400,
                                size: 26.sp,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              color: Colors.grey.shade400,
                              size: 26.sp,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14.w,
                        height: 14.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 12.w),

              // Partner Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SERVICE PARTNER",
                      style: GoogleFonts.inter(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0284C7),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      partner.name ?? "Service Partner",
                      style: GoogleFonts.inter(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    if (arrivalTime.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: const Color(0xFFFFEDD5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 11.sp,
                              color: const Color(0xFFC2410C),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              arrivalTime,
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFC2410C),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (partner.phone != null && partner.phone!.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 11.sp,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            partner.phone!,
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Phone Call Icon Button
              if (partner.phone != null && partner.phone!.isNotEmpty)
                IconButton(
                  onPressed: () => widget.onPhoneCall(partner.phone!),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 1,
                    shadowColor: Colors.black12,
                  ),
                  icon: Icon(
                    Icons.phone,
                    color: const Color(0xFF16A34A),
                    size: 18.sp,
                  ),
                ),
            ],
          ),

          // OTP Container
          if (isAssigned && hasOtp) ...[
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFBFDBFE)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.03),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "SHARE THIS OTP WITH AGENT",
                    style: GoogleFonts.inter(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2563EB),
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.verificationOtp!,
                    style: GoogleFonts.inter(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E40AF),
                      letterSpacing: 5.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProblemReportedSection(ListElement item) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.report_problem_outlined,
                size: 15.sp,
                color: const Color(0xFFF97316),
              ),
              SizedBox(width: 6.w),
              Text(
                "PROBLEM REPORTED",
                style: GoogleFonts.inter(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // 3 Info Grid tiles
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  label: "ADDRESS",
                  value: item.address ?? "N/A",
                ),
                Divider(height: 14.h, color: Colors.grey.shade100),
                _buildInfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: "SERVICE DATE",
                  value: _formatDate(item.serviceDate),
                ),
                Divider(height: 14.h, color: Colors.grey.shade100),
                _buildInfoRow(
                  icon: Icons.access_time_outlined,
                  label: "TIME SLOT",
                  value: item.serviceTimeSlot ?? "N/A",
                ),
              ],
            ),
          ),

          // Requested Services List
          if (item.items != null && item.items!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              "REQUESTED SERVICES",
              style: GoogleFonts.inter(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 6.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: item.items!.length,
              separatorBuilder: (_, __) => SizedBox(height: 6.h),
              itemBuilder: (context, idx) {
                final svc = item.items![idx];
                return Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      // Thumbnail
                      if (svc.image != null && svc.image!.isNotEmpty)
                        Container(
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            color: Colors.grey.shade100,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            svc.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFEFF6FF),
                              alignment: Alignment.center,
                              child: Text(
                                svc.title?.isNotEmpty == true
                                    ? svc.title![0]
                                    : "S",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  color: primaryCyan,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            color: const Color(0xFFEFF6FF),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            svc.title?.isNotEmpty == true ? svc.title![0] : "S",
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: primaryCyan,
                            ),
                          ),
                        ),

                      SizedBox(width: 10.w),

                      // Service Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    svc.title ?? "Service Item",
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: primaryDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (svc.isExtra == true) ...[
                                  SizedBox(width: 6.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3E8FF),
                                      borderRadius: BorderRadius.circular(4.r),
                                      border: Border.all(
                                        color: const Color(0xFFE9D5FF),
                                      ),
                                    ),
                                    child: Text(
                                      "EXTRA",
                                      style: GoogleFonts.inter(
                                        fontSize: 8.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF7E22CE),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (svc.description != null &&
                                svc.description!.isNotEmpty) ...[
                              SizedBox(height: 2.h),
                              Text(
                                svc.description!,
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  color: Colors.grey.shade500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Price
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFDCFCE7)),
                        ),
                        child: Text(
                          "₹${svc.price ?? 0}",
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],

          SizedBox(height: 10.h),

          // Visiting Fee Row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: const BoxDecoration(
                        color: primaryCyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Service Charge / Visiting Fee",
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E40AF),
                      ),
                    ),
                  ],
                ),
                Text(
                  "₹$_visitingFee",
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: primaryCyan,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // Total Payable Dark Banner
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1F2937), Color(0xFF111827)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TOTAL PAYABLE AMOUNT",
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade400,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "(All Services + Service Charge Included)",
                      style: GoogleFonts.inter(
                        fontSize: 9.5.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                Text(
                  "₹$_calculatedTotal",
                  style: GoogleFonts.inter(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFB923C),
                  ),
                ),
              ],
            ),
          ),

          // Problem Image & Message
          if (item.problemImgae != null && item.problemImgae!.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => widget.onShowImage(item.problemImgae!),
                  child: Container(
                    width: 70.w,
                    height: 70.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      item.problemImgae!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.broken_image, color: Colors.grey.shade400),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PROBLEM MESSAGE",
                          style: GoogleFonts.inter(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey.shade400,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '"${item.message ?? 'No details provided'}"',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ] else if (item.message != null && item.message!.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PROBLEM MESSAGE",
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '"${item.message}"',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.sp, color: primaryCyan),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 8.5.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade400,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: primaryDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentPendingBanner(ListElement item, isPaymentLoading) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFEF2F2), const Color(0xFFFFF7ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.payment,
                      color: Colors.red.shade600,
                      size: 22.sp,
                    ),
                  ),
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "PAYMENT PENDING",
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.red.shade700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            "₹$_calculatedTotal",
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Please complete the payment or scan QR code to finish your request.",
                      style: GoogleFonts.inter(
                        fontSize: 10.5.sp,
                        color: Colors.red.shade900.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (item.qrCodeImage != null && item.qrCodeImage!.isNotEmpty) ...[
            GestureDetector(
              onTap: () => widget.onShowImage(item.qrCodeImage!),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Image.network(
                  item.qrCodeImage!,
                  width: 90.w,
                  height: 90.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () => widget.onPayNow(_calculatedTotal),
              child: isPaymentLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 1.5.w,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "PAY ₹$_calculatedTotal",
                          style: GoogleFonts.inter(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16.sp,
                          color: Colors.white,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewFeedbackSection(ListElement item) {
    final hasRatings = item.ratings != null && item.ratings!.isNotEmpty;
    final firstRating = hasRatings ? item.ratings![0] : null;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: hasRatings && firstRating != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 16.sp,
                      color: const Color(0xFFFBBF24),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "YOUR FEEDBACK",
                      style: GoogleFonts.inter(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '"${firstRating.review?.isNotEmpty == true ? firstRating.review : 'No written review'}"',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: const Color(0xFFFBBF24),
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "${firstRating.rating ?? 0} / 5",
                              style: GoogleFonts.inter(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w700,
                                color: primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (firstRating.image != null &&
                    firstRating.image!.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: () => widget.onShowImage(firstRating.image!),
                    child: Container(
                      width: 70.w,
                      height: 70.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        firstRating.image!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star_outline_rounded,
                      size: 16.sp,
                      color: const Color(0xFFFBBF24),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "SHARE YOUR EXPERIENCE",
                      style: GoogleFonts.inter(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (starIdx) {
                        final starNumber = starIdx + 1;
                        final isFilled = starNumber <= _ratingStars;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _ratingStars = starNumber;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: Icon(
                              Icons.star_rounded,
                              size: 28.sp,
                              color: isFilled
                                  ? const Color(0xFFFBBF24)
                                  : Colors.grey.shade300,
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      _ratingStars > 0
                          ? "$_ratingStars Star${_ratingStars > 1 ? 's' : ''}"
                          : "Select rating",
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: _reviewController,
                  maxLines: 2,
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    color: primaryDark,
                  ),
                  decoration: InputDecoration(
                    hintText: "How was the service? (optional)",
                    hintStyle: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey.shade400,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: primaryCyan),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    // Photo Attachment Button
                    InkWell(
                      onTap: _showImagePickerSheet,
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: const Color(0xFFFFEDD5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: primaryCyan,
                              size: 16.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              _reviewImage != null
                                  ? "Change Photo"
                                  : "Add Photo",
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: primaryCyan,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_reviewImage != null) ...[
                      SizedBox(width: 8.w),
                      Stack(
                        children: [
                          Container(
                            width: 34.w,
                            height: 34.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.file(_reviewImage!, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: -4,
                            right: -4,
                            child: GestureDetector(
                              onTap: () => setState(() => _reviewImage = null),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                      ),
                      onPressed: (_ratingStars > 0 && !_isSubmittingReview)
                          ? _submitReview
                          : null,
                      child: _isSubmittingReview
                          ? SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Submit",
                              style: GoogleFonts.inter(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildStatusStepper(int activeIndex) {
    final steps = [
      {"title": "Confirmed", "icon": Icons.check_circle_outline},
      {"title": "Assigned", "icon": Icons.person_pin_circle_outlined},
      {"title": "Working", "icon": Icons.handyman_outlined},
      {"title": "Payment", "icon": Icons.account_balance_wallet_outlined},
      {"title": "Completed", "icon": Icons.task_alt_outlined},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final itemWidth = totalWidth / steps.length;
        final lineStart = itemWidth / 2;
        final lineWidth = totalWidth - itemWidth;
        final clampedIndex = activeIndex.clamp(0, steps.length - 1);
        final activeLineWidth = lineWidth * (clampedIndex / (steps.length - 1));

        return Stack(
          alignment: Alignment.topCenter,
          children: [
            // Background Inactive Connecting Line
            Positioned(
              top: 15.w,
              left: lineStart,
              width: lineWidth,
              child: Container(
                height: 2.5.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // Active Progress Line
            if (clampedIndex > 0)
              Positioned(
                top: 15.w,
                left: lineStart,
                width: activeLineWidth,
                child: Container(
                  height: 2.5.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

            // 5 Step Columns
            Row(
              children: List.generate(steps.length, (idx) {
                final isReached = idx <= activeIndex;
                final isCurrent = idx == activeIndex;

                return Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 30.w,
                        height: 30.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: isReached
                                ? const Color(0xFF22C55E)
                                : Colors.grey.shade300,
                            width: isCurrent ? 2.5 : 1.5,
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF22C55E,
                                    ).withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          steps[idx]["icon"] as IconData,
                          size: 14.sp,
                          color: isReached
                              ? const Color(0xFF16A34A)
                              : Colors.grey.shade400,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.w),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            steps[idx]["title"] as String,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: isReached
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isReached
                                  ? primaryDark
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
