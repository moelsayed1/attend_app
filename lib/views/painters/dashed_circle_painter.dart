import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A custom painter that draws a dashed circle.
/// 
/// This painter creates a circular border with dashes and gaps of specified lengths.
/// The circle is drawn using the provided color and stroke width.
class DashedCirclePainter extends CustomPainter {
  /// The color of the dashed circle
  final Color color;
  
  /// The width of the stroke
  final double strokeWidth;
  
  /// The length of each dash
  final double dashLength;
  
  /// The length of each gap between dashes
  final double gapLength;

  /// Creates a [DashedCirclePainter].
  /// 
  /// All parameters are required:
  /// * [color] - The color of the dashed circle
  /// * [strokeWidth] - The width of the stroke
  /// * [dashLength] - The length of each dash
  /// * [gapLength] - The length of each gap between dashes
  const DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    const double startAngle = 0.0;
    const double sweepAngle = 2 * math.pi; // A full circle

    double currentAngle = startAngle;
    while (currentAngle < startAngle + sweepAngle) {
      final double dashSweep = dashLength / (radius * 2 * math.pi) * sweepAngle;
      final double gapSweep = gapLength / (radius * 2 * math.pi) * sweepAngle;

      canvas.drawArc(
        Rect.fromCircle(center: size.center(Offset.zero), radius: radius),
        currentAngle,
        dashSweep,
        false,
        paint,
      );
      currentAngle += dashSweep + gapSweep;
    }
  }

  @override
  bool shouldRepaint(covariant DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
} 

