import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound_lite/flutter_sound.dart' hide PlayerState;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:social_foundation/models/app.dart';
import 'package:social_foundation/services/locator_manager.dart';
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
class SfAudioPlayerModel extends SfViewState{
  SfAudioPlayerModel({
    this.uri,
    this.earpieceMode = false,
    this.compatible = false,
    this.volume = 1.0
  });
  String uri;
  bool earpieceMode;
  bool compatible;
  double volume;
  AudioPlayer player = new AudioPlayer();
  StreamSubscription _stateSubscription;
  StreamSubscription _positionSubscription;
  int position = 0;
  static SfAudioPlayerModel playingVM;
  
  bool get isPlaying => player.state==PlayerState.PLAYING;
  Future play() async {
    if(!compatible) await playingVM?.stop();
    return player.play(uri,volume:volume);
  }
  Future pause(){
    return player.pause();
  }
  Future stop(){
    return player.stop();
  }
  void setGlobal(bool enable){
    if(compatible) return;
    playingVM = enable ? this : (playingVM!=this ? playingVM : null);
  }
  void onPlayerStateChanged(PlayerState s){
    setGlobal(false);
    if(s!=PlayerState.PAUSED) position = 0;
    notifyListeners();
  }
  void onAudioPositionChanged(Duration p){
    setGlobal(true);
    position = p.inMilliseconds;
    notifyListeners();
  }

  Future initData() async {
    _stateSubscription = player.onPlayerStateChanged.listen(onPlayerStateChanged);
    _positionSubscription = player.onAudioPositionChanged.listen(onAudioPositionChanged);
    
    if(earpieceMode) await player.earpieceOrSpeakersToggle();
    if(uri!=null) uri = await SfApp.prepareSound(uri);
  }
  void dispose(){
    setGlobal(false);
    player.dispose();
    _stateSubscription.cancel();
    _positionSubscription.cancel();
    super.dispose();
  }
  void onRefactor(newState) async {
    var state = newState as SfAudioPlayerModel;
    if(uri!=state.uri){
      uri = state.uri;
      uri = await SfApp.prepareSound(uri);
      await player.setUrl(uri);
    }
    if(earpieceMode!=state.earpieceMode){
      earpieceMode = state.earpieceMode;
      await player.earpieceOrSpeakersToggle();
      if(!isPlaying) play();
    }
    if(volume!=state.volume){
      volume = state.volume;
      await player.setVolume(volume);
    }
  }
  bool get wantKeepAlive => isPlaying;
}

class SfAudioPlayer extends StatelessWidget{
  SfAudioPlayer({
    Key key,
    this.uri,
    this.builder,
    this.autoplay = true,
    this.loop = true,
    this.compatible = true,
    this.volume = 1.0,
    this.onInit,
    this.onDispose
  }):super(key:key);
  final String uri;
  final Widget Function(SfAudioPlayerVM model) builder;
  final bool autoplay;
  final bool loop;
  final bool compatible;
  final double volume;
  final Future Function(SfAudioPlayerVM model) onInit;
  final void Function(SfAudioPlayerVM model) onDispose;
  SfAudioPlayerVM createModel() => SfAudioPlayerVM(this);
  Widget build(BuildContext context) => SfProvider<SfAudioPlayerVM>(
    model: createModel(),
    builder: (_,model,__) => builder?.call(model)
  );
}
class SfAudioPlayerVM extends SfAudioPlayerModel{
  SfAudioPlayerVM(this.widget):super(uri:widget.uri,compatible:widget.compatible);
  SfAudioPlayer widget;
  Future initData() async {
    await super.initData();
    await widget.onInit?.call(this);
    if(widget.autoplay) await play();
  }
  void dispose(){
    widget.onDispose?.call(this);
    super.dispose();
  }
  void onPlayerStateChanged(PlayerState s){
    super.onPlayerStateChanged(s);
    if(widget.loop && s==PlayerState.COMPLETED) play();
  }
}
