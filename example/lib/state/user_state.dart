import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../model/user.dart';

class UserState with ChangeNotifier{
  static UserState get instance => GetIt.instance<UserState>();
  Map<String,User> _users = {};
  User _curUser;

  User get curUser => _curUser;
  User operator [](String userId) => _curUser!=null&&_curUser.userId==userId ? _curUser : _users[userId];
  void changeCurUser(User user){
    _curUser = user;
    notifyListeners();
  }
  void updateUser(User user){
    if(_curUser==null || _curUser.userId==user.userId){
      return changeCurUser(user);
    }
    _users[user.userId] = user;
    notifyListeners();
  }
}