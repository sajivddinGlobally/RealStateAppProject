/*
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../Controller/getMyPropertyController.dart';
import '../Model/SavedModel.dart';
import '../core/network/api.state.dart';
import '../core/utils/preety.dio.dart';



class MyListedPropertiesScreen extends ConsumerWidget {
  const MyListedPropertiesScreen({super.key});

  String _formatPrice(String? price) {
    if (price == null || price.isEmpty) return '—';
    try {
      final numPrice = double.parse(price.replaceAll(',', ''));
      return NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0).format(numPrice);
    } catch (_) {
      return '₹ $price';
    }
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null || timestamp <= 0) return '—';
    return DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':     return Colors.orange;
      case 'contacted':
      case 'responded':   return Colors.blue;
      case 'done':
      case 'closed':      return Colors.green;
      case 'rejected':    return Colors.red;
      default:            return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFFFF5722);
    final propertiesAsync = ref.watch(getMyPropertyContantListController);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("My Listed Properties", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18.5.sp)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: Colors.white,
        backgroundColor: primaryColor,
        onRefresh: () async => ref.invalidate(getMyPropertyContantListController),
        child: propertiesAsync.when(
          data: (response) {
            final contacts = response.data?.list ?? [];

            if (contacts.isEmpty) return _buildEmptyState("No properties or inquiries yet");

            final grouped = groupBy(contacts, (ListElementSavedProperty c) => c.propertyId?.id ?? 'unknown');

            final uniqueProperties = grouped.entries.map((entry) {
              final contactsForProp = entry.value;
              final first = contactsForProp.first;
              final prop = first.propertyId;

              String displayStatus = 'No inquiries';
              if (contactsForProp.any((c) => c.status?.toLowerCase() == 'pending')) {
                displayStatus = 'Pending';
              } else if (contactsForProp.any((c) => c.status?.toLowerCase() == 'contacted')) {
                displayStatus = 'Contacted';
              } else if (contactsForProp.isNotEmpty) {
                displayStatus = contactsForProp.first.status ?? 'Viewed';
              }

              return {
                'prop': prop,
                'status': displayStatus,
                'count': contactsForProp.length,
                'image': prop?.uploadedPhotos?.isNotEmpty == true ? prop!.uploadedPhotos!.first.trim() : null,
              };
            }).toList();

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              itemCount: uniqueProperties.length,
              itemBuilder: (context, index) {
                final data = uniqueProperties[index];
                final prop = data['prop'] as PropertyId?;
                final status = data['status'] as String;
                final count = data['count'] as int;
                final imageUrl = data['image'] as String?;

                if (prop == null) return const SizedBox.shrink();

                if (imageUrl != null) debugPrint("Loading image: $imageUrl");

                return Card(
                  margin: EdgeInsets.only(bottom: 12.h),
                  elevation: 1.5,
                  shadowColor: Colors.black.withOpacity(0.06),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image – smaller height
                      if (imageUrl != null && imageUrl.isNotEmpty && Uri.tryParse(imageUrl)?.hasScheme == true)
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: 140.h,                      // ← reduced from 180
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(primaryColor))),
                          ),
                          errorWidget: (context, url, error) {
                            debugPrint("Image failed: $url → $error");
                            return _noImagePlaceholder(140.h);
                          },
                        )
                      else
                        _noImagePlaceholder(140.h),

                      Padding(
                        padding: EdgeInsets.all(12.w),           // reduced from 14
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    prop.property ?? "Unnamed Property",
                                    style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w700), // slightly smaller
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (status != 'No inquiries')
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        color: _getStatusColor(status),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10.sp,           // smaller badge text
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            if (count > 0)
                              Padding(
                                padding: EdgeInsets.only(top: 3.h),
                                child: Text(
                                  "$count ${count == 1 ? 'inquiry' : 'inquiries'}",
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
                                ),
                              ),

                            SizedBox(height: 8.h),   // reduced

                            Wrap(
                              spacing: 8.w,
                              runSpacing: 6.h,
                              children: [
                                _chip(prop.propertyType ?? '—', primaryColor),
                                _chip(prop.listingCategory ?? '—', Colors.blueGrey.shade700),
                              ],
                            ),

                            SizedBox(height: 10.h),

                            _propertyInfoRow(Icons.location_on_outlined, prop.city ?? "—", prop.propertyAddress ?? ""),

                            SizedBox(height: 8.h),

                            Row(
                              children: [
                                Expanded(child: _propertyInfoRow(Icons.currency_rupee_rounded, _formatPrice(prop.price), "")),
                                if (prop.area?.isNotEmpty ?? false) ...[
                                  Container(width: 1.w, height: 26.h, color: Colors.grey.shade300, margin: EdgeInsets.symmetric(horizontal: 10.w)),
                                  Expanded(child: _propertyInfoRow(Icons.square_foot, prop.area!, "")),
                                ],
                              ],
                            ),

                            if (prop.furnishing?.isNotEmpty ?? false)
                              Padding(padding: EdgeInsets.only(top: 8.h), child: _propertyInfoRow(Icons.weekend_outlined, "Furnishing", prop.furnishing!)),

                            if (prop.bathrooms?.isNotEmpty ?? false)
                              Padding(padding: EdgeInsets.only(top: 8.h), child: _propertyInfoRow(Icons.bathtub_outlined, "Bathrooms", prop.bathrooms!)),
                          ],
                        ),
                      ),

                      // Compact footer
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        color: primaryColor.withOpacity(0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 13.sp, color: Colors.grey.shade700),
                            SizedBox(width: 5.w),
                            Text(
                              "Listed ${_formatDate(prop.createdAt)}",
                              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700),
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
          error: (err, stack) {
            log("Error: $err\n$stack");
            return Center(child: Text("Error: $err", style: TextStyle(color: Colors.red)));
          },
          loading: () => Center(child: CircularProgressIndicator(color: primaryColor)),
        ),
      ),
    );
  }

  Widget _noImagePlaceholder(double height) {
    return Container(
      height: height.h,
      color: Colors.grey.shade300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_outlined, size: 48.sp, color: Colors.grey.shade500),
          SizedBox(height: 6.h),
          Text("No photo", style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20.r)),
      child: Text(label.toUpperCase(), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _propertyInfoRow(IconData icon, String mainText, String secondaryText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 17.sp, color: Colors.grey.shade700),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mainText, style: GoogleFonts.inter(fontSize: 14.5.sp, fontWeight: FontWeight.w600)),
              if (secondaryText.isNotEmpty)
                Text(
                  secondaryText,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home_work_outlined, size: 80.sp, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text("No Properties", style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}*/

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../Model/SavedModel.dart'; // adjust if name is different
import '../core/network/api.state.dart';
import '../core/utils/preety.dio.dart';

