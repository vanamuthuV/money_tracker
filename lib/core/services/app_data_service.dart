import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../storage/storage.dart';
import 'currency_service.dart';
import 'category_service.dart';
import 'expense_service.dart';

class AppDataService {
  static final AppDataService instance = AppDataService._internal();
  AppDataService._internal();

  static const _kKey = 'app_data_v1';

  Future<void> init() async {
    // Listen to changes and persist combined JSON immediately
    CurrencyService.instance.code.addListener(_saveCombined);
    CategoryService.instance.categories.addListener(_saveCombined);
    ExpenseService.instance.expenses.addListener(_saveCombined);
    await load();
  }

  Future<void> _saveCombined() async {
    final payload = _buildPayload();
    await Storage.instance.setString(_kKey, jsonEncode(payload));
  }

  Map<String, dynamic> _buildPayload() {
    final currency = CurrencyService.instance.code.value;
    final categories = CategoryService.instance.categories.value
        .map((c) => c.name)
        .toList();
    final expenses = ExpenseService.instance.expenses.value.map((e) {
      // Persist explicit type (normalize to lowercase) instead of deriving from amount sign
      final type = (e.type.toLowerCase() == 'credit') ? 'credit' : 'debit';
      return {
        'id': e.id,
        'amount': e.amount,
        'category': e.category,
        'note': e.note,
        'type': type,
        'date': e.date.toIso8601String(),
      };
    }).toList();

    return {
      'currency': currency,
      'categories': categories,
      'expenses': expenses,
    };
  }

  Future<void> load() async {
    try {
      final raw = await Storage.instance.getString(_kKey);
      if (raw == null) return;
      final obj = jsonDecode(raw) as Map<String, dynamic>;
      final currency = obj['currency'] as String?;
      final cats = (obj['categories'] as List?)?.cast<String?>();
      final exps = (obj['expenses'] as List?)?.cast<Map<String, dynamic>?>();

      if (currency != null) await CurrencyService.instance.set(currency);
      if (cats != null) {
        // Replace categories fully (keeps color defaults if missing)
        final catObjs = cats
            .map((n) => CategoryService.makeCategoryFromName(n ?? 'Other'))
            .toList();
        CategoryService.instance.categories.value = catObjs;
      }
      if (exps != null) {
        final list = exps.map((m) {
          final map = Map<String, dynamic>.from(m ?? {});
          return ExpenseService.fromMap(map);
        }).toList();
        ExpenseService.instance.setAll(list);
      }
    } catch (_) {}
  }

