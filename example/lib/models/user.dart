import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/services/storage_manager.dart';

class User extends SfUser{
  String nickName;
  String icon;
  User(Map data) : nickName = data['nickName'],icon = data['icon'],super(data){
    nickName = userId;
    icon = 'assets/images/cat.jpg';
  }
  @override
  Map<String,dynamic> toMap(){
    var map = super.toMap();
    map['nickName'] = nickName;
    map['icon'] = icon;
    return map;
  }
  static Future<User> login(String userId) async {
    var user = User({'userId':userId});
    await SfLocatorManager.chatManager.login(userId);
    await user.save();
    return user;
  }
  static Future<User> queryUser(String userId,bool fetch) async {
    if(!fetch){
      var database = await StorageManager.instance.getDatabase();
      var result = await database.query('user',where:'userId=?',whereArgs:[userId]);
      if(result.length > 0) return User(result[0]);
    }
    var user = await fetchUser(userId);
    await user.save();
    return user;
  }
  static Future<User> fetchUser(String userId) async {
    return null;
  }
}