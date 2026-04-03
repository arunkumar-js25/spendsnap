import 'package:flutter/material.dart';
import 'package:spendsnap/features/expense/presentation/widgets/sectionTitle.dart';
import 'package:spendsnap/data/db/database.dart';
import 'package:spendsnap/core/utils/expense_calculator.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final data = await db.getAllExpenses();
    setState(() => expenses = data);
  }
  
  final db = AppDatabase();
  List<Expense> expenses = [];

  final categoryIcons = {
    "Food": Icons.restaurant,
    "Travel": Icons.directions_car,
    "Shopping": Icons.shopping_bag,
    "Bills": Icons.receipt,
    "Medicine": Icons.local_hospital,
    "Entertainment": Icons.movie,
    "Investment": Icons.trending_up,
    "Others": Icons.category,
  };

  final categoryColors = {
    "Food": Colors.orange,
    "Travel": Colors.blue,
    "Shopping": Colors.purple,
    "Bills": Colors.red,
    "Medicine": Colors.green,
    "Entertainment": Colors.teal,
    "Investment": Colors.green,
    "Others": Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Insights")),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.insights, size: 60, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                "No insights yet",
                style: TextStyle(fontSize: 16),
              ),
              Text("Start adding expenses to see trends"),
            ],
          ),
        ),
      );
    }else{
    return Scaffold(
      appBar: AppBar(title: const Text("Insights")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.insights, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ExpenseCalculator.getWeeklyInsight(expenses),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Divider(thickness: 0.5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionTitle("Today vs Average"),

                Text("Today: ₹${ExpenseCalculator.getTodayTotal(expenses).toStringAsFixed(0)}"),
                Text("Avg (7 days): ₹${ExpenseCalculator.getLast7DaysAverage(expenses).toStringAsFixed(0)}"),

                const SizedBox(height: 6),

                Text(
                  ExpenseCalculator.getTodayVsAverageInsight(expenses),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Divider(thickness: 0.5),
            sectionTitle("Top Spending"),
            const SizedBox(height: 6),
            Text(ExpenseCalculator.getTopCategory(expenses)), //top spending category
            const SizedBox(height: 16),
            Divider(thickness: 0.5),
            sectionTitle("Category Totals"),
            const SizedBox(height: 8),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ExpenseCalculator.getCategoryTotals(expenses).entries.map((entry) {
                    final color = categoryColors[entry.key] ?? Colors.grey;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${entry.key}: ₹${entry.value.toStringAsFixed(0)}",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
  }
}