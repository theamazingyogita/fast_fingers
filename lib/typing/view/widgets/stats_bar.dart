import 'package:flutter/material.dart';

class StatsBar extends StatelessWidget {
  const StatsBar({
    super.key,
    required this.remainingSeconds,
    required this.wordsPerMinute,
    required this.wordsTyped,
    required this.accuracy,
  });

  final int remainingSeconds;
  final int wordsPerMinute;
  final int wordsTyped;
  final int accuracy;

  @override
  Widget build(BuildContext context) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        _StatTile(label: 'TIME', value: '$minutes:$seconds'),
        _StatTile(label: 'WPM', value: '$wordsPerMinute'),
        _StatTile(label: 'WORDS', value: '$wordsTyped'),
        _StatTile(label: 'ACCURACY', value: '$accuracy%'),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        spacing: 4,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              value,
              key: ValueKey(value),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}
