// ignore_for_file: deprecated_member_use

import 'package:attendance/core/controller/holiday_list_controller.dart';
import 'package:attendance/utils/app_color.dart';
import 'package:attendance/utils/helper.dart';
import 'package:attendance/utils/ui_text_style.dart';
import 'package:attendance/views/widgets/common_space_divider_widget.dart';
import 'package:attendance/views/widgets/icon_and_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HolidayList extends StatefulWidget {
  const HolidayList({super.key});

  @override
  State<HolidayList> createState() => _HolidayListState();
}

class _HolidayListState extends State<HolidayList> {
  ScrollController scrollController = ScrollController();

  final HolidayListController holidayController =
      Get.put(HolidayListController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Center(
          child: Text(
            "Holidays".tr,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      backgroundColor: AppColor.appBackGround,
      body: SafeArea(
        child: GetBuilder<HolidayListController>(builder: (controller) {
          return RefreshIndicator(
            onRefresh: () async {
              await controller.getHolidayList();
            },
            child: controller.holidayList.isEmpty && !controller.isLoading.value
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_sharp,
                            size: 80,
                            color: AppColor.primaryColor.withOpacity(0.7),
                          ),
                          verticalSpace(16),
                          Text(
                            "No Holidays Found",
                            style: pMedium16.copyWith(
                                color: AppColor.cBlack,
                                fontWeight: FontWeight.w500),
                          ),
                          verticalSpace(8),
                          Text(
                            "There are no upcoming holidays scheduled",
                            style: pRegular14.copyWith(color: AppColor.cLabel),
                          ),
                        ],
                      )),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.holidayList.length,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    itemBuilder: (context, index) {
                      var data = controller.holidayList[index];

                      return GestureDetector(
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColor.cWhite,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.title.toString(),
                                style: TextStyle(
                                  color: AppColor.cLabel,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColor.primaryColor
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        assetSvdImageWidget(
                                          image:
                                              "asset/image/svg_image/ic_calender.svg",
                                          width: 18,
                                          height: 18,
                                        ),
                                        horizontalSpace(8),
                                        Text(
                                          dateFormatted(
                                              date: data.start ?? "",
                                              formatType: formatForDateTime(
                                                  FormatType.ddMMMYYYY)),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColor.cLabel,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  if (data.className?.isNotEmpty == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColor.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        data.className ?? "",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColor.primaryColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
        }),
      ),
    );
  }
}
