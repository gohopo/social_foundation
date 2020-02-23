import 'package:flutter/material.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/model/user.dart';
import 'package:social_foundation_example/state/user_state.dart';
import 'package:social_foundation_example/widget/provider_widget.dart';

class UserConsumer extends StatelessWidget {
  final String userId;
  final User user;
  final ValueWidgetBuilder<User> builder;
  final Widget child;

  UserConsumer({
    Key key,
    this.userId,
    this.user,
    this.builder,
    this.child
  }) : super(key:key);

  @override
  Widget build(BuildContext context){
    return ProviderWidget<UserState>(
      model: UserState.instance,
      onModelReady: (model){
        if(this.user==null && this.userId.isNotEmpty){
          model.queryUser(this.userId);
        }
      },
      builder: (context,model,child) => builder(context,this.user??model[this.userId],child),
      child: this.child,
      autoDispose: false,
    );
  }
}

class UserAvatar extends Avatar {
  final User user;

  UserAvatar({
    Key key,
    @required this.user,
    double width : 45,
    double height : 45,
    Decoration decoration,
    BorderRadiusGeometry borderRadius,
    double radius,
    ImageProvider image,
    Widget child,
    VoidCallback onTap,
  }) : super(key:key,width:width,height:height,decoration:decoration,borderRadius:borderRadius,radius:radius,image:image??AssetImage(user.icon),child:child,onTap:onTap);
}

class UserNickName extends StatelessWidget {
  final User user;
  UserNickName({
    Key key,
    @required this.user
  }) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return Text(this.user.nickName);
  }
}