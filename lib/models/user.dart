import 'dart:ui';

import 'package:get_it/get_it.dart';
import 'package:social_foundation/services/storage_manager.dart';
import 'package:sqflite/sqflite.dart';

class SfUser{
  String userId;
  int gender;
  String? icon;
  SfUser(Map data) : userId=data['userId'],gender=data['gender']??0,icon=data['icon'];
  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    map['userId'] = userId;
    map['gender'] = gender;
    map['icon'] = icon;
    return map;
  }
  int get genderReverse => gender==2 ? 1 : 2;
  Color get genderColor => gender==2 ? Color.fromRGBO(255,67,142,1) : Color.fromRGBO(64,101,153,1);
  Future save() async {
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    await database.insert('user', toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
  }
}