import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/services/category_service.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/expense_service.dart';
import '../../models/category_model.dart' as cat_model;
import '../../models/expense_model.dart';
import 'widgets/amount_input.dart';
import 'widgets/note_input.dart';
import 'widgets/date_picker.dart';

class AddExpenseScreen extends StatefulWidget {
  static const String route = '/add';
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _category = 'Food';
  String _type = 'Debit';
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amt = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0.0;
    if (amt <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Enter a valid amount')));
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _isSaving = true);

    final type = (_type.toLowerCase() == 'credit') ? 'credit' : 'debit';
    final e = ExpenseModel.fromMap({
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'amount': amt.abs(),
      'category': _category,
      'note': _noteCtrl.text.trim(),
      'date': _date.toIso8601String(),
      'type': type,
    });

    await ExpenseService.instance.add(e);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Expense saved')));
    setState(() => _isSaving = false);
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    final cats = CategoryService.instance.categories.value;
    if (cats.isNotEmpty && !_categoriesContains(_category)) {
      _category = cats.first.name;
    }
  }

  bool _categoriesContains(String name) =>
      CategoryService.instance.categories.value.any((c) => c.name == name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            padding: EdgeInsets.all(Spacing.md),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Draggable indicator
                    Center(
                      child: Container(
                        width: 56,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(height: Spacing.md),
                    Text(
                      'Add Expense',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),

                    SizedBox(height: Spacing.sm),
                    // Amount with currency prefix inside widget
                    AmountInput(controller: _amountCtrl),
                    SizedBox(height: Spacing.md),

                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: InputDecoration(labelText: 'Type'),
                      items: ['Debit', 'Credit']
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _type = v ?? 'Debit'),
                    ),
                    SizedBox(height: Spacing.sm),

                    ValueListenableBuilder<List<cat_model.Category>>(
                      valueListenable: CategoryService.instance.categories,
                      builder: (ctx, categories, _) =>
                          DropdownButtonFormField<String>(
                            initialValue: _category,
                            decoration: InputDecoration(labelText: 'Category'),
                            items: categories
                                .map<DropdownMenuItem<String>>(
                                  (c) => DropdownMenuItem(
                                    value: c.name,
                                    child: Text(c.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _category = v ?? _category),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Select a category'
                                : null,
                          ),
                    ),
                    SizedBox(height: Spacing.md),

                    NoteInput(controller: _noteCtrl),
                    SizedBox(height: Spacing.md),

                    DatePickerField(
                      selected: _date,
                      onChanged: (d) =>
                          setState(() => _date = d ?? DateTime.now()),
                    ),
                    SizedBox(height: Spacing.lg),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSaving ? null : _onSave,
                        child: _isSaving
                            ? CircularProgressIndicator(strokeWidth: 2)
                            : ValueListenableBuilder<String>(
                                valueListenable: CurrencyService.instance.code,
                                builder: (ctx, code, _) => Text(
                                  'Save (${CurrencyService.symbolMap[code] ?? code})',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: Spacing.md),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
