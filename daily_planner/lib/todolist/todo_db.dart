import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'todo_model.dart';

class TodoDb {
  static final TodoDb instance = TodoDb._init();
  static Database? _db;
  TodoDb._init();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('todos.db');
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, fileName);
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        deadline INTEGER NOT NULL,
        isCompleted INTEGER NOT NULL,
        isDailyRecurring INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        completedAt INTEGER
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE todos ADD COLUMN isDailyRecurring INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<void> insertTodo(Todo t) async {
    final db = await database;
    await db.insert('todos', t.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTodo(Todo t) async {
    final db = await database;
    await db.update('todos', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<void> deleteTodo(String id) async {
    final db = await database;
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Todo>> getAllTodos() async {
    final db = await database;
    final maps = await db.query('todos');
    return maps.map((m) => Todo.fromMap(m)).toList();
  }

  Future close() async {
    final db = _db;
    if (db != null) await db.close();
    _db = null;
  }
}
