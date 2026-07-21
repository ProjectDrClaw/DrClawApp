import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 工作台视觉 token（对齐旧库 DrClawApp `constants/theme.ts`）
class WbTheme {
  WbTheme._();

  // —— 品牌 ——
  static const primary = Color(0xFF4A7DD9);
  static const primaryDark = Color(0xFF2657C9);
  static Color primaryAlpha8 = const Color(0xFF4A7DD9).withOpacity(0.08);
  static Color primaryAlpha20 = const Color(0xFF4A7DD9).withOpacity(0.2);

  // —— 文本 ——
  static const textPrimary = Color(0xFF303133);
  static const textRegular = Color(0xFF606266);
  static const textSecondary = Color(0xFF909399);
  static const textHint = Color(0xFFC0C4CC);

  // —— 背景 ——
  static const background = Color(0xFFF2F3F5);
  static const backgroundLight = Color(0xFFFFFFFF);
  static const inputBackground = Color(0xFFF7F8FA);
  static const border = Color(0xFFEBEEF5);
  static const danger = Color(0xFFF56C6C);

  static TextStyle get title16 => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        height: 1.25,
      );

  static TextStyle get title16Bold => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.25,
      );

  static TextStyle get body15 => TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get meta13 => TextStyle(
        fontSize: 13.sp,
        color: textHint,
        height: 1.3,
      );

  static TextStyle get caption10 => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      );

  static TextStyle get body14Hint => TextStyle(
        fontSize: 14.sp,
        color: textHint,
      );

  static TextStyle get label12 => TextStyle(
        fontSize: 12.sp,
        color: textSecondary,
      );

  static BorderRadius get radiusSm => BorderRadius.circular(4.r);
  static BorderRadius get radiusMd => BorderRadius.circular(8.r);
  static BorderRadius get radiusLg => BorderRadius.circular(12.r);
}
