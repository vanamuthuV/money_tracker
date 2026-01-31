import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

class Storage {
  Storage._internal();
  static final Storage instance = Storage._internal();

  final String _fileName = 'money_tracker_storage.json';
  Map<String, String> _cache = {};
  bool _loaded = false;

  Future<File> get _file async {
    final dir = Directory.systemTemp; // simple portable location
    return File(p.join(dir.path, _fileName));
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    try {
      final f = await _file;
      if (await f.exists()) {
        final raw = await f.readAsString();
        final Map<String, dynamic> obj = jsonDecode(raw);
        _cache = obj.map((k, v) => MapEntry(k, v.toString()));
      }
    } catch (_) {
      _cache = {};
    }
    _loaded = true;
  }

  Future<String?> getString(String key) async {
    await _ensureLoaded();
    return _cache[key];
  }

  Future<void> setString(String key, String value) async {
    await _ensureLoaded();
    _cache[key] = value;
    try {
      final f = await _file;
      await f.writeAsString(jsonEncode(_cache));
    } catch (_) {}
  }
}
