import 'package:flutter/material.dart';
import '../../../models/expense_model.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/colors.dart';
import '../../home/widgets/glass_card.dart';
import '../../../core/animations/micro_interactions.dart';
import '../../../core/services/currency_service.dart';

class TransactionCard extends StatelessWidget {
  final ExpenseModel tx;
  final int index;
  const TransactionCard({required this.tx, required this.index, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDebit = tx.type == 'debit';
    final color = isDebit ? AppColors.debit : AppColors.credit;
    final icon = isDebit ? Icons.remove : Icons.add;
    final iconSemantic = isDebit ? 'Debit' : 'Credit';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 12.0, end: 0.0),
      duration: Duration(milliseconds: 380 + index * 30),
      builder: (ctx, value, child) => Opacity(
        opacity: (1 - (value / 12)).clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, value), child: child),
      ),
      child: ScaleOnTap(
        child: GlassCard(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              // flat icon, no background circle
              SizedBox(
                width: 28,
                child: Icon(
                  icon,
                  color: color,
                  semanticLabel: iconSemantic,
                  size: 20,
                ),
              ),
              SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tx.category,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '${CurrencyService.instance.symbol}${tx.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    if (tx.note != null && tx.note!.isNotEmpty)
                      Text(
                        tx.note!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    SizedBox(height: 8),
                    Text(
                      _formatDate(tx.date),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () {},
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day)
      return 'Today • ${_formatTime(d)}';
    if (d.year == now.year && d.month == now.month && d.day == now.day - 1)
      return 'Yesterday • ${_formatTime(d)}';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year} • ${_formatTime(d)}';
  }

  String _formatTime(DateTime d) {
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }
}
