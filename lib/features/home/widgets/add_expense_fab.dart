import 'package:flutter/material.dart';
import '../../add_expense/add_expense_screen.dart';
import '../../../core/constants/colors.dart';

class AddExpenseFab extends StatelessWidget {
  const AddExpenseFab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => AddExpenseScreen())),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Icon(Icons.add, color: Colors.black, size: 28),
        ),
      ),
    );
  }
}
