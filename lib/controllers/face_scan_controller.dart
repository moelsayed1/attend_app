import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:attendance/views/pages/home _screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:attendance/utils/app_constant.dart';
import 'package:attendance/utils/base_api.dart';
import 'package:attendance/utils/prefer.dart';
import 'package:attendance/views/widgets/loading_widget.dart';
import 'package:http/http.dart' as http;

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
      final XFile file = await controller!.takePicture();
      if (file.path.isEmpty) {
        Get.snackbar('Error', 'Failed to capture photo.');
        isCapturing = false;
        update();
        return;
      }

      Loader.showLoader();
      String url = API.baseUrl + API.dailyImage;
      var headers = {
        "Authorization": 'Bearer '+Prefs.getToken()+'',
      };
      var request = http.MultipartRequest("POST", Uri.parse(url));
      request.fields.addAll({
        'workspace_id': Prefs.getString(AppConstant.workSpaceId),
        'user_id': Prefs.getUserID(),
      });
      request.files.add(await http.MultipartFile.fromPath('image', file.path));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      var decodedData = await response.stream.bytesToString();
      Loader.hideLoader();
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Face scan upload response: ' + decodedData);
        Get.snackbar(
          'Success',
          'Face scan uploaded successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        Get.offAll(() => const HomeScreen());
      } else {
        Get.snackbar('Error', 'Failed to upload face scan: ${response.statusCode}\n$decodedData');
      }
    } catch (e) {
      Loader.hideLoader();
      Get.snackbar('Error', 'Failed to capture/upload photo: $e');
    } finally {
      isCapturing = false;
      update();
    }
  }

  /// Checks if today's face scan image is already uploaded
  Future<bool> isTodayFaceScanUploaded() async {
    try {
      final today = DateTime.now();
      final dateStr = "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      final url = "${API.baseUrl}${API.dailyImage}?workspace_id=${Prefs.getString(AppConstant.workSpaceId)}&user_id=${Prefs.getUserID()}&date=$dateStr";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": 'Bearer '+Prefs.getToken()+'',
          'Content-Type': 'application/json',
        },
      );
      print('Face scan check GET response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        // If the API returns 200 and data, assume image exists
        return true;
      } else if (response.statusCode == 404) {
        // Not found means not uploaded yet
        return false;
      } else {
        // Other errors, treat as not uploaded (or handle as needed)
        return false;
      }
    } catch (e) {
      print('Error checking today face scan: $e');
      return false;
    }
  }

  @override
  void onClose() {
    controller?.dispose();
    super.onClose();
  }
} 