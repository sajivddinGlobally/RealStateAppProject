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
      case 'documents collection':
      case 'documents_collection':
      case 'eligibility check':
      case 'eligibility_check':
        return Colors.blue;
      case 'approved':
      case 'disbursement':
        return Colors.green;
      case 'rejected':
        return Colors.red;
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
                      _buildStatusStepper(item, primaryColor),
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
                            SizedBox(height: 10.h),
                            _infoRow(
                              Icons.account_balance_outlined,
                              "Bank",
                              (item.bankName != null &&
                                      item.bankName!.isNotEmpty)
                                  ? item.bankName!
                                  : (item.manualBankName?.isNotEmpty == true
                                        ? item.manualBankName!
                                        : "—"),
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

  Widget _buildStatusStepper(LoanItem item, Color primaryColor) {
    final status = item.status?.toLowerCase() ?? 'pending';

    if (status == 'rejected') {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 14.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.red.shade200, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 20.sp),
                  SizedBox(width: 8.w),
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
              if (item.rejectedReason != null &&
                  item.rejectedReason!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  "Reason: ${item.rejectedReason}",
                  style: GoogleFonts.inter(
                    color: Colors.red.shade700,
                    fontSize: 12.5.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    int currentStep = 0;

    switch (status) {
      case 'pending':
        currentStep = 0;
        break;

      case 'documents collection':
      case 'documents_collection':
        currentStep = 1;
        break;

      case 'eligibility check':
      case 'eligibility_check':
        currentStep = 2;
        break;

      case 'approved':
        currentStep = 3;
        break;

      case 'disbursement':
        currentStep = 4;
        break;

      default:
        currentStep = 0;
    }

    final steps = [
      _Step(title: "Pending", icon: Icons.schedule),
      _Step(title: "Documents\nCollection", icon: Icons.description),
      _Step(title: "Eligibility\nCheck", icon: Icons.manage_search),
      _Step(title: "Loan\nApproved", icon: Icons.check_circle),
      _Step(title: "Disbursement", icon: Icons.payments),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 16.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(bottom: 8.h), // for shadow
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(steps.length, (i) {
              final step = steps[i];
              final isLast = i == steps.length - 1;
              final isCompleted = i < currentStep;
              final isCurrent = i == currentStep;

              return Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isCurrent ? 38.w : 32.w,
                        height: isCurrent ? 38.w : 32.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            isCurrent ? 12.r : 10.r,
                          ),
                          color: isCurrent
                              ? primaryColor
                              : (isCompleted
                                    ? primaryColor.withOpacity(0.15)
                                    : Colors.white),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                          border: Border.all(
                            color: isCurrent
                                ? primaryColor
                                : (isCompleted
                                      ? primaryColor.withOpacity(0.3)
                                      : Colors.grey.shade300),
                            width: isCurrent ? 2 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            step.icon,
                            color: isCurrent
                                ? Colors.white
                                : (isCompleted
                                      ? primaryColor
                                      : Colors.grey.shade400),
                            size: isCurrent ? 20.sp : 16.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        step.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: isCurrent ? 10.5.sp : 10.sp,
                          color: isCurrent
                              ? primaryColor
                              : (isCompleted
                                    ? Colors.black87
                                    : Colors.grey.shade500),
                          fontWeight: isCurrent
                              ? FontWeight.w700
                              : (isCompleted
                                    ? FontWeight.w600
                                    : FontWeight.w500),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  if (!isLast)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32.w,
                      height: i < currentStep ? 4.h : 2.5.h,
                      margin: EdgeInsets.symmetric(horizontal: 6.w).copyWith(
                        top: isCurrent ? 17.w : 15.w,
                      ), // align with icon center
                      decoration: BoxDecoration(
                        color: i < currentStep
                            ? primaryColor
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                ],
              );
            }),
          ),
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
  final IconData icon;

  _Step({required this.title, required this.icon});
}
