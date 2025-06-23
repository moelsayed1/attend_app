import 'package:attendance/core/controller/event_controller.dart';
import 'package:attendance/utils/app_color.dart';
import 'package:attendance/utils/helper.dart';
import 'package:attendance/utils/image_path.dart';
import 'package:attendance/utils/ui_text_style.dart';
import 'package:attendance/views/widgets/common_space_divider_widget.dart';
import 'package:attendance/views/widgets/icon_and_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:attendance/core/model/calender_event_response.dart';

class EventCalender extends StatefulWidget {
  const EventCalender({super.key});

  @override
  State<EventCalender> createState() => _EventCalenderState();
}

class _EventCalenderState extends State<EventCalender> {
  final EventController _controller = Get.find<EventController>();

  final List<Map<String, dynamic>> _staticEvents = [
    {
      'title': 'Team Meeting',
      'startDate': '2024-03-22',
      'endDate': '2024-03-22',
      'description': 'Discussion on Q2 strategy.',
      'color': '0xFF42A5F5', // Example color: blue
    },
    {
      'title': 'Project Deadline',
      'startDate': '2024-03-25',
      'endDate': '2024-03-25',
      'description': 'Final submission for Attendance App.',
      'color': '0xFFEF5350', // Example color: red
    },
    {
      'title': 'Client Presentation',
      'startDate': '2024-03-28',
      'endDate': '2024-03-28',
      'description': 'Presenting new features to client.',
      'color': '0xFF66BB6A', // Example color: green
    },
    {
      'title': 'Company Holiday',
      'startDate': '2024-04-01',
      'endDate': '2024-04-01',
      'description': 'New Year\'s Day observed.',
      'color': '0xFFFFCA28', // Example color: amber
    },
    {
      'title': 'Training Session',
      'startDate': '2024-04-05',
      'endDate': '2024-04-06',
      'description': 'Flutter advanced topics workshop.',
      'color': '0xFFAB47BC', // Example color: purple
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller.eventList.clear();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_controller.eventList.isEmpty) {
        // Load static events if no real events are fetched initially
        _staticEvents.forEach((eventMap) {
          _controller.eventList.add(EventData.fromJson(eventMap));
        });
      }
      _controller.fetchEvents(
          _controller.getMonth(), _controller.getYear().toString());
    });
  }

  @override
  Widget build(BuildContext context) {
  return SafeArea(
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.cWhite,
        surfaceTintColor: Colors.transparent,
        title: Text("Event Calender".tr,style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      backgroundColor: AppColor.appBackGround,
    body: Obx(
        ()=> _controller.isLoading.value == true
            ? const Center(
          child: CircularProgressIndicator(),
        ):SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 1, 1),
                  focusedDay: _controller.focusedDay.value,
                  selectedDayPredicate: (day) =>
                      isSameDay(day, _controller.selectedDay.value),
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month'
                  },
                  headerStyle: const HeaderStyle(formatButtonVisible: false,titleCentered: true),
                  calendarStyle: const CalendarStyle(
                    markersAlignment: Alignment.bottomRight,

                    defaultTextStyle: TextStyle(color: Colors.blue),
                    weekNumberTextStyle: TextStyle(color: Colors.red),
                    weekendTextStyle: TextStyle(color: Colors.pink),
                  ),
                  eventLoader: (day) {
                    return _controller.eventList
                        .where((event) =>
                    event.startDate == getDateFormmatted(day))
                        .toList();
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    print("selectedDay $focusedDay");
                    if (!isSameDay(
                        _controller.selectedDay.value, selectedDay)) {
                      _controller.selectedDay.value =
                          _controller.focusedDay.value = focusedDay;
                      _controller.updateSelectedEvents(selectedDay);
                    }
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) => events.isNotEmpty
                        ? Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration:  BoxDecoration(
                        color: AppColor.primaryColor,
                      ),
                      child: Text(
                        '${events.length}',
                        style:
                        const TextStyle(color: Colors.white),
                      ),
                    )
                        : null,
                  ),
                  onPageChanged: (focusedDay) {
                    print("focusDay  $focusedDay");
                    _controller.setFocusedDay(focusedDay);
                    String focusDayMonth = DateFormat('MM').format(focusedDay); // 'MM' ensures the month has leading zero if needed

                    _controller.fetchEvents(
                        focusDayMonth,
                        focusedDay.year.toString());
                    /*_controller.fetchEventsForMonth(
                                focusedDay.year, focusedDay.month);*/
                  },
                ),
                verticalSpace(10),
                _controller.selectedEvents.isNotEmpty  ?Text(
                  "Events",
                  style: pMedium24,
                ) :const SizedBox(),
                verticalSpace(10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _controller.selectedEvents.isEmpty && _staticEvents.isNotEmpty
                      ? _staticEvents.length
                      : _controller.selectedEvents.length,
                  itemBuilder: (context, index) {
                    final isStaticData = _controller.selectedEvents.isEmpty && _staticEvents.isNotEmpty;
                    final dynamic eventItem;

                    if (isStaticData) {
                      eventItem = _staticEvents[index];
                    } else {
                      eventItem = _controller.selectedEvents[index];
                    }

                    String title = '';
                    String startDate = '';
                    String endDate = '';
                    String colorString = '';

                    if (eventItem is Map<String, dynamic>) {
                      title = eventItem['title'].toString();
                      startDate = eventItem['startDate'].toString();
                      endDate = eventItem['endDate'].toString();
                      colorString = eventItem['color'].toString();
                    } else if (eventItem is EventData) {
                      title = eventItem.title.toString();
                      startDate = eventItem.startDate.toString();
                      endDate = eventItem.endDate.toString();
                      colorString = eventItem.color.toString();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColor.cWhite),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Color(int.parse(colorString)),
                                borderRadius:
                                BorderRadius.circular(12)),
                            child: assetSvdImageWidget(
                                image: ImagePath.calender,
                                colorFilter: ColorFilter.mode(
                                    AppColor.cWhite, BlendMode.srcIn)),
                          ),
                          title: Text(
                            title,
                            style: pMedium16,
                          ),
                          subtitle: Text(
                            'Start Date: ${startDate} - End Date: ${endDate}',
                            style: pRegular12.copyWith(
                                color: AppColor.grey),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              ],
            ),
          ),
        )
    ),
    ),
  );
  }
}