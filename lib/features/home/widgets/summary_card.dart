import 'package:flutter/material.dart';
import '../../../core/constants/spacing.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  const SummaryCard({
    required this.title,
    required this.subtitle,
    this.trailing,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 360),
      opacity: 1.0,
      child: Container(
        padding: EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: Spacing.cardRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
