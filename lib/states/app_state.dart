import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/models/app.dart';
import 'package:social_foundation/services/storage_manager.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfAppState extends SfViewState{
  //主题
  bool _userDarkMode;//用户选择的明暗模式
  MaterialColor _themeColor;//当前主题颜色
  int _fontIndex;//当前字体索引
  List<String> fontList = ['system'];
  int get fontIndex => _fontIndex;
  void switchTheme({bool userDarkMode, MaterialColor color}) {
    _userDarkMode = userDarkMode ?? _userDarkMode;
    _themeColor = color ?? _themeColor;
    notifyListeners();
    saveTheme(_userDarkMode, _themeColor);
  }
  void switchRandomTheme({Brightness brightness}) {
    int colorIndex = Random().nextInt(Colors.primaries.length - 1);
    switchTheme(
      userDarkMode: Random().nextBool(),
      color: Colors.primaries[colorIndex],
    );
  }
  void switchFont(int index) {
    _fontIndex = index;
    switchTheme();
    saveFontIndex(index);
  }
  ThemeData themeData({bool platformDarkMode: false}){
    var isDark = platformDarkMode || _userDarkMode;
    return onThemeData(ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColorBrightness: Brightness.dark,
      accentColorBrightness: Brightness.dark,
      primarySwatch: _themeColor,
      accentColor: isDark ? _themeColor[700] : _themeColor,
      fontFamily: fontList[fontIndex]
    ));
  }
  Future saveTheme(bool userDarkMode, MaterialColor themeColor) async {
    var index = Colors.primaries.indexOf(themeColor);
    await Future.wait([
      GetIt.instance<SfStorageManager>().sharedPreferences.setBool(SfStorageManagerKey.themeUserDarkMode, userDarkMode),
      GetIt.instance<SfStorageManager>().sharedPreferences.setInt(SfStorageManagerKey.themeColorIndex, index)
    ]);
  }
  Future saveFontIndex(int index) async {
    await GetIt.instance<SfStorageManager>().sharedPreferences.setInt(SfStorageManagerKey.fontIndex, index);
  }
  InputDecorationTheme inputDecorationTheme(ThemeData theme){
    var width = 0.5;
    return InputDecorationTheme(
      hintStyle: TextStyle(fontSize: 14),
      errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: width, color: theme.errorColor)),
      focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 0.7, color: theme.errorColor)),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: width, color: theme.primaryColor)),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: width, color: theme.dividerColor)),
      border: UnderlineInputBorder(
          borderSide: BorderSide(width: width, color: theme.dividerColor)),
      disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: width, color: theme.disabledColor)),
    );
  }
  String fontName(index) {
    return fontList[index];
  }
  ThemeData onThemeData(ThemeData themeData){
    return themeData.copyWith(
      brightness: themeData.brightness,
      accentColor: themeData.accentColor,
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: _themeColor,
        brightness: themeData.brightness,
      ),
      appBarTheme: themeData.appBarTheme.copyWith(elevation: 0),
      splashColor: _themeColor.withAlpha(50),
      hintColor: themeData.hintColor.withAlpha(90),
      errorColor: Colors.red,
      cursorColor: themeData.accentColor,
      textTheme: themeData.textTheme.copyWith(
        //subhead: themeData.textTheme.subhead.copyWith(textBaseline: TextBaseline.alphabetic)
      ),
      textSelectionColor: themeData.accentColor.withAlpha(60),
      textSelectionHandleColor: themeData.accentColor.withAlpha(60),
      toggleableActiveColor: themeData.accentColor,
      chipTheme: themeData.chipTheme.copyWith(
        pressElevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 10),
        labelStyle: themeData.textTheme.caption,
        backgroundColor: themeData.chipTheme.backgroundColor.withOpacity(0.1),
      ),
      inputDecorationTheme: inputDecorationTheme(themeData),
    );
  }
  //通知
  List<String> notifyList = [];
  bool isNotifyUnread(String notifyType) => notifyList.contains(notifyType);
  Future queryNotifyList() async {
    notifyList = await GetIt.instance.get<SfApp>().queryNotifyList(GetIt.instance.get<SfUserState>().curUserId);
    notifyListeners();
  }
  void addNotify(String notifyType){
    notifyList.add(notifyType);
    notifyListeners();
  }
  void removeNotify(String notifyType){
    notifyList.removeWhere((data) => data==notifyType);
    notifyListeners();
  }

  @override
  Future initData() async {
    _userDarkMode = GetIt.instance<SfStorageManager>().sharedPreferences.getBool(SfStorageManagerKey.themeUserDarkMode) ?? false;
    _themeColor = Colors.primaries[GetIt.instance<SfStorageManager>().sharedPreferences.getInt(SfStorageManagerKey.themeColorIndex) ?? 5];
    _fontIndex = GetIt.instance<SfStorageManager>().sharedPreferences.getInt(SfStorageManagerKey.fontIndex) ?? 0;
  }
}