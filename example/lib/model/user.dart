import 'package:social_foundation_example/config/chat_manager.dart';
import 'package:social_foundation_example/config/storage_manager.dart';
import 'package:social_foundation_example/state/chat_state.dart';
import 'package:social_foundation_example/state/user_state.dart';
import 'package:sqflite/sqflite.dart';

class User {
  String userId;
  String nickName;
  String icon;
  User(Map<String,dynamic> data) :
  userId = data['userId'],nickName = data['nickName'],icon = data['icon']{
    nickName = userId;
    icon = 'bird.png';
  }
  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['userId'] = userId;
    map['icon'] = icon;
    return map;
  }
  Future<void> save() async {
    UserState.instance.updateUser(this);
    var database = await StorageManager.instance.getDatabase();
    await database.insert('user', toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
  }
  static Future<void> login(String userId) async {
    await ChatManager.instance.login(userId);
    var user = User({'userId':userId});
    user.save();
    ChatState.instance.loadMore();
  }
  static Future<User> queryUser(String userId) async {
    var user = UserState.instance[userId];
    if(user == null){
      var database = await StorageManager.instance.getDatabase();
      var result = await database.query('user',where:'userId=?',whereArgs:[userId]);
      if(result.length > 0){
        user = User(result[0]);
        UserState.instance.updateUser(user);
      }
      else{
        user = User({'userId':userId});
        user.save();
      }
    }
    return user;
  }
}