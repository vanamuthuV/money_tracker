import 'package:flutter/material.dart';
import '../../widgets/expense_tile.dart';
import '../add_expense/add_expense_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Money Tracker")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "₹ 12,450",
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Spent this month",
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 24),
            const Text(
              "Recent Expenses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  ExpenseTile(
                    title: "Food",
                    subtitle: "Biryani",
                    amount: "- ₹250",
                  ),
                  ExpenseTile(
                    title: "Transport",
                    subtitle: "Auto",
                    amount: "- ₹120",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
