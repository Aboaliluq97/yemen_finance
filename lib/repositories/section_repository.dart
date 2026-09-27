import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../models/section_model.dart';

class SectionRepository {
  SectionRepository._();

  static final SectionRepository instance = SectionRepository._();

  Future<int> createSection(SectionModel section) async {
    final Database database = await AppDatabase.instance.database;

    return database.insert(
      DatabaseTables.sections,
      section.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SectionModel>> getSectionsByAccountId(
    String accountId, {
    bool includeArchived = false,
  }) async {
    final Database database = await AppDatabase.instance.database;

    final List<Map<String, dynamic>> rows = await database.query(
      DatabaseTables.sections,
      where: includeArchived
          ? 'account_id = ?'
          : 'account_id = ? AND is_archived = ?',
      whereArgs: includeArchived
          ? <Object>[accountId]
          : <Object>[accountId, 0],
      orderBy: 'created_at DESC',
    );

    return rows
        .map(
          (Map<String, dynamic> row) => SectionModel.fromMap(row),
        )
        .toList();
  }

  Future<SectionModel?> getSectionById(String sectionId) async {
    final Database database = await AppDatabase.instance.database;

    final List<Map<String, dynamic>> rows = await database.query(
      DatabaseTables.sections,
      where: 'id = ?',
      whereArgs: <Object>[sectionId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return SectionModel.fromMap(rows.first);
  }

  Future<int> updateSection(SectionModel section) async {
    final Database database = await AppDatabase.instance.database;

    return database.update(
      DatabaseTables.sections,
      section.toMap(),
      where: 'id = ?',
      whereArgs: <Object>[section.id],
    );
  }

  Future<int> archiveSection({
    required String sectionId,
    required bool isArchived,
  }) async {
    final Database database = await AppDatabase.instance.database;

    return database.update(
      DatabaseTables.sections,
      <String, dynamic>{
        'is_archived': isArchived ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: <Object>[sectionId],
    );
  }

  Future<int> deleteSectionPermanently(String sectionId) async {
    final Database database = await AppDatabase.instance.database;

    return database.delete(
      DatabaseTables.sections,
      where: 'id = ?',
      whereArgs: <Object>[sectionId],
    );
  }

  Future<bool> sectionExists(String sectionId) async {
    final SectionModel? section = await getSectionById(sectionId);

    return section != null;
  }
}
