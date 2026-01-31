import 'package:flutter/foundation.dart';
import '../../models/expense_model.dart';

class ExpenseService {
  static final ExpenseService instance = ExpenseService._internal();
  ExpenseService._internal();

  final ValueNotifier<List<ExpenseModel>> expenses =
      ValueNotifier<List<ExpenseModel>>([]);
  final ValueNotifier<double> balance = ValueNotifier<double>(0.0);

  void _recompute() {
    balance.value = expenses.value.fold<double>(0.0, (s, e) {
      final t = e.type ?? (e.amount < 0 ? 'credit' : 'debit');
      return t == 'credit' ? s + e.amount.abs() : s - e.amount.abs();
    });
  }

  Future<void> add(ExpenseModel e) async {
    final list = [...expenses.value, e];
    expenses.value = list;
    _recompute();
  }

  Future<void> remove(String id) async {
    final list = expenses.value.where((e) => e.id != id).toList();
    expenses.value = list;
    _recompute();
  }

  Future<void> update(ExpenseModel updated) async {
    final list = expenses.value
        .map((e) => e.id == updated.id ? updated : e)
        .toList();
    expenses.value = list;
    _recompute();
  }

  // Public: set full list (on import/load)
  void setAll(List<ExpenseModel> list) {
    expenses.value = list;
    _recompute();
  }

  static ExpenseModel fromMap(Map<String, dynamic> m) {
    return ExpenseModel.fromMap(m);
  }
}
