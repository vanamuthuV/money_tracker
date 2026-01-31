import 'package:flutter/material.dart';

class ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double endScale;
  final Duration duration;
  const ScaleOnTap({
    required this.child,
    this.onTap,
    this.endScale = 0.96,
    this.duration = const Duration(milliseconds: 120),
    Key? key,
  }) : super(key: key);

  @override
  _ScaleOnTapState createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<ScaleOnTap>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  void _down() => setState(() => _scale = widget.endScale);
  void _up() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => _down(),
      onTapUp: (_) {
        _up();
        widget.onTap?.call();
      },
      onTapCancel: _up,
      child: AnimatedScale(
        scale: _scale,
        duration: widget.duration,
        child: widget.child,
      ),
    );
  }
}
