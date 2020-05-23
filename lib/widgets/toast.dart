import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SfDialog{
  CancelFunc _cancelFunc;
  
  void onShow({Widget child,UniqueKey key,String groupKey,bool crossPage,bool allowClick,bool clickClose,bool ignoreContentClick,bool onlyOne,FutureFunc closeFunc,VoidCallback onClose,Color backgroundColor,WrapWidget warpWidget,Duration duration}) => BotToast.showEnhancedWidget(
    toastBuilder: (cancelFunc){
      _cancelFunc = cancelFunc;
      return child;
    },
    key: key,
    groupKey: groupKey ?? 'SfDialog',
    crossPage: crossPage ?? true,
    allowClick: allowClick ?? false,
    clickClose: clickClose ?? false,
    ignoreContentClick: ignoreContentClick ?? false,
    onlyOne: onlyOne ?? true,
    closeFunc: closeFunc,
    onClose: onClose,
    backgroundColor: backgroundColor ?? Colors.black45,
    warpWidget: warpWidget,
    duration: duration,
  );
  void close() => _cancelFunc?.call();
}

class SfEasyDialog extends SfDialog{
  @protected Widget buildTitle(String title) => Text(title);
  @protected Widget buildContent(String content) => Text(content);
  @protected Widget buildAction(String action) => Container(
    padding: EdgeInsets.symmetric(horizontal:15,vertical:10),
    color: Colors.grey,
    child: Text(action),
  );

  Future onShowAlert(String title,String content,String action) => onShowConfirm(title,content,[action]);
  Future<int> onShowConfirm(String title,String content,List<String> actions,{Color backgroundColor}) => onShowCustomConfirm(
    title: buildTitle(title),
    content: buildContent(content),
    actions: actions.map(buildAction).toList(),
  );
  Future<int> onShowCustomConfirm({Widget title,Widget content,List<Widget> actions,Color backgroundColor}){
    var completer = Completer<int>();
    onShowFrame(
      title: title,
      close: Container(),
      body: content,
      footer: Container(
        child: Row(
          children: actions.asMap().keys.map((index) => GestureDetector(
            onTap: (){
              this.close();
              completer.complete(index);
            },
            child: actions[index]
          )).toList(),
        )
      ),
      backgroundColor: backgroundColor
    );
    return completer.future;
  }
  void onShowFrame({Widget title,Widget close,Widget body,Widget footer,VoidCallback onClose,Color backgroundColor}) => onShowCustomFrame(
    header: Container(
      child: Row(
        children: [
          Expanded(
            child: title,
          ),
          close
        ],
      ),
    ),
    body:body,footer:footer,onClose:onClose,backgroundColor:backgroundColor
  );
  void onShowCustomFrame({Widget header,Widget body,Widget footer,VoidCallback onClose,Color backgroundColor}) => onShowCustom(
    child: Container(
      child: Column(
        children: [header,body,footer],
      ),
    ),
    onClose:onClose,backgroundColor:backgroundColor
  );
  void onShowCustom({Widget child,String groupKey,VoidCallback onClose,Color backgroundColor}) => onShow(groupKey:groupKey??'SfEasyDialog',onClose:onClose,backgroundColor:backgroundColor,child:child);
}

class SfToast{
  void onShowText(String text) => onShowCustomText(text);
  void onShowCustomText(String text,{Color backgroundColor,AlignmentGeometry align,EdgeInsetsGeometry contentPadding,Color contentColor,BorderRadiusGeometry borderRadius,TextStyle textStyle}) => BotToast.showText(
    text: text,
    backgroundColor: backgroundColor ?? Colors.transparent,
    align: align ?? const Alignment(0, 0.8),
    contentPadding: contentPadding ?? EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 7),
    contentColor: contentColor ?? Colors.black54,
    borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(8)),
    textStyle: textStyle ?? TextStyle(fontSize: 17, color: Colors.white)
  );
  void onShowLoading({double size,Color color}) => onShowCustomLoading(SpinKitCubeGrid(
    size: size ?? 50.0,
    color: color ?? Colors.white,
  ));
  void onShowCustomLoading(Widget loadingWidget,{Color backgroundColor,Alignment align}) => BotToast.showCustomLoading(
    backgroundColor: backgroundColor ?? Colors.black26,
    align: align ?? Alignment.center,
    toastBuilder: (_) => loadingWidget,
  );
  void onCloseAllLoading() => BotToast.closeAllLoading();
}