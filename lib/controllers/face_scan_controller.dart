import 'package:attendance/utils/prefer.dart';
import 'package:attendance/views/pages/home _screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class FaceScanController extends GetxController {
  CameraController? controller;
  Future<void>? initializeControllerFuture;
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;
  bool isCapturing = false;
  String token = Prefs.getToken();

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
      Get.snackbar('Permission Denied',
          'Camera permission is required for face scanning.');
    } else if (status.isPermanentlyDenied) {
      Get.snackbar('Permission Denied',
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
    selectedCameraIndex = cameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
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

  Future<void> toggleCamera() async {
    try {
      // Dispose current camera controller before switching
      if (controller != null) {
        await controller!.dispose();
      }

      // Toggle camera index safely
      if (cameras.isNotEmpty) {
        selectedCameraIndex = selectedCameraIndex < cameras.length - 1
            ? selectedCameraIndex + 1
            : 0;

        // Initialize new camera
        await initializeCamera(cameras[selectedCameraIndex]);
        update(); // Update UI
      } else {
        log('No cameras available');
        Get.snackbar('Error', 'No cameras available to switch to',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      log('Error toggling camera: $e');
      Get.snackbar('Error', 'Failed to switch camera',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> captureAndSendPhoto() async {
    if (controller == null || !controller!.value.isInitialized || isCapturing) {
      log('[FaceScanController] Camera not ready or already capturing.');
      return;
    }

    isCapturing = true;
    update();
    log('[FaceScanController] Starting photo capture...');

    try {
      final XFile file = await controller!.takePicture();
      log('[FaceScanController] Photo captured. Path: ${file.path}');
      if (file.path.isEmpty) {
        log('[FaceScanController] Failed to capture photo: file path is empty.');
        Get.snackbar('Error', 'لم يتم التقاط الصورة بنجاح');
        isCapturing = false;
        update();
        return;
      }

      // Show loading indicator
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);
      log('[FaceScanController] Sending photo to backend...');

      // Prepare multipart request
      var uri = Uri.parse('https://do-system.com/api/Hrm/daily-image');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('image', file.path));
      // Add Authorization header with the provided token
      request.headers['Authorization'] = 'Bearer $token';

      log('[FaceScanController] Request prepared. Sending...');
      var response = await request.send();
      log('[FaceScanController] Response status: ${response.statusCode}');
      Get.back(); // Close loading dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('[FaceScanController] Photo uploaded successfully.');
        Get.snackbar(
          'Success',
          'Face image uploaded successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        Get.back();
        await Prefs.setLastFaceScanTime(DateTime.now().toUtc().toString());
        await Future.delayed(const Duration(seconds: 2));
        Get.offAll(() => const HomeScreen());
      } else {
        final respStr = await response.stream.bytesToString();
        log('[FaceScanController] Upload failed: ${response.statusCode} - $respStr');
        if (response.statusCode == 409) {
          Get.snackbar('Notice', "You've already uploaded today's image.");
          Get.back();
          await Prefs.setLastFaceScanTime(DateTime.now().toUtc().toString());
          await Future.delayed(const Duration(seconds: 2));
          Get.offAll(() => const HomeScreen());
        } else {
          Get.snackbar('Error',
              'Failed to upload image: ${response.statusCode}\n$respStr');
          Get.back();
          await Prefs.setLastFaceScanTime(DateTime.now().toUtc().toString());
          await Future.delayed(const Duration(seconds: 2));
          Get.offAll(() => const HomeScreen());
        }
      }
    } catch (e) {
      log('[FaceScanController] Exception: $e');
      Get.back();
      Get.snackbar('خطأ', 'حدث خطأ أثناء التقاط/رفع الصورة: $e');
      Get.back();
      await Prefs.setLastFaceScanTime(DateTime.now().toUtc().toString());
      await Future.delayed(const Duration(seconds: 2));
      Get.offAll(() => const HomeScreen());
    } finally {
      isCapturing = false;
      update();
      log('[FaceScanController] Done.');
    }
  }

  @override
  void onClose() {
    controller?.dispose();
    super.onClose();
  }
}
