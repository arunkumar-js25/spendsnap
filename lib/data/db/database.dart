import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Expenses])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // CRUD operations for Expenses
  // Get all expenses from the database
  Future<List<Expense>> getAllExpenses() {
    return select(expenses).get();
  }

  // Insert a new expense into the database
  Future<int> insertExpense(ExpensesCompanion expense) {
    return into(expenses).insert(expense);
  }

  //Delete an expense by ID
  Future<int> deleteExpense(int id) {
  return (delete(expenses)..where((tbl) => tbl.id.equals(id))).go();
}
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'expense.sqlite'));
    return NativeDatabase(file);
  });
}