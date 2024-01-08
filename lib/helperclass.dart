import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE notes(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    title TEXT,
    note TEXT,
    createAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");
  }

  static Future<sql.Database> myData() async {
    return sql.openDatabase('myNotes.db', version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  static Future<int> createNote(String title, String note) async {
    final db = await SQLHelper.myData();
    final data = {'title': title, 'note': note};
    final id = await db.insert("notes", data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> readNotes() async {
    final db = await SQLHelper.myData();
    return db.query('notes', orderBy: 'id');
  }

  static Future<int> updateNote(int id, String titlenew, String notenew) async {
    final db = await SQLHelper.myData();
    final newdata = {
      'title': titlenew,
      'note': notenew,
      'createAt': DateTime.now().toString()
    };
    final result =
        await db.update('note', newdata, where: "id=?", whereArgs: [id]);
    return result;
  }

  static Future<void> deletenote(int id) async {
    final db = await SQLHelper.myData();
    try {
      await db.delete("notes", where: "id=?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something wrong");
    }
  }
}
