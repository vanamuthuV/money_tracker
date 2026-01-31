import 'package:flutter/material.dart';
import '../home/widgets/summary_card.dart';
import '../../core/services/currency_service.dart';
import '../../core/animations/micro_interactions.dart';
import 'widgets/transaction_card.dart';
import '../../../models/expense_model.dart';
import '../../core/services/expense_service.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/colors.dart';

class HistoryScreen extends StatefulWidget {
  static const String route = '/history';
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ExpenseModel>>(
      valueListenable: ExpenseService.instance.expenses,
      builder: (ctx, items, _) {
        final total = items.fold<double>(0, (s, e) => s + e.amount);
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text('History'),
              actions: [],
              bottom: TabBar(
                tabs: [
                  Tab(text: 'All'),
                  Tab(text: 'Debit'),
                  Tab(text: 'Credit'),
                ],
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                children: [
                  SummaryCard(
                    title: 'Total',
                    subtitle:
                        '${CurrencyService.instance.symbol} ${total.toStringAsFixed(2)}',
                  ),
                  SizedBox(height: Spacing.sm),
                  // search
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search by note, category, amount',
                    ),
                    onChanged: (q) =>
                        setState(() => _searchQuery = q.toLowerCase()),
                  ),
                  SizedBox(height: Spacing.md),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildTabList(items, 'all'),
                        _buildTabList(
                          items.where((e) => e.type == 'debit').toList(),
                          'debit',
                        ),
                        _buildTabList(
                          items.where((e) => e.type == 'credit').toList(),
                          'credit',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabList(List<ExpenseModel> list, String tabKey) {
    final filtered = list.where((e) {
      if (_searchQuery.isEmpty) return true;
      final s = '${e.note ?? ''} ${e.category} ${e.amount}'.toLowerCase();
      return s.contains(_searchQuery);
    }).toList();
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 320),
      child: ListView.builder(
        key: ValueKey('${tabKey}_${filtered.length}_${_searchQuery}'),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) {
          final tx = filtered[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
            child: Dismissible(
              key: ValueKey(tx.id),
              background: Container(
                color: Colors.transparent,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 16),
                child: Icon(Icons.edit, color: AppColors.credit),
              ),
              secondaryBackground: Container(
                color: Colors.transparent,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.delete, color: AppColors.debit),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  await ExpenseService.instance.remove(tx.id);
                  ScaffoldMessenger.of(
                    ctx,
                  ).showSnackBar(SnackBar(content: Text('Deleted')));
                  return true;
                }
                return false;
              },
              child: TransactionCard(tx: tx, index: i),
            ),
          );
        },
      ),
    );
  }
}
