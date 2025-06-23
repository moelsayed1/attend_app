import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:attendance/views/pages/home _screen.dart';
import 'package:flutter/material.dart';

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
      return;
    }

    isCapturing = true;
    update();

    try {
      await controller!.takePicture();
      
      Get.snackbar(
        'Success', 
        'Face scan completed successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      Get.offAll(() => const HomeScreen());
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture photo: $e');
    } finally {
      isCapturing = false;
      update();
    }
  }

  @override
  void onClose() {
    controller?.dispose();
    super.onClose();
  }
} 