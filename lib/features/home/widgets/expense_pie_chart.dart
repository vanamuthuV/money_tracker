import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/services/currency_service.dart';

class ExpensePieChart extends StatefulWidget {
  final Map<String, double> data;
  const ExpensePieChart({required this.data, Key? key}) : super(key: key);

  @override
  _ExpensePieChartState createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctl;
  late Animation<double> _anim;

  final List<Color> _palette = [
    AppColors.accent.withOpacity(0.95),
    Color(0xFF6EA8FF), // muted lighter blue
    Color(0xFF7B6DFF).withOpacity(0.9), // muted purple
    Color(0xFF2DD4BF).withOpacity(0.9), // muted teal
    Color(0xFF8EA6C4), // muted cool gray
  ];

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _anim = CurvedAnimation(parent: _ctl, curve: Curves.easeOutCubic);
    _ctl.forward();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.data.entries.toList();
    final total = widget.data.values.fold<double>(0, (s, v) => s + v);
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: AnimatedBuilder(
            animation: _anim,
            builder: (ctx, child) => CustomPaint(
              painter: _PiePainter(entries, total, _anim.value, _palette),
              child: Container(),
            ),
          ),
        ),
        SizedBox(height: Spacing.sm),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: entries.asMap().entries.map((e) {
            final amount = e.value.value;
            final label =
                '${e.value.key} — ${formatCurrency(amount, CurrencyService.instance.symbol)}';
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  color: _palette[e.key % _palette.length],
                ),
                SizedBox(width: 6),
                Text(label, style: Theme.of(context).textTheme.bodyLarge),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final double total;
  final double t;
  final List<Color> palette;
  _PiePainter(this.entries, this.total, this.t, this.palette);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide / 2) - 6;
    final paint = Paint()..style = PaintingStyle.fill;
    double start = -pi / 2;
    for (var i = 0; i < entries.length; i++) {
      final sweep = (entries[i].value / (total == 0 ? 1 : total)) * 2 * pi * t;
      paint.color = palette[i % palette.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        paint,
      );
      start += sweep;
    }
    // Center circle
    final holePaint = Paint()..color = AppColors.card;
    canvas.drawCircle(center, radius * 0.55, holePaint);
  }

  @override
  bool shouldRepaint(covariant _PiePainter old) =>
      old.t != t || old.entries != entries;
}
