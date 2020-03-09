import 'package:get_it/get_it.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/models/user.dart';

class UserState extends SfUserState<User>{
  static UserState get instance => GetIt.instance<SfUserState>();

  Future<User> login(String userId) async {
    var user = await User.login(userId);
    setCurUser(user);
    return user;
  }
  Future<User> queryUser(String userId) async {
    var user = await super.queryUser(userId);
    if(user == null){
      user = await User.queryUser(userId);
      setUser(user);
    }
    return user;
  }
}