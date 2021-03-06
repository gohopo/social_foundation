import 'package:flutter/material.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/view_models/signin_model.dart';

class SigninPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfProvider<SigninModel>(
        model: SigninModel(),
        builder: (context,model,child) => Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                renderHeader(),
                renderFields(model)
              ],
            )
          )
        ),
      )
    );
  }
  renderHeader() => Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      FlutterLogo(
        textColor: Colors.green,
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
  renderFields(SigninModel model) => Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
          child: TextField(
            controller: model.phoneController,
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
        GestureDetector(
          onTap: model.signin,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
            padding: EdgeInsets.all(12.0),
            color: Colors.green,
            child: Text(
              '登陆',
              style: TextStyle(color: Colors.white),
            )
          )
        )
      ]
    ),
  );
}