import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/spacing.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: Spacing.cardRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.65),
            borderRadius: Spacing.cardRadius,
            border: Border.all(color: Colors.white.withOpacity(0.03)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
