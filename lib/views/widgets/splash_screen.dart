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
    
    // Check token and navigate accordingly
    final token = Prefs.getToken();
    if (token != '') {
      Get.offAll(() => const HomeScreen());
    } else {
      Get.offAll(() => LoginScreen());
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
                width: 100.w,
                height: 100.h,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 