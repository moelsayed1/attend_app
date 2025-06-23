import 'package:attendance/views/pages/attendance_history.dart';
import 'package:attendance/views/pages/event_calender.dart';
import 'package:attendance/views/pages/home%20_screen.dart';
import 'package:attendance/views/pages/leave_history.dart';
import 'package:attendance/views/pages/setting_screen.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  RxInt currantIndex = 0.obs;
  List itemList = [
    {
      "icon": "asset/image/svg_image/ic_home.svg",
      "screen":  const HomeScreen()
    },
    {
      "icon": "asset/image/svg_image/ic_history.svg",
      "screen":  const LeaveHistory()
    },
    {
      "icon": "asset/image/svg_image/ic_attendance_history.svg",
      "screen":  const AttendanceHistory()
    },
    {
      "icon": "asset/image/svg_image/ic_holiday.svg",
      "screen":  const EventCalender()
    },
    {
      "icon": "asset/image/svg_image/ic_settings.svg",
      "screen":  const SettingScreen()
    },
  ];

  @override
  void onInit() {
    currantIndex=0.obs;
    super.onInit();
  }
}
