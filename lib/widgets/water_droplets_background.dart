import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class WaterDropletsBackground extends StatelessWidget {
  final Widget child;

  const WaterDropletsBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _WaterDropletPainter(),
          ),
        ),
        child,
      ],
    );
  }
}

class _WaterDropletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 1. Draw base background color
    canvas.drawColor(const Color(0xFFDFE9F7), BlendMode.srcOver);

    // 2. Draw soft ambient glow (fluid background gradient)
    final gradient = RadialGradient(
      center: Alignment.topLeft,
      radius: 1.4,
      colors: [
        AppColors.primary.withAlpha(20),
        const Color(0xFFDFE9F7),
      ],
    );
    paint.shader = gradient.createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);

    // 3. Draw repeating subtle "DFSICON" watermark
    final textStyle = TextStyle(
      color: AppColors.primary.withAlpha(10), // Extremely soft purple/blue
      fontSize: 44,
      fontWeight: FontWeight.w900,
      letterSpacing: 4.0,
      fontFamily: 'Roboto',
    );
    final textPainter = TextPainter(
      text: TextSpan(text: 'DFSICON 2026', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    canvas.save();
    canvas.rotate(-math.pi / 8); // Tilted watermark
    for (double y = -150; y < size.height * 1.5; y += 220) {
      for (double x = -150; x < size.width * 1.5; x += 320) {
        textPainter.paint(canvas, Offset(x, y));
      }
    }
    canvas.restore();

    // 4. Paint realistic transparent water droplets
    final math.Random random = math.Random(54321); // Constant seed for stable drop layout
    final int numDroplets = 26;

    for (int i = 0; i < numDroplets; i++) {
      final double cx = random.nextDouble() * size.width;
      final double cy = random.nextDouble() * size.height;
      final double r = 10.0 + random.nextDouble() * 18.0;

      // Soft drop shadow below the water drop
      paint.shader = null;
      paint.color = Colors.black.withAlpha(8);
      canvas.drawCircle(Offset(cx, cy + 1.8), r, paint);

      // Droplet refraction body (radial gradient)
      final dropletGrad = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.95,
        colors: [
          Colors.white.withAlpha(100),
          AppColors.primary.withAlpha(25),
          AppColors.primary.withAlpha(55),
        ],
        stops: const [0.0, 0.55, 1.0],
      );
      paint.shader = dropletGrad.createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
      canvas.drawCircle(Offset(cx, cy), r, paint);

      // Droplet top-left light glare reflection
      paint.shader = null;
      paint.color = Colors.white.withAlpha(180);
      canvas.drawCircle(Offset(cx - r * 0.35, cy - r * 0.35), r * 0.22, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
