// ignore_for_file: prefer_const_constructors

import 'package:attendance/core/controller/home_controller.dart';
import 'package:attendance/utils/app_color.dart';
import 'package:attendance/utils/ui_text_style.dart';
import 'package:attendance/views/widgets/common_space_divider_widget.dart';
import 'package:flutter/material.dart';

class AnnouncementsSection extends StatelessWidget {
  final HomeController homeController;

  const AnnouncementsSection({Key? key, required this.homeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: homeController.isViewVisible.value,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text("Announcement's",
                  style: pMedium18.copyWith(
                      color: AppColor.cBlack, fontSize: 24)),
            ),
          ),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final data = homeController.announcementList[index];
              return Padding(
                padding: EdgeInsets.only(top: 10),
                child: Container(
                  height: 110,
                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColor.cWhite),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        data.title.toString(),
                        style: pBold16.copyWith(color: AppColor.cBlack),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                      verticalSpace(3),
                      Text(
                          "Date : ${homeController.eventDate(data.startDate)} To ${homeController.eventDate(data.endDate)}",
                          style: pMedium14.copyWith(
                              color: AppColor.cBlack),
                          textAlign: TextAlign.center),
                      verticalSpace(3),
                      Text(data.description.toString(),
                          style: pRegular14.copyWith(
                              color: AppColor.cBlack),
                          maxLines: 3,
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.start)
                    ],
                  ),
                ),
              );
            },
            itemCount: homeController.announcementList.length,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 0),
          ),
        ],
      ),
    );
  }
} 