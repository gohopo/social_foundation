import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  ChatInput({
    Key key
  }) : super(key:key);

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  TextEditingController _controller;

  @override
  void initState(){
    _controller = TextEditingController();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Row(children: <Widget>[
        Expanded(
          child: buildEditor()
        ),
        buildSend()
      ]),
      buildAccessory()
    ]);
  }
  Widget buildEditor(){
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: '请输入消息...'
      ),
    );
  }
  Widget buildSend(){
    return RaisedButton(
      onPressed: () {
        print('send');
      }
    );
  }
  Widget buildAccessory(){
    return Row(children: <Widget>[
      buildSend(),
      buildSend(),
      buildSend()
    ]);
  }
}