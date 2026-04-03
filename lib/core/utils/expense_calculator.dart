import 'package:spendsnap/data/db/database.dart';

class ExpenseCalculator {
  static double getTotal(List<Expense> expenses) {
    return expenses.fold(0, (sum, e) => sum + e.amount);
  }

  static double getTodayTotal(List<Expense> expenses) {
    final now = DateTime.now();

    return expenses
        .where((e) =>
            e.date.day == now.day &&
            e.date.month == now.month &&
            e.date.year == now.year)
        .fold(0, (sum, e) => sum + e.amount);
  }

  static double getThisWeekTotal(List<Expense> expenses) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return expenses
        .where((e) => e.date.isAfter(startOfWeek))
        .fold(0, (sum, e) => sum + e.amount);
  }

  static double getThisMonthTotal(List<Expense> expenses) {
    final now = DateTime.now();

    return expenses
        .where((e) =>
            e.date.month == now.month &&
            e.date.year == now.year)
        .fold(0, (sum, e) => sum + e.amount);
  }

  static Map<String, double> getCategoryTotals(List<Expense> expenses) {
    final map = <String, double>{};

    for (var e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }

    return map;
  }

  static String getTopCategory(List<Expense> expenses) {
    final map = getCategoryTotals(expenses);

    if (map.isEmpty) return "No data";

    final top = map.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return "${top.key} (₹${top.value.toStringAsFixed(0)})";
  }

  static double getLast7DaysAverage(List<Expense> expenses) {
    final now = DateTime.now();
    final last7Days = now.subtract(const Duration(days: 7));

    final filtered = expenses.where(
      (e) => e.date.isAfter(last7Days),
    );

    if (filtered.isEmpty) return 0;

    final total = filtered.fold(0.0, (sum, e) => sum + e.amount);

    return total / 7;
  }

  static String getTodayVsAverageInsight(List<Expense> expenses) {
    final today = getTodayTotal(expenses);
    final avg = getLast7DaysAverage(expenses);

    if (avg == 0) return "No data to compare";

    final diff = today - avg;

    if (diff > 0) {
      return "You spent ₹${diff.toStringAsFixed(0)} more than your average";
    } else if (diff < 0) {
      return "You spent ₹${(-diff).toStringAsFixed(0)} less than your average";
    } else {
      return "Your spending matches your average";
    }
  }

  static double getLastWeekTotal(List<Expense> expenses) {
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

  static  String getWeeklyInsight(List<Expense> expenses) {
    final thisWeek = getThisWeekTotal(expenses);
    final lastWeek = getLastWeekTotal(expenses);

    if (lastWeek == 0) return "Not enough data for weekly comparison"; //"No data for last week";

    final diff = thisWeek - lastWeek;

    if (diff > 0) {
      return "You spent ₹${diff.toStringAsFixed(0)} more than last week";
    } else if (diff < 0) {
      return "You saved ₹${(-diff).toStringAsFixed(0)} compared to last week";
    } else {
      return "Your spending is same as last week";
    }
  }
}