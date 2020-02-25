import 'package:social_foundation_example/service/chat_manager.dart';
import 'package:social_foundation_example/service/storage_manager.dart';
import 'package:sqflite/sqflite.dart';

class User {
  String userId;
  String nickName;
  String icon;
  User(Map data) :
  userId = data['userId'],nickName = data['nickName'],icon = data['icon']{
    nickName = userId;
    icon = 'assets/images/bird.png';
  }
  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    map['userId'] = userId;
    map['icon'] = icon;
    return map;
  }
  Future<User> save() async {
    var database = await StorageManager.instance.getDatabase();
    await database.insert('user', toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
    return this;
  }
  static Future<User> login(String userId) async {
    var user = User({'userId':userId});
    ChatManager.instance.login(userId);
    return user.save();
  }
  static Future<User> queryUser(String userId) async {
    var database = await StorageManager.instance.getDatabase();
    var result = await database.query('user',where:'userId=?',whereArgs:[userId]);
    if(result.length > 0) return User(result[0]);
    var user = User({'userId':userId});
    return user.save();
  }
}