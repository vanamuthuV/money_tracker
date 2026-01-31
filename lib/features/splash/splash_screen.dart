import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import 'splash_controller.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String route = '/';
  const SplashScreen({Key? key}) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: SplashController.animationDuration,
    );
    final curve = CurvedAnimation(parent: _ctl, curve: Curves.easeInOut);
    _scale = Tween(begin: 0.85, end: 1.0).animate(curve);
    _opacity = Tween(begin: 0.0, end: 1.0).animate(curve);
    _ctl.forward();
    Timer(SplashController.animationDuration, () {
      Navigator.of(context).pushReplacementNamed(HomeScreen.route);
    });
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _ctl,
            builder: (_, __) => Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: AnimatedScale(
                    scale: 1,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 120,
                      height: 120,
                    ),
                  ),

                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
