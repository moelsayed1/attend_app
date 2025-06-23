import 'package:attendance/core/model/calender_event_response.dart';
import 'package:attendance/network_dio/network_dio.dart';
import 'package:attendance/utils/base_api.dart';
import 'package:attendance/utils/app_constant.dart';
import 'package:attendance/utils/prefer.dart';
import 'package:attendance/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EventController extends GetxController {

  RxBool isLoading = false.obs;
  RxList selectedEvents= <EventData>[].obs;
  RxList eventList= <EventData>[].obs;
  final List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow, Colors.orange];
  var focusedDay = DateTime.now().obs;
  var selectedDay = DateTime.now().obs;

  String getMonth()
  {
    DateTime now = DateTime.now();
    String month = DateFormat('MM').format(now); // 'MM' ensures the month has leading zero if needed

    return month;
  }
  int getYear()
  {
    DateTime now = DateTime.now();
    return now.year;
  }

  void setSelectedDay(DateTime date) {
    selectedDay.value = date;
  }

  void setFocusedDay(DateTime date) {
    focusedDay.value = date;
  }

  fetchEvents(String monthName,String year) async {
    isLoading.value = true;
    try {
      var responseData = await NetworkHttps.getRequest("${API.eventCalender}?workspace_id=${Prefs.getString(AppConstant.workSpaceId)}&month=$monthName&year=$year");
      print('announcement');
      print(responseData['data']['announcements']);
    } catch (e) {
      isLoading.value = false;
    }
  }

  void updateSelectedEvents(DateTime date) {
    selectedEvents.clear();
    print("Calender  Date ${getDateFormmatted(date)}");
    for( var data in eventList)
    {
      print("appointmentDate${data.startDate}");
    }
    selectedEvents.value = eventList.where((event) => event.startDate == getDateFormmatted(date)).toList();
  }

} 