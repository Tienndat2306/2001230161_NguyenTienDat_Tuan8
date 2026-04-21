import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        date_of_birth TEXT NOT NULL,
        country TEXT NOT NULL,
        avatar_path TEXT
      )
    ''');

    // Insert sample data
    await db.insert('users', {
      'name': 'Melissa Peters',
      'email': 'melpeters@gmail.com',
      'password': '************',
      'date_of_birth': '23/05/1995',
      'country': 'Nigeria',
      'avatar_path': null,
    });
    await db.insert('users', {
      'name': 'John Smith',
      'email': 'john.smith@gmail.com',
      'password': '************',
      'date_of_birth': '10/03/1990',
      'country': 'USA',
      'avatar_path': null,
    });
    await db.insert('users', {
      'name': 'Linh Nguyen',
      'email': 'linh.nguyen@gmail.com',
      'password': '************',
      'date_of_birth': '15/07/1998',
      'country': 'Vietnam',
      'avatar_path': null,
    });
  }

  // CREATE
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // READ ALL
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // READ ONE
  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  // UPDATE
  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // DELETE
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}