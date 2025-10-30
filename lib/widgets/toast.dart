import 'dart:async';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_foundation/services/locator_manager.dart';
import 'package:social_foundation/utils/image_helper.dart';
import 'package:social_foundation/widgets/animation.dart';

typedef SfDialogBuilder = Widget Function(SfDialog dialog);

class SfDialog{
  CancelFunc? _cancelFunc;
  void onShow({required SfDialogBuilder builder,Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapAnimation,WrapAnimation? wrapToastAnimation,UniqueKey? key,String? groupKey,bool? crossPage,bool? allowClick,bool? clickClose,bool? ignoreContentClick,bool? onlyOne,VoidCallback? onClose,Color? backgroundColor,Duration? duration}) => BotToast.showAnimationWidget(
    toastBuilder: (cancelFunc){
      _cancelFunc = cancelFunc;
      return builder(this);
    },
    animationDuration: animationDuration ?? Duration(milliseconds:250),
    animationReverseDuration: animationReverseDuration,
    wrapAnimation: wrapAnimation ?? (controller,cancelFunc,widget) => Material(
      color: Colors.transparent,
      type: MaterialType.transparency,
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (_) => widget
          )
        ],
      )
    ),
    wrapToastAnimation: wrapToastAnimation ?? (controller,cancelFunc,widget) => SfTranslateAnimation(controller:controller,child:widget),
    key: key,
    groupKey: groupKey ?? 'SfDialog',
    crossPage: crossPage ?? true,
    allowClick: allowClick ?? false,
    clickClose: clickClose ?? false,
    ignoreContentClick: ignoreContentClick ?? false,
    onlyOne: onlyOne ?? true,
    onClose: onClose,
    backgroundColor: backgroundColor ?? Color.fromRGBO(221,221,221,0.6),
    duration: duration,
  );
  void close() => _cancelFunc?.call();



  static Future<T?> actionSheet<T>({String? title,String? message,List<SheetAction<T>> actions=const[],String? cancelLabel,BuildContext? context,bool dismissible=true,AdaptiveStyle? style}) => showModalActionSheet<T>(
    context: context ?? SfLocatorManager.routerManager.navigator!.context,
    title: title,
    message: message,
    actions: actions,
    cancelLabel: cancelLabel,
    isDismissible: dismissible,
    style: style
  );
  static Future<T?> alert<T>({String? title,String? message,List<AlertDialogAction<T>> actions = const [],BuildContext? context,bool dismissible=true,AdaptiveStyle? style}) => showAlertDialog(
    context: context ?? SfLocatorManager.routerManager.navigator!.context,
    title: title,
    message: message,
    actions: actions,
    barrierDismissible: dismissible,
    style: style
  );
  static Future<T?> confirmation<T>({required String title,String? message,List<AlertDialogAction<T>> actions=const[],T? initialSelected,String? okLabel,String? cancelLabel,BuildContext? context,double? contentMaxHeight,bool dismissible=true,AdaptiveStyle? style}) => showConfirmationDialog(
    context: context ?? SfLocatorManager.routerManager.navigator!.context,
    title: title,
    message: message,
    actions: actions,
    initialSelectedActionKey: initialSelected,
    okLabel: okLabel,
    cancelLabel: cancelLabel,
    contentMaxHeight: contentMaxHeight,
    barrierDismissible: dismissible,
    style: style
  );
  static Future<List<String>?> edit({String? title,String? message,List<DialogTextField> textFields=const[],String? okLabel,String? cancelLabel,BuildContext? context,bool dismissible=true,AdaptiveStyle? style}) => showTextInputDialog(
    context: context ?? SfLocatorManager.routerManager.navigator!.context,
    title: title,
    message: message,
    textFields: textFields,
    okLabel: okLabel,
    cancelLabel: cancelLabel,
    barrierDismissible: dismissible,
    style: style
  );
  static Future<OkCancelResult> okAlert({String? title,String? message,String? okLabel,BuildContext? context,bool dismissible=true,AdaptiveStyle? style}) => showOkAlertDialog(
    context: context ?? SfLocatorManager.routerManager.navigator!.context,
    title: title,
    message: message,
    okLabel: okLabel,
    barrierDismissible: dismissible,
    style: style
  );
  static Future<OkCancelResult> okCancelAlert({String? title,String? message,String? okLabel,String? cancelLabel,BuildContext? context,bool dismissible=true,AdaptiveStyle? style}) => showOkCancelAlertDialog(
    context: context ?? SfLocatorManager.routerManager.navigator!.context,
    title: title,
    message: message,
    okLabel: okLabel,
    cancelLabel: cancelLabel,
    barrierDismissible: dismissible,
    style: style
  );
}

