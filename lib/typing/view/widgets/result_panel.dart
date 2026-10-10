import 'package:flutter/material.dart';

import 'confetti_burst.dart';
import 'success_badge.dart';

class ResultPanel extends StatelessWidget {
  const ResultPanel({
    super.key,
    required this.wordsPerMinute,
    required this.accuracy,
    required this.mistakes,
    required this.isPerfect,
    required this.onRestart,
  });

  final int wordsPerMinute;
  final int accuracy;
  final int mistakes;
  final bool isPerfect;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onContainer = theme.colorScheme.onPrimaryContainer;

    final panel = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        spacing: 16,
        children: [
          if (isPerfect) ...[
            const SuccessBadge(),
            Text(
              'Perfect!',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: onContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          TweenAnimationBuilder(
            tween: IntTween(begin: 0, end: wordsPerMinute),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text(
              '$value WPM',
              style: theme.textTheme.displayMedium?.copyWith(
                color: onContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '$accuracy% accuracy, $mistakes '
            '${mistakes == 1 ? 'mistake' : 'mistakes'}',
            style: theme.textTheme.titleMedium?.copyWith(color: onContainer),
          ),
          FilledButton.icon(
            onPressed: onRestart,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    );

    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0, 1),
        child: Transform.scale(scale: 0.85 + 0.15 * value, child: child),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          panel,
          if (isPerfect)
            const Positioned.fill(child: IgnorePointer(child: ConfettiBurst())),
        ],
      ),
    );
  }
}
