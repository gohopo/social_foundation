import 'package:flutter/material.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/services/router_manager.dart';
import 'package:social_foundation_example/states/user_state.dart';

class SigninModel extends SfViewState{
  TextEditingController phoneController = TextEditingController();
  signin() async {
    try{
      if(phoneController.text.isEmpty) throw '请填写用户名!';
      await UserState.instance.login(phoneController.text);
      RouterManager.instance.navigator.pushReplacementNamed(RouteName.Tab);
    }
    catch(e){
      BotToast.showText(text: e.toString());
    }
  }
}