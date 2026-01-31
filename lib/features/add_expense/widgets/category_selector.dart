import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class CategorySelector extends StatefulWidget {
  final ValueChanged<String> onSelected;
  const CategorySelector({required this.onSelected});

  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final List<String> _categories = [
    'Food',
    'Transport',
    'Coffee',
    'Groceries',
    'Bills',
  ];
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _categories.map((c) {
        final selected = c == _selected;
        return GestureDetector(
          onTap: () {
            setState(() => _selected = c);
            widget.onSelected(c);
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 220),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.accent : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              c,
              style: TextStyle(color: selected ? Colors.black : Colors.white),
            ),
          ),
        );
      }).toList(),
    );
  }
}
