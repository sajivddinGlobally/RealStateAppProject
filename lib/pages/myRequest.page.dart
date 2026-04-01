import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:realstate/Controller/myRequestBookingSerivceController.dart';
import 'package:realstate/Model/verfiyServiceAgenetBodyModel.dart';
import 'package:realstate/core/network/api.state.dart';
import 'package:realstate/core/utils/preety.dio.dart';
import 'package:url_launcher/url_launcher.dart';

class MyRequestPage extends ConsumerWidget {
  const MyRequestPage({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFFFF5722);
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
      body: RefreshIndicator(
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
                      // 1. Header
                      _buildCardHeader(item, status, primaryColor),

                      // 2. Status Stepper (new chain)
                      _buildStatusStepper(status, primaryColor),

                      const Divider(height: 1),

                      // 3. Details
                      _buildDetailsSection(item, status),

                      // 4. Verification & Technician Section
                      if (status != 'rejected')
                        _buildVerificationCard(
                          item,
                          context,
                          primaryColor,
                          ref,
                          status,
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
            child: CircularProgressIndicator(color: Color(0xFFFF5722)),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  //  SUB WIDGETS
  // ────────────────────────────────────────────────

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
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Row(
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
          SizedBox(width: 12.w),
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
                Text(
                  "ID: #${(item.id ?? "").substring((item.id ?? "").length - 8)}",
                  style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStepper(String status, Color primaryColor) {
    if (status == 'rejected') {
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

    // New requested chain
    final steps = [
      _Step(title: "Pending", active: true),
      _Step(title: "Assigned", active: status != 'pending'),
      _Step(
        title: "On Way",
        active:
            status == 'on_way' || status == 'working' || status == 'complete',
      ),
      _Step(
        title: "Working",
        active: status == 'working' || status == 'complete',
      ),
      _Step(title: "Completed", active: status == 'complete'),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 16.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(steps.length, (i) {
            final step = steps[i];
            final isLast = i == steps.length - 1;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: step.active
                            ? primaryColor
                            : Colors.grey.shade200,
                        border: Border.all(
                          color: step.active
                              ? primaryColor
                              : Colors.grey.shade400,
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: step.active
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      step.title,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: step.active
                            ? primaryColor
                            : Colors.grey.shade700,
                        fontWeight: step.active
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (!isLast)
                  Container(
                    width: 50.w,
                    height: 3.h,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    color: steps[i + 1].active
                        ? primaryColor
                        : Colors.grey.shade300,
                  ),
              ],
            );
          }),
        ),
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

    final bool isPending = lowerStatus == 'pending';
    final bool isAssigned = lowerStatus == 'assigned';
    final bool isOnWay = lowerStatus == 'on_way';
    final bool isWorking = lowerStatus == 'working';
    final bool isCompleted = lowerStatus == 'complete';

    final serviceCategory = item.serviceType?.name ?? "Technician";
    final technicianName =
        item.serviceBoy?.name ?? "Assigning $serviceCategory...";
    final technicianImage = item.serviceBoy?.image ?? "";

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.shade50
            : isWorking
            ? Colors.indigo.shade50
            : isOnWay
            ? Colors.blue.shade50
            : isAssigned
            ? Colors.amber.shade50
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isCompleted
              ? Colors.green.shade200
              : isWorking
              ? Colors.indigo.shade200
              : isOnWay
              ? Colors.blue.shade200
              : isAssigned
              ? Colors.amber.shade200
              : Colors.orange.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap:
                    technicianImage.isNotEmpty &&
                        (isOnWay || isWorking || isCompleted)
                    ? () {
                        showDialog(
                          context: context,
                          barrierColor: Colors.black87,
                          builder: (_) => Stack(
                            children: [
                              Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: EdgeInsets.zero,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Hero(
                                    tag: technicianImage,
                                    child: PhotoView(
                                      imageProvider: NetworkImage(
                                        technicianImage,
                                      ),
                                      backgroundDecoration: const BoxDecoration(
                                        color: Colors.black,
                                      ),
                                      minScale:
                                          PhotoViewComputedScale.contained,
                                      maxScale:
                                          PhotoViewComputedScale.covered * 2.5,
                                    ),
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
                                  onPressed: () => Navigator.pop(context),
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
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          : isAssigned
                          ? "Technician assigned"
                          : isOnWay
                          ? "Technician is on the way"
                          : isWorking
                          ? "Service in progress"
                          : isCompleted
                          ? "Service completed"
                          : "Status updating...",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOnWay || isWorking)
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
          SizedBox(height: 16.h),

          // Action / Status indicator
          if (isOnWay || isWorking)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _showVerifyDialog(context, technicianName, item.id, ref),
                icon: const Icon(Icons.verified_user, size: 18),
                label: const Text("VERIFY TECHNICIAN ARRIVAL"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade100,
                  foregroundColor: Colors.blue.shade800,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            )
          else if (isCompleted)
            _statusIndicator(
              Icons.check_circle,
              "SERVICE COMPLETED SUCCESSFULLY",
              Colors.green.shade800,
              Colors.green.shade100,
            )
          else if (isWorking)
            _statusIndicator(
              Icons.engineering,
              "TECHNICIAN WORKING ON SITE",
              Colors.indigo.shade800,
              Colors.indigo.shade50,
            )
          else if (isOnWay)
            _statusIndicator(
              Icons.directions_car,
              "TECHNICIAN IS ON THE WAY",
              Colors.blue.shade800,
              Colors.blue.shade50,
            )
          else if (isAssigned)
            _statusIndicator(
              Icons.person_add,
              "TECHNICIAN ASSIGNED",
              Colors.amber.shade900,
              Colors.amber.shade100,
            )
          else if (isPending)
            _statusIndicator(
              Icons.sync,
              "SEARCHING FOR TECHNICIAN...",
              Colors.orange.shade800,
              Colors.orange.shade100,
            ),
        ],
      ),
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
                fontSize: 13.sp,
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

class _Step {
  final String title;
  final bool active;

  _Step({required this.title, required this.active});
}
