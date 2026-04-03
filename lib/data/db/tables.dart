import 'package:drift/drift.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Core fields
  TextColumn get description => text()();
  TextColumn get category => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // Cash / UPI / Credit / Debit

  DateTimeColumn get date => dateTime()();

  DateTimeColumn get createdAt => dateTime()();

  /*
  TextColumn get paidBy => text()(); // GPay / PhonePe / Card / Cash
  // Card specific
  TextColumn get cardCompany => text().nullable()(); // HDFC / ICICI / SBI
  DateTimeColumn get ccPaidOn => dateTime().nullable()(); // Credit card due date

  // Rewards
  RealColumn get rewardPoints => real().withDefault(const Constant(0.0))();
  RealColumn get cashback => real().withDefault(const Constant(0.0))();

  // Date & Month
  DateTimeColumn get date => dateTime()();
  TextColumn get month => text()(); // "January 2025" for easy grouping

  // Sync
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get firestoreId => text().nullable()();

  // Timestamps
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();*/
}