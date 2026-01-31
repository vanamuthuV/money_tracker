import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class NoteInput extends StatelessWidget {
  final TextEditingController controller;
  const NoteInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 2,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Add a note (optional)',
        hintStyle: TextStyle(color: AppColors.muted),
        border: InputBorder.none,
      ),
    );
  }
}