  // Export combined JSON to a user-accessible location (Downloads if available).
  Future<String> exportToDownloads() async {
    await _saveCombined();
    final raw = await Storage.instance.getString(_kKey);
    if (raw == null) throw Exception('No data to export');

    // Desired filename format: money_tracker_backup_YYYY_MM_DD_HH_mm.json
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final fileName =
        'money_tracker_backup_${now.year}_${two(now.month)}_${two(now.day)}_${two(now.hour)}_${two(now.minute)}.json';

    // On Android, use platform MediaStore to save into Downloads/Money Tracker
    if (Platform.isAndroid) {
      try {
        const channel = MethodChannel('com.example.money_tracker/export');
        final res = await channel.invokeMethod<String>('exportToDownloads', {
          'filename': fileName,
          'payload': raw,
        });
        if (res == null) throw Exception('Platform export failed');
        return res; // filename
      } on MissingPluginException {
        // Native platform code not available (likely hot-reload or not built)
        throw Exception(
          'Export not available: native implementation missing. Please fully stop the app and rebuild (flutter run).',
        );
      } catch (e) {
        throw Exception('Export failed: ${e.toString()}');
      }
    }

    // Fallback for other platforms: write to a best-effort folder
    final dir = _getExportFolder();
    try {
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(raw);
      final summary = _buildHumanReadableSummary();
      final sumFile = File(
        '${dir.path}/money_tracker_export_summary_${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      await sumFile.writeAsString(summary);
      return file.path;
    } catch (e) {
      throw Exception('Failed to export data to ${dir.path}: $e');
    }
  }

  // List available JSON files in the official import/export folder (Downloads/MoneyTracker or fallback)
  List<File> listImportFiles() {
    try {
      final dir = _getExportFolder();
      if (!dir.existsSync()) return [];
      return dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.json'))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Restrict import to files only inside export folder
  String _buildHumanReadableSummary() {
    final exps = ExpenseService.instance.expenses.value;
    final now = DateTime.now();
    final currentMonth = exps
        .where(
          (e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.type == 'debit',
        )
        .toList();
    final total = currentMonth.fold<double>(0, (s, e) => s + e.amount);
    final Map<String, double> byCat = {};
    for (var e in currentMonth)
      byCat[e.category] = (byCat[e.category] ?? 0) + e.amount;
    final buffer = StringBuffer();
    buffer.writeln(
      'Total This Month Spending: ${CurrencyService.instance.symbol}${total.toStringAsFixed(2)}',
    );
    buffer.writeln('');
    buffer.writeln('Breakdown by category:');
    for (var entry in byCat.entries) {
      buffer.writeln(
        '${entry.key}: ${CurrencyService.instance.symbol}${entry.value.toStringAsFixed(2)}',
      );
    }
    buffer.writeln('');
    buffer.writeln('Export generated at ${DateTime.now().toIso8601String()}');
    return buffer.toString();
  }

  // Return the official export/import folder (for UI checks)
  Directory getExportFolder() => _getExportFolder();

  // Import a JSON file from system path and merge/replace app state
  // // If [allowOutside] is true, imports are allowed from arbitrary locations
  // Future<void> importFromPath(String path, {bool allowOutside = false}) async {
  //   final f = File(path);
  //   if (!await f.exists()) throw Exception('File not found');
  //   final folder = _getExportFolder();
  //   // only allow imports from the designated folder unless explicitly allowed
  //   if (!allowOutside && !f.parent.path.startsWith(folder.path)) {
  //     throw Exception(
  //       'Import not allowed from this location. Use the app export folder: ${folder.path}',
  //     );
  //   }
  //   final raw = await f.readAsString();
  //   late final Map<String, dynamic> obj;
  //   try {
  //     obj = jsonDecode(raw) as Map<String, dynamic>;
  //   } catch (e) {
  //     throw Exception('Invalid JSON file');
  //   }

  //   // If the file wraps the payload (e.g. has the storage key), unwrap it
  //   if (obj.containsKey(_kKey) && obj[_kKey] is Map) {
  //     obj = Map<String, dynamic>.from(obj[_kKey] as Map);
  //   }

  //   // Basic validation: ensure we have an 'expenses' list (try to find one if nested)
  //   if (!(obj.containsKey('expenses') && obj['expenses'] is List)) {
  //     // attempt to find nested map that contains expenses
  //     bool found = false;
  //     obj.forEach((k, v) {
  //       if (!found && v is Map && v.containsKey('expenses')) {
  //         obj = Map<String, dynamic>.from(v as Map);
  //         found = true;
  //       }
  //     });
  //     if (!found) throw Exception('Invalid import file: missing required "expenses" array');
  //   }

  //   // Normalize expenses: ensure numeric amounts, proper type and ISO dates
  //   final rawExps = (obj['expenses'] as List).cast<dynamic>();
  //   final normalized = rawExps.map((e) {
  //     final Map<String, dynamic> m = Map<String, dynamic>.from(e as Map);
  //     // normalize amount
  //     final amountRaw = m['amount'];
  //     double amount;
  //     if (amountRaw is num) {
  //       amount = amountRaw.toDouble().abs();
  //     } else if (amountRaw is String) {
  //       amount = double.tryParse(amountRaw.replaceAll(',', '')) ?? 0.0;
  //     } else {
  //       amount = 0.0;
  //     }
  //     m['amount'] = amount;

  //     // normalize type
  //     final typeRaw = (m['type'] as String?)?.toLowerCase();
  //     m['type'] = (typeRaw == 'credit') ? 'credit' : 'debit';

  //     // normalize date to ISO8601
  //     final dateRaw = m['date'];
  //     if (dateRaw is int) {
  //       m['date'] = DateTime.fromMillisecondsSinceEpoch(dateRaw).toIso8601String();
  //     } else if (dateRaw is String) {
  //       if (DateTime.tryParse(dateRaw) == null) {
  //         final asInt = int.tryParse(dateRaw);
  //         if (asInt != null) m['date'] = DateTime.fromMillisecondsSinceEpoch(asInt).toIso8601String();
  //       }
  //     } else {
  //       m['date'] = DateTime.now().toIso8601String();
  //     }

  //     return m;
  //   }).toList();

  //   obj['expenses'] = normalized;

  //   // Overwrite internal "app_data" key and reload
  //   await Storage.instance.setString(_kKey, jsonEncode(obj));
  //   await load();
  // }

  Future<void> importFromPath(String path, {bool allowOutside = false}) async {
    final f = File(path);
    if (!await f.exists()) {
      throw Exception('File not found');
    }

    final folder = _getExportFolder();

    // Restrict imports to export folder unless explicitly allowed
    if (!allowOutside && !f.parent.path.startsWith(folder.path)) {
      throw Exception(
        'Import not allowed from this location. Use the app export folder: ${folder.path}',
      );
    }

    final raw = await f.readAsString();

    // Decode root JSON (IMMUTABLE)
    final Map<String, dynamic> root;
    try {
      root = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Invalid JSON file');
    }

    // WORKING mutable object
    Map<String, dynamic> obj = root;

    // Unwrap if wrapped under storage key
    if (obj.containsKey(_kKey) && obj[_kKey] is Map) {
      obj = Map<String, dynamic>.from(obj[_kKey] as Map);
    }

    // Ensure we have expenses (handle nested exports)
    if (!(obj.containsKey('expenses') && obj['expenses'] is List)) {
      bool found = false;

      for (final entry in obj.entries) {
        final v = entry.value;
        if (!found && v is Map && v.containsKey('expenses')) {
          obj = Map<String, dynamic>.from(v);
          found = true;
        }
      }

      if (!found) {
        throw Exception(
          'Invalid import file: missing required "expenses" array',
        );
      }
    }

    // Normalize expenses
    final rawExps = (obj['expenses'] as List).cast<dynamic>();

    final normalized = rawExps.map((e) {
      final Map<String, dynamic> m = Map<String, dynamic>.from(e as Map);

      // Amount
      final amountRaw = m['amount'];
      double amount;
      if (amountRaw is num) {
        amount = amountRaw.toDouble().abs();
      } else if (amountRaw is String) {
        amount = double.tryParse(amountRaw.replaceAll(',', '')) ?? 0.0;
      } else {
        amount = 0.0;
      }
      m['amount'] = amount;

      // Type
      final typeRaw = (m['type'] as String?)?.toLowerCase();
      m['type'] = (typeRaw == 'credit') ? 'credit' : 'debit';

      // Date
      final dateRaw = m['date'];
      if (dateRaw is int) {
        m['date'] = DateTime.fromMillisecondsSinceEpoch(
          dateRaw,
        ).toIso8601String();
      } else if (dateRaw is String) {
        if (DateTime.tryParse(dateRaw) == null) {
          final asInt = int.tryParse(dateRaw);
          m['date'] = (asInt != null)
              ? DateTime.fromMillisecondsSinceEpoch(asInt).toIso8601String()
              : DateTime.now().toIso8601String();
        }
      } else {
        m['date'] = DateTime.now().toIso8601String();
      }

      return m;
    }).toList();

    obj['expenses'] = normalized;

    // Persist and reload
    await Storage.instance.setString(_kKey, jsonEncode(obj));
    await load();
  }

  // Best-effort downloads location for Android; fallback to system temp
  Directory _getExportFolder() {
    final androidDownload = Directory(
      '/storage/emulated/0/Download/Money Tracker',
    );
    if (androidDownload.existsSync() ||
        Directory('/storage/emulated/0/Download').existsSync()) {
      return androidDownload;
    }
    final fallback = Directory('${Directory.systemTemp.path}/MoneyTracker');
    return fallback;
  }
}
