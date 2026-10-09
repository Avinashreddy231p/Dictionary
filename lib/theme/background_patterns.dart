import 'package:flutter/material.dart';

class BackgroundTextureWidget extends StatelessWidget {
  final String texture; // 'none', 'dots', 'grid', 'crosshatch'
  final Widget child;
  final double opacity;

  const BackgroundTextureWidget({
    super.key,
    required this.texture,
    required this.child,
    this.opacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    if (texture == 'none' || texture.isEmpty || opacity <= 0) {
      return child;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = theme.colorScheme.background;
    final baseAlpha = isDark ? 0.24 : 0.16;
    final patternColor = (isDark ? Colors.white : Colors.black)
        .withOpacity((baseAlpha * opacity).clamp(0.0, 1.0));

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: BackgroundTexturePainter(
              texture: texture,
              backgroundColor: bgColor,
              patternColor: patternColor,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class BackgroundTexturePainter extends CustomPainter {
  final String texture;
  final Color backgroundColor;
  final Color patternColor;

  BackgroundTexturePainter({
    required this.texture,
    required this.backgroundColor,
    required this.patternColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fill background canvas
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Draw texture pattern on top of background canvas
    final paint = Paint()
      ..color = patternColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    if (texture == 'dots') {
      final dotPaint = Paint()
        ..color = patternColor
        ..style = PaintingStyle.fill;

      const spacing = 22.0;
      const dotRadius = 1.3;

      for (double x = spacing / 2; x < size.width; x += spacing) {
        for (double y = spacing / 2; y < size.height; y += spacing) {
          canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
        }
      }
    } else if (texture == 'grid') {
      const spacing = 26.0;

      for (double x = spacing; x < size.width; x += spacing) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }

      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    } else if (texture == 'crosshatch') {
      const spacing = 22.0;

      for (double i = -size.height; i < size.width + size.height; i += spacing) {
        canvas.drawLine(
          Offset(i, 0),
          Offset(i + size.height, size.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundTexturePainter oldDelegate) {
    return oldDelegate.texture != texture ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.patternColor != patternColor;
  }
}
