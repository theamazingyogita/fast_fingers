import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app_colors.dart';

class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, this.pieces = 70});

  final int pieces;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..forward();

  late final List<_Piece> _pieces = () {
    final random = Random();
    return List.generate(widget.pieces, (_) => _Piece.random(random));
  }();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return CustomPaint(
      painter: _ConfettiPainter(
        progress: _controller,
        pieces: _pieces,
        palette: [
          AppColors.of(context).success,
          scheme.primary,
          scheme.secondary,
          scheme.tertiary,
          scheme.error,
        ],
      ),
    );
  }
}

class _Piece {
  _Piece.random(Random random)
    : angle = -pi / 2 + (random.nextDouble() - 0.5) * pi * 1.4,
      speed = 250 + random.nextDouble() * 350,
      spin = (random.nextDouble() - 0.5) * 12,
      size = 6 + random.nextDouble() * 6,
      colorIndex = random.nextInt(1 << 16);

  final double angle;
  final double speed;
  final double spin;
  final double size;
  final int colorIndex;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.progress,
    required this.pieces,
    required this.palette,
  }) : super(repaint: progress);

  static const _gravity = 700.0;

  final Animation<double> progress;
  final List<_Piece> pieces;
  final List<Color> palette;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t == 0 || t == 1) return;

    final origin = Offset(size.width / 2, size.height * 0.2);
    final opacity = (1 - t) * (1 - t);
    final seconds = t * 2.4;

    for (final piece in pieces) {
      final position =
          origin +
          Offset(
            cos(piece.angle) * piece.speed * seconds,
            sin(piece.angle) * piece.speed * seconds +
                _gravity * seconds * seconds / 2,
          );
      final color = palette[piece.colorIndex % palette.length];

      canvas
        ..save()
        ..translate(position.dx, position.dy)
        ..rotate(piece.spin * seconds)
        ..drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: piece.size * 0.5,
          ),
          Paint()..color = color.withValues(alpha: opacity),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.palette != palette;
}
