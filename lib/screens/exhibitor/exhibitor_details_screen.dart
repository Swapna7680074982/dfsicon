import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../providers/explore_provider.dart';

class ExhibitorDetailsScreen extends StatelessWidget {
  final Exhibitor exhibitor;

  const ExhibitorDetailsScreen({super.key, required this.exhibitor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          exhibitor.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.tileBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: exhibitor.bg,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      exhibitor.initials,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exhibitor.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exhibitor.category,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEEECF9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${exhibitor.boothCode}  •  ${exhibitor.boothZone}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.tileBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exhibitor.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.tileBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Products & Services',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...exhibitor.products.map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              p,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Downloading brochure for ${exhibitor.name}...'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text(
                        'Download Brochure',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: Color(0xFFD1CBEF), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.tileBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booth Location',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Convention Center / Floor Plan / ${exhibitor.boothCode}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100, width: 1),
                    ),
                    child: CustomPaint(
                      painter: ExhibitorFloorPlanPainter(exhibitorId: exhibitor.id),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.tileBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactRow(
                    icon: Icons.language,
                    text: exhibitor.website,
                  ),
                  const SizedBox(height: 14),
                  _buildContactRow(
                    icon: Icons.email_outlined,
                    text: exhibitor.email,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.textSecondary, size: 16),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class ExhibitorFloorPlanPainter extends CustomPainter {
  final String exhibitorId;

  const ExhibitorFloorPlanPainter({required this.exhibitorId});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final fillHighlight = Paint()
      ..color = const Color(0xFFEEF2FF)
      ..style = PaintingStyle.fill;

    final borderHighlight = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillOther = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final isHallA = exhibitorId == 'ha';
    final isHallB = exhibitorId == 'hb';
    final isRoomC = exhibitorId == 'cf';
    final isRoomD = exhibitorId == 'pt';
    final isExhibitionHall = exhibitorId == 'mc';

    final hallARect = RRect.fromRectAndRadius(
      Rect.fromLTWH(16, 16, (size.width - 48) * 0.45, 60),
      const Radius.circular(8),
    );
    canvas.drawRRect(hallARect, isHallA ? fillHighlight : fillOther);
    canvas.drawRRect(hallARect, isHallA ? borderHighlight : paintLine);

    final hallBRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(24 + (size.width - 48) * 0.45, 16, (size.width - 48) * 0.55, 60),
      const Radius.circular(8),
    );
    canvas.drawRRect(hallBRect, isHallB ? fillHighlight : fillOther);
    canvas.drawRRect(hallBRect, isHallB ? borderHighlight : paintLine);

    final roomCRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(16, 88, (size.width - 48) * 0.3, 40),
      const Radius.circular(8),
    );
    canvas.drawRRect(roomCRect, isRoomC ? fillHighlight : fillOther);
    canvas.drawRRect(roomCRect, isRoomC ? borderHighlight : paintLine);

    final lobbyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(24 + (size.width - 48) * 0.3, 88, (size.width - 48) * 0.7, 40),
      const Radius.circular(8),
    );
    canvas.drawRRect(lobbyRect, fillOther);
    canvas.drawRRect(lobbyRect, paintLine);

    final roomDRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(16, 140, (size.width - 48) * 0.33, 40),
      const Radius.circular(8),
    );
    canvas.drawRRect(roomDRect, isRoomD ? fillHighlight : fillOther);
    canvas.drawRRect(roomDRect, isRoomD ? borderHighlight : paintLine);

    final exhibitRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(24 + (size.width - 48) * 0.33, 140, (size.width - 48) * 0.67, 40),
      const Radius.circular(8),
    );
    canvas.drawRRect(exhibitRect, isExhibitionHall ? fillHighlight : fillOther);
    canvas.drawRRect(exhibitRect, isExhibitionHall ? borderHighlight : paintLine);

    _drawCenterText(canvas, textPainter, 'Hall A', Offset(16 + (size.width - 48) * 0.225, 46), isHighlighted: isHallA);
    _drawCenterText(canvas, textPainter, 'Hall B', Offset(24 + (size.width - 48) * 0.725, 46), isHighlighted: isHallB);
    _drawCenterText(canvas, textPainter, 'Room C', Offset(16 + (size.width - 48) * 0.15, 108), isHighlighted: isRoomC);
    _drawCenterText(canvas, textPainter, 'Lobby', Offset(24 + (size.width - 48) * 0.65, 108));
    _drawCenterText(canvas, textPainter, 'Room D', Offset(16 + (size.width - 48) * 0.165, 160), isHighlighted: isRoomD);
    _drawCenterText(canvas, textPainter, 'Exhibition Hall', Offset(24 + (size.width - 48) * 0.665, 160), isHighlighted: isExhibitionHall);

    final dotPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;
    final outerDotPaint = Paint()
      ..color = const Color(0xFF6366F1).withAlpha(40)
      ..style = PaintingStyle.fill;

    Offset? targetOffset;
    if (isHallA) {
      targetOffset = Offset(16 + (size.width - 48) * 0.225, 46);
    } else if (isHallB) {
      targetOffset = Offset(24 + (size.width - 48) * 0.725, 46);
    } else if (isRoomC) {
      targetOffset = Offset(16 + (size.width - 48) * 0.15, 108);
    } else if (isRoomD) {
      targetOffset = Offset(16 + (size.width - 48) * 0.165, 160);
    } else if (isExhibitionHall) {
      targetOffset = Offset(24 + (size.width - 48) * 0.665, 160);
    }

    if (targetOffset != null) {
      canvas.drawCircle(Offset(targetOffset.dx, targetOffset.dy + 12), 10, outerDotPaint);
      canvas.drawCircle(Offset(targetOffset.dx, targetOffset.dy + 12), 4, dotPaint);
    }
  }

  void _drawCenterText(Canvas canvas, TextPainter tp, String text, Offset center, {bool isHighlighted = false}) {
    tp.text = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
        color: isHighlighted ? const Color(0xFF2B1F7D) : AppColors.textSecondary,
      ),
    );
    tp.layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
