part of '../login_page.dart';

class _TopographicLinesPainter extends CustomPainter {
  const _TopographicLinesPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final lineColor = (isDark ? Colors.white : const Color(0xffb8bec6))
        .withValues(alpha: isDark ? 0.085 : 0.24);
    final lowerLeftColor = (isDark ? Colors.white : const Color(0xffc8cdd3))
        .withValues(alpha: isDark ? 0.055 : 0.16);

    _paintCluster(
      canvas: canvas,
      origin: Offset(size.width * 0.54, size.height * 0.63),
      width: size.width * 0.58,
      height: size.height * 0.32,
      color: lineColor,
      count: 13,
      spacing: 12,
      amplitude: 26,
    );

    _paintCluster(
      canvas: canvas,
      origin: Offset(size.width * 0.76, size.height * 0.35),
      width: size.width * 0.34,
      height: size.height * 0.42,
      color: lineColor.withValues(alpha: lineColor.a * 0.7),
      count: 10,
      spacing: 10,
      amplitude: 22,
    );

    _paintCluster(
      canvas: canvas,
      origin: Offset(size.width * -0.08, size.height * 0.78),
      width: size.width * 0.42,
      height: size.height * 0.22,
      color: lowerLeftColor,
      count: 8,
      spacing: 10,
      amplitude: 18,
    );
  }

  void _paintCluster({
    required Canvas canvas,
    required Offset origin,
    required double width,
    required double height,
    required Color color,
    required int count,
    required double spacing,
    required double amplitude,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    for (var i = 0; i < count; i++) {
      final y = origin.dy + i * spacing;
      final path = Path()..moveTo(origin.dx, y);

      path.cubicTo(
        origin.dx + width * 0.18,
        y - amplitude,
        origin.dx + width * 0.32,
        y + amplitude,
        origin.dx + width * 0.48,
        y,
      );
      path.cubicTo(
        origin.dx + width * 0.66,
        y - amplitude * 0.9,
        origin.dx + width * 0.84,
        y + amplitude * 0.8,
        origin.dx + width,
        y - height * 0.08,
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TopographicLinesPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
