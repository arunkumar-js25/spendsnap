import 'package:flutter/material.dart';
import 'package:spendsnap/data/db/database.dart';
import 'add_expense_screen.dart';
import 'package:spendsnap/features/scanner/presentation/qr_scanner_screen.dart';
import 'package:spendsnap/core/utils/upi_parser.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = AppDatabase();
  List<Expense> expenses = [];

  // 👇 ADD THIS FUNCTION HERE
  Map<String, double> getCategoryTotals() {
      final map = <String, double>{};

      for (var e in expenses) {
        map[e.category] = (map[e.category] ?? 0) + e.amount;
      }

      return map;
  }

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
    

    //Moved this logic to handle scanner result in QRScannerScreen to prevent multiple calls and ensure smooth UX
    /*
    void _openScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QRScannerScreen(),
      ),
    
      if (result != null) {
      final data = parseUpi(result);

      final amount = double.tryParse(data["amount"] ?? "0") ?? 0;
      final note = data["note"] ?? "";

      final category = detectCategory(note);

      // ✅ SHOW MESSAGE HERE
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("QR detected! Review and save")),
      );

      _openAddScreen(
        prefilledAmount: amount,
        prefilledDesc: note,
        prefilledCategory: category,
      );
    }
  }*/
  
  double getTotal() {
    return expenses.fold(0, (sum, e) => sum + e.amount);
  }

  double getThisMonthTotal() {
    final now = DateTime.now();

    return expenses
        .where((e) =>
            e.date.month == now.month &&
            e.date.year == now.year)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double getThisWeekTotal() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return expenses
        .where((e) => e.date.isAfter(startOfWeek))
        .fold(0, (sum, e) => sum + e.amount);
  }

  double getLastWeekTotal() {
    final now = DateTime.now();

    final startOfThisWeek =
        now.subtract(Duration(days: now.weekday - 1));

    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    final endOfLastWeek = startOfThisWeek;

    return expenses
        .where((e) =>
            e.date.isAfter(startOfLastWeek) &&
            e.date.isBefore(endOfLastWeek))
        .fold(0, (sum, e) => sum + e.amount);
  }

  String getWeeklyInsight() {
    final thisWeek = getThisWeekTotal();
    final lastWeek = getLastWeekTotal();

    if (lastWeek == 0) return "No data for last week";

    final diff = thisWeek - lastWeek;

    if (diff > 0) {
      return "You spent ₹${diff.toStringAsFixed(0)} more than last week";
    } else if (diff < 0) {
      return "You saved ₹${(-diff).toStringAsFixed(0)} compared to last week";
    } else {
      return "Your spending is same as last week";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expenses")),
      body: Column(
            children: [
              // ✅ THIS MONTH TOTAL  
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "This Month: ₹${getThisMonthTotal().toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // ✅ WEEKLY INSIGHT
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
                          getWeeklyInsight(),
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
              // ✅ TOTAL SPEND
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Total: ₹${getTotal().toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              // ✅ CATEGORY TOTALS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 10,
                  children: getCategoryTotals().entries.map((entry) {
                    return Chip(
                      label: Text("${entry.key}: ₹${entry.value.toStringAsFixed(2)}"),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 10),
              Expanded(
                child: expenses.isEmpty
                    ? const Center(child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: const [
                                                Icon(Icons.receipt_long, size: 50, color: Colors.grey),
                                                SizedBox(height: 10),
                                                Text("No expenses yet"),
                                                Text("Start by adding or scanning a payment"),
                                              ],
                                            ),)
                    : ListView.builder(
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