import 'dart:math' as math;
import 'package:flutter/material.dart';

class ThemePatternPainter extends CustomPainter {
  final String pattern;
  final Color patColor;
  final bool isDark;

  ThemePatternPainter({
    required this.pattern,
    required this.patColor,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pattern == 'none') return;

    if (pattern == 'grid') {
      _paintGrid(canvas, size);
    } else if (pattern == 'check') {
      _paintCheck(canvas, size);
    } else if (pattern == 'dot') {
      _paintDots(canvas, size);
    } else if (pattern == 'star') {
      _paintStars(canvas, size);
    } else if (pattern == 'spook') {
      _paintSpook(canvas, size);
    }
  }

  void _paintGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = patColor.withValues(alpha: 0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _paintCheck(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = patColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    const double step = 72.0;
    const double half = step / 2.0;

    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        // Alternating picnic gingham squares
        canvas.drawRect(Rect.fromLTWH(x, y, half, half), paint);
        canvas.drawRect(Rect.fromLTWH(x + half, y + half, half, half), paint);
      }
    }
  }

  void _paintDots(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = patColor
      ..style = PaintingStyle.fill;

    const double step = 56.0;
    const double radius = 3.0;

    for (double y = 0; y < size.height + step; y += step) {
      for (double x = 0; x < size.width + step; x += step) {
        canvas.drawCircle(Offset(x, y), radius, paint);
        // Staggered dots
        canvas.drawCircle(Offset(x + step / 2, y + step / 2), radius, paint);
      }
    }
  }

  void _paintStars(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = patColor
      ..style = PaintingStyle.fill;

    const double step = 130.0;
    for (double y = 0; y < size.height + step; y += step) {
      for (double x = 0; x < size.width + step; x += step) {
        _drawStar(canvas, Offset(x + 24, y + 24), 8.0, 3.5, paint);
        _drawStar(canvas, Offset(x + 88, y + 84), 5.5, 2.5, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double outerRadius, double innerRadius, Paint paint) {
    final path = Path();
    const int points = 5;
    const double stepAngle = math.pi / points;

    for (int i = 0; i < points * 2; i++) {
      final double r = i.isEven ? outerRadius : innerRadius;
      final double angle = i * stepAngle - math.pi / 2;
      final double x = center.dx + r * math.cos(angle);
      final double y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _paintSpook(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = patColor
      ..style = PaintingStyle.fill;

    const double step = 150.0;
    for (double y = 0; y < size.height + step; y += step) {
      for (double x = 0; x < size.width + step; x += step) {
        _drawBat(canvas, Offset(x + 30, y + 28), 12.0, paint);
        _drawBat(canvas, Offset(x + 105, y + 100), 9.0, paint);

        // Little spooky glowing dots
        canvas.drawCircle(Offset(x + 115, y + 36), 2.2, paint);
        canvas.drawCircle(Offset(x + 45, y + 118), 1.8, paint);
      }
    }
  }

  void _drawBat(Canvas canvas, Offset center, double scale, Paint paint) {
    final path = Path();
    // Stylized bat silhouette
    path.moveTo(center.dx, center.dy);
    path.quadraticBezierTo(center.dx - scale * 0.4, center.dy - scale * 0.8, center.dx - scale, center.dy - scale * 0.4);
    path.quadraticBezierTo(center.dx - scale * 0.7, center.dy + scale * 0.2, center.dx - scale * 0.3, center.dy + scale * 0.3);
    path.quadraticBezierTo(center.dx - scale * 0.1, center.dy + scale * 0.5, center.dx, center.dy + scale * 0.4);
    path.quadraticBezierTo(center.dx + scale * 0.1, center.dy + scale * 0.5, center.dx + scale * 0.3, center.dy + scale * 0.3);
    path.quadraticBezierTo(center.dx + scale * 0.7, center.dy + scale * 0.2, center.dx + scale, center.dy - scale * 0.4);
    path.quadraticBezierTo(center.dx + scale * 0.4, center.dy - scale * 0.8, center.dx, center.dy);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ThemePatternPainter oldDelegate) {
    return oldDelegate.pattern != pattern ||
        oldDelegate.patColor != patColor ||
        oldDelegate.isDark != isDark;
  }
}
