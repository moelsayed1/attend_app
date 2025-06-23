import 'package:attendance/core/controller/attendence_history_controller.dart';
import 'package:attendance/utils/app_color.dart';
import 'package:attendance/utils/app_constant.dart';
import 'package:attendance/utils/image_path.dart';
import 'package:attendance/utils/prefer.dart';
import 'package:attendance/utils/ui_text_style.dart';
import 'package:attendance/views/widgets/common_space_divider_widget.dart';
import 'package:attendance/views/widgets/icon_and_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attendance/core/model/attendance_history.dart';

class AttendanceHistory extends StatefulWidget {

  const AttendanceHistory({super.key});

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  ScrollController scrollController = ScrollController();

  final AttendanceHistoryController historyController = Get.find<AttendanceHistoryController>();

  final List<Map<String, dynamic>> _staticAttendanceHistory = [
    {
      'total_time': '08:00',
      'date': '2024-03-22',
      'history': [
        {'clock_in': '09:00 AM', 'clock_out': '01:00 PM', 'total': '04:00'},
        {'clock_in': '02:00 PM', 'clock_out': '06:00 PM', 'total': '04:00'},
      ],
    },
    {
      'total_time': '07:30',
      'date': '2024-03-21',
      'history': [
        {'clock_in': '09:30 AM', 'clock_out': '05:00 PM', 'total': '07:30'},
      ],
    },
    {
      'total_time': '08:00',
      'date': '2024-03-20',
      'history': [
        {'clock_in': '08:00 AM', 'clock_out': '12:00 PM', 'total': '04:00'},
        {'clock_in': '01:00 PM', 'clock_out': '05:00 PM', 'total': '04:00'},
      ],
    },
    {
      'total_time': '06:45',
      'date': '2024-03-19',
      'history': [
        {'clock_in': '10:00 AM', 'clock_out': '04:45 PM', 'total': '06:45'},
      ],
    },
    {
      'total_time': '08:15',
      'date': '2024-03-18',
      'history': [
        {'clock_in': '08:45 AM', 'clock_out': '05:00 PM', 'total': '08:15'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    historyController.attendanceHistoryList.clear();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (historyController.attendanceHistoryList.isEmpty) {
        _staticAttendanceHistory.forEach((dataMap) {
          historyController.attendanceHistoryList.add(AttendanceData.fromJson(dataMap));
        });
      }
   historyController.attendanceHistory(historyController.currentMonth.value.toString(),historyController.currentYear.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    String languageCode = Prefs.getString(AppConstant.languageCode) == '' ? 'en' : Prefs.getString(AppConstant.languageCode);


    return Scaffold(
      backgroundColor: AppColor.appBackGround,
      appBar: AppBar(
        backgroundColor: AppColor.cWhite,
        surfaceTintColor: Colors.transparent,
        title: const Text("Attendance History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              verticalSpace(20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  height: 40,
                  decoration: BoxDecoration(
                      color: AppColor.cWhite,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(child: assetSvdImageWidget(image:languageCode == 'ar'?ImagePath.ic_next :ImagePath.ic_prev),onTap: (){
                            historyController.navigateToPreviousMonth();
                      },),
                      Expanded(
                        child: Center(
                          child: Text(
                            historyController.selectedDateText.value,
                              style: pSemiBold16.copyWith(color: AppColor.cBlack),
                          ),
                        ),
                      ),
                      InkWell(child:assetSvdImageWidget(image: languageCode == 'ar'?ImagePath.ic_prev :ImagePath.ic_next), onTap: () {
                        historyController.navigateToNextMonth();
                      }),
                    ],
                  ),
                ),
              ),
              verticalSpace(20),
              Expanded(
                child: historyController.isLoading.value==true ?  const Center(child: CircularProgressIndicator()):

                historyController.attendanceHistoryList.value.isEmpty ?Center(child: Text("Data Not Found",style: pMedium16.copyWith(color: AppColor.cBlack))):

                ListView.builder(
                    shrinkWrap: true,
                    itemCount: historyController.attendanceHistoryList.value.isEmpty
                        ? _staticAttendanceHistory.length
                        : historyController.attendanceHistoryList.value.length,
                    scrollDirection: Axis.vertical,
                    controller: scrollController,
                    clipBehavior: Clip.hardEdge,
                    itemBuilder: (context, index) {
                      final dataList = historyController.attendanceHistoryList.value.isEmpty
                          ? _staticAttendanceHistory
                          : historyController.attendanceHistoryList.value.map((e) => e.toJson()).toList();
                      final Map<String, dynamic> attendanceData = dataList[index];

                      final List<Map<String, dynamic>> historyList = (attendanceData['history'] as List)
                          .map((e) => e as Map<String, dynamic>).toList();

                      return ClipRect(
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          child: Container(

                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: AppColor.cWhite),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 35,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(topRight:Radius.circular(12),topLeft: Radius.circular(12)),
                                    color: AppColor.primaryColor,
                                  ),

                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(child: Text("Date: ${historyController.getFormattedDate(attendanceData['date'].toString())}",style: pSemiBold14.copyWith(color: AppColor.cWhite),)),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text("Total Hours : ${attendanceData['total_time'].toString()}",style: pSemiBold14.copyWith(color: AppColor.cWhite)),
                                        ),
                                      )

                                    ],
                                  ),
                                ),
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: historyList.length,
                                    scrollDirection: Axis.vertical,
                                    clipBehavior: Clip.hardEdge,
                                    itemBuilder: (context,index){

                                      var historyData=historyList[index];
                                      return   Padding(
                                        padding: const EdgeInsets.only(top: 8,left: 16,right: 16,bottom: 8),
                                        child: Column(

                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                timeWidget(ImagePath.check_in,
                                                    historyData['clock_in'] ?? "", "Check In"),
                                                const VerticalDivider(),
                                                timeWidget(ImagePath.check_out,
                                                    historyData['clock_out'] ?? "", "Check Out"),
                                                const VerticalDivider(),
                                                timeWidget(ImagePath.total_hrs,
                                                    historyData['total'] ?? "", "Total Hrs"),
                                              ],
                                            ),
                                            const Divider()
                                          ],

                                        ),
                                      );
                                    })
                              ],
                            )
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget timeWidget(String icon, String time, String titleText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        assetSvdImageWidget(image: icon, width: 16, height: 16),
        verticalSpace(5),
        Text(time, style: pMedium14),
        Text(titleText, style: pRegular14),
      ],
    );
  }
}
