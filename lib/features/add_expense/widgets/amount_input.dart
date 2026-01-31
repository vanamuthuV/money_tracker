import 'package:flutter/material.dart';
import 'package:money_tracker/core/constants/colors.dart';
import 'package:money_tracker/core/constants/spacing.dart';
import 'package:money_tracker/core/services/currency_service.dart';

class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  const AmountInput({required this.controller, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: CurrencyService.instance.code,
      builder: (ctx, code, _) => TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          prefixText: CurrencyService.instance.symbol + ' ',
          hintText: '0.00',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
        validator: (v) {
          final val = double.tryParse(v?.replaceAll(',', '') ?? '');
          return (val == null || val <= 0) ? 'Enter amount' : null;
        },
      ),
    );
  }
}
