import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../storage/storage.dart';
import '../../models/category_model.dart' as cat_model;

class CategoryService {
  static final CategoryService instance = CategoryService._internal();
  CategoryService._internal() {
    _load();
  }
  // Create/find a category by name (used by import)
  static cat_model.Category makeCategoryFromName(String name) {
    final existing = instance.categories.value.firstWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
      orElse: () => cat_model.Category.create(name: name),
    );
    return existing;
  }

  static const _kKey = 'categories_v1';
  final ValueNotifier<List<cat_model.Category>> categories =
      ValueNotifier<List<cat_model.Category>>([]);

  Future<void> add(cat_model.Category c) async {
    final list = [...categories.value, c];
    categories.value = list;
    await _save();
  }

  Future<void> update(cat_model.Category c) async {
    final list = categories.value.map((e) => e.id == c.id ? c : e).toList();
    categories.value = list;
    await _save();
  }

  Future<void> remove(String id) async {
    final list = categories.value.where((e) => e.id != id).toList();
    categories.value = list;
    await _save();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = [...categories.value];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    categories.value = list;
    await _save();
  }

  Future<void> _save() async {
    final encoded = jsonEncode(categories.value.map((e) => e.toMap()).toList());
    await Storage.instance.setString(_kKey, encoded);
  }

  Future<void> _load() async {
    final raw = await Storage.instance.getString(_kKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        categories.value = decoded
            .map(
              (e) => cat_model.Category.fromMap(Map<String, dynamic>.from(e)),
            )
            .toList();
      } catch (_) {}
    } else {
      // defaults
      categories.value = [
        cat_model.Category(
          id: 'c_food',
          name: 'Food',
          colorValue: 0xFFFFA726,
          iconCodePoint: 0xe328,
        ),
        cat_model.Category(
          id: 'c_trans',
          name: 'Transport',
          colorValue: 0xFF29B6F6,
          iconCodePoint: 0xe3d2,
        ),
        cat_model.Category(
          id: 'c_sho',
          name: 'Shopping',
          colorValue: 0xFFAB47BC,
          iconCodePoint: 0xe59a,
        ),
        cat_model.Category(
          id: 'c_bills',
          name: 'Bills',
          colorValue: 0xFFEF5350,
          iconCodePoint: 0xe53b,
        ),
        cat_model.Category(
          id: 'c_other',
          name: 'Other',
          colorValue: 0xFF90A4AE,
          iconCodePoint: 0xe3ef,
        ),
      ];
      await _save();
    }
  }
}
