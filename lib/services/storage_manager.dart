import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

abstract class SfStorageManager {
  SfStorageManager({
    this.dbPath = 'social.db',
    this.dbVersion = 1
  }) {
    getTemporaryDirectory().then((data) => temporaryDirectory=data);
  }
  Directory temporaryDirectory;
  final String dbPath;
  final int dbVersion;
  Database _database;

  Future<Database> getDatabase() async {
    if(_database == null){
      _database = await openDatabase(dbPath,version:dbVersion,onCreate: onCreateDatabase,onUpgrade: onUpgradeDatabase);
    }
    return _database;
  }
  @protected void onCreateDatabase(Database database,int version);
  @protected void onUpgradeDatabase(Database database,int oldVersion, int newVersion);
}