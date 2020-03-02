import 'package:event_bus/event_bus.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation_example/models/message.dart';

class MessageEvent {
  Message message;
  bool isNew;
  MessageEvent({this.message,this.isNew});
  static void emit({Message message,bool isNew:true}){
    GetIt.instance<EventBus>().fire(MessageEvent(message:message,isNew:isNew));
  }
}