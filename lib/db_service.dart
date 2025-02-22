// lib/db_service.dart
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// For non-web platforms, import dart:io and sqflite_common_ffi
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBService {
  static Database? _database;

  // Use an in-memory map as cache on web
  static final Map<String, String> _memoryCache = {};

  /// Initializes FFI for non-web platforms.
  static Future<void> initialize() async {
    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      // On Android/iOS, sqflite initializes automatically.
    }
  }

  /// Returns the database for non-web platforms.
  /// On web, returns null (and we'll use the in-memory cache).
  static Future<Database?> getDatabase() async {
    if (kIsWeb) {
      return null; // We'll use our _memoryCache for web.
    }
    await initialize();
    if (_database != null) return _database!;
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'probability.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE results (query TEXT PRIMARY KEY, result TEXT)",
        );
      },
    );
    return _database!;
  }

  /// Saves a query result.
  static Future<void> saveResult(String query, String result) async {
    if (kIsWeb) {
      _memoryCache[query] = result;
    } else {
      final db = await getDatabase();
      if (db != null) {
        await db.insert(
          "results",
          {"query": query, "result": result},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  /// Retrieves a cached result.
  static Future<String?> getCachedResult(String query) async {
    if (kIsWeb) {
      return _memoryCache[query];
    } else {
      final db = await getDatabase();
      if (db != null) {
        final List<Map<String, dynamic>> maps = await db.query(
          "results",
          where: "query = ?",
          whereArgs: [query],
        );
        return maps.isNotEmpty ? maps.first["result"] as String : null;
      }
      return null;
    }
  }
}
