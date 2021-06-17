import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfAudioPlayerModel extends SfViewState{
  SfAudioPlayerModel({
    this.uri,
    this.earpieceMode = false,
    this.compatible = false
  });
  String uri;
  bool earpieceMode;
  bool compatible;
  AudioPlayer _player = new AudioPlayer();
  StreamSubscription _stateSubscription;
  StreamSubscription _positionSubscription;
  int position = 0;
  static SfAudioPlayerModel playingVM;
  
  bool get isPlaying => _player.state==PlayerState.PLAYING;
  Future play() async {
    if(!compatible) await playingVM?.stop();
    return _player.play(uri);
  }
  Future pause(){
    return _player.pause();
  }
  Future stop(){
    return _player.stop();
  }
  void setGlobal(bool enable){
    if(compatible) return;
    playingVM = enable ? this : null;
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
    _stateSubscription = _player.onPlayerStateChanged.listen(onPlayerStateChanged);
    _positionSubscription = _player.onAudioPositionChanged.listen(onAudioPositionChanged);
    
    await _player.setUrl(uri);
    if(earpieceMode) await _player.earpieceOrSpeakersToggle();
  }
  void dispose(){
    _player.stop();
    _stateSubscription.cancel();
    _positionSubscription.cancel();
    super.dispose();
  }
  void onRefactor(newState) async {
    var state = newState as SfAudioPlayerModel;
    if(uri!=state.uri){
      uri = state.uri;
      await _player.setUrl(uri);
    }
    if(earpieceMode!=state.earpieceMode){
      earpieceMode = state.earpieceMode;
      await _player.earpieceOrSpeakersToggle();
      if(!isPlaying) play();
    }
  }
  bool get wantKeepAlive => isPlaying;
}