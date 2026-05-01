import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spendsnap/core/utils/settings_service.dart';

import 'package:spendsnap/data/db/database.dart';

class SyncService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final db = appDatabase;

  // =========================================================
  // 🔥 SYNC ALL
  // =========================================================
  Future<bool> _isSyncEnabled() async {

    return await SettingsService()
        .isCloudSyncEnabled();
  }

  Future<void> syncAll() async {

    final enabled =
      await _isSyncEnabled();

    // ❌ sync disabled
    if (!enabled) {

      debugPrint(
        'Cloud sync disabled',
      );

      return;
    }

    // ✅ Categories first
    await syncCategories();

    // ✅ Then expenses
    await syncExpenses();
  }

  // =========================================================
  // 🔥 PUSH EXPENSES
  // =========================================================

  Future<void> syncExpenses() async {

    final user = _auth.currentUser;

    if (user == null) return;

    final unsyncedExpenses =
        await db.getUnsyncedExpenses();

    for (final expense in unsyncedExpenses) {

      try {

        debugPrint(
          'Syncing expense: '
          '${expense.id} '
          'deleted=${expense.isDeleted} '
          'firestoreId=${expense.firestoreId}',
        );
        // =====================================================
        // 🔥 DELETE FLOW
        // =====================================================

        if (expense.isDeleted) {

          try {

            // ✅ delete firestore doc
            if (expense.firestoreId != null) {

              await _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('expenses')
                  .doc(expense.firestoreId)
                  .delete();
            }

            // ✅ permanent local cleanup
            await db.deleteExpense(
              expense.id,
            );

          } catch (e) {

            debugPrint(
              'Expense delete sync failed: $e',
            );
          }

          continue;
        }

        // =====================================================
        // 🔥 UPDATE EXISTING FIRESTORE DOC
        // =====================================================

        if (expense.firestoreId != null) {

          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('expenses')
              .doc(expense.firestoreId)
              .set({

            'description':
                expense.description,

            'category':
                expense.category,

            'amount':
                expense.amount,

            'type':
                expense.type,

            'date':
                expense.date
                    .toIso8601String(),

            'createdAt':
                expense.createdAt
                    .toIso8601String(),

            'updatedAt':
                expense.updatedAt
                    .toIso8601String(),

          }, SetOptions(
            merge: true,
          ));

          // ✅ MARK AS SYNCED
          await db.updateExpense(

            expense.copyWith(
              isSynced: true,
            ),
          );
        }

        // =====================================================
        // 🔥 CREATE NEW FIRESTORE DOC
        // =====================================================

        else {

          final doc =
              await _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('expenses')
                  .add({

            'description':
                expense.description,

            'category':
                expense.category,

            'amount':
                expense.amount,

            'type':
                expense.type,

            'date':
                expense.date
                    .toIso8601String(),

            'createdAt':
                expense.createdAt
                    .toIso8601String(),

            'updatedAt':
                expense.updatedAt
                    .toIso8601String(),
          });

          // ✅ SAVE firestoreId + synced
          await db.updateExpense(

            expense.copyWith(

              firestoreId:
                  Value(doc.id),

              isSynced: true,
            ),
          );
        }

      } catch (e) {

        debugPrint(
          'Expense sync failed: $e',
        );
      }
    }
  }

  // =========================================================
  // 🔥 PUSH CATEGORIES
  // =========================================================

  Future<void> syncCategories() async {

    final user = _auth.currentUser;

    if (user == null) return;

    final unsyncedCategories =
        await db.getUnsyncedCategories();

    for (final category in unsyncedCategories) {

      try {

        // =====================================================
        // 🔥 DELETE FLOW
        // =====================================================

        if (category.isDeleted) {

          try {

            // ✅ delete firestore doc
            if (category.firestoreId != null) {

              await _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('categories')
                  .doc(category.firestoreId)
                  .delete();
            }

            // ✅ permanent local cleanup
            await db.deleteCategory(
              category.id,
            );

          } catch (e) {

            debugPrint(
              'Category delete sync failed: $e',
            );
          }

          continue;
        }

        // =====================================================
        // 🔥 UPDATE EXISTING FIRESTORE DOC
        // =====================================================

        if (category.firestoreId != null) {

          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('categories')
              .doc(category.firestoreId)
              .set({

            'name':
                category.name,

            'colorValue':
                category.colorValue,

            'iconCodePoint':
                category.iconCodePoint,

            'keywords':
                category.keywords,

            'createdAt':
                category.createdAt
                    .toIso8601String(),

            'updatedAt':
                category.updatedAt
                    .toIso8601String(),

          }, SetOptions(
            merge: true,
          ));

          // ✅ MARK AS SYNCED
          await db.updateCategory(

            category.copyWith(
              isSynced: true,
            ),
          );
        }

        // =====================================================
        // 🔥 CREATE NEW FIRESTORE DOC
        // =====================================================

        else {

          final doc =
              await _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('categories')
                  .add({

            'name':
                category.name,

            'colorValue':
                category.colorValue,

            'iconCodePoint':
                category.iconCodePoint,

            'keywords':
                category.keywords,

            'createdAt':
                category.createdAt
                    .toIso8601String(),

            'updatedAt':
                category.updatedAt
                    .toIso8601String(),
          });

          // ✅ SAVE firestoreId + synced
          await db.updateCategory(

            category.copyWith(

              firestoreId:
                  Value(doc.id),

              isSynced: true,
            ),
          );
        }

      } catch (e) {

        debugPrint(
          'Category sync failed: $e',
        );
      }
    }
  }

  // =========================================================
  // 🔥 PULL EXPENSES
  // =========================================================

  Future<void> pullExpenses() async {

    final user = _auth.currentUser;

    if (user == null) return;

    final snapshot =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('expenses')
            .get();

    for (final doc in snapshot.docs) {

      final data = doc.data();

      final exists =
          await db.expenseExistsByFirestoreId(
            doc.id,
          );

      // ✅ skip duplicates
      if (exists) continue;

      await db.insertExpense(

        ExpensesCompanion.insert(

          userId: user.uid,

          description:
              data['description'] ?? '',

          category:
              data['category'] ?? '',

          amount:
              (data['amount'] ?? 0)
                  .toDouble(),

          type:
              data['type'] ?? 'Cash',

          // ✅ preserve actual expense date
          date: DateTime.parse(
            data['date'] ??
                data['createdAt'],
          ),

          createdAt: Value(
            DateTime.parse(
              data['createdAt'],
            ),
          ),

          updatedAt: Value(
            DateTime.parse(
              data['updatedAt'],
            ),
          ),

          isSynced:
              const Value(true),

          firestoreId:
              Value(doc.id),
        ),
      );
    }
  }

  // =========================================================
  // 🔥 PULL CATEGORIES
  // =========================================================

  Future<void> pullCategories() async {

    final user = _auth.currentUser;

    if (user == null) return;

    final snapshot =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('categories')
            .get();

    for (final doc in snapshot.docs) {

      final data = doc.data();

      final exists =
          await db.categoryExistsByFirestoreId(
            doc.id,
          );

      // ✅ skip duplicates
      if (exists) continue;

      await db.insertCategory(

        CategoriesCompanion.insert(

          userId: user.uid,

          name:
              data['name'] ?? '',

          colorValue:
              data['colorValue'] ?? 0,

          iconCodePoint:
              data['iconCodePoint'] ?? 0,

          keywords:
              data['keywords'] ?? '',

          createdAt: Value(
            DateTime.parse(
              data['createdAt'],
            ),
          ),

          updatedAt: Value(
            DateTime.parse(
              data['updatedAt'],
            ),
          ),

          isSynced:
              const Value(true),

          firestoreId:
              Value(doc.id),
        ),
      );
    }
  }

  // =========================================================
  // 🔥 SOFT DELETE EXPENSE
  // =========================================================

  Future<void> deleteExpenseFromCloud(
      Expense expense) async {

    try {

      debugPrint(
        'Delete called for firestoreId: ${expense.firestoreId}',
      );

      // ✅ mark deleted locally first
      await db.updateExpense(

        expense.copyWith(

          isDeleted: true,

          isSynced: false,

          updatedAt: DateTime.now(),
        ),
      );

      // ✅ sync queue
      //await syncExpenses();
      await syncAll();

    } catch (e) {

      debugPrint(
        'Delete expense failed: $e',
      );
    }
  }

  // =========================================================
  // 🔥 SOFT DELETE CATEGORY
  // =========================================================

  Future<void> deleteCategoryFromCloud(
      Category category) async {

    try {

      // ✅ mark deleted locally first
      await db.updateCategory(

        category.copyWith(

          isDeleted: true,

          isSynced: false,

          updatedAt: DateTime.now(),
        ),
      );

      // ✅ sync queue
      //await syncCategories();
      await syncAll();

    } catch (e) {

      debugPrint(
        'Delete category failed: $e',
      );
    }
  }
}