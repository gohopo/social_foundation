import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../model/user.dart';

class AppState with ChangeNotifier{
  static AppState get instance => GetIt.instance<AppState>();
  User curUser;
}