import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfAudioPlayerModel extends SfViewState{
  SfAudioPlayerModel({
    this.uri,
    this.earpieceMode = false
  });
  String uri;
  bool earpieceMode;
  AudioPlayer _player = new AudioPlayer();
  StreamSubscription _stateSubscription;
  StreamSubscription _positionSubscription;
  int position = 0;
  static SfAudioPlayerModel playingVM;
  
  bool get isPlaying => position>0;
  Future play() async {
    await playingVM?.stop();
    return _player.play(uri);
  }
  Future stop(){
    return _player.stop();
  }

  @override
  Future initData() async {
    _stateSubscription = _player.onPlayerStateChanged.listen((s){
      playingVM = null;
      position = 0;
      notifyListeners();
    });
    _positionSubscription = _player.onAudioPositionChanged.listen((p){
      playingVM = this;
      position = p.inMilliseconds;
      notifyListeners();
    });
    
    await _player.setUrl(uri);
    if(earpieceMode){
      await _player.earpieceOrSpeakersToggle();
    }
  }
  @override
  void dispose(){
    _player.stop();
    _stateSubscription.cancel();
    _positionSubscription.cancel();
    super.dispose();
  }
  @override
  void onRefactor(newState) async {
    var state = newState as SfAudioPlayerModel;
    if(earpieceMode!=state.earpieceMode){
      earpieceMode = state.earpieceMode;
      await _player.earpieceOrSpeakersToggle();
      if(!isPlaying) play();
    }
  }
  @override bool get wantKeepAlive => isPlaying;
}