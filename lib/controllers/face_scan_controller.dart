import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:attendance/views/pages/home _screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class FaceScanController extends GetxController {
  CameraController? controller;
  Future<void>? initializeControllerFuture;
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;
  bool isCapturing = false;

  @override
  void onInit() {
    super.onInit();
    requestCameraPermission();
  }

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      getAvailableCameras();
    } else if (status.isDenied) {
      Get.snackbar(
          'Permission Denied', 'Camera permission is required for face scanning.');
    } else if (status.isPermanentlyDenied) {
      Get.snackbar(
          'Permission Denied',
          'Camera permission is permanently denied. Please enable it from app settings.',
          mainButton: TextButton(
            onPressed: () {
              openAppSettings();
            },
            child: const Text('Settings'),
          ));
    }
  }

  Future<void> getAvailableCameras() async {
    cameras = await availableCameras();
    selectedCameraIndex = cameras.indexWhere((camera) => camera.lensDirection == CameraLensDirection.front);
    if (selectedCameraIndex == -1) {
      selectedCameraIndex = 0;
    }
    initializeCamera(cameras[selectedCameraIndex]);
  }

  Future<void> initializeCamera(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
    );

    initializeControllerFuture = controller?.initialize();
    update();
  }

  void toggleCamera() {
    selectedCameraIndex = selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    initializeCamera(cameras[selectedCameraIndex]);
  }

  Future<void> captureAndSendPhoto() async {
    if (controller == null || !controller!.value.isInitialized || isCapturing) {
      print('[FaceScanController] Camera not ready or already capturing.');
      return;
    }

    isCapturing = true;
    update();
    print('[FaceScanController] Starting photo capture...');

    try {
      final XFile file = await controller!.takePicture();
      print('[FaceScanController] Photo captured. Path: ' + file.path);
      if (file.path.isEmpty) {
        print('[FaceScanController] Failed to capture photo: file path is empty.');
        Get.snackbar('Error', 'لم يتم التقاط الصورة بنجاح');
        isCapturing = false;
        update();
        return;
      }

      // Show loading indicator
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      print('[FaceScanController] Sending photo to backend...');

      // Prepare multipart request
      var uri = Uri.parse('https://do-system.com/api/Hrm/daily-image');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('image', file.path));
      // Add Authorization header with the provided token
      request.headers['Authorization'] = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2RvLXN5c3RlbS5jb20vYXBpL0hybS9sb2dpbiIsImlhdCI6MTc1MDk0MDUxNSwiZXhwIjoxNzUwOTQ0MTE1LCJuYmYiOjE3NTA5NDA1MTUsImp0aSI6IjZzQjdpeklETjB4NndtTDkiLCJzdWIiOiI1MCIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.h_1Zd3FQ-QpRjPUX1Yxv95p9pBzNUm4kcL9xLNhMXlc';

      print('[FaceScanController] Request prepared. Sending...');
      var response = await request.send();
      print('[FaceScanController] Response status: ${response.statusCode}');
      Get.back(); // Close loading dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[FaceScanController] Photo uploaded successfully.');
        Get.snackbar(
          'Success',
          'Face image uploaded successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        Get.offAll(() => const HomeScreen());
      } else {
        final respStr = await response.stream.bytesToString();
        print('[FaceScanController] Upload failed: ${response.statusCode} - $respStr');
        if (response.statusCode == 409) {
          Get.snackbar('Notice', "You've already uploaded today's image.");
          Get.offAll(() => const HomeScreen());
        } else {
          Get.snackbar('Error', 'Failed to upload image: ${response.statusCode}\n$respStr');
        }
      }
    } catch (e) {
      print('[FaceScanController] Exception: $e');
      Get.back();
      Get.snackbar('خطأ', 'حدث خطأ أثناء التقاط/رفع الصورة: $e');
    } finally {
      isCapturing = false;
      update();
      print('[FaceScanController] Done.');
    }
  }

  @override
  void onClose() {
    controller?.dispose();
    super.onClose();
  }
} 