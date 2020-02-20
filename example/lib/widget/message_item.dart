import 'package:flutter/material.dart';
import 'package:social_foundation_example/model/message.dart';

class MessageItemWidget extends StatelessWidget{
  MessageItemWidget({
    this.message,
    this.onTap
  }) : super(key: ValueKey(message.msgId));

  final Message message;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Text(DateTime.fromMillisecondsSinceEpoch(message.timestamp).toString().substring(0,19));
  }
}