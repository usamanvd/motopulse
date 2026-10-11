import 'dart:math';
import 'package:flutter/material.dart';

class MotoPulseLogo extends StatelessWidget {
  final double size;
  final bool animate;

  const MotoPulseLogo({
    super.key,
    this.size = 100,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF006B58), // Deep Pixel Emerald
            Color(0xFF008F7A), // Teal
            Color(0xFFE8710A), // Coral Accent
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF008F7A).withValues(alpha: 0.35),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.72, size * 0.72),
          painter: _MotoPulseLogoPainter(),
        ),
      ),
    );
  }
}

class _MotoPulseLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer Speedometer Arc
    final arcPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.82),
      pi * 0.75,
      pi * 1.5,
      false,
      arcPaint,
    );

    // Active Speedometer Glow Arc
    final activeArcPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF80D6B1), Colors.white, Color(0xFFFFB784)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.82),
      pi * 0.75,
      pi * 1.1,
      false,
      activeArcPaint,
    );

    // Pulse Wave / Lightning Center
    final pulsePath = Path();
    final pWidth = size.width;
    final pHeight = size.height;

    pulsePath.moveTo(pWidth * 0.22, pHeight * 0.54);
    pulsePath.lineTo(pWidth * 0.42, pHeight * 0.54);
    pulsePath.lineTo(pWidth * 0.52, pHeight * 0.28); // high peak
    pulsePath.lineTo(pWidth * 0.60, pHeight * 0.74); // low dip
    pulsePath.lineTo(pWidth * 0.68, pHeight * 0.54);
    pulsePath.lineTo(pWidth * 0.82, pHeight * 0.54);

    final pulsePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(pulsePath, pulsePaint);

    // Center Needle Hub Dot
    final dotPaint = Paint()
      ..color = const Color(0xFFFFB784)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(pWidth * 0.52, pHeight * 0.28), size.width * 0.07, dotPaint);

    // Fuel Drop / Spark accent
    final sparkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(pWidth * 0.60, pHeight * 0.74), size.width * 0.05, sparkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
