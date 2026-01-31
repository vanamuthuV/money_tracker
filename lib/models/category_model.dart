import 'package:flutter/material.dart';
import 'dart:math';

class Category {
  final String id;
  final String name;
  final int colorValue;
  final int iconCodePoint;

  Category({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCodePoint,
  });

  factory Category.create({
    required String name,
    int? colorValue,
    int? iconCodePoint,
  }) {
    final rand = Random().nextInt(100000);
    return Category(
      id: 'cat_$rand',
      name: name,
      colorValue: colorValue ?? 0xFF90A4AE,
      iconCodePoint: iconCodePoint ?? Icons.category.codePoint,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'colorValue': colorValue,
    'iconCodePoint': iconCodePoint,
  };

  factory Category.fromMap(Map<String, dynamic> m) {
    return Category(
      id: m['id'] as String,
      name: m['name'] as String,
      colorValue: (m['colorValue'] as num).toInt(),
      iconCodePoint: (m['iconCodePoint'] as num).toInt(),
    );
  }

  Color get color => Color(colorValue);
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
}
