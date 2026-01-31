import 'package:flutter/foundation.dart';

class ExpenseModel {
  final String id;
  final double amount; // always positive
  final String category;
  final String? note;
  final DateTime date;
  final String type; // 'debit' or 'credit'

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    this.note,
    required this.date,
    this.type = 'debit',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'amount': amount,
    'category': category,
    'note': note,
    'date': date.toIso8601String(),
    'type': type,
  };

  factory ExpenseModel.fromMap(Map<String, dynamic> m) {
    return ExpenseModel(
      id:
          m['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      amount: (m['amount'] as num?)?.toDouble()?.abs() ?? 0.0,
      category: m['category'] as String? ?? 'Other',
      note: m['note'] as String?,
      date: DateTime.tryParse(m['date'] as String? ?? '') ?? DateTime.now(),
      type: (m['type'] as String?) ?? 'debit',
    );
  }
}
