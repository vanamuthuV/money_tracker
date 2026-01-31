import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final Duration duration;
  final String prefix;
  const AnimatedCounter({
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 900),
    this.prefix = '',
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (ctx, v, child) =>
          Text('${prefix}${v.toStringAsFixed(2)}', style: style),
    );
  }
}
