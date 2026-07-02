import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realstate/Controller/notificationController.dart';
import 'package:realstate/Controller/readNotificationController.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();

  static const Color primaryColor = Color(0xFF24ADD7);

  static IconData _getNotificationIcon(String type) {
    switch (type) {
      case "status_update":
        return Icons.notifications_active_rounded;

      case "service_request":
        return Icons.home_repair_service_rounded;

      case "payment":
        return Icons.account_balance_wallet_rounded;

      case "property":
        return Icons.home_work_rounded;

      default:
        return Icons.notifications_rounded;
    }
  }

  static String _formatTime(DateTime? createdAt) {
    if (createdAt == null) return "";

    final diff = DateTime.now().difference(createdAt);

    if (diff.inSeconds < 60) {
      return "Just now";
    }

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min ago";
    }

    if (diff.inHours < 24) {
      return "${diff.inHours} hr ago";
    }

    if (diff.inDays == 1) {
      return "Yesterday";
    }

    if (diff.inDays < 7) {
      return "${diff.inDays} days ago";
    }

    return "${createdAt.day}/${createdAt.month}/${createdAt.year}";
  }
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      ref.refresh(readNotificationController);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationController);
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: notificationState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF24ADD7)),
        ),

        error: (error, stackTrace) => Center(
          child: Text(error.toString(), style: TextStyle(fontSize: 14.sp)),
        ),

        data: (response) {
          final notifications = response.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 70.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    "No Notifications Found",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];

              return _notificationTile(
                icon: NotificationPage._getNotificationIcon(item.type ?? ""),
                title: item.title ?? "",
                subtitle: item.message ?? "",
                time: NotificationPage._formatTime(item.createdAt),
                isUnread: !(item.isRead ?? false),
              );
            },
          );
        },
      ),
    );
  }

  Widget _notificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isUnread
              ? NotificationPage.primaryColor.withOpacity(.25)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56.h,
            width: 56.w,
            decoration: BoxDecoration(
              color: NotificationPage.primaryColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              icon,
              color: NotificationPage.primaryColor,
              size: 28.sp,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    if (isUnread)
                      Container(
                        height: 10.h,
                        width: 10.w,
                        decoration: const BoxDecoration(
                          color: NotificationPage.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 6.h),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13.sp,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 10.h),

                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
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