final getMyPropertyContantListController =
    FutureProvider.autoDispose<SavedListModel>((ref) async {
      final service = APIStateNetwork(createDio());
      return await service.getMyPropertyContantList();
    });

class MyListedPropertiesScreen extends ConsumerWidget {
  const MyListedPropertiesScreen({super.key});

  String _formatPrice(String? price) {
    if (price == null || price.isEmpty) return '—';
    try {
      final numPrice = double.parse(price.replaceAll(',', ''));
      return NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹ ',
        decimalDigits: 0,
      ).format(numPrice);
    } catch (_) {
      return '₹ $price';
    }
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null || timestamp <= 0) return '—';
    return DateFormat(
      'dd MMM yyyy',
    ).format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'contacted':
      case 'responded':
        return Colors.blue;
      case 'done':
      case 'closed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF24ADD7);
    final propertiesAsync = ref.watch(getMyPropertyContantListController);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "My Listed Properties",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18.5.sp,
          ),
        ),
        backgroundColor: Color(0xFF24ADD7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: Colors.white,
        backgroundColor: Color(0xFF24ADD7),
        onRefresh: () async =>
            ref.invalidate(getMyPropertyContantListController),
        child: propertiesAsync.when(
          data: (response) {
            final contacts = response.data?.list ?? [];

            if (contacts.isEmpty)
              return _buildEmptyState("No properties or inquiries yet");

            final grouped = groupBy(
              contacts,
              (ListElementSavedProperty c) => c.propertyId?.id ?? 'unknown',
            );

            final uniqueProperties = grouped.entries.map((entry) {
              final contactsForProp = entry.value;
              final first = contactsForProp.first;
              final prop = first.propertyId;

              String displayStatus = 'No inquiries';
              if (contactsForProp.any(
                (c) => c.status?.toLowerCase() == 'pending',
              )) {
                displayStatus = 'Pending';
              } else if (contactsForProp.any(
                (c) => c.status?.toLowerCase() == 'contacted',
              )) {
                displayStatus = 'Contacted';
              } else if (contactsForProp.isNotEmpty) {
                displayStatus = contactsForProp.first.status ?? 'Viewed';
              }

              return {
                'prop': prop,
                'status': displayStatus,
                'count': contactsForProp.length,
                'image': prop?.uploadedPhotos?.isNotEmpty == true
                    ? prop!.uploadedPhotos!.first.trim()
                    : null,
              };
            }).toList();

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              itemCount: uniqueProperties.length,
              itemBuilder: (context, index) {
                final data = uniqueProperties[index];
                final prop = data['prop'] as PropertyId?;
                final status = data['status'] as String;
                final count = data['count'] as int;
                final imageUrl = data['image'] as String?;

                if (prop == null) return const SizedBox.shrink();

                if (imageUrl != null) debugPrint("Loading image: $imageUrl");

                return SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: 14.h,
                    ), // extra space for shadow
                    child: Material(
                      elevation: 6, // ubhra hua feel ke liye
                      shadowColor: Colors.black.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(18.r),
                      color: Colors.white, // clean white background
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          if (imageUrl != null &&
                              imageUrl.isNotEmpty &&
                              Uri.tryParse(imageUrl)?.hasScheme == true)
                            CachedNetworkImage(
                              imageUrl: imageUrl,
                              height: 140.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation(
                                      primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                debugPrint("Image failed: $url → $error");
                                return _noImagePlaceholder(140.h);
                              },
                            )
                          else
                            _noImagePlaceholder(140.h),

                          Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        prop.property ?? "Unnamed Property",
                                        style: GoogleFonts.inter(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (status != 'No inquiries')
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                            status,
                                          ).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                        ),
                                        child: Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                            color: _getStatusColor(status),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                if (count > 0)
                                  Padding(
                                    padding: EdgeInsets.only(top: 3.h),
                                    child: Text(
                                      "$count ${count == 1 ? 'inquiry' : 'inquiries'}",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),

                                SizedBox(height: 8.h),

                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 6.h,
                                  children: [
                                    _chip(
                                      prop.propertyType ?? '—',
                                      primaryColor,
                                    ),
                                    _chip(
                                      prop.listingCategory ?? '—',
                                      Colors.blueGrey.shade700,
                                    ),
                                  ],
                                ),

                                SizedBox(height: 10.h),

                                _propertyInfoRow(
                                  Icons.location_on_outlined,
                                  prop.city ?? "—",
                                  prop.propertyAddress ?? "",
                                ),

                                SizedBox(height: 8.h),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _propertyInfoRow(
                                        Icons.currency_rupee_rounded,
                                        _formatPrice(prop.price),
                                        "",
                                      ),
                                    ),
                                    if (prop.area?.isNotEmpty ?? false) ...[
                                      Container(
                                        width: 1.w,
                                        height: 26.h,
                                        color: Colors.grey.shade300,
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                        ),
                                      ),
                                      Expanded(
                                        child: _propertyInfoRow(
                                          Icons.square_foot,
                                          prop.area!,
                                          "",
                                        ),
                                      ),
                                    ],
                                  ],
                                ),

                                if (prop.furnishing?.isNotEmpty ?? false)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.h),
                                    child: _propertyInfoRow(
                                      Icons.weekend_outlined,
                                      "Furnishing",
                                      prop.furnishing!,
                                    ),
                                  ),

                                if (prop.bathrooms?.isNotEmpty ?? false)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.h),
                                    child: _propertyInfoRow(
                                      Icons.bathtub_outlined,
                                      "Bathrooms",
                                      prop.bathrooms!,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            color: primaryColor.withOpacity(0.05),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 13.sp,
                                  color: Colors.grey.shade700,
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  "Listed ${_formatDate(prop.createdAt)}",
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
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

          error: (err, stack) {
            log("Error: $err\n$stack");
            return Center(
              child: Text("Error: $err", style: TextStyle(color: Colors.red)),
            );
          },

          loading: () =>
              Center(child: CircularProgressIndicator(color: primaryColor)),
        ),
      ),
    );
  }

  Widget _noImagePlaceholder(double height) {
    return Container(
      height: height.h,
      color: Colors.grey.shade300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_work_outlined,
            size: 48.sp,
            color: Colors.grey.shade500,
          ),
          SizedBox(height: 6.h),
          Text(
            "No photo",
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _propertyInfoRow(
    IconData icon,
    String mainText,
    String secondaryText,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 17.sp, color: Colors.grey.shade700),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mainText,
                style: GoogleFonts.inter(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (secondaryText.isNotEmpty)
                Text(
                  secondaryText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 80.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              "No Properties",
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
