import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../pages/login.page.dart';
import 'globalroute.key.dart';

Dio createDio() {
  final dio = Dio();
  dio.interceptors.add(
    PrettyDioLogger(
      requestBody: true,
      requestHeader: true,
      responseBody: true,
      responseHeader: true,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final box = Hive.box("userdata");
        final token = box.get("token");

        options.headers.addAll({
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        });
        handler.next(options);
      },
      onResponse: (response, handler) async {
        if (response.data['code'] == 401 || response.data['code'] == 3) {
          navigatorKey.currentState?.pushAndRemoveUntil(
            CupertinoPageRoute(builder: (_) => LoginPage()),
            (route) => false,
          );
          final box = Hive.box("userdata");
          await box.clear(); 
          Fluttertoast.showToast(
            msg: response.data['message'],
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
        handler.next(response);
      },

      // onError: (error, handler) async {
      //   if (error.response!.statusCode == 401) {
      //     final box = Hive.box("userdata");
      //     await box.clear();
      //     Fluttertoast.showToast(
      //       msg: "Token expire please login again.",
      //       backgroundColor: Colors.red,
      //       toastLength: Toast.LENGTH_LONG,
      //     );
      //     navigatorKey.currentState?.pushAndRemoveUntil(
      //       CupertinoPageRoute(builder: (_) => LoginPage()),
      //       (route) => false,
      //     );
      //   } else {
      //     log("Global context is null, cannot show SnackBar or navigate");
      //   }
      //   return handler.next(error);
      // },
      onError: (DioException error, handler) async {
        // 🔹 Case 1: Server / Internet issue
        if (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          Fluttertoast.showToast(
            msg: "Server not reachable. Please try again later.",
            backgroundColor: Colors.red,
            toastLength: Toast.LENGTH_LONG,
          );
          return handler.next(error);
        }
        // 🔹 Case 2: Response aaya hai (safe check)
        if (error.response != null) {
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            final box = Hive.box("userdata");
            await box.clear();
            Fluttertoast.showToast(
              msg: "Session expired. Please login again.",
              backgroundColor: Colors.red,
              toastLength: Toast.LENGTH_LONG,
            );
            navigatorKey.currentState?.pushAndRemoveUntil(
              CupertinoPageRoute(builder: (_) => LoginPage()),
              (route) => false,
            );
          }
        } else {
          // 🔹 Unknown error
          log("❌ Dio error without response: ${error.message}");
        }
        handler.next(error);
      },
    ),
  );
  return dio;
}
