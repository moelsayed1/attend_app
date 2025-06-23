// ignore_for_file: prefer_const_constructors

import 'package:attendance/utils/app_color.dart';
import 'package:attendance/utils/ui_text_style.dart';
import 'package:attendance/views/widgets/common_space_divider_widget.dart';
import 'package:attendance/views/widgets/icon_and_image.dart';
import 'package:flutter/material.dart';

class AttendanceRowWidget extends StatelessWidget {
  final String iconPath;
  final String title;
  final String dateTimeText;

  const AttendanceRowWidget({
    Key? key,
    required this.iconPath,
    required this.title,
    required this.dateTimeText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        assetSvdImageWidget(image: iconPath, width: 20, height: 20),
        horizontalSpace(16),
        Text(
          title,
          style: pMedium16.copyWith(color: AppColor.primaryColor),
        ),
        Expanded(
          child: Text(
            dateTimeText,
            textAlign: TextAlign.right,
            style: pMedium16.copyWith(color: AppColor.textColor),
          ),
        ),
      ],
    );
  }
} 