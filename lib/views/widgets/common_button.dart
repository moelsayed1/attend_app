import 'package:attendance/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import for responsive sizing

class CommonButton extends StatelessWidget {
  final String? title;
  final Function()? onPressed;
  final Color? buttonColor; // Add a color parameter
  final TextStyle? textStyle; // Optional text style parameter

  const CommonButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.buttonColor, // Make color optional
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 40.h, // Make height responsive
        decoration: BoxDecoration(
          color: buttonColor ?? AppColor.cLabel, // Use provided color or a default
          borderRadius: BorderRadius.circular(15.r), // Make border radius responsive
        ),
        child: Center(
          child: Text(
            title!,
            style: textStyle ?? const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontFamily: 'Outfit',
            ), // Use provided text style or a default
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
