import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:social_foundation/services/locator_manager.dart';
import 'package:social_foundation/view_models/audio_model.dart';
import 'package:social_foundation/widgets/provider_widget.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfAudioRecorderConsumer extends StatelessWidget{
  SfAudioRecorderConsumer({
    Key key,
    this.child,
    this.onStartRecord,
    this.onStopRecord
  }):super(key:key);
  final Widget child;
  final Function() onStartRecord;
  final Function(String path,int duration,bool isCancelled) onStopRecord;

  Widget build(BuildContext context) => SfProvider<SfAudioRecorderConsumerVM>(
    model: SfAudioRecorderConsumerVM(this),
    builder: (context,model,child) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: model.onLongPressStart,
      onLongPressEnd: model.onLongPressEnd,
      onLongPressMoveUpdate: model.onLongPressMoveUpdate,
      child: child
    ),
    child: child,
  );
}
class SfAudioRecorderConsumerVM extends SfViewState{
  SfAudioRecorderConsumerVM(this.widget);
  SfAudioRecorderConsumer widget;
  FlutterSoundRecorder _soundRecorder;
  OverlayEntry _overlayEntry;
  String decibelsIconDir = 'assets/images/audio_recorder/';
  Duration duration = Duration.zero;
  double decibels = 0;
  String _tips = '手指上滑,取消录音';
  double _startY = 0;
  double _offsetY = 0;
  bool get isCancelled => _startY-_offsetY>100;
  int get decibelsIcon => max(1, min(decibels*7~/120,7));
  Future start() async {
    var status = await Permission.microphone.status;
    if(!status.isGranted) status = await Permission.microphone.request();
    if(!status.isGranted) throw '没有录音权限!';
    buildOverLay();
    if(Platform.isIOS) await _soundRecorder.setAudioFocus();
    await _soundRecorder.startRecorder(codec:Codec.aacADTS,toFile:'${SfLocatorManager.storageManager.voiceDirectory}/record.aac');
    widget.onStartRecord?.call();
  }
  Future stop() async {
    if(_overlayEntry==null) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    var path = await _soundRecorder.stopRecorder();
    widget.onStopRecord?.call(path,duration.inMilliseconds,isCancelled);
    _startY = _offsetY = 0;
  }
  void onLongPressStart(LongPressStartDetails details){
    _startY = _offsetY = details.globalPosition.dy;
    start();
  }
  void onLongPressEnd(LongPressEndDetails details) => stop();
  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details){
    _offsetY = details.globalPosition.dy;
    _tips = isCancelled ? '松开 取消 录音' : '手指上滑,取消录音';
    notifyListeners();
  }
  buildOverLay(){
    if(_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(builder: (content) => Positioned(
      top: ScreenUtil.screenHeightDp * 0.5 - 80,
      left: ScreenUtil.screenWidthDp * 0.5 - 80,
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: Opacity(
            opacity: 0.8,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Color(0xff77797A),
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Image.asset(
                      '$decibelsIconDir$decibelsIcon.png',
                      width: 100,
                      height: 100,
                      package: 'social_foundation',
                    ),
                  ),
                  Container(
                    child: Text(
                      _tips,
                      style: TextStyle(
                        fontStyle: FontStyle.normal,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  )
                ]),
              ),
            ),
          ),
        ),
      )
    );
    SfLocatorManager.routerManager.navigator.overlay.insert(_overlayEntry);
  }

  Future initData() async {
    _soundRecorder = await FlutterSoundRecorder().openAudioSession();
    await _soundRecorder.setSubscriptionDuration(Duration(milliseconds:100));
    _soundRecorder.onProgress.listen((event){
      duration = event.duration;
      decibels = event.decibels;
      notifyListeners();
      _overlayEntry?.markNeedsBuild();
      if(_startY == 0) stop();
    });
    return super.initData();
  }
  void dispose() async {
    await stop();
    await _soundRecorder?.closeAudioSession();
    super.dispose();
  }
}

class SfAudioPlayerWidget extends StatelessWidget {
  SfAudioPlayerWidget({
    Key key,
    this.uri,
    this.duration,
    this.width,
    this.height,
    this.color,
    this.borderColor,
    this.textColor = Colors.white,
    this.onTap,
    this.earpieceMode
  }) : super(key:key);
  final String uri;
  final int duration;
  final double width;
  final double height;
  final Color color;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;
  final bool earpieceMode;

  int getSecond(SfAudioPlayerModel model) => ((model.position>0?duration-model.position:duration)/1000).ceil();
  Widget buildContainer(BuildContext context,SfAudioPlayerModel model){
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(width:0.5,color:borderColor),
        borderRadius: BorderRadius.circular(5)
      ),
      child: buildChildren(context, model),
    );
  }
  onTapContainer(SfAudioPlayerModel model){
    if(model.position <= 0){
      model.play();
    }
    else{
      model.stop();
    }
    onTap?.call();
  }
  Widget buildChildren(BuildContext context,SfAudioPlayerModel model){
    return Row(children: <Widget>[
      buildIcon(context, model),
      buildText(context, model)
    ]);
  }
  Widget buildIcon(BuildContext context,SfAudioPlayerModel model){
    return SizedBox(
      width: 25,
      child: !model.isPlaying ? Icon(
        Icons.music_note,
        size: 20,
        color: textColor,
      ) : SpinKitWave(
        size: 10,
        color: textColor,
      )
    );
  }
  Widget buildText(BuildContext context,SfAudioPlayerModel model){
    return Text('${getSecond(model)}"',style:TextStyle(color:textColor));
  }

  @override
  Widget build(BuildContext context){
    return SfProvider<SfAudioPlayerModel>(
      model: SfAudioPlayerModel(uri:uri,earpieceMode:earpieceMode),
      builder: (context,model,child) => GestureDetector(
        onTap: () => onTapContainer(model),
        child: buildContainer(context, model),
      ),
    );
  }
}