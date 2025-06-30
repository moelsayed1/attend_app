import 'package:attendance/utils/app_color.dart';
import 'package:attendance/views/widgets/icon_and_image.dart';
import 'package:flutter/material.dart';

class BottomNavItem {
  final String iconPath;
  final String label;

  BottomNavItem({required this.iconPath, required this.label});
}

class CustomAnimatedBottomBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;

  const CustomAnimatedBottomBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  State<CustomAnimatedBottomBar> createState() => _CustomAnimatedBottomBarState();
}

class _CustomAnimatedBottomBarState extends State<CustomAnimatedBottomBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90, // Increased height to take more bottom area
      margin: const EdgeInsets.only(top: 10, right: 10, left: 10),
      decoration: BoxDecoration(
        color: AppColor.cWhite, // Background of the whole bar
        borderRadius: BorderRadius.circular(20), // Rounded corners for the bar
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.items.asMap().entries.map((entry) {
          int index = entry.key;
          BottomNavItem item = entry.value;
          bool isSelected = index == widget.selectedIndex;

          return GestureDetector(
            onTap: () => widget.onTap(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.symmetric(horizontal: isSelected ? 32 : 10, vertical: 10), // Increased horizontal padding when selected
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0C335E) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20), // Rounded corners for the icon background
                  ),
                  child: assetSvdImageWidget(
                    image: item.iconPath,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      isSelected ? Colors.white : Colors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 4), // Space between icon and label
                Text(
                  item.label,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF0C335E) : Colors.grey, // Label color changes
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
} 