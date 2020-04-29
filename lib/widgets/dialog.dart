import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

typedef SfDialogBuilder = Widget Function(SfDialog dialog);

class SfDialog{
  SfDialog({
    this.key,
    this.groupKey = 'SfDialog',
    this.crossPage = true,
    this.allowClick = false,
    this.clickClose = false,
    this.ignoreContentClick = false,
    this.onlyOne = true,
    this.closeFunc,
    this.onClose,
    this.backgroundColor = Colors.black45,
    this.warpWidget,
    this.duration,
    this.builder,
  });
  UniqueKey key;
  String groupKey;
  bool crossPage;
  bool allowClick;
  bool clickClose;
  bool ignoreContentClick;
  bool onlyOne;
  FutureFunc closeFunc;
  VoidCallback onClose;
  Color backgroundColor;
  WrapWidget warpWidget;
  Duration duration;
  SfDialogBuilder builder;
  CancelFunc _cancelFunc;
  
  void show() => BotToast.showEnhancedWidget(
    toastBuilder: (cancelFunc){
      _cancelFunc = cancelFunc;
      return build();
    },
    key: key,
    groupKey: groupKey,
    crossPage: crossPage,
    allowClick: allowClick,
    clickClose: clickClose,
    ignoreContentClick: ignoreContentClick,
    onlyOne: onlyOne,
    closeFunc: closeFunc,
    onClose: onClose,
    backgroundColor: backgroundColor,
    warpWidget: warpWidget,
    duration: duration,
  );
  void close(){
    if(_cancelFunc != null) _cancelFunc();
  }
  Widget build() => builder(this);
}

class SfAlertDialog extends SfDialog{
  SfAlertDialog({
    UniqueKey key,
    Color backgroundColor,
    SfDialogBuilder builder,
    Widget title,
    Widget content,
    List<Widget> actions,
    void Function(int index) onClicked,
  }) : this.enhanced(
    key:key,backgroundColor:backgroundColor,builder:builder,title:title,content:content,
    actionsBuilder: (dialog) => actions.asMap().keys.map((index) => GestureDetector(
      onTap: (){
        dialog.close();
        onClicked(index);
      },
      child: actions[index]
    )).toList(),
  );

  SfAlertDialog.enhanced({
    UniqueKey key,
    Color backgroundColor,
    SfDialogBuilder builder,
    this.title,
    this.content,
    this.actionsBuilder,
  }) : super(key:key,backgroundColor:backgroundColor,builder:builder);

  Widget title;
  Widget content;
  List<Widget> Function(SfAlertDialog dialog) actionsBuilder;

  static Future<int> showAsync({
    Color backgroundColor,
    SfDialogBuilder builder,
    Widget title,
    Widget content,
    List<Widget> actions,
  }){
    var completer = Completer<int>();
    SfAlertDialog(
      backgroundColor: backgroundColor,
      builder: builder,
      title: title,
      content: content,
      actions: actions,
      onClicked: (index){
        completer.complete(index);
      }
    ).show();
    return completer.future;
  }

  @override
  Widget build(){
    return builder!=null ? builder.call(this) : AlertDialog(
      title: title,
      content: content,
      actions: actionsBuilder(this)
    );
  }
}

class SfSimpleAlert{
  Future alert(String title,String content,String action) => confirm(title:title,content:content,actions:[action]);
  Future<int> confirm({String title,String content,List<String> actions}) => SfAlertDialog.showAsync(
    builder: hook(),
    title: buildTitle(title),
    content: buildContent(content),
    actions: actions.map(buildAction).toList(),
  );
  @protected Widget buildTitle(String title) => Text(title);
  @protected Widget buildContent(String content) => Text(content);
  @protected Widget buildAction(String action) => Container(
    padding: EdgeInsets.symmetric(horizontal:15,vertical:10),
    color: Colors.grey,
    child: Text(action),
  );
  @protected SfDialogBuilder hook() => null;
}