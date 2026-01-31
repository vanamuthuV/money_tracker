import 'package:flutter/material.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/services/currency_service.dart';

class MonthComparisonCard extends StatelessWidget {
  final double last;
  final double current;
  const MonthComparisonCard({
    required this.last,
    required this.current,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final diff = current - last;
    final increased = diff >= 0;
    final symbol = CurrencyService.instance.symbol;
    return Container(
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
                Text(
                  'Last month',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                AnimatedCount(value: last, symbol: symbol),
              ],
            ),
          ),
          VerticalDivider(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This month',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                AnimatedCount(value: current, symbol: symbol),
                SizedBox(height: 6),
                Text(
                  '${increased ? '+' : ''}$symbol${diff.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    color: increased ? Colors.redAccent : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedCount extends StatelessWidget {
  final double value;
  final String symbol;
  const AnimatedCount({required this.value, required this.symbol, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: value),
      duration: Duration(milliseconds: 900),
      curve: Curves.easeOut,
      builder: (ctx, v, child) => Text(
        '$symbol${v.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }
}
