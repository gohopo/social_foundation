import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

abstract class SfStorageManager{
  SfStorageManager({
    this.dbPath = 'social_foundation.db',
    this.dbVersion = 1
  });
  final String dbPath;
  final int dbVersion;
  Directory cacheDirectory;
  SharedPreferences sharedPreferences;
  Database _database;

  Future<void> init() async {
    cacheDirectory = await getApplicationDocumentsDirectory();
    sharedPreferences = await SharedPreferences.getInstance();
    return onInit();
  }
  String getFileDirectory(String dir) => p.join(cacheDirectory.path,dir);
  String get imageDirectory => getFileDirectory('image');
  String get voiceDirectory => getFileDirectory('voice');
  Future<Database> getDatabase() async {
    if(_database == null){
      _database = await openDatabase(dbPath,version:dbVersion,onCreate: onCreateDatabase,onUpgrade: onUpgradeDatabase);
    }
    return _database;
  }
  @protected Future<void> onInit() async {
    await Directory(p.join(cacheDirectory.path,'image')).create(recursive:true);
    await Directory(p.join(cacheDirectory.path,'voice')).create(recursive:true);
  }
  @protected void onCreateDatabase(Database database,int version);
  @protected void onUpgradeDatabase(Database database,int oldVersion, int newVersion);
}

class SfStorageManagerKey{
  static const themeUserDarkMode = 'themeUserDarkMode';
  static const themeColorIndex = 'themeColorIndex';
  static const fontIndex = 'fontIndex';
}