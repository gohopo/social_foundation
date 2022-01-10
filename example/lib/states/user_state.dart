import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/models/user.dart';

class UserState extends SfUserState<User>{
  static UserState get instance => GetIt.instance<SfUserState>();

  Future<User> login(String userId) async {
    var user = await User.login(userId);
    setCurUser(user);
    return user;
  }
  Future<User> queryUser(String userId,bool fetch) async {
    var user = fetch ? await super.queryUser(userId,fetch) : null;
    if(user == null){
      user = await User.queryUser(userId,fetch);
      setUser(user);
    }
    return user;
  }
}