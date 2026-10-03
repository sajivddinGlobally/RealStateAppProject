import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:realstate/Controller/myPlanController.dart';
import 'package:realstate/Model/mySubscriptionResModel.dart';
import 'package:realstate/Model/subscriptionHistoryResModel.dart';
import 'package:realstate/pages/pricePlan.page.dart';

class MyPlanPage extends ConsumerStatefulWidget {
  const MyPlanPage({super.key});

  @override
  ConsumerState<MyPlanPage> createState() => _MyPlanPageState();
}

class _MyPlanPageState extends ConsumerState<MyPlanPage> {
  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    try {
      return DateFormat('d MMM yyyy').format(dt);
    } catch (_) {
      return 'N/A';
    }
  }

  int _calculateDaysRemaining(DateTime? endDate) {
    if (endDate == null) return 0;
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(mySubscriptionController);
    final historyState = ref.watch(subscriptionHistoryController);

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
          'My Plan',
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
          ref.invalidate(mySubscriptionController);
          ref.invalidate(subscriptionHistoryController);
        },
        child: subState.when(
          data: (subRes) {
            final activeSub = subRes.data;
            final bool hasActivePlan =
                activeSub != null &&
                (activeSub.status?.toLowerCase() == 'active');

            return historyState.when(
              data: (historyRes) {
                final historyList = historyRes.data ?? [];
                return _buildContent(
                  activeSub: activeSub,
                  hasActivePlan: hasActivePlan,
                  historyList: historyList,
                );
              },
              loading: () => _buildContent(
                activeSub: activeSub,
                hasActivePlan: hasActivePlan,
                historyList: [],
                isHistoryLoading: true,
              ),
              error: (err, _) => _buildContent(
                activeSub: activeSub,
                hasActivePlan: hasActivePlan,
                historyList: [],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF24ADD7)),
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 140.h),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 50.sp,
                        color: Colors.redAccent,
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        'Failed to load plan details',
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
                          ref.invalidate(mySubscriptionController);
                          ref.invalidate(subscriptionHistoryController);
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
          ),
        ),
      ),
    );
  }

  Widget _buildContent({
    required MySubscriptionData? activeSub,
    required bool hasActivePlan,
    required List<SubscriptionHistoryItem> historyList,
    bool isHistoryLoading = false,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      children: [
        // Top Header matching website
        _buildHeaderRow(),
        SizedBox(height: 18.h),

        // Active Plan Card or Empty State Card
        if (hasActivePlan && activeSub != null)
          _buildActivePlanCard(activeSub)
        else
          _buildNoActivePlanCard(),

        SizedBox(height: 24.h),

        // Subscription History Section
        if (isHistoryLoading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF24ADD7)),
            ),
          )
        else if (historyList.isNotEmpty)
          _buildHistorySection(historyList),
      ],
    );
  }

  // Header matching website:
  // "My Membership Plan" + Subtitle + "Explore Plans" Button
  Widget _buildHeaderRow() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF24ADD7).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: const Color(0xFF24ADD7),
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MY MEMBERSHIP PLAN',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'View your active subscription & benefits',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const PricePlanPage()),
                );
              },
              icon: Icon(Icons.star_outline_rounded, size: 16.sp),
              label: Text(
                'EXPLORE PLANS',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF24ADD7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Active Plan Card matching web design
  Widget _buildActivePlanCard(MySubscriptionData sub) {
    final plan = sub.planId;
    final int daysRemaining = _calculateDaysRemaining(sub.endDate);
    final points = plan?.points ?? [];
    final usageTracking = sub.usageTracking ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF24ADD7), width: 1.5.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF24ADD7).withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Active Member Banner
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF24ADD7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 14.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'ACTIVE MEMBER',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'CURRENT PLAN',
                    style: GoogleFonts.inter(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Plan Name & Description
                Text(
                  (plan?.name ?? 'SUBSCRIPTION PLAN').toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF111827),
                    letterSpacing: -0.3,
                  ),
                ),
                if (plan?.description != null &&
                    plan!.description!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    plan.description!,
                    style: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                SizedBox(height: 16.h),

                // Price Paid & Days Remaining Box
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PRICE PAID',
                              style: GoogleFonts.inter(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF9CA3AF),
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '₹${sub.price ?? plan?.discountPrice ?? plan?.price ?? 0}',
                              style: GoogleFonts.inter(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1.w,
                        height: 38.h,
                        color: const Color(0xFFE5E7EB),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DAYS REMAINING',
                              style: GoogleFonts.inter(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF9CA3AF),
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '$daysRemaining Days',
                              style: GoogleFonts.inter(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF24ADD7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // 3 Status & Dates Badges Grid
                Row(
                  children: [
                    // Start Date
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF24ADD7,
                          ).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 12.sp,
                                  color: const Color(0xFF24ADD7),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'START DATE',
                                  style: GoogleFonts.inter(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF24ADD7),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _formatDate(sub.startDate),
                              style: GoogleFonts.inter(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // End Date
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.hourglass_bottom_rounded,
                                  size: 12.sp,
                                  color: Colors.amber.shade700,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'VALID UNTIL',
                                  style: GoogleFonts.inter(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _formatDate(sub.endDate),
                              style: GoogleFonts.inter(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Payment Status
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 12.sp,
                                  color: Colors.green.shade700,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'STATUS',
                                  style: GoogleFonts.inter(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              (sub.paymentStatus ?? 'Paid').toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Included Plan Benefits
                if (points.isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  const Divider(height: 1),
                  SizedBox(height: 14.h),
                  Text(
                    'INCLUDED PLAN BENEFITS:',
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF9CA3AF),
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ...List.generate(points.length, (i) {
                    final pt = points[i];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
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
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                // Voucher & Service Limits
                if (usageTracking.isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  const Divider(height: 1),
                  SizedBox(height: 14.h),
                  Text(
                    'YOUR VOUCHER & SERVICE LIMITS:',
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF9CA3AF),
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ...List.generate(usageTracking.length, (i) {
                    final item = usageTracking[i];
                    final used = item.usedCount ?? 0;
                    final total = item.totalLimit ?? 0;
                    final remaining = total - used;
                    final bool hasRemaining = remaining > 0;

                    return Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.pointName ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Used: $used / $total',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: hasRemaining
                                      ? const Color(
                                          0xFF24ADD7,
                                        ).withValues(alpha: 0.12)
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  hasRemaining
                                      ? '$remaining Remaining'
                                      : 'Fully Used',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w800,
                                    color: hasRemaining
                                        ? const Color(0xFF24ADD7)
                                        : Colors.red.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // No Active Plan Card matching web design
  Widget _buildNoActivePlanCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: const Color(0xFF24ADD7).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 32.sp,
              color: const Color(0xFF24ADD7),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Active Membership Plan',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You currently do not have an active subscription plan. Upgrade your plan to get exclusive maintenance vouchers, free services, and priority support.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              color: const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const PricePlanPage()),
                );
              },
              icon: Icon(Icons.bolt_rounded, size: 18.sp),
              label: Text(
                'CHOOSE A PLAN NOW',
                style: GoogleFonts.inter(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF24ADD7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                elevation: 3,
                shadowColor: const Color(0xFF24ADD7).withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Subscription History Section matching website
  Widget _buildHistorySection(List<SubscriptionHistoryItem> historyList) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SUBSCRIPTION HISTORY',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF111827),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 14.h),
          ...List.generate(historyList.length, (i) {
            final item = historyList[i];
            final planName = item.planId?.name ?? 'Subscription Plan';
            final status = (item.status ?? 'expired').toLowerCase();

            Color statusColor;
            Color statusBg;
            if (status == 'active') {
              statusColor = Colors.green.shade700;
              statusBg = Colors.green.shade50;
            } else if (status == 'upcoming') {
              statusColor = const Color(0xFF24ADD7);
              statusBg = const Color(0xFF24ADD7).withValues(alpha: 0.12);
            } else {
              statusColor = Colors.grey.shade600;
              statusBg = Colors.grey.shade100;
            }

            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          planName,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${item.price ?? 0}',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF24ADD7),
                        ),
                      ),
                      Text(
                        '${_formatDate(item.startDate)} - ${_formatDate(item.endDate)}',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
