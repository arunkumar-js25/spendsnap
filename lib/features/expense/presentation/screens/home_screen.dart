import 'package:flutter/material.dart';
import 'package:spendsnap/data/db/database.dart';
import 'add_expense_screen.dart';
import 'package:spendsnap/features/scanner/presentation/qr_scanner_screen.dart';
import 'package:spendsnap/features/expense/presentation/widgets/summary_card.dart';
import 'package:spendsnap/core/utils/expense_calculator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = AppDatabase();
  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final data = await db.getAllExpenses();
    setState(() => expenses = data);
  }

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

  void _openAddScreen({double? prefilledAmount, String? prefilledDesc, String? prefilledCategory}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          db: db,
          prefilledAmount: prefilledAmount,
          prefilledDesc: prefilledDesc,
          prefilledCategory: prefilledCategory,
        ),
      ),
    );

    if (result == true) {
      _loadExpenses();
    }
  }

  void _openScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QRScannerScreen(),
      ),
      );
      
      if (result == true) {
        _loadExpenses(); // ✅ refresh list
      }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SpendSnap")),
      body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    buildSummaryCard(
                      title: "Today",
                      amount: ExpenseCalculator.getTodayTotal(expenses),
                      color: Colors.red,
                      icon: Icons.today,
                    ),
                    buildSummaryCard(
                      title: "This Week",
                      amount: ExpenseCalculator.getThisWeekTotal(expenses),
                      color: Colors.blue,
                      icon: Icons.calendar_view_week,
                    ),
                    buildSummaryCard(
                      title: "This Month",
                      amount: ExpenseCalculator.getThisMonthTotal(expenses),
                      color: Colors.green,
                      icon: Icons.calendar_month,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // ✅ TOTAL SPEND
              const SizedBox(height: 10),
              Expanded(
                child: expenses.isEmpty
                    ? const Center(child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.receipt_long, size: 50, color: Colors.grey),
                                                SizedBox(height: 10),
                                                Text("No expenses yet"),
                                                Text("Start by adding or scanning a payment"),
                                              ],
                                            ),)
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: expenses.length,
                        itemBuilder: (_, index) {
                          final e = expenses[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    (categoryColors[e.category] ?? Colors.grey).withOpacity(0.2),
                                child: Icon(
                                  categoryIcons[e.category] ?? Icons.category,
                                  color: categoryColors[e.category] ?? Colors.grey,
                                ),
                              ),
                              title: Text(e.description),
                              subtitle: Text(
                                "${e.category} • ${e.date.day}/${e.date.month}/${e.date.year}",
                              ),
                              trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("₹${e.amount.toStringAsFixed(2)}",
                                        style: const TextStyle(fontWeight: FontWeight.bold),),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Color.fromARGB(255, 132, 55, 49)),
                                          onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    title: const Text("Delete Expense"),
                                                    content: const Text("Are you sure you want to delete this expense?"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context, false),
                                                        child: const Text("Cancel"),
                                                      ),
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context, true),
                                                        child: const Text("Delete"),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                 if (confirm == true) {
                                                    await db.deleteExpense(e.id);
                                                    _loadExpenses();
                                                  }
                                                }
                                        ),
                                      ],
                                    ),
                              )
                          );
                        },
                      ),
              ),
            ],
          ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "scan",
            onPressed: _openScanner,
            child: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "add",
            onPressed: _openAddScreen,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}