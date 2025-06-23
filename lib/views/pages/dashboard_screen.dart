import 'package:attendance/core/controller/dashboard_controller.dart';
import 'package:attendance/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatelessWidget {

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
  final DashboardController dashboardController = Get.put(DashboardController());

    return Scaffold(
      body: Obx(() {
        return dashboardController
            .itemList[dashboardController.currantIndex.value]['screen'];
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: dashboardController.currantIndex.value,
          onTap: (value) {
            dashboardController.currantIndex.value = value;
          },
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: List.generate(dashboardController.itemList.length, (index) {
            var data = dashboardController.itemList[index];
            return BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  data["icon"],
                  colorFilter: ColorFilter.mode(
                      index == dashboardController.currantIndex.value
                          ? AppColor.themeGreenColor
                          : AppColor.cLabel,
                      BlendMode.srcIn),
                ),
                label: "");
          }),
        ),
      ),
    );
  }
}
