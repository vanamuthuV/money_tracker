import 'package:flutter/material.dart';
import '../../../core/constants/spacing.dart';

class InsightChip extends StatelessWidget {
  final String text;
  final Color? color;
  const InsightChip({required this.text, this.color, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 420),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: EdgeInsets.only(right: Spacing.sm),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).colorScheme.secondary).withOpacity(
          0.12,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
