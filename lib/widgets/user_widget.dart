import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/models/user.dart';
import 'package:social_foundation/states/user_state.dart';
import 'package:social_foundation/widgets/provider_widget.dart';

class SfUserConsumer<TUser extends SfUser> extends StatelessWidget {
  SfUserConsumer({
    Key key,
    this.userId,
    this.user,
    this.builder,
    this.child
  }) : super(key:key);

  final String userId;
  final TUser user;
  final ValueWidgetBuilder<TUser> builder;
  final Widget child;

  @override
  Widget build(BuildContext context){
    return SfProviderWidget<SfUserState>(
      model: GetIt.instance<SfUserState>(),
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