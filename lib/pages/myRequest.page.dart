import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:realstate/Controller/myRequestBookingSerivceController.dart';
import 'package:realstate/Model/cancelServiceBookingBodyModel.dart';
import 'package:realstate/Model/reseduleServiceBookingBodyModel.dart';
import 'package:realstate/Model/verfiyServiceAgenetBodyModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Model/myBookingServiceRequestResModel.dart';
import 'rating.page.dart';

class MyrequestPage extends ConsumerStatefulWidget {
  const MyrequestPage({super.key});

  @override
  ConsumerState<MyrequestPage> createState() => _MyrequestPageState();
}

class _MyrequestPageState extends ConsumerState<MyrequestPage> {
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.amber;
      case 'on_way':
        return Colors.blue;
      case 'working':
        return Colors.indigo;
      case 'complete':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  final ratingProvider = StateProvider.family<int, String>((ref, id) => 0);
  final reviewTextProvider = StateProvider.family<String, String>(
    (ref, id) => "",
  );

  File? problemSolvePhtot;
  String existingImage = "";

  final ImagePicker _picker = ImagePicker();

  /// Pick image (Camera / Gallery)
  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        problemSolvePhtot = File(pickedFile.path);
      });
    }
  }

  /// Bottom sheet for image picker
  void showImagePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
              child: const Text("Camera"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
              child: const Text("Gallery"),
            ),
          ],
        );
      },
    );
  }

  DateTime? selectedDate;
  String? selectedSlot;
  bool isReschedule = false;

  void showRescheduleDialog(
    BuildContext context,
    List<Slot> slots,
    String bookingId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            bool isButtonEnabled = selectedDate != null && selectedSlot != null;
            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 24.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 20.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Header
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Reschedule Booking",
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              dialogSetState(() {
                                selectedDate = null;
                                selectedSlot = null;
                              });
                            },
                            icon: Icon(Icons.close, size: 24.sp),
                          ),
                        ],
                      ),

                      Divider(thickness: 1.h),

                      SizedBox(height: 15.h),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "SELECT NEW DATE",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),

                      SizedBox(height: 8.h),

                      InkWell(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                          );

                          if (picked != null) {
                            dialogSetState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(15.w),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1.w,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedDate == null
                                    ? "Select Date"
                                    : DateFormat(
                                        "dd/MM/yyyy",
                                      ).format(selectedDate!),
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              Icon(
                                Icons.calendar_month,
                                color: Colors.black54,
                                size: 22.sp,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      Text(
                        "SELECT TIME SLOT",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: slots.length,
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3.5,
                          crossAxisSpacing: 10.w,
                          mainAxisSpacing: 10.h,
                        ),
                        itemBuilder: (context, index) {
                          final slot = slots[index].timeSlot;
                          bool isSelected = selectedSlot == slot;

                          return InkWell(
                            onTap: () {
                              dialogSetState(() {
                                selectedSlot = slot;
                              });
                            },
                            borderRadius: BorderRadius.circular(10.r),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF24ADD7)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF24ADD7)
                                      : Colors.grey.shade400,
                                  width: 1.w,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF24ADD7,
                                          ).withOpacity(0.3),
                                          blurRadius: 5.r,
                                          offset: Offset(0, 3.h),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                child: Text(
                                  slot ?? "",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.blueGrey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF24ADD7),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            disabledBackgroundColor: Colors.grey.shade400,
                            disabledForegroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          onPressed: isButtonEnabled
                              ? () async {
                                  dialogSetState(() {
                                    isReschedule = true;
                                  });
                                  final body =
                                      RescheduleServiceBookingBodyModel(
                                        serviceDate: selectedDate,
                                        serviceTimeSlot: selectedSlot,
                                        bookingId: bookingId,
                                      );

                                  try {
                                    final service = APIStateNetwork(
                                      createDio(),
                                    );
                                    final res = await service
                                        .rescheduleServiceBooking(body);
                                    if (res.code == 0 && res.error == false) {
                                      ref.invalidate(
                                        myRequestBookingServiceContorller,
                                      );
                                      Navigator.pop(context);
                                      Fluttertoast.showToast(
                                        msg:
                                            res.message ??
                                            "Reschedule Sucessfull",
                                      );
                                      dialogSetState(() {
                                        selectedDate = null;
                                        selectedSlot = null;
                                      });
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: res.message ?? "Reschedule Failed",
                                      );
                                      dialogSetState(() {
                                        isReschedule = false;
                                      });
                                    }
                                  } catch (e) {
                                    log(e.toString());
                                    dialogSetState(() {
                                      isReschedule = false;
                                    });
                                  } finally {
                                    dialogSetState(() {
                                      isReschedule = false;
                                    });
                                  }
                                }
                              : null,
                          child: isReschedule
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 1.5,
                                    ),
                                  ),
                                )
                              : Text(
                                  "Confirm Reschedule",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Rating>? ratings;
    const primaryColor = Color(0xFF24ADD7);
    final myRequestProvider = ref.watch(myRequestBookingServiceContorller);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "My Service Requests",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: primaryColor,
          color: Colors.white,
          onRefresh: () async {
            ref.invalidate(myRequestBookingServiceContorller);
          },
          child: myRequestProvider.when(
            data: (data) {
              final list = data.data?.list ?? [];
              if (list.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: EdgeInsets.all(15.w),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  final status = (item.status ?? "pending").toLowerCase();
                  return Container(
                    margin: EdgeInsets.only(bottom: 15.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildCardHeader(item, status, primaryColor),
                        _buildItemsList(item, primaryColor),
                        // 2. Status Stepper (new chain)
                        if (status != "cancelled")
                          _buildStatusStepper(item, status, primaryColor),

                        const Divider(height: 1),

                        // 4. Verification & Technician Section
                        if (status != 'rejected')
                          _buildVerificationCard(
                            item,
                            context,
                            primaryColor,
                            ref,
                            status,
                          ),
                        ///////// reschedule dialog
                        if (status == "pending")
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 45.h,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        showRescheduleDialog(
                                          context,
                                          item.serviceType?.slots ?? [],
                                          item.bookingId.toString(),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8.h,
                                        ),
                                        side: BorderSide(
                                          color: const Color(0xFF24ADD7),
                                          width: 1.2.w,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Reschedule",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF24ADD7),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: SizedBox(
                                    height: 42.h,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        showGeneralDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          barrierLabel: "Loading",
                                          barrierColor: Colors.black38,
                                          transitionDuration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          pageBuilder: (_, __, ___) {
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                color: Color(0xFF24ADD7),
                                              ),
                                            );
                                          },
                                        );

                                        try {
                                          final body =
                                              CancelServiceBookingBodyModel(
                                                bookingId: item.bookingId,
                                              );

                                          final service = APIStateNetwork(
                                            createDio(),
                                          );
                                          final res = await service
                                              .cancelServiceBooking(body);

                                          if (res.code == 0 ||
                                              res.error == false) {
                                            ref.invalidate(
                                              myRequestBookingServiceContorller,
                                            );
                                            Fluttertoast.showToast(
                                              msg:
                                                  res.message ??
                                                  "Booking cancelled successfully",
                                            );
                                          } else {
                                            Fluttertoast.showToast(
                                              msg:
                                                  res.message ??
                                                  "Something went wrong",
                                            );
                                          }
                                        } catch (e) {
                                          log(e.toString());

                                          Fluttertoast.showToast(
                                            msg: "Something went wrong",
                                          );
                                        } finally {
                                          if (mounted) {
                                            Navigator.of(
                                              context,
                                              rootNavigator: true,
                                            ).pop();
                                          }
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Color(0xFF24ADD7),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8.h,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          fontSize: 14.sp,
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
                        // 5. Footer
                        _buildFooter(item, primaryColor),
                      ],
                    ),
                  );
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_late_outlined,
            size: 80.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            "No Requests Found",
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            "You haven't booked any services yet.",
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(dynamic item, String status, Color primaryColor) {
    final lowerStatus = status.toLowerCase();
    final bool hasServiceBoy =
        item.serviceBoy != null && item.serviceBoy?.name != null;

    final bool isCompleted = lowerStatus == 'complete';
    final bool isWorking =
        lowerStatus == 'working' || lowerStatus == 'waiting_for_approval';
    final bool isAssigned =
        lowerStatus == 'in_progress' ||
        lowerStatus == 'assigned' ||
        lowerStatus == 'on_the_way' ||
        hasServiceBoy;
    final bool isPending = lowerStatus == 'pending' && !hasServiceBoy;

    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  "ID:${(item.bookingId ?? "")}",
                  style: TextStyle(color: primaryColor, fontSize: 10.sp),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.shade50
                      : isWorking
                      ? Colors.purple.shade50
                      : isAssigned
                      ? Colors.blue.shade50
                      : lowerStatus == 'cancelled' || lowerStatus == 'rejected'
                      ? Colors.red.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isCompleted
                        ? Colors.green.shade200
                        : isWorking
                        ? Colors.purple.shade200
                        : isAssigned
                        ? Colors.blue.shade200
                        : lowerStatus == 'cancelled' ||
                              lowerStatus == 'rejected'
                        ? Colors.red.shade200
                        : Colors.orange.shade200,
                  ),
                ),
                child: Text(
                  "${(item.status ?? "").toUpperCase()}",
                  style: TextStyle(
                    color: isCompleted
                        ? Colors.green.shade700
                        : isWorking
                        ? Colors.purple.shade700
                        : isAssigned
                        ? Colors.blue.shade700
                        : lowerStatus == 'cancelled' ||
                              lowerStatus == 'rejected'
                        ? Colors.red.shade700
                        : Colors.orange.shade700,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Image.network(
                  item.serviceType?.image ?? "",
                  width: 40.w,
                  height: 40.w,
                  errorBuilder: (c, e, s) =>
                      Icon(Icons.build, color: primaryColor, size: 30.sp),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.serviceType?.name ?? "Service",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    Row(
                      children: [
                        _buildDetailChip(
                          icon: Icons.calendar_month,
                          text: DateFormat(
                            'd MMM yyyy',
                          ).format(DateTime.parse(item.serviceDate.toString())),
                          iconColor: Colors.orange,
                        ),
                        SizedBox(width: 5.w),
                        _buildDetailChip(
                          icon: Icons.access_time_filled,
                          text: item.serviceTimeSlot,
                          iconColor: Colors.orange,
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FB),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 2.h),
                                  child: Icon(
                                    Icons.location_on,
                                    size: 10.sp,
                                    color: Colors.orange,
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                Expanded(
                                  child: Text(
                                    item.address ?? "",
                                    style: GoogleFonts.roboto(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF37474F),
                                    ),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(dynamic item, Color primaryColor) {
    final items = item.items;
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    final mainItems = items.where((e) => e.isExtra != true).toList();
    final extraItems = items.where((e) => e.isExtra == true).toList();

    int totalServiceCharges = 0;
    int totalAmountPayable = 0;
    for (var i in items) {
      if (i.serviceFee != null) {
        totalServiceCharges += (i.serviceFee as int);
      }
      if (i.price != null) {
        totalAmountPayable += (i.price as int);
      }
    }
    totalAmountPayable += totalServiceCharges;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mainItems.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                child: Text(
                  "BOOKED SERVICES",
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ...mainItems.map(
                (item) => _buildItemRow(item, false, primaryColor),
              ),
            ],
            if (extraItems.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                child: const Divider(height: 1, color: Colors.black12),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.orange.shade700,
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "ADDITIONAL EXTRA WORK",
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              ...extraItems.map(
                (item) => _buildItemRow(item, true, primaryColor),
              ),
            ],
            if (totalServiceCharges > 0) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                child: const Divider(height: 1, color: Colors.black12),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Service Charges",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "₹$totalServiceCharges",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Amount Payable",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.green.shade800,
                    ),
                  ),
                  Text(
                    "₹$totalAmountPayable",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(dynamic item, bool isExtra, Color primaryColor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 4.h, right: 10.w),
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: isExtra ? Colors.orange.shade400 : primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              item.title ?? "Item",
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            "₹${item.price ?? 0}",
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: isExtra ? Colors.orange.shade700 : primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String text,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.sp, color: iconColor),
          SizedBox(width: 5.w),
          Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF37474F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStepper(dynamic item, String status, Color primaryColor) {
    final lowerStatus = status.toLowerCase();
    final bool hasServiceBoy =
        item.serviceBoy != null && item.serviceBoy?.name != null;

    if (lowerStatus == 'rejected') {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cancel, color: Colors.red, size: 22.sp),
                SizedBox(width: 10.w),
                Text(
                  "REQUEST REJECTED",
                  style: GoogleFonts.inter(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    int currentStepIndex = 0;
    bool isPaymentState =
        lowerStatus == 'waiting_for_approval' ||
        (item.afterImage != null && item.afterImage!.trim().isNotEmpty);

    if (lowerStatus == 'complete') {
      currentStepIndex = 4;
    } else if (isPaymentState) {
      currentStepIndex = 3;
    } else if (lowerStatus == 'in_progress' || lowerStatus == 'working') {
      if (item.beforeImage != null && item.beforeImage!.trim().isNotEmpty) {
        currentStepIndex = 2;
      } else {
        currentStepIndex = 1;
      }
    } else if (lowerStatus == 'assigned' || lowerStatus == 'on_the_way') {
      currentStepIndex = 1;
    } else if (lowerStatus == 'pending') {
      currentStepIndex = hasServiceBoy ? 1 : 0;
    }

    final int activeUntil = currentStepIndex;

    final stepTitles = [
      "Confirmed",
      "Assigned",
      // "On Way",
      "Working",
      "Payment",
      "Completed",
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(stepTitles.length * 2 - 1, (index) {
          if (index.isOdd) {
            final lineIndex = index ~/ 2;
            final bool isLineActive = lineIndex < activeUntil;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 20.w),
                child: Container(
                  height: 3.h,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: isLineActive ? primaryColor : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            );
          } else {
            final i = index ~/ 2;
            final bool isCircleActive = i <= activeUntil;
            final bool isCurrent = i == activeUntil && activeUntil < 4;
            final bool isCompleted = i < activeUntil || activeUntil == 4;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 40.w,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isCurrent ? 36.w : 28.w,
                      height: isCurrent ? 36.w : 28.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isCompleted || isCurrent)
                            ? primaryColor
                            : Colors.white,
                        border: Border.all(
                          color: (isCompleted || isCurrent)
                              ? primaryColor
                              : Colors.grey.shade300,
                          width: 2.w,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 18.sp,
                              )
                            : isCurrent
                            ? Icon(
                                Icons.sync_rounded,
                                color: Colors.white,
                                size: 18.sp,
                              )
                            : Text(
                                '${i + 1}',
                                style: GoogleFonts.inter(
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  stepTitles[i],
                  style: GoogleFonts.inter(
                    fontSize: isCurrent ? 11.sp : 10.sp,
                    color: (isCompleted || isCurrent)
                        ? primaryColor
                        : Colors.grey.shade500,
                    fontWeight: isCurrent || isCompleted
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }

  Widget _buildDetailsSection(dynamic item, String status) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        children: [
          _infoRow(
            Icons.location_on_outlined,
            "Address",
            item.address ?? "No Address Provided",
          ),
          if ((item.message ?? "").isNotEmpty) ...[
            SizedBox(height: 10.h),
            _infoRow(Icons.message_outlined, "Message", item.message!),
          ],
        ],
      ),
    );
  }

  Widget _buildVerificationCard(
    dynamic item,
    BuildContext context,
    Color primaryColor,
    WidgetRef ref,
    String status,
  ) {
    final lowerStatus = status.toLowerCase();
    final bool hasServiceBoy =
        item.serviceBoy != null && item.serviceBoy?.name != null;

    final bool isCompleted = lowerStatus == 'complete';
    final bool isWorking =
        lowerStatus == 'working' ||
        lowerStatus == 'waiting_for_approval' ||
        lowerStatus == 'in_progress';
    final bool isCancelled = lowerStatus == 'cancelled';
    final bool isAssigned =
        lowerStatus == 'assigned' ||
        lowerStatus == 'on_the_way' ||
        hasServiceBoy;
    final bool isPending = lowerStatus == 'pending' && !hasServiceBoy;

    final serviceCategory = item.serviceType?.name ?? "Technician";
    final technicianName =
        item.serviceBoy?.name ?? "Assigning $serviceCategory...";
    final technicianImage = item.serviceBoy?.image ?? "";

    final existingRating = (item.ratings != null && item.ratings!.isNotEmpty)
        ? item.ratings!.first
        : null;
    final bool isAlreadyRated = existingRating != null;

    /// ✅ AUTO FILL FROM API
    if (isAlreadyRated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(ratingProvider(item.id ?? "").notifier).state =
            existingRating.rating ?? 0;

        ref.read(reviewTextProvider(item.id ?? "").notifier).state =
            existingRating.review?.toString() ?? "";
      });
    }
    final hasRating = item.ratings != null && item.ratings.isNotEmpty;
    // 2. Agar rating hai, to uski image nikalo (maan lo pehle index par hai)
    final String? apiImage = hasRating ? item.ratings[0].image : null;

    // 3. UI logic check: Nayi photo pick hui ho OR API se purani photo aa rahi ho
    final bool showImage =
        problemSolvePhtot != null || (apiImage != null && apiImage.isNotEmpty);
    final rating = ref.watch(ratingProvider(item.id ?? ""));
    final reviewText = ref.watch(reviewTextProvider(item.id ?? ""));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isCancelled
            ? Container(
                margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: null, // Disabled
                  icon: const Icon(Icons.error),
                  label: const Text("Service Cancelled"),
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: Colors.red.shade100,
                    disabledForegroundColor: Colors.red.shade700,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              )
            : Container(
                margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.shade50
                      : isWorking
                      ? Colors.purple.shade50
                      : isAssigned
                      ? Colors.blue.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isCompleted
                        ? Colors.green.shade200
                        : isWorking
                        ? Colors.purple.shade200
                        : isAssigned
                        ? Colors.blue.shade200
                        : Colors.orange.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap:
                                  technicianImage.isNotEmpty &&
                                      (isAssigned || isWorking || isCompleted)
                                  ? () {
                                      showDialog(
                                        context: context,
                                        barrierColor: Colors.black87,
                                        builder: (_) => Stack(
                                          children: [
                                            Dialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              insetPadding: EdgeInsets.zero,
                                              child: Hero(
                                                tag: technicianImage,
                                                child: PhotoView(
                                                  imageProvider: NetworkImage(
                                                    technicianImage,
                                                  ),
                                                  backgroundDecoration:
                                                      const BoxDecoration(
                                                        color: Colors.black,
                                                      ),
                                                  minScale:
                                                      PhotoViewComputedScale
                                                          .contained,
                                                  maxScale:
                                                      PhotoViewComputedScale
                                                          .covered *
                                                      2.5,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 40.h,
                                              left: 16.w,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 32,
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  : null,
                              child: CircleAvatar(
                                radius: 26.r,
                                backgroundColor: Colors.white,
                                backgroundImage: technicianImage.isNotEmpty
                                    ? NetworkImage(technicianImage)
                                    : null,
                                child: technicianImage.isEmpty
                                    ? Icon(
                                        Icons.person_search,
                                        color: Colors.orange,
                                        size: 28.sp,
                                      )
                                    : null,
                              ),
                            ),
                            if (!isPending)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap:
                                      technicianImage.isNotEmpty &&
                                          (isAssigned ||
                                              isWorking ||
                                              isCompleted)
                                      ? () {
                                          showDialog(
                                            context: context,
                                            barrierColor: Colors.black87,
                                            builder: (_) => Stack(
                                              children: [
                                                Dialog(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  insetPadding: EdgeInsets.zero,
                                                  child: Hero(
                                                    tag: technicianImage,
                                                    child: PhotoView(
                                                      imageProvider:
                                                          NetworkImage(
                                                            technicianImage,
                                                          ),
                                                      backgroundDecoration:
                                                          const BoxDecoration(
                                                            color: Colors.black,
                                                          ),
                                                      minScale:
                                                          PhotoViewComputedScale
                                                              .contained,
                                                      maxScale:
                                                          PhotoViewComputedScale
                                                              .covered *
                                                          2.5,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 40.h,
                                                  left: 16.w,
                                                  child: IconButton(
                                                    icon: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 32,
                                                    ),
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      : null,
                                  child: Container(
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.zoom_in_rounded,
                                        color: Colors.white,
                                        size: 12.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isPending)
                                Text(
                                  "Service Partner",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              Text(
                                technicianName,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                isPending
                                    ? "Finding technician..."
                                    : isCompleted
                                    ? "Service completed"
                                    : isWorking
                                    ? (lowerStatus == 'waiting_for_approval'
                                          ? "Waiting for your approval"
                                          : "Service in progress")
                                    : isAssigned
                                    ? (lowerStatus == 'on_the_way'
                                          ? "Technician is on the way"
                                          : "Technician assigned")
                                    : "Status updating...",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isAssigned || isWorking)
                          IconButton(
                            onPressed: () async {
                              final phone = item.serviceBoy?.phone ?? "";
                              if (phone.isEmpty) return;
                              final uri = Uri.parse('tel:$phone');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                log("Cannot call: $uri");
                              }
                            },
                            icon: const Icon(Icons.call, color: Colors.green),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.all(10.w),
                            ),
                          ),
                      ],
                    ),
                    if (isAssigned &&
                        !isCompleted &&
                        !isWorking &&
                        lowerStatus != 'in_progress' &&
                        item.verificationOtp != null &&
                        item.verificationOtp!.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "SHARE THIS OTP WITH AGENT",
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              item.verificationOtp!,
                              style: GoogleFonts.inter(
                                fontSize: 25.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // SizedBox(height: 10.h),
                    // Action / Status indicator
                    // if (isAssigned)
                    //   SizedBox(
                    //     width: double.infinity,
                    //     child: ElevatedButton.icon(
                    //       onPressed: () => _showVerifyDialog(
                    //         context,
                    //         technicianName,
                    //         item.id,
                    //         ref,
                    //       ),
                    //       icon: const Icon(Icons.verified_user, size: 18),
                    //       label: Text("VERIFY TECHNICIAN ARRIVAL"),
                    //       style: ElevatedButton.styleFrom(
                    //         backgroundColor: Colors.blue.shade100,
                    //         foregroundColor: Colors.blue.shade800,
                    //         padding: EdgeInsets.symmetric(vertical: 12.h),
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(12.r),
                    //         ),
                    //       ),
                    //     ),
                    //   )
                    // else
                    if (isCompleted ||
                        lowerStatus == 'waiting_for_approval') ...[
                      // _statusIndicator(
                      //   isCompleted ? Icons.check_circle : Icons.hourglass_top,
                      //   isCompleted
                      //       ? "SERVICE COMPLETED SUCCESSFULLY"
                      //       : "WAITING FOR APPROVAL",
                      //   isCompleted
                      //       ? Colors.green.shade800
                      //       : Colors.orange.shade800,
                      //   isCompleted
                      //       ? Colors.green.shade100
                      //       : Colors.orange.shade50,
                      // ),
                      SizedBox(height: 12.h),
                      // ⭐ REVIEW CARD
                      if (isAlreadyRated)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.green.shade100,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_rate_rounded,
                                    color: Colors.green.shade600,
                                    size: 22.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "Your Review",
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ],
                              ),
                              if (rating > 0) ...[
                                SizedBox(height: 14.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: Colors.amber.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber.shade700,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        rating.toString(),
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade900,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (reviewText.isNotEmpty) ...[
                                SizedBox(height: 16.h),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    reviewText,
                                    style: GoogleFonts.inter(
                                      color: Colors.grey.shade800,
                                      fontSize: 14.sp,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                              if (showImage) ...[
                                SizedBox(height: 20.h),
                                Text(
                                  "Problem Resolution Photo",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                    fontSize: 13.sp,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16.r),
                                    child: Image.network(
                                      apiImage!,
                                      width: double.infinity,
                                      height: 180.h,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => RatingPage(item: item),
                                ),
                              ).then((_) {
                                ref.invalidate(
                                  myRequestBookingServiceContorller,
                                );
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              "Give Rating & Review",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ]
                    // else if (isWorking &&
                    //     lowerStatus != 'waiting_for_approval')
                    //   _statusIndicator(
                    //     Icons.engineering,
                    //     "TECHNICIAN WORKING ON SITE",
                    //     Colors.indigo.shade800,
                    //     Colors.indigo.shade50,
                    //   )
                    // else if (isAssigned)
                    //   _statusIndicator(
                    //     lowerStatus == 'on_the_way'
                    //         ? Icons.directions_car
                    //         : Icons.assignment_ind,
                    //     lowerStatus == 'on_the_way'
                    //         ? "TECHNICIAN IS ON THE WAY"
                    //         : "TECHNICIAN ASSIGNED",
                    //     Colors.blue.shade800,
                    //     Colors.blue.shade50,
                    //   )
                    else if (isPending)
                      _statusIndicator(
                        Icons.sync,
                        "SEARCHING FOR TECHNICIAN...",
                        Colors.orange.shade800,
                        Colors.orange.shade100,
                      ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildFooter(dynamic item, Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.access_time, size: 12.sp, color: Colors.grey),
          SizedBox(width: 4.w),
          Text(
            item.createdAt != null
                ? DateFormat(
                    'dd MMM yyyy, hh:mm a',
                  ).format(DateTime.fromMillisecondsSinceEpoch(item.createdAt!))
                : "",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 10.sp),
          ),
        ],
      ),
    );
  }

  Widget _statusIndicator(
    IconData icon,
    String text,
    Color textColor,
    Color bgColor,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20.sp),
          SizedBox(width: 10.w),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showVerifyDialog(
    BuildContext context,
    String name,
    String? id,
    WidgetRef ref,
  ) {
    if (id == null) return;

    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: const Text("Confirm Arrival"),
            content: isLoading
                ? const SizedBox(
                    height: 60,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Text("Has $name arrived at your location?"),
            actions: isLoading
                ? null
                : [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("No"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() => isLoading = true);
                        try {
                          final service = APIStateNetwork(createDio());
                          final response = await service.verifyServiceAgent(
                            VerifyServiceAgentBodyModel(id: id),
                          );

                          if (response.code == 0) {
                            if (context.mounted) Navigator.pop(context);
                            Fluttertoast.showToast(
                              msg: "Verified! Service has started.",
                              backgroundColor: Colors.green,
                            );
                            ref.invalidate(myRequestBookingServiceContorller);
                          } else {
                            Fluttertoast.showToast(
                              msg: response.message ?? "Failed",
                            );
                          }
                        } catch (e) {
                          Fluttertoast.showToast(msg: "Connection Error");
                        } finally {
                          if (context.mounted)
                            setState(() => isLoading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5722),
                      ),
                      child: const Text("Yes, Arrived"),
                    ),
                  ],
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sp, color: color ?? Colors.grey.shade700),
        SizedBox(width: 10.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                color: color ?? Colors.black87,
                fontSize: 13.sp,
              ),
              children: [
                TextSpan(
                  text: "$title:  ",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
