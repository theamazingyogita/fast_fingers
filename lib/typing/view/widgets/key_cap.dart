import 'package:flutter/material.dart';

class KeyCap extends StatelessWidget {
  const KeyCap({
    super.key,
    required this.label,
    required this.width,
    required this.height,
    required this.isPressed,
    required this.isNext,
  });

  final String label;
  final double width;
  final double height;
  final bool isPressed;

  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    const duration = Duration(milliseconds: 120);

    return AnimatedScale(
      scale: isPressed ? 0.88 : 1,
      duration: duration,
      child: AnimatedContainer(
        duration: duration,
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPressed ? colors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isNext ? colors.primary : colors.outlineVariant,
            width: isNext ? 2 : 1,
          ),
          boxShadow: [
            if (!isPressed)
              BoxShadow(color: colors.shadow, offset: const Offset(0, 3)),
          ],
        ),
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isPressed ? colors.onPrimary : colors.onSurface,
          ),
        ),
      ),
    );
  }
}
