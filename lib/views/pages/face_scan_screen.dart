import 'package:attendance/utils/app_color.dart';
import 'package:attendance/utils/prefer.dart';
import 'package:attendance/utils/ui_text_style.dart';
import 'package:attendance/views/widgets/common_button.dart';
import 'package:attendance/views/widgets/common_space_divider_widget.dart';
import 'package:attendance/controllers/face_scan_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FaceScanScreen extends StatelessWidget {
  const FaceScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FaceScanController());
    final double circleSize = 270.w;
    Prefs.setLastFaceScanTime(DateTime.now().toUtc().toString());

    return Scaffold(
      backgroundColor: AppColor.appBackGround,
      appBar: AppBar(
        backgroundColor: AppColor.appBackGround,
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            children: [
              Text(
                'Face Verification ',
                style: pSemiBold21.copyWith(
                    color: AppColor.cBlack, fontSize: pSemiBold21.fontSize?.sp),
              ),
              Text('👋', style: TextStyle(fontSize: 28.sp)),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.switch_camera_rounded, color: AppColor.cBlack),
            onPressed:
                controller.cameras.isEmpty ? null : controller.toggleCamera,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpace(0.h),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        GetBuilder<FaceScanController>(
                          builder: (controller) {
                            if (controller.controller == null) {
                              return Container(
                                width: circleSize,
                                height: circleSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColor.cDarkGreyFont,
                                    style: BorderStyle.solid,
                                    width: 2.0.w,
                                  ),
                                ),
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            }

                            return FutureBuilder<void>(
                              future: controller.initializeControllerFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (controller.controller != null &&
                                      controller
                                          .controller!.value.isInitialized) {
                                    try {
                                      return ClipOval(
                                        child: SizedBox(
                                          width: circleSize,
                                          height: circleSize,
                                          child: Transform.scale(
                                            scale: 1.5,
                                            child: Center(
                                              child: AspectRatio(
                                                aspectRatio: 1 /
                                                    controller.controller!.value
                                                        .aspectRatio,
                                                child: CameraPreview(
                                                    controller.controller!),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      print('Camera preview error: $e');
                                      return Container(
                                        width: circleSize,
                                        height: circleSize,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColor.cRed,
                                            style: BorderStyle.solid,
                                            width: 2.0.w,
                                          ),
                                        ),
                                        child: Center(
                                            child: Text('Camera Error',
                                                style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color: AppColor.cRed))),
                                      );
                                    }
                                  } else {
                                    return Container(
                                      width: circleSize,
                                      height: circleSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColor.cDarkGreyFont,
                                          style: BorderStyle.solid,
                                          width: 2.0.w,
                                        ),
                                      ),
                                      child: Center(
                                          child: Text('Camera Error',
                                              style:
                                                  TextStyle(fontSize: 14.sp))),
                                    );
                                  }
                                } else if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  // Add a fallback timeout for loading
                                  return FutureBuilder(
                                    future: Future.delayed(
                                        const Duration(seconds: 10)),
                                    builder: (context, timeoutSnapshot) {
                                      if (timeoutSnapshot.connectionState ==
                                          ConnectionState.done) {
                                        return Container(
                                          width: circleSize,
                                          height: circleSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColor.cRed,
                                              style: BorderStyle.solid,
                                              width: 2.0.w,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Camera is taking too long to load.\nPlease check permissions or restart the app.',
                                              style: TextStyle(
                                                  color: AppColor.cRed,
                                                  fontSize: 14.sp),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          width: circleSize,
                                          height: circleSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColor.cDarkGreyFont,
                                              style: BorderStyle.solid,
                                              width: 2.0.w,
                                            ),
                                          ),
                                          child: const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        );
                                      }
                                    },
                                  );
                                } else {
                                  return Container(
                                    width: circleSize,
                                    height: circleSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColor.cDarkGreyFont,
                                        style: BorderStyle.solid,
                                        width: 2.0.w,
                                      ),
                                    ),
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }
                              },
                            );
                          },
                        ),
                        CustomPaint(
                          size: Size(circleSize, circleSize),
                          painter: DashedCirclePainter(
                            color: AppColor.cDarkGreyFont,
                            strokeWidth: 2.0.w,
                            dashLength: 10.0.w,
                            gapLength: 5.0.w,
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(80.h),
                    CommonButton(
                      title: "Scan Your Face",
                      onPressed: controller.captureAndSendPhoto,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    const double startAngle = 0.0;
    const double sweepAngle = 2 * math.pi; // A full circle

    double currentAngle = startAngle;
    while (currentAngle < startAngle + sweepAngle) {
      final double dashSweep = dashLength / (radius * 2 * math.pi) * sweepAngle;
      final double gapSweep = gapLength / (radius * 2 * math.pi) * sweepAngle;

      canvas.drawArc(
        Rect.fromCircle(center: size.center(Offset.zero), radius: radius),
        currentAngle,
        dashSweep,
        false,
        paint,
      );
      currentAngle += dashSweep + gapSweep;
    }
  }

  @override
  bool shouldRepaint(covariant DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}
