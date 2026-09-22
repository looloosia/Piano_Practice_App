import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:piano_practice_app/data/piece.dart';
import 'package:piano_practice_app/data/section.dart';

class PieceDatabase {
  static final PieceDatabase instance = PieceDatabase._internal();

  PieceDatabase._internal();

  late Future<Database> _database;

  Future<void> initDatabase() async {
    _database = _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'piano_practice.db');

    return openDatabase(
      path,
      version: 1,

      // SQLite에서 FOREIGN KEY 사용
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: _createDB,
    );
  }

  Future<void> _createDB(
      Database db,
      int version,
      ) async {
    // 곡
    await db.execute('''
      CREATE TABLE pieces (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // 연습 구간
    await db.execute('''
      CREATE TABLE sections (
        id TEXT PRIMARY KEY,
        pieceId TEXT NOT NULL,
        title TEXT NOT NULL,
        sortOrder INTEGER NOT NULL,
        createdAt INTEGER NOT NULL,
        currentCount INTEGER NOT NULL,
        targetCount INTEGER NOT NULL,

        FOREIGN KEY (pieceId)
          REFERENCES pieces(id)
          ON DELETE CASCADE
      )
    ''');
  }

  // --------------------
  // Piece
  // --------------------

  Future<void> insertPiece(Piece piece) async {
    final db = await _database;

    await db.insert(
      'pieces',
      {
        'id': piece.id,
        'title': piece.title,
        'createdAt': piece.createdAt.millisecondsSinceEpoch,
        'updatedAt': piece.updatedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePieceTitle(
      String id,
      String title,
      ) async {
    final db = await _database;

    await db.update(
      'pieces',
      {
        'title': title,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletePiece(String id) async {
    final db = await _database;

    await db.delete(
      'pieces',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Piece>> loadPieces() async {
    final db = await _database;

    final result = await db.query(
      'pieces',
      orderBy: 'createdAt ASC',
    );

    return result.map((row) {
      return Piece(
        id: row['id'] as String,
        title: row['title'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          row['createdAt'] as int,
        ),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          row['updatedAt'] as int,
        ),
      );
    }).toList();
  }

  // --------------------
  // Section
  // --------------------

  Future<void> insertSection(Section section) async {
    final db = await _database;

    await db.insert(
      'sections',
      {
        'id': section.id,
        'pieceId': section.pieceId,
        'title': section.title,
        'sortOrder': section.sortOrder,
        'createdAt': section.createdAt.millisecondsSinceEpoch,
        'currentCount': section.currentCount,
        'targetCount': section.targetCount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertSections(
      List<Section> sections,
      ) async {
    final db = await _database;

    final batch = db.batch();

    for (final section in sections) {
      batch.insert(
        'sections',
        {
          'id': section.id,
          'pieceId': section.pieceId,
          'title': section.title,
          'sortOrder': section.sortOrder,
          'createdAt': section.createdAt.millisecondsSinceEpoch,
          'currentCount': section.currentCount,
          'targetCount': section.targetCount,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> updateSectionTitle(
      String id,
      String title,
      ) async {
    final db = await _database;

    await db.update(
      'sections',
      {
        'title': title,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSectionTargetCount(
      String id,
      int targetCount,
      ) async {
    final db = await _database;

    await db.update(
      'sections',
      {
        'targetCount': targetCount,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSectionCurrentCount(
      String id,
      int currentCount,
      ) async {
    final db = await _database;

    await db.update(
      'sections',
      {
        'currentCount': currentCount,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteSection(String id) async {
    final db = await _database;

    await db.delete(
      'sections',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Section>> loadSections(
      String pieceId,
      ) async {
    final db = await _database;

    final result = await db.query(
      'sections',
      where: 'pieceId = ?',
      whereArgs: [pieceId],
      orderBy: 'sortOrder ASC',
    );

    return result.map((row) {
      return Section(
        id: row['id'] as String,
        pieceId: row['pieceId'] as String,
        title: row['title'] as String,
        sortOrder: row['sortOrder'] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          row['createdAt'] as int,
        ),
        currentCount: row['currentCount'] as int,
        targetCount: row['targetCount'] as int,
      );
    }).toList();
  }

  Future<List<Section>> loadAllSections() async {
    final db = await _database;

    final result = await db.query(
      'sections',
      orderBy: 'sortOrder ASC',
    );

    return result.map((row) {
      return Section(
        id: row['id'] as String,
        pieceId: row['pieceId'] as String,
        title: row['title'] as String,
        sortOrder: row['sortOrder'] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          row['createdAt'] as int,
        ),
        currentCount: row['currentCount'] as int,
        targetCount: row['targetCount'] as int,
      );
    }).toList();
  }
}