import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'siscont.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE sample (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<int> insertSample(String name) async {
    final dbClient = await database;
    return await dbClient.insert('sample', {
      'name': name,
      'synced': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSamples() async {
    final dbClient = await database;
    return await dbClient.query('sample', where: 'synced = ?', whereArgs: [0]);
  }

  Future<void> markSampleSynced(int id) async {
    final dbClient = await database;
    await dbClient
        .update('sample', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
