import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({required this.success, required this.onSuccess});

  final Color success;
  final Color onSuccess;

  static const dark = AppColors(
    success: Color(0xFF4ADE80),
    onSuccess: Color(0xFF052E16),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? dark;

  @override
  AppColors copyWith({Color? success, Color? onSuccess}) => AppColors(
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
    );
  }
}
