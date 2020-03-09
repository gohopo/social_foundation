import 'package:get_it/get_it.dart';
import 'package:social_foundation/services/storage_manager.dart';
import 'package:sqflite/sqflite.dart';

class SfUser{
  String userId;
  SfUser(Map data) : userId = data['userId'];
  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    map['userId'] = userId;
    return map;
  }
  Future<void> save() async {
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    await database.insert('user', toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
  }
}