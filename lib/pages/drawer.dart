// import 'dart:developer';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hive/hive.dart';
// import 'package:realstate/Controller/getMyPropertyController.dart';
// import 'package:realstate/Controller/userProfileController.dart';
// import 'package:realstate/Model/userProfileResModel.dart';
// import 'package:realstate/pages/editProfile.page.dart';
// import 'package:realstate/pages/login.page.dart';
// import 'package:shimmer/shimmer.dart';
// class AppDrawer extends ConsumerStatefulWidget {
//   final AsyncValue<UserProfileResModel> profileController;
//   final Function(int) onItemSelected;
//   const AppDrawer({
//     super.key,
//     required this.profileController,
//     required this.onItemSelected,
//   });
//   @override
//   ConsumerState<AppDrawer> createState() => _AppDrawerState();
// }
// class _AppDrawerState extends ConsumerState<AppDrawer> {
//   Future<void> showLogoutDialog() async {
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Logout"),
//           content: const Text("Are you sure you want to logout?"),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 final box = Hive.box("userdata");
//                 await box.clear();
//                 Fluttertoast.showToast(msg: "Log out Sucessfull");
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   CupertinoPageRoute(builder: (context) => LoginPage()),
//                   (route) => false,
//                 );
//               },
//               child: const Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     var box = Hive.box("userdata");
//     final profileController = ref.watch(userProfileController);
//     return Drawer(
//       width: MediaQuery.of(context).size.width / 1.6,
//       child: profileController.when(
//         data: (user) {
//           return ListView(
//             padding: EdgeInsets.zero,
//             children: [
//               Container(
//                 width: double.infinity,
//                 height: 230.h,
//                 padding: EdgeInsets.only(left: 20.w, top: 20.h),
//                 decoration: BoxDecoration(color: Color(0xffFF6A2A)),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         Container(
//                           width: 90.w,
//                           height: 90.w,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.grey.shade200,
//                           ),
//                           child: ClipOval(
//                             child: Image.network(
//                               user.data!.image ?? "https://i.pravatar.cc/150",
//                               fit: BoxFit.cover,
//                               loadingBuilder:
//                                   (context, child, loadingProgress) {
//                                     if (loadingProgress == null) return child;
//                                     return Center(
//                                       child: CircularProgressIndicator(
//                                         color: Color(0xFFFF5722),
//                                         strokeWidth: 1,
//                                       ),
//                                     );
//                                   },
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Image.network(
//                                   "https://i.pravatar.cc/150",
//                                   width: 40.w,
//                                   height: 40.h,
//                                   fit: BoxFit.cover,
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                           top: 0,
//                           bottom: -40,
//                           right: -8,
//                           child: Center(
//                             child: InkWell(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   CupertinoPageRoute(
//                                     builder: (context) => EditProfilePage(),
//                                   ),
//                                 );
//                               },
//                               child: Container(
//                                 width: 35.w,
//                                 height: 35.h,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.blueGrey,
//                                 ),
//                                 child: Center(
//                                   child: Icon(
//                                     Icons.edit,
//                                     color: Colors.white,
//                                     size: 20.sp,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       'Welcome, ${user.data!.name ?? "User"}',
//                       style: GoogleFonts.inter(
//                         color: Colors.white,
//                         fontSize: 18.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       '${user.data!.email ?? "user@example.com"}',
//                       style: GoogleFonts.inter(
//                         color: Colors.white70,
//                         fontSize: 14.sp,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Drawer Header (user profile या logo)
//               // Menu Items
//               ListTile(
//                 leading: const Icon(Icons.home),
//                 title: const Text('Home'),
//                 selected: ModalRoute.of(context)?.settings.name == '/',
//                 onTap: () {
//                   Navigator.pop(context);
//                   widget.onItemSelected(0);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.description),
//                 title: const Text('My Listings'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   widget.onItemSelected(1);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.call),
//                 title: const Text('Call Us'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   widget.onItemSelected(2);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.bookmark),
//                 title: const Text('Saved'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   widget.onItemSelected(3);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.settings),
//                 title: const Text('Settings'),
//                 onTap: () {
//                   //Navigator.pop(context);
//                   // Settings page पर navigate
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.logout),
//                 title: const Text('Logout'),
//                 onTap: () {
//                   showLogoutDialog();
//                 },
//               ),
//             ],
//           );
//         },
//         error: (error, stackTrace) {
//           log(stackTrace.toString());
//           return Center(child: Text(error.toString()));
//         },
//         loading: () {
//           return ListView(
//             padding: EdgeInsets.zero,
//             children: [
//               Container(
//                 width: double.infinity,
//                 height: 230.h,
//                 padding: EdgeInsets.only(left: 20.w, top: 20.h),
//                 decoration: const BoxDecoration(color: Color(0xffFF6A2A)),
//                 child: Shimmer.fromColors(
//                   baseColor: Colors.white.withOpacity(0.4),
//                   highlightColor: Colors.white.withOpacity(0.8),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // Profile image shimmer
//                       Container(
//                         width: 80,
//                         height: 80,
//                         decoration: const BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Container(width: 160, height: 16, color: Colors.white),
//                       const SizedBox(height: 8),
//                       Container(width: 200, height: 14, color: Colors.white),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20.h),
//               const DrawerMenuShimmer(),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
// class DrawerMenuShimmer extends StatelessWidget {
//   const DrawerMenuShimmer({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey,
//       highlightColor: Colors.grey,
//       child: Column(
//         children: List.generate(6, (index) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             child: Row(
//               children: [
//                 // icon placeholder
//                 Container(
//                   width: 24,
//                   height: 24,
//                   decoration: BoxDecoration(
//                     color: Colors.grey,
//                     borderRadius: BorderRadius.circular(10.r),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 // text placeholder
//                 Expanded(child: Container(height: 14, color: Colors.grey)),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

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

                // _drawerItem(
                //   icon: Icons.home_rounded,
                //   label: 'Home',
                //   index: 0,
                //   context: context,
                // ),
                // _drawerItem(
                //   icon: Icons.description_rounded,
                //   label: 'My Listings',
                //   index: 1,
                //   context: context,
                // ),
                // _drawerItem(
                //   icon: Icons.bookmark_rounded,
                //   label: 'Saved Properties',
                //   index: 4,
                //   context: context,
                // ),
                // _drawerItem(
                //   icon: Icons.call_rounded,
                //   label: 'Contact Us',
                //   index: 3,
                //   context: context,
                // ),
              
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

          /// --- Logout Footer ---
          // Padding(
          //   padding: EdgeInsets.all(20.w),
          //   child: InkWell(
          //     onTap: showLogoutDialog,
          //     borderRadius: BorderRadius.circular(15),
          //     child: Container(
          //       padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          //       decoration: BoxDecoration(
          //         color: Colors.red.withOpacity(0.05),
          //         borderRadius: BorderRadius.circular(15.r),
          //       ),
          //       child: Row(
          //         children: [
          //           const Icon(Icons.logout_rounded, color: Colors.red),
          //           SizedBox(width: 15.w),
          //           Text(
          //             "Logout",
          //             style: GoogleFonts.inter(
          //               color: Colors.red,
          //               fontWeight: FontWeight.w600,
          //               fontSize: 15.sp,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),

          SafeArea(
            top:
                false, // ← Top safe area ignore karo (header already handle karta hai)
            minimum: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20.w,
                12.h,
                20.w,
                20.h,
              ), // bottom padding thoda zyada safe feel ke liye
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
