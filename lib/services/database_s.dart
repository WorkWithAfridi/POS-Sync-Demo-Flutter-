import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:user_sync/models/user_m.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  DatabaseService._internal();
  factory DatabaseService() => _instance;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pos_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          created_at TEXT
        )
      ''');
      },
    );
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final result = await db.query('users');
    return result.map((e) => User.fromMap(e)).toList();
  }

  Future<void> replaceAllUsers(List<User> users) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('users');
    for (var u in users) {
      batch.insert('users', u.toMap());
    }
    await batch.commit(noResult: true);
  }
}
