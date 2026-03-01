import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/password_entry.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'cipherguard.db';
  static const _dbVersion = 1;

  static const _entriesTable = 'password_entries';
  static const _settingsTable = 'settings';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final path = join(await getDatabasesPath(), _dbName);
    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_entriesTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            username TEXT NOT NULL,
            category TEXT NOT NULL,
            encrypted_password TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $_settingsTable (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  Future<List<PasswordEntry>> getEntries() async {
    final db = await database;
    final rows = await db.query(
      _entriesTable,
      orderBy: 'created_at DESC',
    );
    return rows.map(PasswordEntry.fromMap).toList();
  }

  Future<int> insertEntry(PasswordEntry entry) async {
    final db = await database;
    return db.insert(
      _entriesTable,
      entry.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateEntry(PasswordEntry entry) async {
    if (entry.id == null) {
      throw const FormatException('Güncelleme için id zorunlu.');
    }
    final db = await database;
    await db.update(
      _entriesTable,
      entry.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final rows = await db.query(
      _settingsTable,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first['value'] as String;
  }

  Future<void> clearAllEntries() async {
    final db = await database;
    await db.delete(_entriesTable);
  }

  Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.delete(
      _entriesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      _settingsTable,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}



