import 'package:flutter/material.dart';

import '../../../app_colors.dart';

class PassageView extends StatelessWidget {
  const PassageView({super.key, required this.passage, required this.typed});

  final String passage;
  final String typed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final success = AppColors.of(context).success;
    final base = Theme.of(
      context,
    ).textTheme.headlineSmall?.copyWith(height: 1.6, letterSpacing: 1);

    return RichText(
      text: TextSpan(
        style: base,
        children: [
          for (var i = 0; i < passage.length; i++)
            TextSpan(text: passage[i], style: _styleFor(i, colors, success)),
        ],
      ),
    );
  }

  TextStyle _styleFor(int index, ColorScheme colors, Color success) {
    if (index < typed.length) {
      if (typed[index] == passage[index]) {
        return TextStyle(color: success);
      }
      return TextStyle(
        color: colors.onError,
        backgroundColor: colors.error.withValues(alpha: 0.8),
      );
    }
    final pending = TextStyle(color: colors.onSurfaceVariant);
    if (index == typed.length) {
      return pending.copyWith(
        color: colors.onSurface,
        decoration: TextDecoration.underline,
        decorationColor: colors.primary,
        decorationThickness: 3,
      );
    }
    return pending;
  }
}
