import 'package:flutter/material.dart';

// Slide + Fade
class SlideFadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  SlideFadePageRoute({required this.page})
    : super(
        pageBuilder: (ctx, a1, a2) => page,
        transitionDuration: Duration(milliseconds: 450),
        reverseTransitionDuration: Duration(milliseconds: 350),
        transitionsBuilder: (ctx, a1, a2, child) {
          final offset = Tween<Offset>(
            begin: Offset(0, 0.08),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOut));
          final opacity = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: a1, curve: Curves.easeOut));
          return SlideTransition(
            position: a1.drive(offset),
            child: FadeTransition(opacity: opacity, child: child),
          );
        },
      );
}

// Scale + Fade (good for modals like AddExpense)
class ScaleFadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  ScaleFadePageRoute({required this.page})
    : super(
        opaque:
            false, // allow background to remain visible during transition (fixes black-screen)
        pageBuilder: (ctx, a1, a2) => page,
        transitionDuration: Duration(milliseconds: 380),
        reverseTransitionDuration: Duration(milliseconds: 280),
        transitionsBuilder: (ctx, a1, a2, child) {
          final scale = Tween<double>(
            begin: 0.95,
            end: 1.0,
          ).animate(CurvedAnimation(parent: a1, curve: Curves.easeOutBack));
          final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(a1);
          return FadeTransition(
            opacity: opacity,
            child: ScaleTransition(scale: scale, child: child),
          );
        },
      );
}

// Page Flip (subtle)
class FlipPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  FlipPageRoute({required this.page})
    : super(
        pageBuilder: (ctx, a1, a2) => page,
        transitionDuration: Duration(milliseconds: 520),
        reverseTransitionDuration: Duration(milliseconds: 420),
        transitionsBuilder: (ctx, a1, a2, child) {
          final rotation = Tween<double>(
            begin: 0.5,
            end: 0.0,
          ).chain(CurveTween(curve: Curves.easeOut));
          return AnimatedBuilder(
            animation: a1,
            builder: (context, _) {
              final value = rotation.evaluate(a1);
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(value),
                child: Opacity(opacity: a1.value.clamp(0.0, 1.0), child: child),
              );
            },
          );
        },
      );
}
