// ignore_for_file: prefer_const_constructors

import 'package:attendance/core/controller/home_controller.dart';
import 'package:attendance/utils/app_color.dart';
import 'package:attendance/utils/ui_text_style.dart';
import 'package:attendance/views/widgets/common_space_divider_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeamMeetingsSection extends StatelessWidget {
  final HomeController homeController;

  const TeamMeetingsSection({Key? key, required this.homeController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            "Team Meetings",
            style: pSemiBold21.copyWith(color: AppColor.cBlack),
          ),
        ),
        verticalSpace(16),
        Obx(() => ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: homeController.teamMeetings.length,
              itemBuilder: (context, index) {
                final meeting = homeController.teamMeetings[index];
                Color statusColor;
                switch (meeting['status']) {
                  case 'pending':
                    statusColor = Colors.yellow;
                    break;
                  case 'Canceled':
                    statusColor = Colors.red;
                    break;
                  case 'Done':
                    statusColor = Colors.green;
                    break;
                  default:
                    statusColor = AppColor.cWhite;
                }
                return GestureDetector(
                  onTap: () {
                    if (meeting['meeting_link'] != null ||
                        meeting['record_meeting_link'] != null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Meeting Links',
                                style: pSemiBold16.copyWith(
                                    color: AppColor.cBlack)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (meeting['meeting_link'] != null) ...[
                                  InkWell(
                                    onTap: () {
                                      // Add your URL launcher logic here
                                      // launch(meeting['meeting_link']);
                                    },
                                    child: Text(
                                      'Meeting Link',
                                      style: pMedium14.copyWith(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  verticalSpace(8),
                                ],
                                if (meeting['record_meeting_link'] != null) ...[
                                  InkWell(
                                    onTap: () {
                                      // Add your URL launcher logic here
                                      // launch(meeting['record_meeting_link']);
                                    },
                                    child: Text(
                                      'Recording Link',
                                      style: pMedium14.copyWith(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColor.cWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                meeting['title'],
                                style: pBold16.copyWith(color: AppColor.cBlack),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                meeting['status'].toString().toUpperCase(),
                                style: pMedium14.copyWith(color: statusColor),
                              ),
                            ),
                          ],
                        ),
                        verticalSpace(12),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: AppColor.textColor),
                            SizedBox(width: 4),
                            Text(
                              meeting['start_date'] ?? 'No date',
                              style:
                                  pMedium14.copyWith(color: AppColor.textColor),
                            ),
                            SizedBox(width: 16),
                            Icon(Icons.access_time,
                                size: 16, color: AppColor.textColor),
                            SizedBox(width: 4),
                            Text(
                              meeting['start_time'] ?? 'No time',
                              style:
                                  pMedium14.copyWith(color: AppColor.textColor),
                            ),
                            SizedBox(width: 16),
                            Icon(Icons.timer,
                                size: 16, color: AppColor.textColor),
                            SizedBox(width: 4),
                            Text(
                              'Duration: ${meeting['duration'] ?? 'N/A'}',
                              style:
                                  pMedium14.copyWith(color: AppColor.textColor),
                            ),
                          ],
                        ),
                        verticalSpace(8),
                        if (meeting['note'] != null) ...[
                          Text(
                            'Note:',
                            style: pSemiBold14.copyWith(color: AppColor.cBlack),
                          ),
                          verticalSpace(4),
                          Text(
                            meeting['note'],
                            style:
                                pMedium14.copyWith(color: AppColor.textColor),
                          ),
                          verticalSpace(8),
                        ],
                        Row(
                          children: [
                            Icon(Icons.meeting_room,
                                size: 16, color: AppColor.textColor),
                            SizedBox(width: 4),
                            Text(
                              'Meeting Type: ${meeting['meeting_type']?.toString().toUpperCase() ?? 'N/A'}',
                              style:
                                  pMedium14.copyWith(color: AppColor.textColor),
                            ),
                          ],
                        ),
                        verticalSpace(8),
                        if (meeting['meeting_link'] != null) ...[
                          Row(
                            children: [
                              Icon(Icons.link,
                                  size: 16, color: AppColor.textColor),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Meeting Link: ${meeting['meeting_link']}',
                                  style: pMedium14.copyWith(
                                      color: AppColor.textColor),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          verticalSpace(8),
                        ],
                        if (meeting['record_meeting_link'] != null) ...[
                          Row(
                            children: [
                              Icon(Icons.videocam,
                                  size: 16, color: AppColor.textColor),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Recording: ${meeting['record_meeting_link']}',
                                  style: pMedium14.copyWith(
                                      color: AppColor.textColor),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          verticalSpace(8),
                        ],
                        if (meeting['lead'] != null) ...[
                          Text(
                            'Lead Information:',
                            style: pSemiBold14.copyWith(color: AppColor.cBlack),
                          ),
                          verticalSpace(4),
                          Row(
                            children: [
                              Icon(Icons.person,
                                  size: 16, color: AppColor.textColor),
                              SizedBox(width: 4),
                              Text(
                                meeting['lead']['name'] ?? 'N/A',
                                style: pMedium14.copyWith(
                                    color: AppColor.textColor),
                              ),
                            ],
                          ),
                          verticalSpace(4),
                          Row(
                            children: [
                              Icon(Icons.phone,
                                  size: 16, color: AppColor.textColor),
                              SizedBox(width: 4),
                              Text(
                                meeting['lead']['phone'] ?? 'N/A',
                                style: pMedium14.copyWith(
                                    color: AppColor.textColor),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            )),
      ],
    );
  }
}
