
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:realstate/Model/userProfileResModel.dart';
import 'package:realstate/pages/editProfile.page.dart';
import 'package:realstate/pages/myRequest.page.dart';
import 'MyPropertyRequest.dart';
import 'loginwithOtp.page.dart';
import 'myLoanRequest.dart';

class AppDrawer extends ConsumerStatefulWidget {
  final AsyncValue<UserProfileResModel> profileController;
  final Function(int) onItemSelected;
  const AppDrawer({
    super.key,
    required this.profileController,
    required this.onItemSelected,
  });
  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  Future<void> showLogoutDialog() async {
    const primaryColor = Color(0xffFF6A2A);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ), // Rounded corners for modern look
          ),
          title: Column(
            children: [
              const Icon(Icons.logout_rounded, color: primaryColor, size: 50),
              const SizedBox(height: 15),
              const Text(
                "Logout",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to logout?\nYou will need to login again to access your data.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          actionsPadding: const EdgeInsets.only(
            bottom: 20,
            left: 20,
            right: 20,
          ),
          actions: [
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Logout Button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      Navigator.pop(context); // Dialog close
                      final box = Hive.box("userdata");
                      await box.clear();

                      Fluttertoast.showToast(msg: "Logout Successful");

                      Navigator.pushAndRemoveUntil(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => LoginPageWithOtp(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Logout",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width:
          MediaQuery.of(context).size.width *
          0.70, // Thoda wide width for better look
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          // topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          /// --- Elegant Header ---
          _buildHeader(),

          /// --- Drawer Items ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              children: [

                _drawerItem(
                  icon: Icons.support_agent,
                  label: 'My Services Request',
                  context: context,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => MyRequestPage()),
                    );
                  },
                ),

                _drawerItem(
                  icon: Icons.house_outlined,
                  label: 'My Property Request',
                  context: context,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => MyListedPropertiesScreen(),
                      ),
                    );
                  },
                ),

                _drawerItem(
                  icon: Icons.account_balance_wallet,
                  label: 'My Loan Request',
                  context: context,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => MyLoanRequestsPage(),
                      ),
                    );
                  },
                ),

                const Divider(
                  height: 30,
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                ),
              ],
            ),
          ),


          SafeArea(
            top: false,
            minimum: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
              child: InkWell(
                onTap: showLogoutDialog,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 16.w,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded, color: Colors.red),
                      SizedBox(width: 15.w),
                      Text(
                        "Logout",
                        style: GoogleFonts.inter(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Custom Header Design
  Widget _buildHeader() {
    final box = Hive.box("userdata");
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 60.h,
        bottom: 20.h,
        left: 20.w,
        right: 20.w,
      ),
      decoration: const BoxDecoration(
        color: Color(0xffFF6A2A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: ClipOval(
                  child: Image.network(
                    //user.data!.image ?? "https://i.pravatar.cc/150",
                    box.get("image").toString(),
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF5722),
                          strokeWidth: 1,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        "https://t4.ftcdn.net/jpg/16/74/69/27/240_F_1674692759_KcsTyCBrF888fdlD7eDFrGRyEUbniWXj.jpg",
                        width: 70.w,
                        height: 70.w,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.edit_note_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Text(
            // user.data!.name ?? "Guest User",
            box.get("name").toString() ?? "User",
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            box.get("email").toString(),
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable modern Drawer Item
  Widget _drawerItem({
    required IconData icon,
    required String label,
    int? index,
    required BuildContext context,
    VoidCallback? onTap,
  }) {
    bool isSelected = false;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.only(left: 10.w),
      onTap:
          onTap ??
          () {
            Navigator.pop(context);
            if (index != null && index != -1) widget.onItemSelected(index);
          },
      leading: Icon(icon, color: Colors.blueGrey.shade700),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          letterSpacing: -0.70,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      selected: isSelected,
      selectedTileColor: const Color(0xffFF6A2A).withOpacity(0.1),
    );
  }
}
