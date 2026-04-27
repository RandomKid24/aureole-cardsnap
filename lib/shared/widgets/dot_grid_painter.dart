import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.dotGrid
      ..style = PaintingStyle.fill;
    
    const spacing = 28.0;
    const radius = 1.5;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class DotGridBackground extends StatelessWidget {
  final Widget child;
  const DotGridBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: DotGridPainter()),
        ),
        child,
      ],
    );
  }
}
