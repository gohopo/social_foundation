import 'package:flutter/material.dart';
import 'package:flutter_plugin_record/index.dart';
import 'package:social_foundation/index.dart';

class AudioRecorderConsumer extends StatefulWidget {
  final Widget child;
  final Function() onStartRecord;
  final Function(String path,int duration) onStopRecord;
  AudioRecorderConsumer({
    Key key,
    this.child,
    this.onStartRecord,
    this.onStopRecord
  }) : super(key:key);

  @override
  _AudioRecorderConsumerState createState() => _AudioRecorderConsumerState();
}

class _AudioRecorderConsumerState extends State<AudioRecorderConsumer> {
  FlutterPluginRecord _recordPlugin;
  OverlayEntry _overlayEntry;
  String _voiceIconBasePath = 'assets/images/audio_recorder/';
  int _voiceIcon = 1;
  String _tips = '手指上滑,取消录音';
  double _startY = 0;

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
  start(){
    buildOverLay();
    _recordPlugin.start();
  }
  stop(){
    _recordPlugin.stop();
    _overlayEntry?.remove();
    _overlayEntry = null;
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
          widget.onStopRecord?.call(data.path,data.audioTimeLength.toInt()*1000);
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
      });
  }
  @override
  void dispose() {
    _recordPlugin?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (details){
        _startY = details.globalPosition.dy;
        start();
      },
      onVerticalDragEnd: (details) => stop(),
      onVerticalDragCancel: stop,
      onVerticalDragUpdate: (details){
        setState((){
          _tips = _startY-details.globalPosition.dy>100 ? '松开 取消 录音' : '手指上滑,取消录音';
        });
      },
      child: widget.child
    );
  }
}


class AudioPlayerWidget extends StatelessWidget {
  final String path;
  final int duration;
  final double width;
  final double height;
  final Color color;
  final Color borderColor;
  AudioPlayerWidget({
    Key key,
    this.path,
    this.duration,
    this.width,
    this.height,
    this.color,
    this.borderColor
  }) : super(key:key);

  _onTap(AudioPlayerModel model){
    if(model.position < 0){
      model.play(path);
    }
    else{
      model.stop();
    }
  }

  @override
  Widget build(BuildContext context){
    return ProviderWidget<AudioPlayerModel>(
      model: AudioPlayerModel(),
      builder: (context,model,child) => GestureDetector(
        onTap: () => _onTap(model),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(width:0.5,color:borderColor),
            borderRadius: BorderRadius.circular(5)
          ),
          child: Row(children: <Widget>[
            Icon(Icons.music_note),
            Text('${duration ~/1000}"')
          ]),
        ),
      ),
    );
  }
}