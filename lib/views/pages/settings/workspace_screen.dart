import 'dart:convert';

import 'package:attendance/core/controller/setting_controller.dart';
import 'package:attendance/core/model/login_response.dart';
import 'package:attendance/utils/app_color.dart';
import 'package:attendance/utils/app_constant.dart';
import 'package:attendance/utils/common_snackbar_widget.dart';
import 'package:attendance/utils/prefer.dart';
import 'package:attendance/utils/ui_text_style.dart';
import 'package:attendance/views/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkSpaceScreen extends StatefulWidget {
  const WorkSpaceScreen({super.key});

  @override
  State<WorkSpaceScreen> createState() => _WorkSpaceScreenState();
}

class _WorkSpaceScreenState extends State<WorkSpaceScreen> {
  SettingController settingController =Get.put(SettingController());


  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    var jsonList=jsonDecode(Prefs.getString(AppConstant.workSpaceArray));
    var workSpaceList = jsonList.map((json) => Workspace.fromJson(json)).toList();
    return Scaffold(
      backgroundColor: AppColor.appBackGround,
      appBar: AppBar(
        backgroundColor: AppColor.cWhite,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () =>
          {
            Get.back(result: {
              "profileImage": Prefs.getString(AppConstant.profileImage)
            })
          },
        ),
        title: Text(
          "WorkSpace".tr,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColor.cBlack),
        ),
      ),
      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Padding(
                padding: const EdgeInsets.all(14),
                child: ListView.builder(
                    itemCount: workSpaceList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var data = workSpaceList[index];

                      return Obx(() {
                        return GestureDetector(
                            onTap: () {
                              settingController.selectedWorkSpaceId.value = index;
                              settingController.workSpaceId.value = data.id.toString();
                              settingController.selectedWorkSpaceId.refresh();
                            },
                            child: workSpaceWidget(
                              title: data.name,
                              color: data.id.toString() ==
                                  settingController.workSpaceId.value
                                  ? AppColor.themeGreenColor
                                  : AppColor.cWhite,
                              bColor: data.id.toString() ==
                                  settingController.workSpaceId.value
                                  ? AppColor.themeGreenColor
                                  : AppColor.cBorder,
                            ));
                      });
                    }),
              )),
              Padding(
                padding: const EdgeInsets.all(16),
                child: CommonButton(
                  onPressed: () {
                    if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                      commonToast(AppConstant.demoString);
                    } else {
                      Prefs.setString(AppConstant.workSpaceId, settingController.workSpaceId.value);
                      Get.back();
                    }
                  },
                  title: "Save",
                ),
              )
            ],
          )),
    );
  }

  Widget workSpaceWidget({String? title, Color? color, Color? bColor}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        height: 55,
        width: Get.width,
        decoration: BoxDecoration(
          color: AppColor.cWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: bColor ?? AppColor.cBorder)),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  title!,
                  style: pMedium14,
                ),
              ],
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                  border:
                  Border.all(color: bColor ?? AppColor.cBorder, width: 1),
                  shape: BoxShape.circle),
              padding: const EdgeInsets.all(01.5),
              child: CircleAvatar(
                backgroundColor: color ?? AppColor.cWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }


}
