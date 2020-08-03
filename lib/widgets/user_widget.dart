import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/models/user.dart';
import 'package:social_foundation/states/user_state.dart';
import 'package:social_foundation/widgets/provider_widget.dart';

class SfUserConsumer<TUser extends SfUser> extends StatelessWidget {
  SfUserConsumer({
    Key key,
    String userId,
    TUser user,
    this.builder,
    this.child,
    this.fetch = false
  }) :userId=userId,user=user,
      super(key:key ?? Key(userId ?? user?.userId));

  final String userId;
  final TUser user;
  final ValueWidgetBuilder<TUser> builder;
  final Widget child;
  final bool fetch;

  @override
  Widget build(BuildContext context){
    return SfProviderEnhanced<SfUserState>(
      model: GetIt.instance<SfUserState>(),
      onModelReady: (vsync,model){
        if(this.user==null && this.userId!=null){
          model.queryUser(this.userId,this.fetch);
        }
      },
      builder: (context,model,child) => builder(context,this.user??model[this.userId],child),
      child: this.child,
    );
  }
}