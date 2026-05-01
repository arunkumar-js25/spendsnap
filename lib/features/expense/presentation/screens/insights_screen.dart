import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:spendsnap/core/utils/expense_calculator.dart';
import 'package:spendsnap/data/db/database.dart';
import 'package:spendsnap/features/expense/presentation/widgets/sectionTitle.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() =>
      _InsightsScreenState();
}

class _InsightsScreenState
    extends State<InsightsScreen> {

  final db = AppDatabase();

  List<Expense> expenses = [];
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();

    _loadExpenses();
    _loadCategories();
  }

  Future<void> _loadExpenses() async {

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final data =
        await db.getUserExpenses(user.uid);

    setState(() {
      expenses = data;
    });
  }

  Future<void> _loadCategories() async {

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final data =
        await db.getUserCategories(user.uid);

    setState(() {
      categories = data;
    });
  }

  Category? _findCategory(String name) {

    try {

      return categories.firstWhere(
        (c) => c.name == name,
      );

    } catch (e) {

      return null;
    }
  }

  @override
  Widget build(BuildContext context) {

    if (expenses.isEmpty) {

      return Scaffold(

        appBar: AppBar(
          title: const Text("Insights"),
        ),

        body: const Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              Icon(
                Icons.insights,
                size: 60,
                color: Colors.grey,
              ),

              SizedBox(height: 10),

              Text(
                "No insights yet",
                style: TextStyle(fontSize: 16),
              ),

              Text(
                "Start adding expenses to see trends",
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("Insights"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // 🔥 WEEKLY INSIGHT
            Container(

              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.blue.shade50,

                borderRadius:
                    BorderRadius.circular(12),
              ),

              child: Row(

                children: [

                  const Icon(
                    Icons.insights,
                    color: Colors.blue,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(

                      ExpenseCalculator
                          .getWeeklyInsight(
                              expenses),

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Divider(thickness: 0.5),

            // 🔥 TODAY VS AVERAGE
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                sectionTitle(
                  "Today vs Average",
                ),

                Text(
                  "Today: ₹${ExpenseCalculator.getTodayTotal(expenses).toStringAsFixed(0)}",
                ),

                Text(
                  "Avg (7 days): ₹${ExpenseCalculator.getLast7DaysAverage(expenses).toStringAsFixed(0)}",
                ),

                const SizedBox(height: 6),

                Text(
                  ExpenseCalculator
                      .getTodayVsAverageInsight(
                          expenses),

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ],
            ),

            const Divider(thickness: 0.5),

            // 🔥 TOP SPENDING
            sectionTitle("Top Spending"),

            const SizedBox(height: 6),

            Text(
              ExpenseCalculator
                  .getTopCategory(expenses),
            ),

            const SizedBox(height: 16),

            const Divider(thickness: 0.5),

            // 🔥 CATEGORY TOTALS
            sectionTitle("Category Totals"),

            const SizedBox(height: 8),

            Wrap(

              spacing: 8,
              runSpacing: 8,

              children:
                  ExpenseCalculator
                      .getCategoryTotals(
                          expenses)
                      .entries
                      .map((entry) {

                final categoryData =
                    _findCategory(entry.key);

                final color =
                    categoryData != null
                        ? Color(
                            categoryData
                                .colorValue,
                          )
                        : Colors.grey;

                final icon =
                    categoryData != null
                        ? IconData(
                            categoryData
                                .iconCodePoint,

                            fontFamily:
                                'MaterialIcons',
                          )
                        : Icons.category;

                return Container(

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(

                    color:
                        color.withOpacity(0.15),

                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Row(

                    mainAxisSize:
                        MainAxisSize.min,

                    children: [

                      Icon(
                        icon,
                        size: 18,
                        color: color,
                      ),

                      const SizedBox(width: 6),

                      Text(

                        "${entry.key}: ₹${entry.value.toStringAsFixed(0)}",

                        style: TextStyle(
                          color: color,

                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );

              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}