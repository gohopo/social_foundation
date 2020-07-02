import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/models/message.dart';

class SfEvent<T>{
  StreamSubscription _subscription;
  
  void listen(void onData(T event)){
    _subscription = GetIt.instance<EventBus>().on<T>().listen(onData);
  }
  void emit(){
    GetIt.instance<EventBus>().fire(this);
  }
  void dispose(){
    _subscription?.cancel();
    _subscription = null;
  }
}

class SfMessageEvent extends SfEvent<SfMessageEvent>{
  SfMessage message;
  bool isNew;
  SfMessageEvent({this.message,this.isNew});
}