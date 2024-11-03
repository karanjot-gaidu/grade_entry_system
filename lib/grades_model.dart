import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'grade.dart';

class GradesModel {
  static final GradesModel _instance = GradesModel._internal();
  Database? _database;

  GradesModel._internal();

  factory GradesModel() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'grades.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE grades(id INTEGER PRIMARY KEY, sid TEXT, grade TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<List<Grade>> getAllGrades() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('grades');
    return List.generate(maps.length, (i) => Grade.fromMap(maps[i]));
  }

  Future<int> insertGrade(Grade grade) async {
    final db = await database;
    return await db.insert('grades', grade.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateGrade(Grade grade) async {
    final db = await database;
    return await db.update(
      'grades',
      grade.toMap(),
      where: 'id = ?',
      whereArgs: [grade.id],
    );
  }

  Future<int> deleteGradeById(int id) async {
    final db = await database;
    return await db.delete(
      'grades',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
