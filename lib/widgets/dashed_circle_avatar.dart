import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;
  final double gapLength;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashCount = 45,
    this.gapLength = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double circumference = 2 * pi * radius;
    
    final double gapAngle = (gapLength / circumference) * 2 * pi;
    final double dashAngle = (2 * pi / dashCount) - gapAngle;

    for (int i = 0; i < dashCount; i++) {
      final double startAngle = i * (2 * pi / dashCount);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashCount != dashCount ||
        oldDelegate.gapLength != gapLength;
  }
}

class DashedCircleAvatar extends StatelessWidget {
  final String? imagePath;
  final double radius;
  final VoidCallback? onTap;

  const DashedCircleAvatar({
    super.key,
    this.imagePath,
    this.radius = 80,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double diameter = radius * 2;

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: diameter,
          height: diameter,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              if (imagePath == null)
                Positioned.fill(
                  child: CustomPaint(
                    painter: DashedCirclePainter(
                      color: AppColors.avatarDottedBorder,
                      strokeWidth: 2.0,
                      dashCount: 40,
                      gapLength: 4.5,
                    ),
                  ),
                ),

              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: imagePath == null 
                          ? AppColors.avatarBg 
                          : Colors.transparent,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imagePath != null
                        ? Image.file(
                            File(imagePath!),
                            fit: BoxFit.cover,
                            width: diameter,
                            height: diameter,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: radius * 0.5,
                                color: AppColors.iconCamera,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Your photo',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.iconCamera,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
