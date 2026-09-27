import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../models/account_model.dart';

class AccountRepository {
  AccountRepository._();

  static final AccountRepository instance = AccountRepository._();

  Future<int> createAccount(AccountModel account) async {
    final Database database = await AppDatabase.instance.database;

    return database.insert(
      DatabaseTables.accounts,
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AccountModel>> getAllAccounts({
    bool includeArchived = false,
  }) async {
    final Database database = await AppDatabase.instance.database;

    final List<Map<String, dynamic>> rows = await database.query(
      DatabaseTables.accounts,
      where: includeArchived ? null : 'is_archived = ?',
      whereArgs: includeArchived ? null : <Object>[0],
      orderBy: 'created_at DESC',
    );

    return rows
        .map(
          (Map<String, dynamic> row) => AccountModel.fromMap(row),
        )
        .toList();
  }

  Future<AccountModel?> getAccountById(String accountId) async {
    final Database database = await AppDatabase.instance.database;

    final List<Map<String, dynamic>> rows = await database.query(
      DatabaseTables.accounts,
      where: 'id = ?',
      whereArgs: <Object>[accountId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return AccountModel.fromMap(rows.first);
  }

  Future<int> updateAccount(AccountModel account) async {
    final Database database = await AppDatabase.instance.database;

    return database.update(
      DatabaseTables.accounts,
      account.toMap(),
      where: 'id = ?',
      whereArgs: <Object>[account.id],
    );
  }

  Future<int> archiveAccount({
    required String accountId,
    required bool isArchived,
  }) async {
    final Database database = await AppDatabase.instance.database;

    return database.update(
      DatabaseTables.accounts,
      <String, dynamic>{
        'is_archived': isArchived ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: <Object>[accountId],
    );
  }

  Future<int> deleteAccountPermanently(String accountId) async {
    final Database database = await AppDatabase.instance.database;

    return database.delete(
      DatabaseTables.accounts,
      where: 'id = ?',
      whereArgs: <Object>[accountId],
    );
  }

  Future<bool> accountExists(String accountId) async {
    final AccountModel? account = await getAccountById(accountId);

    return account != null;
  }
}
