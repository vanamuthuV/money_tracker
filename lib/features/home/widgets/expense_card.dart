import 'package:flutter/material.dart';
import '../../../models/expense_model.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/services/currency_service.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final int index;
  const ExpenseCard({required this.expense, required this.index});

  @override
  Widget build(BuildContext context) {
    // Staggered entrance via TweenAnimationBuilder offset + opacity
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 18.0, end: 0.0),
      duration: Duration(milliseconds: 420 + (index * 40)),
      builder: (context, value, child) => Opacity(
        opacity: (1 - (value / 18)).clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, value), child: child),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: Spacing.sm),
        padding: EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: Spacing.cardRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                expense.category[0].toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.category,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (expense.note != null && expense.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        expense.note!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: Spacing.sm),
            Text(
              '${CurrencyService.instance.symbol}${expense.amount.toStringAsFixed(2)}',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
