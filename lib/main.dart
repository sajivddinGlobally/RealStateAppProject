import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:realstate/pages/home.page.dart';
import 'package:realstate/pages/splash.page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// <-- Yeh import add karo

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('userdata'); // Pehli baar open → baad mein fast

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    var box = Hive.box("userdata");
    var token = box.get('token');
    log(token ?? "No token found");
    return ScreenUtilInit(
      designSize: Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'RealState',
          home: token == null ? PropertyIntroPage() : RealEstateHomePage(),
        );
      },
    );
  }
}
