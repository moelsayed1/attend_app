// ignore_for_file: prefer_const_constructors

import 'package:attendance/utils/app_color.dart';
import 'package:attendance/utils/image_path.dart';
import 'package:attendance/utils/ui_text_style.dart';
import 'package:attendance/views/widgets/common_space_divider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:attendance/views/widgets/icon_and_image.dart';

class SettingMenuItem extends StatelessWidget {
  final String iconPath;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const SettingMenuItem({
    Key? key,
    required this.iconPath,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.cWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                assetSvdImageWidget(
                  image: iconPath,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isDestructive ? AppColor.cRed : AppColor.primaryColor,
                    BlendMode.srcIn,
                  ),
                ),
                horizontalSpace(16),
                Expanded(
                  child: Text(
                    title,
                    style: pMedium16.copyWith(
                      color: isDestructive ? AppColor.cRed : AppColor.cBlack,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDestructive ? AppColor.cRed : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 