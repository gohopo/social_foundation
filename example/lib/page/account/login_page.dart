import 'package:flutter/material.dart';
import 'package:social_foundation_example/service/router_manager.dart';
import 'package:social_foundation_example/state/user_state.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[renderHeader(),renderFields()],
          )
        )
      )
    );
  }
  renderHeader() => Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      FlutterLogo(
        colors: Colors.green,
        size: 80.0
      ),
      SizedBox(
        height: 30.0,
      ),
      Text(
        'social foundation',
        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.green),
      ),
      SizedBox(
        height: 5.0,
      ),
      Text(
        '登陆并继续',
        style: TextStyle(color: Colors.grey),
      ),
    ],
  );
  renderFields() => Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
          child: TextField(
            controller: _usernameController,
            maxLines: 1,
            decoration: InputDecoration(
              labelText: '用户名',
              hintText: '请输入用户名',
            ),
          ),
        ),
        SizedBox(
          height: 30.0,
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
          width: double.infinity,
          child: RaisedButton(
            padding: EdgeInsets.all(12.0),
            shape: StadiumBorder(),
            child: Text(
              '登陆',
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.green,
            onPressed: login
          ),
        ),
      ]
    ),
  );
  void login() async {
    try{
      if(_usernameController.text.isEmpty) throw '请填写用户名!';
      await UserState.instance.login(_usernameController.text);
      Navigator.pushReplacementNamed(context, RouteName.Tab);
    }
    catch(e){
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('提示'),
          content: Text(e.toString()),
        )
      );
    }
  }
}