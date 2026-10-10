import 'package:flutter/material.dart';

import '../../../app_colors.dart';

class SuccessBadge extends StatefulWidget {
  const SuccessBadge({super.key, this.size = 96});

  final double size;

  @override
  State<SuccessBadge> createState() => _SuccessBadgeState();
}

class _SuccessBadgeState extends State<SuccessBadge>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..forward();

  late final _scale = _controller.drive(
    CurveTween(curve: const Interval(0, 0.6, curve: Curves.elasticOut)),
  );
  late final _check = _controller.drive(
    CurveTween(curve: const Interval(0.45, 1, curve: Curves.easeOut)),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: colors.success,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors.success.withValues(alpha: 0.5),
              blurRadius: 24,
            ),
          ],
        ),
        child: CustomPaint(
          painter: _CheckPainter(progress: _check, color: colors.onSuccess),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress, required this.color})
    : super(repaint: progress);

  final Animation<double> progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final check = Path()
      ..moveTo(size.width * 0.28, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.68)
      ..lineTo(size.width * 0.74, size.height * 0.36);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final metric in check.computeMetrics()) {
      canvas.drawPath(
        metric.extractPath(0, metric.length * progress.value),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) => oldDelegate.color != color;
}
