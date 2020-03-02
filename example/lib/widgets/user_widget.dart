import 'package:flutter/material.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/models/user.dart';
import 'package:social_foundation_example/states/user_state.dart';

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
    return SfProviderWidget<UserState>(
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

class UserAvatar extends SfAvatar {
  final User user;
  final String defaultIcon;

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
    this.defaultIcon : 'assets/images/bird.png'
  }) : super(key:key,width:width,height:height,decoration:decoration,borderRadius:borderRadius,radius:radius,image:image??AssetImage(user!=null?user.icon:defaultIcon),child:child,onTap:onTap);
}

class UserNickName extends StatelessWidget {
  final User user;
  final TextStyle style;
  UserNickName({
    Key key,
    @required this.user,
    this.style
  }) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return Text(
      this.user!=null ? this.user.nickName : '',
      style: this.style,
      maxLines: 1,
    );
  }
}