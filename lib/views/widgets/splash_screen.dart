import 'dart:developer';

import 'package:attendance/controllers/face_scan_controller.dart';
import 'package:attendance/views/pages/face_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance/utils/prefer.dart';
import 'package:attendance/views/pages/home _screen.dart';
import 'package:attendance/views/pages/login_screen.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      log("### last face scan time ${Prefs.getLastFaceScanTime()}");
    } catch (e) {
      log(e.toString());
    }
    // Check token and navigate accordingly
    final token = Prefs.getToken();

    if (token == '') {
      Get.offAll(() => LoginScreen());
    } else if (DateTime.parse(Prefs.getLastFaceScanTime()).toUtc().day !=
        DateTime.now().toUtc().day) {
      log("### last face scan time ${DateTime.parse(Prefs.getLastFaceScanTime())}");
      log("### now ${DateTime.now().toUtc()}");
      Get.offAll(() => const FaceScanScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C335E), // #0C335E background color
      body: SafeArea(
        child: Stack(
          children: [
            // Nassar Group logo at top left
            Positioned(
              top: 2.h,
              left: 2.w,
              child: Image.asset(
                'asset/image/png_images/nassar_group.png',
                width: 120.w,
                height: 40.h,
                fit: BoxFit.contain,
              ),
            ),
            // Center logo
            Center(
              child: Image.asset(
                'asset/image/png_images/ic_launcher.png',
                width: 140.w,
                height: 140.h,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
