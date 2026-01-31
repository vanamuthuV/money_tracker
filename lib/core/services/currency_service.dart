import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../storage/storage.dart';

class CurrencyService {
  static final CurrencyService instance = CurrencyService._internal();
  CurrencyService._internal() {
    _load();
  }

  static const _kKey = 'currency_v1';
  final ValueNotifier<String> code = ValueNotifier<String>('INR');

  static const Map<String, String> symbolMap = {
    'INR': '₹',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'AED': 'د.إ',
    'SGD': 'S\$',
  };

  List<String> get supported => symbolMap.keys.toList();

  String get symbol => symbolMap[code.value] ?? code.value;

  Future<void> set(String c) async {
    code.value = c;
    await Storage.instance.setString(_kKey, jsonEncode({'code': c}));
  }

  Future<void> _load() async {
    final raw = await Storage.instance.getString(_kKey);
    if (raw != null) {
      try {
        final obj = jsonDecode(raw);
        final c = obj['code'] as String?;
        if (c != null && symbolMap.containsKey(c)) code.value = c;
      } catch (_) {}
    }
  }
}
