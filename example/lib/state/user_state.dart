import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation_example/model/user.dart';

class UserState with ChangeNotifier{
  static UserState get instance => GetIt.instance<UserState>();
  Map<String,User> _users = {};
  String _curUserId;

  User operator [](String userId) => _users[userId];
  String get curUserId => _curUserId;
  Future<User> login(String userId) async {
    var user = await User.login(userId);
    _curUserId = user.userId;
    _users[user.userId] = user;
    notifyListeners();
    return user;
  }
  Future<User> queryUser(String userId) async {
    var user = this[userId];
    if(user == null){
      user = await User.queryUser(userId);
      _users[user.userId] = user;
      notifyListeners();
    }
    return user;
  }
}