import 'package:drift/drift.dart';

class Expenses extends Table {

  // =========================================================
  // 🔥 PRIMARY KEY
  // =========================================================

  IntColumn get id =>
      integer().autoIncrement()();

  // =========================================================
  // 🔥 USER
  // =========================================================

  TextColumn get userId =>
      text()();

  // =========================================================
  // 🔥 SYNC
  // =========================================================

  BoolColumn get isSynced =>

      boolean().withDefault(
        const Constant(false),
      )();

  TextColumn get firestoreId =>

      text().nullable()();

  // =========================================================
  // 🔥 CORE FIELDS
  // =========================================================

  TextColumn get description =>
      text()();

  TextColumn get category =>
      text()();

  RealColumn get amount =>
      real()();

  TextColumn get type =>
      text()();

  DateTimeColumn get date =>
      dateTime()();

  // =========================================================
  // 🔥 TIMESTAMPS
  // =========================================================

  DateTimeColumn get createdAt =>

      dateTime().withDefault(
        currentDateAndTime,
      )();

  DateTimeColumn get updatedAt =>

      dateTime().withDefault(
        currentDateAndTime,
      )();

  // =========================================================
  // 🔥 SAFETY UNIQUE KEYS
  // =========================================================

  @override
  List<Set<Column>> get uniqueKeys => [

    // ✅ Prevent duplicate firestore records
    {firestoreId},
  ];
  BoolColumn get isDeleted =>    boolean().withDefault(const Constant(false), )();
  /*
  TextColumn get paidBy => text()(); // GPay / PhonePe / Card / Cash

  // Card specific
  TextColumn get cardCompany => text().nullable()(); // HDFC / ICICI / SBI

  DateTimeColumn get ccPaidOn => dateTime().nullable()(); // Credit card due date

  // Rewards
  RealColumn get rewardPoints =>
      real().withDefault(
        const Constant(0.0),
      )();

  RealColumn get cashback =>
      real().withDefault(
        const Constant(0.0),
      )();

  // Date & Month
  TextColumn get month => text()();
  */
}

class Categories extends Table {

  // =========================================================
  // 🔥 PRIMARY KEY
  // =========================================================

  IntColumn get id =>
      integer().autoIncrement()();

  // =========================================================
  // 🔥 USER
  // =========================================================

  TextColumn get userId =>
      text()();

  // =========================================================
  // 🔥 SYNC
  // =========================================================

  BoolColumn get isSynced =>

      boolean().withDefault(
        const Constant(false),
      )();

  TextColumn get firestoreId =>

      text().nullable()();

  // =========================================================
  // 🔥 CATEGORY INFO
  // =========================================================

  TextColumn get name =>
      text()();

  IntColumn get colorValue =>
      integer()();

  IntColumn get iconCodePoint =>
      integer()();

  TextColumn get keywords =>
      text()();

  // =========================================================
  // 🔥 TIMESTAMPS
  // =========================================================

  DateTimeColumn get createdAt =>

      dateTime().withDefault(
        currentDateAndTime,
      )();

  DateTimeColumn get updatedAt =>

      dateTime().withDefault(
        currentDateAndTime,
      )();

  // =========================================================
  // 🔥 SAFETY UNIQUE KEYS
  // =========================================================

  @override
  List<Set<Column>> get uniqueKeys => [

    // ✅ Prevent duplicate categories
    // per user

    {userId, name},

    // ✅ Prevent duplicate firestore docs

    {firestoreId},
  ];
  BoolColumn get isDeleted =>    boolean().withDefault(const Constant(false), )();
}