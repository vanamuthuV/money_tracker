import 'package:flutter/material.dart';
import 'colors.dart';

class AppTypography {
  static TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    displayMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 11, color: AppColors.muted),
    bodyMedium: TextStyle(fontSize: 10, color: Colors.white),
    titleLarge: TextStyle(fontSize: 13, color: AppColors.muted),
  );
}

// Add legacy compatibility getters so code using headlineX/subtitleX/bodyTextX keeps working.
extension LegacyTextTheme on TextTheme {
  TextStyle? get headline1 => displayLarge;
  TextStyle? get headline2 => displayMedium;
  TextStyle? get headline3 => displaySmall;
  TextStyle? get headline4 => headlineLarge;
  TextStyle? get headline5 => headlineMedium;
  TextStyle? get headline6 => headlineSmall;
  TextStyle? get subtitle1 => titleLarge;
  TextStyle? get subtitle2 => titleMedium;
  TextStyle? get bodyText1 => bodyLarge;
  TextStyle? get bodyText2 => bodyMedium;
  TextStyle? get caption => bodyMedium;
  TextStyle? get button => labelLarge;
  TextStyle? get overline => labelSmall;
}
