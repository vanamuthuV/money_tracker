import 'package:flutter/material.dart';

class AppColors {
  // Slightly darker charcoal background
  static const Color background = Color(0xFF1E2127);
  // Card slightly lighter than background
  static const Color card = Color(0xFF252A31);
  static const Color surface = Color(0xFF33373D);

  // Primary (soft purple for dark theme — modern and premium)
  // Chosen to contrast well with charcoal (#21242A) and work with white text
  static const Color accent = Color(0xFF7C6FF0); // soft/pastel purple
  static const Color accentDark = Color(0xFF5E4BEA);

  // Semantic colors
  static const Color debit = Color(0xFFEF4444); // red for outflow
  static const Color credit = Color(0xFF22C55E); // green for inflow

  static const Color muted = Color(0xFF9CA3AF); // secondary text
  static const Color shadow = Color.fromRGBO(0, 0, 0, 0.6);
}
