import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart' show Colors, Icons;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Expenses,Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // CRUD operations for Expenses
  // Get all expenses from the database
  /*Future<List<Expense>> getAllExpenses() {
    return select(expenses).get();
  }*/
  Future<List<Expense>> getUserExpenses(String userId) {
    return (select(expenses)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false)))
        .get();
  }

  // Insert a new expense into the database
  Future<int> insertExpense(ExpensesCompanion expense) {
    return into(expenses).insert(expense);
  }

  // Update an existing expense in the database
  Future updateExpense(Expense expense) {
    return update(expenses).replace(expense);
  }

  //Delete an expense by ID
  Future<int> deleteExpense(int id) {
    return (delete(expenses)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<Expense>> getUnsyncedExpenses() {
    return (select(expenses)
          ..where((tbl) =>
              tbl.isSynced.equals(false)))
        .get();
  }

  Future<bool> expenseExistsByFirestoreId(
    String firestoreId) async {

  final result =
      await (select(expenses)
            ..where((tbl) =>
                tbl.firestoreId.equals(
                    firestoreId)))
          .get();

  return result.isNotEmpty;
}

  // CRUD operations for Categories
  Future<int> insertCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }
  Future updateCategory(Category category) {
    return update(categories).replace(category);
  }

  Future<void> deleteCategory(int id) async {

  await (delete(categories)
        ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
      .go();
}

Future<List<Category>> getUnsyncedCategories() {
  return (select(categories)
        ..where((tbl) =>
            tbl.isSynced.equals(false)))
      .get();
}
Future<bool> categoryExistsByFirestoreId(
    String firestoreId) async {

  final result =
      await (select(categories)
            ..where((tbl) =>
                tbl.firestoreId.equals(
                    firestoreId)))
          .get();

  return result.isNotEmpty;
}

Future<bool> isCategoryUsed(
    String categoryName,
    String userId,
) async {

  final result =
      await (select(expenses)
            ..where((tbl) =>

                tbl.userId.equals(userId) &

                tbl.category.equals(
                    categoryName)))
          .get();

  return result.isNotEmpty;
}

  Future<List<Category>> getUserCategories(String userId) {
    return (select(categories)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false)))
        .get();
  }

  Future<void> seedDefaultCategories(String userId) async {

    final existing = await getUserCategories(userId);

    // ✅ prevent duplicate seeding
    if (existing.isNotEmpty) return;

    final defaults = [

      CategoriesCompanion.insert(
        userId: userId,
        name: "Food",
        colorValue: Colors.orange.value,
        iconCodePoint: Icons.restaurant.codePoint,
        keywords: "food,hotel,restaurant,swiggy,zomato",
      ),

      CategoriesCompanion.insert(
        userId: userId,
        name: "Travel",
        colorValue: Colors.blue.value,
        iconCodePoint: Icons.directions_car.codePoint,
        keywords: "uber,ola,bus,train,travel",
      ),

      CategoriesCompanion.insert(
        userId: userId,
        name: "Bills",
        colorValue: Colors.red.value,
        iconCodePoint: Icons.receipt_long.codePoint,
        keywords: "bill,current,eb,water,recharge",
      ),

      CategoriesCompanion.insert(
        userId: userId,
        name: "Shopping",
        colorValue: Colors.purple.value,
        iconCodePoint: Icons.shopping_bag.codePoint,
        keywords: "amazon,flipkart,shopping",
      ),

      CategoriesCompanion.insert(
        userId: userId,
        name: "Investment",
        colorValue: Colors.green.value,
        iconCodePoint: Icons.trending_up.codePoint,
        keywords: "sip,mutual,nps,investment",
      ),

      CategoriesCompanion.insert(
        userId: userId,
        name: "Medicine",
        colorValue: Colors.green.value,
        iconCodePoint: Icons.local_hospital.codePoint,
        keywords: "med,pharmacy,medicine",
      ),
       CategoriesCompanion.insert(
        userId: userId,
        name: "Entertainment",
        colorValue: Colors.teal.value,
        iconCodePoint: Icons.movie.codePoint,
        keywords: "movie,concert,gaming,streaming",
      ),
        CategoriesCompanion.insert(
          userId: userId,
          name: "Others",
          colorValue: Colors.grey.value,
          iconCodePoint: Icons.category.codePoint,
          keywords: "other,misc,uncategorized",
        ),
    ];

    await batch((batch) {
      batch.insertAll(categories, defaults);
    });

  }
  
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'expense.sqlite'));
    return NativeDatabase(file);
  });
}

late final AppDatabase appDatabase;