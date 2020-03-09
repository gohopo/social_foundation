import 'package:event_bus/event_bus.dart';
import 'package:get_it/get_it.dart';

class SfMessageEvent<TMessage> {
  TMessage message;
  bool isNew;
  SfMessageEvent({this.message,this.isNew});
  static void emit<TMessage>({TMessage message,bool isNew:true}){
    GetIt.instance<EventBus>().fire(SfMessageEvent(message:message,isNew:isNew));
  }
}