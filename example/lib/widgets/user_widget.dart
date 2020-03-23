import 'package:flutter/material.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/models/user.dart';
import 'package:social_foundation_example/services/router_manager.dart';

class UserConsumer extends SfUserConsumer<User>{
  UserConsumer({
    Key key,
    String userId,
    User user,
    ValueWidgetBuilder<User> builder,
    Widget child
  }) : super(key:key,userId:userId,user:user,builder:builder,child:child);
}

class UserAvatar extends SfAvatar{
  UserAvatar({
    Key key,
    @required User user,
    double width = 45,
    double height = 45,
    VoidCallback onTap,
    BorderRadiusGeometry borderRadius,
    ImageProvider defaultImage = const AssetImage('assets/images/head_1.png'),
    BoxFit fit = BoxFit.cover,
    Widget Function(BuildContext context,UserAvatar avatar,ImageProvider image) builder
  }) : super(key:key,user:user,width:width,height:height,onTap:onTap,borderRadius:borderRadius,defaultImage:defaultImage,fit:fit,builder:builder);

  @override
  void onTapOverride(){
    if(onTap != null) return onTap();
    if(user == null) return;
    RouterManager.instance.navigator.pushNamed(RouteName.user_profile,arguments:{'userId':user.userId});
  }
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