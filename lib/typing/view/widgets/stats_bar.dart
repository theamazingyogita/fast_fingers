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
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        _StatTile(
          label: 'TIME',
          value: remainingSeconds,
          format: (s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}',
        ),
        _StatTile(label: 'WPM', value: wordsPerMinute, format: _plain),
        _StatTile(label: 'WORDS', value: wordsTyped, format: _plain),
        _StatTile(label: 'ACCURACY', value: accuracy, format: (a) => '$a%'),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.format,
  });

  final String label;
  final int value;
  final String Function(int) format;

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
          TweenAnimationBuilder(
            tween: IntTween(begin: value, end: value),
            duration: const Duration(milliseconds: 250),
            builder: (context, shown, _) => Text(
              format(shown),
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

String _plain(int value) => '$value';