class SfEasyDialog extends SfDialog{
  Color get dialogBackgroundColor => Colors.white;
  double get dialogTitleFontSize => 18;
  Color get dialogTitleColor => Colors.black.withOpacity(0.85);
  Color get dialogContentColor => Color.fromRGBO(51,51,51,1);
  Color get dialogActionBorderColor => Color.fromRGBO(217,217,217,1);
  Color get dialogActionTextColor => Color.fromRGBO(51,51,51,1);
  double get sheetTitleFontSize => 16;
  Color get sheetTitleColor => Colors.black;
  Color get sheetActionBackgroundColor => Colors.white;
  Color get sheetActionTextColor => Color.fromRGBO(51,51,51,1);
  Color get sheetActionSeparatorColor => Color.fromRGBO(232,232,232,1);

  Widget buildDialog({Widget? child,BoxConstraints? constraints}){
    return Container(
      constraints: constraints ?? BoxConstraints.tightFor(width:250),
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: dialogBackgroundColor,
        borderRadius: BorderRadius.circular(10)
      ),
      child: child
    );
  }
  Widget buildTitle(String title,double fontSize,Color color) => Text(title,style:TextStyle(fontSize:fontSize,color:color),textAlign:TextAlign.center);
  Widget buildContent({String? content,List<InlineSpan>? contentSpans}) => Container(
    margin: EdgeInsets.only(left:7,bottom:10),
    child: Text.rich(TextSpan(
      style: TextStyle(fontSize:14,color:dialogContentColor),
      children: contentSpans ?? (content!=null ? [TextSpan(text:content)] : null)
    )),
  );
  Widget buildAction(int index,String action) => Container(
    margin: EdgeInsets.symmetric(horizontal:15),
    padding: EdgeInsets.symmetric(horizontal:14,vertical:4),
    decoration: BoxDecoration(
      border: Border.all(width:0.5,color:dialogActionBorderColor),
      borderRadius: BorderRadius.circular(2)
    ),
    child: Text(action,style:TextStyle(fontSize:14,color:dialogActionTextColor)),
  );
  Widget buildSheetActionContainer({required int length,int? index,Widget? child,required bool split,bool? splitLast}) => Container(
    margin: EdgeInsets.only(left:10,top:splitLast==true&&index==length-1?10:0,right:10,bottom:index==length-1?10:0),
    decoration: BoxDecoration(
      color: sheetActionBackgroundColor,
      borderRadius: BorderRadius.vertical(
        top: index==0||splitLast==true&&index==length-1?Radius.circular(10):Radius.zero,
        bottom: index==length-1||splitLast==true&&index==length-2?Radius.circular(10):Radius.zero
      )
    ),
    foregroundDecoration: BoxDecoration(
      border: split && index!=0 && (splitLast!=true || index!=length-1) ? Border(top:BorderSide(width:0.5,color:sheetActionSeparatorColor)) : null
    ),
    child: child
  );
  Widget buildSheetAction(int index,String action) => Container(
    height: 44,
    alignment: Alignment.center,
    child: Text(action,style:TextStyle(fontSize:15,color:sheetActionTextColor)),
  );

  Future<List<File>> onPickImages({double? maxWidth=1000,double? maxHeight=1000,int? imageQuality=75,int maxFileSize=6,int? maxLength=9,ImageSource? imageSource,String? title}) async {
    if(imageSource == null){
      var index = await onShowSheet(['从相册选择照片','拍照','取消'],title:title,splitLast:true);
      if(index == 2) return [];
      imageSource = [ImageSource.gallery,ImageSource.camera][index];
    }
    if(imageSource==ImageSource.camera || maxLength==1){
      var file = await SfImageHelper.pickImage(
        source: imageSource,
        maxWidth:maxWidth,maxHeight:maxHeight,imageQuality:imageQuality,maxFileSize:maxFileSize
      );
      return file!=null ? [file] : [];
    }
    return SfImageHelper.pickImages(maxWidth:maxWidth,maxHeight:maxHeight,imageQuality:imageQuality,maxFileSize:maxFileSize,maxLength:maxLength);
  }
  Future onShowAlert(String title,String? content,String action,{List<InlineSpan>? contentSpans,Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapToastAnimation,bool? clickClose,Color? backgroundColor,Duration? duration}) => onShowConfirm(title,content,[action],contentSpans:contentSpans,animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,clickClose:clickClose,backgroundColor:backgroundColor,duration:duration);
  Future<int> onShowConfirm(String? title,String? content,List<String> actions,{List<InlineSpan>? contentSpans,Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapToastAnimation,bool? clickClose,Color? backgroundColor,Duration? duration}) => onShowCustomConfirm(
    title: title!=null ? buildTitle(title,dialogTitleFontSize,dialogTitleColor) : null,
    content: buildContent(content:content,contentSpans:contentSpans),
    actions: actions.asMap().keys.map((index) => buildAction(index,actions[index])).toList(),
    animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,clickClose:clickClose,backgroundColor:backgroundColor,duration:duration
  );
  Future<int> onShowCustomConfirm({Widget? title,Widget? content,required List<Widget> actions,Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapToastAnimation,bool? clickClose,Color? backgroundColor,Duration? duration}){
    var completer = Completer<int>();
    onShowFrame(
      title: title,
      body: content,
      footer: Container(
        margin: EdgeInsets.only(top:10,bottom:3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: actions.asMap().keys.map((index) => GestureDetector(
            onTap: (){
              this.close();
              completer.complete(index);
            },
            child: actions[index]
          )).toList(),
        )
      ),
      onClose: () => !completer.isCompleted ? completer.complete(-1) : null,
      animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,clickClose:clickClose,backgroundColor:backgroundColor,duration:duration
    );
    return completer.future;
  }
  Future<int> onShowSheet(List<String> actions,{String? title,bool? split,bool? splitLast,Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapToastAnimation,bool? clickClose,Color? backgroundColor,Duration? duration}) => onShowSheetEnhanced(
    title: title!=null ? buildTitle(title,sheetTitleFontSize,sheetTitleColor) : null,
    actions: actions.asMap().keys.map((index) => buildSheetAction(index,actions[index])).toList(),
    split:split,splitLast:splitLast,animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,clickClose:clickClose,backgroundColor:backgroundColor,duration:duration
  );
  Future<int> onShowSheetEnhanced({Widget? title,required List<Widget> actions,bool? split,bool? splitLast,Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapToastAnimation,UniqueKey? key,String? groupKey,bool? clickClose,Color? backgroundColor,Duration? duration}) => onShowCustomSheet(
    actions: actions.asMap().keys.map((index) => buildSheetActionContainer(
      length: actions.length,
      index: index,
      child: actions[index],
      split:split??true,splitLast:splitLast
    )).toList(),
    title:title,animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,
    clickClose:clickClose,backgroundColor:backgroundColor,duration:duration
  );
  Future<int> onShowCustomSheet({Widget? title,required List<Widget> actions,Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapToastAnimation,bool? clickClose,Color? backgroundColor,Duration? duration}){
    var completer = Completer<int>();
    onShowCustom(
      builder: (_) => Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(title != null) Padding(
              padding: EdgeInsets.only(left:10,right:10,bottom:16),
              child: title,
            ),
            Column(
              children: actions.asMap().keys.map((index) => GestureDetector(
                onTap: (){
                  this.close();
                  completer.complete(index);
                },
                child: actions[index]
              )).toList(),
            )
          ],
        ),
      ),
      onClose: () => !completer.isCompleted ? completer.complete(-1) : null,
      animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,
      clickClose:clickClose,backgroundColor:backgroundColor,duration:duration
    );
    return completer.future;
  }
  void onShowFrame({Widget? title,Widget? body,Widget? footer,Alignment? alignment,Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapToastAnimation,bool? clickClose,VoidCallback? onClose,Color? backgroundColor,Duration? duration}) => onShowCustomFrame(
    header: Padding(
      padding: EdgeInsets.only(bottom:3),
      child: title,
    ),
    body:body,footer:footer,alignment:alignment,animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,clickClose:clickClose,onClose:onClose,backgroundColor:backgroundColor,duration:duration
  );
  void onShowCustomFrame({Widget? header,Widget? body,Widget? footer,BoxConstraints? constraints,Alignment? alignment,Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapToastAnimation,bool? clickClose,VoidCallback? onClose,Color? backgroundColor,Duration? duration}) => onShowCustom(
    builder: (_) => Align(
      alignment: alignment ?? Alignment.center,
      child: buildDialog(
        constraints: constraints,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if(header != null) header,
            if(body != null) body,
            if(footer != null) footer
          ],
        )
      ),
    ),
    animationDuration:animationDuration,animationReverseDuration:animationReverseDuration,wrapToastAnimation:wrapToastAnimation,
    clickClose:clickClose,onClose:onClose,backgroundColor:backgroundColor,duration:duration
  );
  void onShowCustom({required SfDialogBuilder builder,Duration? animationDuration,Duration? animationReverseDuration,WrapAnimation? wrapToastAnimation,UniqueKey? key,String? groupKey,bool? allowClick,bool? clickClose,bool? ignoreContentClick,VoidCallback? onClose,Color? backgroundColor,Duration? duration}) => onShow(
    builder: builder,
    animationDuration: animationDuration,
    animationReverseDuration: animationReverseDuration,
    wrapToastAnimation: wrapToastAnimation,
    key: key,
    groupKey: groupKey??'SfEasyDialog',
    allowClick: allowClick,
    clickClose: clickClose,
    ignoreContentClick: ignoreContentClick,
    onClose: onClose,
    backgroundColor: backgroundColor,
    duration: duration
  );



  static Future<int?> actionSheet({String? title,String? message,List<String> actions=const[],String? cancelLabel,BuildContext? context,bool dismissible=true,AdaptiveStyle? style}) => SfDialog.actionSheet<int>(
    title: title,
    message: message,
    actions: actions.mapIndexed<SheetAction<int>>((index,x)=>SheetAction<int>(
      key: index,
      label: x
    )).toList(),
    cancelLabel: cancelLabel,
    context: context,
    dismissible: dismissible,
    style: style
  );
  static Future<int?> alert({String? title,String? message,List<String> actions = const [],BuildContext? context,bool dismissible=true,AdaptiveStyle? style}) => SfDialog.alert<int>(
    title: title,
    message: message,
    actions: actions.mapIndexed<AlertDialogAction<int>>((index,x)=>AlertDialogAction<int>(
      key: index,
      label: x
    )).toList(),
    context: context,
    dismissible: dismissible,
    style: style
  );
  static Future<int?> confirmation<T>({required String title,String? message,List<String> actions=const[],int? initialSelected,String? okLabel,String? cancelLabel,BuildContext? context,double? contentMaxHeight,bool dismissible=true,AdaptiveStyle? style}) => SfDialog.confirmation<int>(
    title: title,
    message: message,
    actions: actions.mapIndexed<AlertDialogAction<int>>((index,x)=>AlertDialogAction<int>(
      key: index,
      label: x
    )).toList(),
    initialSelected: initialSelected,
    okLabel: okLabel,
    cancelLabel: cancelLabel,
    context: context,
    contentMaxHeight: contentMaxHeight,
    dismissible: dismissible,
    style: style
  );
  static Future<String?> edit({String? title,String? message,required DialogTextField textField,String? okLabel,String? cancelLabel,BuildContext? context,bool dismissible=true,AdaptiveStyle? style}) async {
    var result = await SfDialog.edit(
      title: title,
      message: message,
      textFields: [textField],
      okLabel: okLabel,
      cancelLabel: cancelLabel,
      context: context,
      dismissible: dismissible,
      style: style
    );
    return result?.firstOrNull;
  }
  static Future<bool> okAlert({String? title,String? message,String? okLabel,BuildContext? context,bool dismissible=true,AdaptiveStyle? style}) async {
    var result = await SfDialog.okAlert(
      title: title,
      message: message,
      okLabel: okLabel,
      context: context,
      dismissible: dismissible,
      style: style
    );
    return result == OkCancelResult.ok;
  }
  static Future<bool> okCancelAlert({String? title,String? message,String? okLabel,String? cancelLabel,BuildContext? context,bool dismissible=true,AdaptiveStyle? style}) async {
    var result = await SfDialog.okCancelAlert(
      title: title,
      message: message,
      okLabel: okLabel,
      cancelLabel: cancelLabel,
      context: context,
      dismissible: dismissible,
      style: style
    );
    return result == OkCancelResult.ok;
  }
}

class SfToast{
  Color get loadingColor => Colors.white;
  void onShowText(String text) => onShowCustomText(text);
  void onShowCustomText(String text,{Color? backgroundColor,AlignmentGeometry? align,EdgeInsetsGeometry? contentPadding,Color? contentColor,BorderRadiusGeometry? borderRadius,TextStyle? textStyle}) => BotToast.showText(
    text: text,
    backgroundColor: backgroundColor ?? Colors.transparent,
    align: align ?? const Alignment(0, 0.8),
    contentPadding: contentPadding ?? EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 7),
    contentColor: contentColor ?? Colors.black54,
    borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(8)),
    textStyle: textStyle ?? TextStyle(fontSize: 17, color: Colors.white)
  );
  void onShowLoading({double? size,Color? color}) => onShowCustomLoading(SpinKitCircle(
    size: size ?? 50.0,
    color: color ?? loadingColor,
  ));
  void onShowCustomLoading(Widget loadingWidget,{Color? backgroundColor,Alignment? align}) => BotToast.showCustomLoading(
    backgroundColor: backgroundColor ?? Colors.black26,
    align: align ?? Alignment.center,
    toastBuilder: (_) => loadingWidget,
  );
  void onCloseAllLoading() => BotToast.closeAllLoading();
}