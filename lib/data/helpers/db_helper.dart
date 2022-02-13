import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'events.db'),
        onCreate: (db, version) {
      db.execute(
          'CREATE TABLE single_event(id TEXT PRIMARY KEY, name TEXT, body Text, time TEXT)');
      db.execute(
          'CREATE TABLE regular_event(id TEXT PRIMARY KEY, name TEXT, body Text, time TEXT)');
    }, version: 2);
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> update(String table, Map<String, Object> data, id) async {
    final db = await DBHelper.database();
    db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }

  static Future<int> delete(String id) async {
    final db = await DBHelper.database();
    return db.delete('regular_event', where: 'id = ?', whereArgs: [id]);
  }
}
