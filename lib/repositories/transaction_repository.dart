import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  TransactionRepository._();

  static final TransactionRepository instance =
      TransactionRepository._();

  Future<int> createTransaction(
    TransactionModel transaction,
  ) async {
    final Database database = await AppDatabase.instance.database;

    return database.insert(
      DatabaseTables.transactions,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> createTransfer({
    required TransactionModel outgoingTransaction,
    required TransactionModel incomingTransaction,
  }) async {
    final Database database = await AppDatabase.instance.database;

    await database.transaction((Transaction databaseTransaction) async {
      await databaseTransaction.insert(
        DatabaseTables.transactions,
        outgoingTransaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await databaseTransaction.insert(
        DatabaseTables.transactions,
        incomingTransaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<List<TransactionModel>> getTransactionsBySectionId(
    String sectionId, {
    int? limit,
  }) async {
    final Database database = await AppDatabase.instance.database;

    final List<Map<String, dynamic>> rows = await database.query(
      DatabaseTables.transactions,
      where: 'section_id = ?',
      whereArgs: <Object>[sectionId],
      orderBy: 'transaction_date DESC, created_at DESC',
      limit: limit,
    );

    return rows
        .map(
          (Map<String, dynamic> row) => TransactionModel.fromMap(row),
        )
        .toList();
  }

  Future<List<TransactionModel>> getTransactionsByAccountId(
    String accountId, {
    int? limit,
  }) async {
    final Database database = await AppDatabase.instance.database;

    final List<Map<String, dynamic>> rows = await database.query(
      DatabaseTables.transactions,
      where: 'account_id = ?',
      whereArgs: <Object>[accountId],
      orderBy: 'transaction_date DESC, created_at DESC',
      limit: limit,
    );

    return rows
        .map(
          (Map<String, dynamic> row) => TransactionModel.fromMap(row),
        )
        .toList();
  }

  Future<TransactionModel?> getTransactionById(
    String transactionId,
  ) async {
    final Database database = await AppDatabase.instance.database;

    final List<Map<String, dynamic>> rows = await database.query(
      DatabaseTables.transactions,
      where: 'id = ?',
      whereArgs: <Object>[transactionId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return TransactionModel.fromMap(rows.first);
  }

  Future<int> updateTransaction(
    TransactionModel transaction,
  ) async {
    final Database database = await AppDatabase.instance.database;

    return database.update(
      DatabaseTables.transactions,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: <Object>[transaction.id],
    );
  }

  Future<int> deleteTransactionPermanently(
    String transactionId,
  ) async {
    final Database database = await AppDatabase.instance.database;

    return database.delete(
      DatabaseTables.transactions,
      where: 'id = ?',
      whereArgs: <Object>[transactionId],
    );
  }

  Future<double> getSectionIncome(String sectionId) async {
    final Database database = await AppDatabase.instance.database;

    final List<Map<String, dynamic>> result = await database.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM ${DatabaseTables.transactions}
      WHERE section_id = ?
      AND transaction_type IN (?, ?, ?)
      ''',
      <Object>[
        sectionId,
        'income',
        'transfer_in',
        'inventory_sale',
      ],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getSectionExpenses(String sectionId) async {
    final Database database = await AppDatabase.instance.database;

    final List<Map<String, dynamic>> result = await database.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM ${DatabaseTables.transactions}
      WHERE section_id = ?
      AND transaction_type IN (?, ?, ?, ?)
      ''',
      <Object>[
        sectionId,
        'expense',
        'transfer_out',
        'inventory_purchase',
        'salary_payment',
      ],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getSectionBalance({
    required String sectionId,
    required double openingBalance,
  }) async {
    final double income = await getSectionIncome(sectionId);

    final double expenses = await getSectionExpenses(sectionId);

    return openingBalance + income - expenses;
  }

  Future<double> getAccountIncome(String accountId) async {
    final Database database = await AppDatabase.instance.database;

    final List<Map<String, dynamic>> result = await database.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM ${DatabaseTables.transactions}
      WHERE account_id = ?
      AND transaction_type IN (?, ?, ?)
      ''',
      <Object>[
        accountId,
        'income',
        'transfer_in',
        'inventory_sale',
      ],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getAccountExpenses(String accountId) async {
    final Database database = await AppDatabase.instance.database;

    final List<Map<String, dynamic>> result = await database.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM ${DatabaseTables.transactions}
      WHERE account_id = ?
      AND transaction_type IN (?, ?, ?, ?)
      ''',
      <Object>[
        accountId,
        'expense',
        'transfer_out',
        'inventory_purchase',
        'salary_payment',
      ],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getAccountBalance({
    required String accountId,
    required double openingBalance,
  }) async {
    final double income = await getAccountIncome(accountId);

    final double expenses = await getAccountExpenses(accountId);

    return openingBalance + income - expenses;
  }

  Future<List<TransactionModel>> searchTransactions({
    required String accountId,
    String query = '',
    String? sectionId,
    String? transactionType,
    String? category,
    String? currency,
  }) async {
    final Database database = await AppDatabase.instance.database;

    final List<String> conditions = <String>[
      'account_id = ?',
    ];

    final List<Object> arguments = <Object>[
      accountId,
    ];

    if (sectionId != null && sectionId.isNotEmpty) {
      conditions.add('section_id = ?');
      arguments.add(sectionId);
    }

    if (transactionType != null && transactionType.isNotEmpty) {
      conditions.add('transaction_type = ?');
      arguments.add(transactionType);
    }

    if (category != null && category.isNotEmpty) {
      conditions.add('category = ?');
      arguments.add(category);
    }

    if (currency != null && currency.isNotEmpty) {
      conditions.add('currency = ?');
      arguments.add(currency);
    }

    if (query.trim().isNotEmpty) {
      conditions.add('''
        (
          title LIKE ?
          OR category LIKE ?
          OR counterparty LIKE ?
          OR notes LIKE ?
          OR labels LIKE ?
          OR reference_number LIKE ?
        )
      ''');

      final String searchValue = '%${query.trim()}%';

      arguments.addAll(
        <Object>[
          searchValue,
          searchValue,
          searchValue,
          searchValue,
          searchValue,
          searchValue,
        ],
      );
    }

    final List<Map<String, dynamic>> rows = await database.query(
      DatabaseTables.transactions,
      where: conditions.join(' AND '),
      whereArgs: arguments,
      orderBy: 'transaction_date DESC, created_at DESC',
    );

    return rows
        .map(
          (Map<String, dynamic> row) => TransactionModel.fromMap(row),
        )
        .toList();
  }
}
