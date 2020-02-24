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
      Container(
        padding: EdgeInsets.symmetric(horizontal:14,vertical:5),
        child: Row(children: <Widget>[
          Expanded(
            child: buildEditor()
          ),
          buildSend()
        ]),
      ),
      buildToolbar(),
      //buildAccessory()
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
    return InkWell(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5,vertical:10),
        child: Icon(Icons.send),
      ),
      onTap: () {
        print('send');
      },
    );
  }
  Widget buildToolbar(){
    return Container(
      padding: EdgeInsets.symmetric(vertical:5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            child: Icon(Icons.keyboard_voice),
            onTap: (){
              print('voice');
            },
          ),
          GestureDetector(
            child: Icon(Icons.photo_album),
            onTap: () {
              print('photo');
            },
          ),
          GestureDetector(
            child: Icon(Icons.photo_camera),
            onTap: () {
              print('camera');
            },
          )
        ],
      ),
    );
  }
  Widget buildAccessory(){
    return null;
  }
}