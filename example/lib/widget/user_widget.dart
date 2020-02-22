// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:social_foundation_example/model/user.dart';
// import 'package:social_foundation_example/state/user_state.dart';

// class WithUserWidget extends StatefulWidget {
//   WithUserWidget({
//     Key key,
//     this.userId,
//     this.child
//   }) : super(key:key);
//   final String userId;
//   final Widget child;
  
//   @override
//   _WithUserWidgetState createState() => _WithUserWidgetState();
// }

// class _WithUserWidgetState extends State<WithUserWidget> {
//   @override
//   void initState(){
//     super.initState();
//     User.queryUser(widget.userId);
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<UserState>(
//       builder: (context,snapshot,_){
//         //var user = snapshot[widget.userId];
//         return child;
//       }
//     );
//   }
// }

// class UserAvatar {

// }