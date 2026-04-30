import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../Model/GetLoanQueryModel.dart';
import '../core/network/api.state.dart';
import '../core/utils/preety.dio.dart';

final myLoanRequestsProvider = FutureProvider<List<LoanItem>>((ref) async {
  final service = APIStateNetwork(createDio());
  final response = await service.myLoanQuery();

  // Agar kuch bhi null ho to empty list de do
  return response.data?.list ?? [];
});

class MyLoanRequestsPage extends ConsumerWidget {
  const MyLoanRequestsPage({super.key});

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
      case 'approved_by_admin':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'in_process':
      case 'processing':
        return Colors.blue;
      default:
        return Colors.blueGrey;
    }
  }

  String getLoanTypeDisplay(String? type) {
    if (type == null || type.isEmpty) return 'Loan Request';
    return type
        .split('_')
        .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF24ADD7);
    final loanProvider = ref.watch(myLoanRequestsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "My Loan Requests",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: Color(0xFF24ADD7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        backgroundColor: Color(0xFF24ADD7),
        color: Colors.white,
        onRefresh: () async => ref.invalidate(myLoanRequestsProvider),
        child: loanProvider.when(
          data: (loans) {
            if (loans.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: EdgeInsets.all(15.w),
              itemCount: loans.length,
              itemBuilder: (context, index) {
                final item = loans[index];
                final status = item.status?.toLowerCase() ?? 'pending';
                return Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: EdgeInsets.all(14.w),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Icon(
                                Icons.account_balance,
                                color: primaryColor,
                                size: 32.sp,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getLoanTypeDisplay(item.loanType),
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15.5.sp,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    "ID: #${(item.id ?? '').substring((item.id ?? '').length - 8)}",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 11.5.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: getStatusColor(status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                status.toUpperCase().replaceAll('_', ' '),
                                style: TextStyle(
                                  color: getStatusColor(status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusStepper(status, primaryColor),
                      const Divider(height: 1),
                      // Details
                      Padding(
                        padding: EdgeInsets.all(14.w),
                        child: Column(
                          children: [
                            _infoRow(
                              Icons.person_outline,
                              "Name",
                              item.name ?? "—",
                            ),
                            SizedBox(height: 10.h),
                            _infoRow(
                              Icons.phone_outlined,
                              "Phone",
                              item.phone ?? "—",
                            ),
                            SizedBox(height: 10.h),
                            _infoRow(
                              Icons.location_on_outlined,
                              "City",
                              item.city ?? "—",
                            ),
                          ],
                        ),
                      ),

                      // Footer
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.r),
                            bottomRight: Radius.circular(20.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 13.sp,
                              color: Colors.grey.shade700,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              item.createdAt != null
                                  ? DateFormat('dd MMM yyyy, hh:mm a').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                        item.createdAt!,
                                      ),
                                    )
                                  : "—",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) {
            log("Loan page error → $err");
            return Center(child: Text("Error: $err"));
          },
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
            Icons.money_off_csred_rounded,
            size: 80.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            "No Loan Requests Found",
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "You haven't applied for any loans yet.",
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
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

    int currentStep = 0;

    switch (status) {
      case 'pending':
        currentStep = 0;
        break;

      case 'in_process':
        currentStep = 1;
        break;

      case 'approved':
        currentStep = 2;
        break;

      default:
        currentStep = 0;
    }

    final steps = [
      _Step(
        title: "Pending",
        active: currentStep >= 0,
        icon: Icons.pending_actions,
      ),
      _Step(title: "In Process", active: currentStep >= 1, icon: Icons.build),
      _Step(
        title: "Approved",
        active: currentStep >= 2,
        icon: Icons.check_circle,
      ),
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
                        child: Icon(
                          step.icon,
                          color: step.active
                              ? Colors.white
                              : Colors.grey.shade600,
                          size: 16.sp,
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

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey.shade700),
        SizedBox(width: 12.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                color: Colors.black87,
                fontSize: 13.5.sp,
              ),
              children: [
                TextSpan(
                  text: "$title: ",
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
  final IconData icon;

  _Step({required this.title, required this.active, required this.icon});
}
