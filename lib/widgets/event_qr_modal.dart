import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/auth_provider.dart';
import '../domain/utility_models.dart';

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

    const int gridCount = 21;
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

class EventQrModal extends StatefulWidget {
  final String? userName;
  final String? eventName;

  const EventQrModal({
    super.key,
    this.userName,
    this.eventName,
  });

  @override
  State<EventQrModal> createState() => _EventQrModalState();
}

class _EventQrModalState extends State<EventQrModal> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      auth.fetchMyQr(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final MyQrData? qrData = authProvider.myQrData;
    final bool isFetching = authProvider.isFetchingQr;

    final String displayName = authProvider.userName.isNotEmpty
        ? authProvider.userName
        : (widget.userName ?? 'User');

    final String displayRole = (qrData != null && qrData.roleCode.isNotEmpty)
        ? (qrData.roleCode.toUpperCase() == 'SK' ? 'Speaker' : 'Delegate')
        : (authProvider.isSpeaker ? 'Speaker' : 'Delegate');

    final String displaySummit = qrData?.summitTitle.isNotEmpty == true
        ? qrData!.summitTitle
        : (widget.eventName ?? 'Diabetic Foot Society of India');

    final String summitDates = qrData?.summitDates ?? '';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 16,
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
                      'My Event QR Code',
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
                      'Show this QR at entrance & desk check-in',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // QR Container
                  Container(
                    width: 220,
                    height: 220,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: AppColors.tileBorder, width: 1),
                    ),
                    child: isFetching && qrData == null
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Fetching QR...',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : (qrData != null && qrData.qrImage.isNotEmpty)
                            ? Image.network(
                                qrData.qrImage,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.primary,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return CustomPaint(
                                    painter: QrMockupPainter(darkColor: AppColors.textPrimary),
                                  );
                                },
                              )
                            : CustomPaint(
                                painter: QrMockupPainter(darkColor: AppColors.textPrimary),
                              ),
                  ),
                  const SizedBox(height: 18),

                  // User Name
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withAlpha(50)),
                    ),
                    child: Text(
                      'Role: $displayRole',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Summit Title & Dates Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          displaySummit,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (summitDates.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                summitDates,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
