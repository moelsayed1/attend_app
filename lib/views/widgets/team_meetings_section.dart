// ignore_for_file: prefer_const_constructors

import 'package:attendance/core/controller/home_controller.dart';
import 'package:attendance/utils/app_color.dart';
import 'package:attendance/utils/ui_text_style.dart';
import 'package:attendance/views/widgets/common_space_divider_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TeamMeetingsSection extends StatelessWidget {
  final HomeController homeController;

  const TeamMeetingsSection({Key? key, required this.homeController}) : super(key: key);

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
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.cWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meeting['title'],
                    style: pBold16.copyWith(color: AppColor.cBlack),
                  ),
                  verticalSpace(8),
                  Text(
                    meeting['description'],
                    style: pMedium14.copyWith(color: AppColor.textColor),
                  ),
                  verticalSpace(8),
                  Text(
                    'Date: ${DateFormat('MMM dd, yyyy').format(meeting['date'])}',
                    style: pMedium14.copyWith(color: AppColor.textColor),
                  ),
                  Text(
                    'Time: ${DateFormat('hh:mm a').format(meeting['date'])}',
                    style: pMedium14.copyWith(color: AppColor.textColor),
                  ),
                ],
              ),
            );
          },
        )),
      ],
    );
  }
} 