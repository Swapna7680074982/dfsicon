import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class QrMockupPainter extends CustomPainter {
  final Color darkColor;

  QrMockupPainter({this.darkColor = AppColors.textPrimary});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    
    final Paint darkPaint = Paint()
      ..color = darkColor
      ..style = PaintingStyle.fill;
      
    final Paint lightPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double finderSize = width * 0.24;
    _drawFinderPattern(canvas, const Offset(0, 0), finderSize, darkPaint, lightPaint);
    _drawFinderPattern(canvas, Offset(width - finderSize, 0), finderSize, darkPaint, lightPaint);
    _drawFinderPattern(canvas, Offset(0, height - finderSize), finderSize, darkPaint, lightPaint);

    final double alignSize = finderSize * 0.4;
    _drawAlignmentPattern(canvas, Offset(width - finderSize * 1.2, height - finderSize * 1.2), alignSize, darkPaint, lightPaint);

    final int gridCount = 21;
    final double cellSize = width / gridCount;
    final Random random = Random(42);

    for (int r = 0; r < gridCount; r++) {
      for (int c = 0; c < gridCount; c++) {
        bool isTopLeftFinder = r < 7 && c < 7;
        bool isTopRightFinder = r < 7 && c >= gridCount - 7;
        bool isBottomLeftFinder = r >= gridCount - 7 && c < 7;
        
        if (isTopLeftFinder || isTopRightFinder || isBottomLeftFinder) {
          continue;
        }

        if (random.nextDouble() > 0.45) {
          canvas.drawRect(
            Rect.fromLTWH(c * cellSize, r * cellSize, cellSize + 0.5, cellSize + 0.5),
            darkPaint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, Offset offset, double size, Paint darkPaint, Paint lightPaint) {
    canvas.drawRect(Rect.fromLTWH(offset.dx, offset.dy, size, size), darkPaint);
    
    final double strokeWidth = size * 0.14;
    canvas.drawRect(
      Rect.fromLTWH(offset.dx + strokeWidth, offset.dy + strokeWidth, size - strokeWidth * 2, size - strokeWidth * 2),
      lightPaint,
    );
    
    final double innerSize = size * 0.44;
    final double innerOffset = (size - innerSize) / 2;
    canvas.drawRect(
      Rect.fromLTWH(offset.dx + innerOffset, offset.dy + innerOffset, innerSize, innerSize),
      darkPaint,
    );
  }

  void _drawAlignmentPattern(Canvas canvas, Offset offset, double size, Paint darkPaint, Paint lightPaint) {
    canvas.drawRect(Rect.fromLTWH(offset.dx, offset.dy, size, size), darkPaint);
    final double innerWhite = size * 0.33;
    canvas.drawRect(
      Rect.fromLTWH(offset.dx + innerWhite, offset.dy + innerWhite, size - innerWhite * 2, size - innerWhite * 2),
      lightPaint,
    );
    final double centerDark = size * 0.33;
    final double centerOffset = (size - centerDark) / 2;
    canvas.drawRect(
      Rect.fromLTWH(offset.dx + centerOffset, offset.dy + centerOffset, centerDark, centerDark),
      darkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant QrMockupPainter oldDelegate) {
    return oldDelegate.darkColor != darkColor;
  }
}

class EventQrModal extends StatelessWidget {
  final String userName;
  final String eventName;

  const EventQrModal({
    super.key,
    required this.userName,
    required this.eventName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'My Event QR',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Show this at the entrance to check in',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                Container(
                  width: 190,
                  height: 190,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: QrMockupPainter(darkColor: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 18),

                Text(
                  userName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  eventName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
