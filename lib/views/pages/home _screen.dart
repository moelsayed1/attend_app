// ignore_for_file: prefer_const_constructors

import 'package:attendance/core/controller/home_controller.dart';
//import 'package:attendance/core/model/meeting_model.dart';
import 'package:attendance/utils/app_color.dart';
import 'package:attendance/utils/ui_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attendance/views/widgets/custom_animated_bottom_bar.dart';

// Import your other screens here
import 'package:attendance/views/pages/leave_history.dart';
import 'package:attendance/views/pages/attendance_history.dart';
import 'package:attendance/views/pages/setting_screen.dart';
import 'package:attendance/views/pages/holiday_list.dart';
import 'package:attendance/views/pages/home_tab_content.dart'; // Import the new file

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController homeController =
      Get.put(HomeController(), permanent: true);
  int _selectedIndex = 0;

  final List<BottomNavItem> _bottomNavItems = [
    BottomNavItem(iconPath: "asset/image/svg_image/ic_home.svg", label: 'Home'),
    BottomNavItem(
        iconPath: "asset/image/svg_image/calendar-tick.svg", label: 'Leaves'),
    BottomNavItem(
        iconPath: "asset/image/svg_image/ic_attendance_history.svg",
        label: 'Attendance'),
    BottomNavItem(
        iconPath: "asset/image/svg_image/calendar.svg", label: 'Holidays'),
    BottomNavItem(
        iconPath: "asset/image/svg_image/ic_settings.svg", label: 'Setting'),
  ];

  // List of screens for the bottom navigation bar
  List<Widget> get _screens => [
        HomeTabContent(homeController: homeController), // Pass homeController
        const LeaveHistory(), // Leaves tab
        const AttendanceHistory(), // Attendance tab
        const HolidayList(),
        const SettingScreen(), // Setting tab
      ];

  // List of titles for each tab
  final List<String> _titles = [
    'Dashboard',
    'Leaves',
    'Attendance',
    'Holidays',
    'Settings'
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index)
      return; // Don't do anything if same tab is tapped
    setState(() {
      _selectedIndex = index;
    });
    homeController.pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 30), // Animation duration
      curve: Curves.easeOut, // Animation curve
    );
  }

  @override
  void initState() {
    super.initState();
    homeController.announcementList.clear();
    // Initialize all controllers at once to prevent token validation on tab switch
    //Get.put(LeaveRequestController(), permanent: true);
    // Get.put(AttendanceHistoryController(), permanent: true);
    //Get.put(EventController(), permanent: true);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // homeController.homeApi();
    });
  }

  @override
  void dispose() {
    // Dispose controllers or resources if needed
    // homeController.dispose(); // Only dispose if controller is not permanent
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBackGround,
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: AppColor.cWhite,
              surfaceTintColor: Colors.transparent,
              title: Text("Dashboard", style: pSemiBold21),
              centerTitle: true,
            )
          : null,
      body: PageView(
        controller: homeController.pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        physics: NeverScrollableScrollPhysics(), // Disable swiping
        children: _screens,
      ),
      bottomNavigationBar: CustomAnimatedBottomBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _bottomNavItems,
      ),
    );
  }
}
