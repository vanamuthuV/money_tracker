import 'package:flutter/material.dart';
import '../../models/expense_model.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import 'widgets/add_expense_fab.dart';
import 'widgets/expense_pie_chart.dart';
import 'widgets/month_comparison_card.dart';
import 'widgets/summary_card.dart';
import 'widgets/glass_card.dart';
import 'widgets/insight_chip.dart';
import 'widgets/animated_counter.dart';
import '../history/history_screen.dart';
import '../common/app_drawer.dart';
import '../../core/services/expense_service.dart';
import '../../core/services/currency_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/services/app_data_service.dart';

class HomeScreen extends StatefulWidget {
  static const String route = '/home';
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // No hard-coded sample data — metrics are derived from the persistent JSON via ExpenseService.

  @override
  Widget build(BuildContext context) {
    // Use live data from ExpenseService (source of truth: JSON)
    return ValueListenableBuilder<List<ExpenseModel>>(
      valueListenable: ExpenseService.instance.expenses,
      builder: (ctx, all, _) {
        final now = DateTime.now();
        // Filter for current month and last month (by year/month)
        final currentMonth = all
            .where((e) => e.date.year == now.year && e.date.month == now.month)
            .toList();
        final lastMonthDate = DateTime(
          now.year,
          now.month - 1 < 1 ? 12 : now.month - 1,
          1,
        );
        final lastMonth = all.where((e) {
          final d = e.date;
          final month = (now.month == 1) ? 12 : now.month - 1;
          final year = (now.month == 1) ? now.year - 1 : now.year;
          return d.year == year && d.month == month;
        }).toList();

        double sumFor(List<ExpenseModel> list) =>
            list.fold(0.0, (s, e) => s + (e.type == 'debit' ? e.amount : 0.0));

        final monthTotal = sumFor(currentMonth);
        final lastMonthTotal = sumFor(lastMonth);

        // distribution by category for current month (only spending)
        final Map<String, double> dist = {};
        for (var e in currentMonth) {
          if (e.type == 'debit')
            dist[e.category] = (dist[e.category] ?? 0) + e.amount;
        }
        final topCategory = dist.isEmpty
            ? '-'
            : dist.entries.reduce((a, b) => a.value > b.value ? a : b).key;
        final String pctChangeLabel = (lastMonthTotal == 0 && monthTotal == 0)
            ? '-'
            : (lastMonthTotal == 0)
            ? '∞'
            : ((monthTotal - lastMonthTotal) / lastMonthTotal * 100)
                      .toStringAsFixed(0) +
                  '%';

        // Build UI with derived values...
        // ...existing code below (replace usages of local variables with computed ones) ...
        // Use monthTotal, lastMonthTotal, topCategory, pctChangeLabel, dist
        // The rest of the widget tree remains, but references to hardcoded lists are removed.
        // (See replaced widget tree below)
        final monthTotalForUi = monthTotal;
        final topCategoryForUi = topCategory;
        final pctChangeForUi = pctChangeLabel;

        // (Continue building using these variables)
        // ...existing code continues below but with replacements...
        // To keep this patch concise, only the necessary replacements are included.
        // The following section updates the specific widgets:
        return Scaffold(
          drawer: const AppDrawer(),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            title: null,
            centerTitle: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: ValueListenableBuilder<double>(
                  valueListenable: ExpenseService.instance.balance,
                  builder: (ctx, bal, _) => TweenAnimationBuilder<double>(
                    tween: Tween(begin: bal, end: bal),
                    duration: Duration(milliseconds: 450),
                    builder: (ctx, v, child) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Available',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${CurrencyService.instance.symbol}${v.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: v > 0
                                    ? AppColors.credit
                                    : v < 0
                                    ? AppColors.debit
                                    : null,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total This Month Spending',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              SizedBox(height: 8),
                              AnimatedCounter(
                                value: monthTotalForUi,
                                style: Theme.of(context).textTheme.displaySmall,
                                prefix: CurrencyService.instance.symbol,
                              ),
                              SizedBox(height: 12),
                              // Only show total amount here; details moved to separate card below
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: Spacing.md),
                      Expanded(
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Top category',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              SizedBox(height: 8),
                              Text(
                                topCategoryForUi,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Spacing.md),

                  // Debit details moved to the bottom of the screen
                  SizedBox.shrink(),

                  MonthComparisonCard(
                    last: lastMonthTotal,
                    current: monthTotal,
                  ),
                  SizedBox(height: Spacing.lg),
                  ExpensePieChart(data: dist),
                  SizedBox(height: Spacing.md),
                  SizedBox(height: Spacing.md),

                  // Debit Details (moved here)
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Debit Details',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        SizedBox(height: 8),
                        if (dist.isNotEmpty)
                          ...dist.entries.map((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    e.key,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    formatCurrency(
                                      e.value,
                                      CurrencyService.instance.symbol,
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            );
                          }).toList()
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'No spending yet',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: Spacing.lg),
                ],
              ),
            ),
          ),
          floatingActionButton: AddExpenseFab(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied, size: 56, color: AppColors.muted),
          SizedBox(height: 12),
          Text(
            'No expenses yet',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Tap + to add your first expense',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Map<String, List<ExpenseModel>> _groupByDay(List<ExpenseModel> items) {
    final Map<String, List<ExpenseModel>> map = {};
    for (var e in items) {
      final key = _formatDate(e.date);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day)
      return 'Today';
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day - 1)
      return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
