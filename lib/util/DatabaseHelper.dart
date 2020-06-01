import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/todo_item.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper._internal();
  static Database _db;

  factory DatabaseHelper() {
    return _instance;
  }

  final String tableName = "toDo";
  final String columnId = "id";
  final String columnItemName = "itemName";
  final String columnDateCreated = "dateCreated";

  DatabaseHelper._internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }

    _db = await initDb();
    return _db;
  }

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "maindb.db");

    var dbObj = await openDatabase(path, version: 1, onCreate: _onCreate);
    return dbObj;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $tableName ($columnId INTEGER PRIMARY KEY,$columnItemName TEXT, $columnDateCreated TEXT) ");
  }

  Future<int> saveItem(ToDoItem item) async {
    var dbClient = await db;
    var result = await dbClient.insert("$tableName", item.toMap());
    return result;
  }

  Future<List> getItems() async {
    var dbClient = await db;
    // print("---------------------------");
    // print(dbClient);
    // print("---------------------------");
    var result = await dbClient
        .rawQuery("SELECT * FROM $tableName ORDER BY $columnDateCreated DESC");

    return result.toList();
  }

  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery("SELECT COUNT(*) FROM $tableName"));
  }

  Future<ToDoItem> getToDoItem(int id) async {
    var dbClient = await db;
    var result =
        await dbClient.rawQuery("SELECT * FROM $tableName WHERE $columnId=$id");
    if (result.length == 0) return null;

    return new ToDoItem.fromMap(result.first);
  }

  Future<int> deleteToDoItem(int id) async {
    var dbClient = await db;

    return await dbClient
        .delete(tableName, where: "$columnId=?", whereArgs: [id]);
  }

  Future<int> updateToDoItem(ToDoItem item) async {
    var dbClient = await db;

    return await dbClient.update(tableName, item.toMap(),
        where: "$columnId=?", whereArgs: [item.id]);
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}
