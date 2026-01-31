import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class DatePickerField extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onChanged;
  const DatePickerField({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final dt = await showDatePicker(
          context: context,
          initialDate: selected,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (ctx, child) =>
              Theme(data: Theme.of(context).copyWith(), child: child!),
        );
        if (dt != null) onChanged(dt);
      },
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined, color: AppColors.muted, size: 18),
          SizedBox(width: 8),
          Text(
            '${selected.day}/${selected.month}/${selected.year}',
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
