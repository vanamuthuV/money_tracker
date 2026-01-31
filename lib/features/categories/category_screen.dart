import 'package:flutter/material.dart';
import '../../core/services/category_service.dart';
import '../../models/category_model.dart' as cat_model;
import '../../core/constants/spacing.dart';
import '../../core/constants/colors.dart';
import '../../core/animations/micro_interactions.dart';

class CategoryScreen extends StatefulWidget {
  static const route = '/categories';
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryService _svc = CategoryService.instance;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categories')),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: ValueListenableBuilder<List<cat_model.Category>>(
          valueListenable: _svc.categories,
          builder: (ctx, List<cat_model.Category> cats, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Horizontal chips removed per UX request
                SizedBox.shrink(),
                SizedBox(height: Spacing.md),
                Expanded(
                  child: ListView.builder(
                    itemCount: cats.length,
                    itemBuilder: (ctx, idx) {
                      final c = cats[idx];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: c.color,
                          child: Icon(c.icon, color: Colors.white),
                        ),
                        title: Text(c.name),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _confirmDelete(c),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: Spacing.md),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                    textStyle: TextStyle(fontWeight: FontWeight.w700),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _showAdd,
                  icon: Icon(Icons.add),
                  label: Text('Add category'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAdd() {
    _showEditor();
  }

  void _showEditor({cat_model.Category? c}) {
    final nameCtrl = TextEditingController(text: c?.name ?? '');
    final hexCtrl = TextEditingController(
      text: c != null
          ? '#${c.color.value.toRadixString(16).substring(2).toUpperCase()}'
          : '#90A4AE',
    );
    Color picked = c != null ? c.color : Colors.blueGrey;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setD) {
          return AlertDialog(
            title: Text(c == null ? 'Add category' : 'Edit category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                SizedBox(height: 8),
                // Hex input + quick-random dice generator
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: hexCtrl,
                        decoration: InputDecoration(
                          labelText: 'Hex color (e.g. #FF5733)',
                        ),
                        onChanged: (v) {
                          final valid = _parseHexColor(v) != null;
                          if (valid) setD(() => picked = _parseHexColor(v)!);
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Generate random color',
                      onPressed: () {
                        final cNew = _generateReadableRandomColor();
                        setD(() {
                          picked = cNew;
                          hexCtrl.text =
                              '#${cNew.value.toRadixString(16).substring(2).toUpperCase()}';
                        });
                      },
                      icon: Icon(Icons.casino),
                      color: AppColors.accent,
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text('Preview:'),
                    SizedBox(width: 12),
                    CircleAvatar(backgroundColor: picked),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel', style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  textStyle: TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) return;
                  final color = _parseHexColor(hexCtrl.text) ?? picked;
                  if (c == null) {
                    CategoryService.instance.add(
                      cat_model.Category.create(
                        name: name,
                        colorValue: color.value,
                        iconCodePoint: Icons.category.codePoint,
                      ),
                    );
                  } else {
                    CategoryService.instance.update(
                      cat_model.Category(
                        id: c.id,
                        name: name,
                        colorValue: color.value,
                        iconCodePoint: c.icon.codePoint,
                      ),
                    );
                  }
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Category saved')));
                },
                child: Text('Save Category'),
              ),
            ],
          );
        },
      ),
    );
  }

  Color? _parseHexColor(String input) {
    try {
      final s = input.replaceAll('#', '').trim();
      if (s.length != 6) return null;
      final v = int.parse(s, radix: 16);
      return Color(0xFF000000 | v);
    } catch (_) {
      return null;
    }
  }

  // Generate a random color that is readable over the charcoal background
  Color _generateReadableRandomColor() {
    // Use HSV with constrained saturation and value to avoid too light/dark
    final rnd = DateTime.now().microsecondsSinceEpoch;
    // pseudo-random but deterministic-ish per tap
    final h = (rnd % 360).toDouble();
    final s = 0.5 + ((rnd ~/ 360) % 40) / 100; // 0.50 - 0.90
    final v = 0.48 + ((rnd ~/ 14400) % 37) / 100; // 0.48 - 0.85
    final col = HSVColor.fromAHSV(
      1.0,
      h,
      s.clamp(0.45, 0.9),
      v.clamp(0.45, 0.85),
    ).toColor();

    // Ensure enough contrast with background; if not, slightly lighten
    final bg = Color(0xFF21242A);
    final contrast = (col.computeLuminance() - bg.computeLuminance()).abs();
    if (contrast < 0.2) {
      return HSVColor.fromColor(col)
          .withValue((HSVColor.fromColor(col).value + 0.25).clamp(0.45, 0.95))
          .toColor();
    }
    return col;
  }

  void _confirmDelete(cat_model.Category c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${c.name}?'),
        content: Text(
          'This will remove the category and any reference to it in the UI.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              CategoryService.instance.remove(c.id);
              Navigator.of(ctx).pop();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
