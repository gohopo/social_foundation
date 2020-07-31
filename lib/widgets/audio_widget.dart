import 'package:flutter/material.dart';
import 'package:flutter_plugin_record/index.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:social_foundation/view_models/audio_model.dart';
import 'package:social_foundation/widgets/provider_widget.dart';

class SfAudioRecorderConsumer extends StatefulWidget {
  final Widget child;
  final Function() onStartRecord;
  final Function(String path,int duration) onStopRecord;
  SfAudioRecorderConsumer({
    Key key,
    this.child,
    this.onStartRecord,
    this.onStopRecord
  }) : super(key:key);

  @override
  _SfAudioRecorderConsumerState createState() => _SfAudioRecorderConsumerState();
}

class _SfAudioRecorderConsumerState extends State<SfAudioRecorderConsumer> {
  FlutterPluginRecord _recordPlugin;
  OverlayEntry _overlayEntry;
  String _voiceIconBasePath = 'assets/images/audio_recorder/';
  int _voiceIcon = 1;
  String _tips = '手指上滑,取消录音';
  double _startY = 0;
  double _offsetY = 0;

  bool get isCancelled => _startY-_offsetY>100;
  buildOverLay(){
    if(_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(builder: (content) => Positioned(
      top: MediaQuery.of(context).size.height * 0.5 - 80,
      left: MediaQuery.of(context).size.width * 0.5 - 80,
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
                      '$_voiceIconBasePath$_voiceIcon.png',
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
    Overlay.of(context).insert(_overlayEntry);
  }
  void start(){
    buildOverLay();
    _recordPlugin.start();
  }
  void stop(){
    _recordPlugin?.stop();
    _overlayEntry?.remove();
    _overlayEntry = null;
    _startY = _offsetY = 0;
  }

  @override
  void initState(){
    super.initState();
    _recordPlugin = FlutterPluginRecord()
      ..init()
      ..response.listen((data){
        if(data.msg == 'onStart'){
          widget.onStartRecord?.call();
        }
        else if(data.msg == 'onStop'){
          if(!isCancelled) widget.onStopRecord?.call(data.path,data.audioTimeLength.toInt()*1000);
        }
      })
      ..responseFromAmplitude.listen((data){
        var voiceData = double.parse(data.msg);
        setState(() {
          if(voiceData > 0 && voiceData < 0.1){
            _voiceIcon = 2;
          }
          else if(voiceData > 0.2 && voiceData < 0.3){
            _voiceIcon = 3;
          }
          else if(voiceData > 0.3 && voiceData < 0.4){
            _voiceIcon = 4;
          }
          else if(voiceData > 0.4 && voiceData < 0.5){
            _voiceIcon = 5;
          }
          else if(voiceData > 0.5 && voiceData < 0.6){
            _voiceIcon = 6;
          }
          else if(voiceData > 0.6 && voiceData < 0.7){
            _voiceIcon = 7;
          }
          else if(voiceData > 0.7 && voiceData < 1){
            _voiceIcon = 7;
          }
          else{
            _voiceIcon = 1;
          }
          _overlayEntry?.markNeedsBuild();
        });
        if(_startY == 0) stop();
      });
  }
  @override
  void dispose() {
    stop();
    _recordPlugin?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details){
        _startY = details.globalPosition.dy;
        start();
      },
      onLongPressEnd: (details) => stop(),
      onLongPressMoveUpdate: (details){
        _offsetY = details.globalPosition.dy;
        setState((){
          _tips = isCancelled ? '松开 取消 录音' : '手指上滑,取消录音';
        });
      },
      child: widget.child
    );
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
    if(model.position < 0){
      model.play(uri);
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
    return Text('${duration ~/1000}"',style:TextStyle(color:textColor));
  }

  @override
  Widget build(BuildContext context){
    return SfProvider<SfAudioPlayerModel>(
      model: SfAudioPlayerModel(earpieceMode:earpieceMode),
      onModelReady: (model) => model.initData(),
      builder: (context,model,child) => GestureDetector(
        onTap: () => onTapContainer(model),
        child: buildContainer(context, model),
      ),
    );
  }
}