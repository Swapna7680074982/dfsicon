import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/colors.dart';
import '../../providers/explore_provider.dart';
import '../../widgets/water_droplets_background.dart';

class ExhibitorDetailsScreen extends StatelessWidget {
  final Exhibitor exhibitor;

  const ExhibitorDetailsScreen({super.key, required this.exhibitor});

  @override
  Widget build(BuildContext context) {
    return WaterDropletsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            exhibitor.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
                color: Colors.white.withAlpha(240),
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
                      color: exhibitor.logoUrl != null ? Colors.white : exhibitor.bg,
                      shape: BoxShape.circle,
                      border: exhibitor.logoUrl != null ? Border.all(color: AppColors.tileBorder, width: 1) : null,
                    ),
                    alignment: Alignment.center,
                    clipBehavior: Clip.antiAlias,
                    child: exhibitor.logoUrl != null
                        ? Image.network(
                            exhibitor.logoUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Text(
                              exhibitor.initials.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              exhibitor.initials.toUpperCase(),
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
                          exhibitor.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exhibitor.category.toUpperCase(),
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
                    '${exhibitor.boothCode.toUpperCase()}  •  ${exhibitor.boothZone.toUpperCase()}',
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
                color: Colors.white.withAlpha(240),
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
                color: Colors.white.withAlpha(240),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.tileBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PRODUCTS & SERVICES',
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
                      onPressed: () async {
                        final String? url = exhibitor.brochureUrl;
                        if (url != null && url.isNotEmpty) {
                          final Uri uri = Uri.parse(url);
                          try {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to open brochure: $e'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('No brochure available for ${exhibitor.name}.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text(
                        'DOWNLOAD BROCHURE',
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
                color: Colors.white.withAlpha(240),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.tileBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BOOTH LOCATION',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Convention Center / Floor Plan / ${exhibitor.boothCode}'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 240,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100, width: 1),
                    ),
                    child: CustomPaint(
                      painter: ExhibitorFloorPlanPainter(boothCode: exhibitor.boothCode),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(240),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.tileBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CONTACT',
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
    ),);
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
  final String boothCode;

  const ExhibitorFloorPlanPainter({required this.boothCode});

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

    final codeClean = boothCode.toLowerCase();
    final isBooth1 = codeClean.contains('booth 1');
    final isBooth2 = codeClean.contains('booth 2');
    final isBooth3 = codeClean.contains('booth 3');
    final isBooth4 = codeClean.contains('booth 4');
    final isBooth5 = codeClean.contains('booth 5');
    final isBooth6 = codeClean.contains('booth 6');

    final hallARect = RRect.fromRectAndRadius(
      Rect.fromLTWH(16, 16, (size.width - 48) * 0.45, 60),
      const Radius.circular(8),
    );
    canvas.drawRRect(hallARect, isBooth1 ? fillHighlight : fillOther);
    canvas.drawRRect(hallARect, isBooth1 ? borderHighlight : paintLine);

    final hallBRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(24 + (size.width - 48) * 0.45, 16, (size.width - 48) * 0.55, 60),
      const Radius.circular(8),
    );
    canvas.drawRRect(hallBRect, isBooth2 ? fillHighlight : fillOther);
    canvas.drawRRect(hallBRect, isBooth2 ? borderHighlight : paintLine);

    final roomCRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(16, 88, (size.width - 48) * 0.3, 60),
      const Radius.circular(8),
    );
    canvas.drawRRect(roomCRect, isBooth3 ? fillHighlight : fillOther);
    canvas.drawRRect(roomCRect, isBooth3 ? borderHighlight : paintLine);

    final lobbyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(24 + (size.width - 48) * 0.3, 88, (size.width - 48) * 0.7, 60),
      const Radius.circular(8),
    );
    canvas.drawRRect(lobbyRect, fillOther);
    canvas.drawRRect(lobbyRect, paintLine);

    final roomDRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(16, 160, (size.width - 48) * 0.33, 60),
      const Radius.circular(8),
    );
    canvas.drawRRect(roomDRect, isBooth4 ? fillHighlight : fillOther);
    canvas.drawRRect(roomDRect, isBooth4 ? borderHighlight : paintLine);

    final booth5Rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(24 + (size.width - 48) * 0.33, 160, (size.width - 48) * 0.33, 60),
      const Radius.circular(8),
    );
    canvas.drawRRect(booth5Rect, isBooth5 ? fillHighlight : fillOther);
    canvas.drawRRect(booth5Rect, isBooth5 ? borderHighlight : paintLine);

    final booth6Rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(32 + (size.width - 48) * 0.66, 160, (size.width - 48) * 0.34, 60),
      const Radius.circular(8),
    );
    canvas.drawRRect(booth6Rect, isBooth6 ? fillHighlight : fillOther);
    canvas.drawRRect(booth6Rect, isBooth6 ? borderHighlight : paintLine);

    _drawCenterText(canvas, textPainter, 'Booth 1', Offset(16 + (size.width - 48) * 0.225, 46), isHighlighted: isBooth1);
    _drawCenterText(canvas, textPainter, 'Booth 2', Offset(24 + (size.width - 48) * 0.725, 46), isHighlighted: isBooth2);
    _drawCenterText(canvas, textPainter, 'Booth 3', Offset(16 + (size.width - 48) * 0.15, 118), isHighlighted: isBooth3);
    _drawCenterText(canvas, textPainter, 'Lobby', Offset(24 + (size.width - 48) * 0.65, 118));
    _drawCenterText(canvas, textPainter, 'Booth 4', Offset(16 + (size.width - 48) * 0.165, 190), isHighlighted: isBooth4);
    _drawCenterText(canvas, textPainter, 'Booth 5', Offset(24 + (size.width - 48) * 0.495, 190), isHighlighted: isBooth5);
    _drawCenterText(canvas, textPainter, 'Booth 6', Offset(32 + (size.width - 48) * 0.83, 190), isHighlighted: isBooth6);

    final dotPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;
    final outerDotPaint = Paint()
      ..color = const Color(0xFF6366F1).withAlpha(40)
      ..style = PaintingStyle.fill;

    Offset? targetOffset;
    if (isBooth1) {
      targetOffset = Offset(16 + (size.width - 48) * 0.225, 46);
    } else if (isBooth2) {
      targetOffset = Offset(24 + (size.width - 48) * 0.725, 46);
    } else if (isBooth3) {
      targetOffset = Offset(16 + (size.width - 48) * 0.15, 118);
    } else if (isBooth4) {
      targetOffset = Offset(16 + (size.width - 48) * 0.165, 190);
    } else if (isBooth5) {
      targetOffset = Offset(24 + (size.width - 48) * 0.495, 190);
    } else if (isBooth6) {
      targetOffset = Offset(32 + (size.width - 48) * 0.83, 190);
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
