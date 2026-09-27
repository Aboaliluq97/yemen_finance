import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_tables.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();

    return _database!;
  }

  Future<Database> _openDatabase() async {
    final String databasesPath = await getDatabasesPath();

    final String databasePath = join(
      databasesPath,
      DatabaseTables.databaseName,
    );

    return openDatabase(
      databasePath,
      version: DatabaseTables.databaseVersion,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createTables(
    Database database,
    int version,
  ) async {
    await database.execute('''
      CREATE TABLE ${DatabaseTables.accounts} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        account_type TEXT NOT NULL,
        currency TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        opening_balance REAL NOT NULL DEFAULT 0,
        image_path TEXT,
        is_archived INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await database.execute('''
      CREATE TABLE ${DatabaseTables.sections} (
        id TEXT PRIMARY KEY,
        account_id TEXT NOT NULL,
        name TEXT NOT NULL,
        currency TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        color_value INTEGER NOT NULL,
        icon_code_point INTEGER NOT NULL,
        opening_balance REAL NOT NULL DEFAULT 0,
        is_archived INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await database.execute('''
      CREATE TABLE ${DatabaseTables.transactions} (
        id TEXT PRIMARY KEY,
        account_id TEXT NOT NULL,
        section_id TEXT NOT NULL,
        title TEXT NOT NULL,
        transaction_type TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT '',
        counterparty TEXT NOT NULL DEFAULT '',
        location TEXT NOT NULL DEFAULT '',
        reason TEXT NOT NULL DEFAULT '',
        payment_method TEXT NOT NULL DEFAULT '',
        reference_number TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT '',
        labels TEXT NOT NULL DEFAULT '',
        transaction_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        linked_transaction_id TEXT
      )
    ''');

    await database.execute('''
      CREATE TABLE ${DatabaseTables.ledgerEntries} (
        id TEXT PRIMARY KEY,
        account_id TEXT NOT NULL,
        ledger_type TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        credit REAL NOT NULL DEFAULT 0,
        debit REAL NOT NULL DEFAULT 0,
        currency TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await database.execute('''
      CREATE TABLE ${DatabaseTables.childGoals} (
        id TEXT PRIMARY KEY,
        account_id TEXT NOT NULL,
        child_name TEXT NOT NULL,
        goal_name TEXT NOT NULL,
        target_amount REAL NOT NULL,
        saved_amount REAL NOT NULL DEFAULT 0,
        reward_points REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await database.execute('''
      CREATE TABLE ${DatabaseTables.inventoryItems} (
        id TEXT PRIMARY KEY,
        account_id TEXT NOT NULL,
        name TEXT NOT NULL,
        sku TEXT NOT NULL DEFAULT '',
        quantity REAL NOT NULL DEFAULT 0,
        minimum_quantity REAL NOT NULL DEFAULT 0,
        unit_price REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await database.execute('''
      CREATE TABLE ${DatabaseTables.profiles} (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        phone TEXT NOT NULL DEFAULT '',
        business_name TEXT NOT NULL DEFAULT '',
        image_path TEXT,
        updated_at TEXT NOT NULL
      )
    ''');

    await database.execute('''
      CREATE TABLE ${DatabaseTables.attachments} (
        id TEXT PRIMARY KEY,
        transaction_id TEXT,
        account_id TEXT,
        attachment_type TEXT NOT NULL,
        file_path TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await database.execute('''
      CREATE TABLE ${DatabaseTables.settings} (
        setting_key TEXT PRIMARY KEY,
        setting_value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDatabase(
    Database database,
    int oldVersion,
    int newVersion,
  ) async {
    // ستضاف ترقيات قاعدة البيانات في النسخ القادمة هنا.
  }

  Future<void> close() async {
    final Database databaseReference = await database;

    await databaseReference.close();

    _database = null;
  }
}
