import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/models/user.dart';
import 'package:social_foundation/states/user_state.dart';
import 'package:social_foundation/widgets/provider_widget.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfUserConsumer<TUser extends SfUser> extends StatelessWidget {
  SfUserConsumer({
    Key? key,
    String? userId,
    TUser? user,
    required this.builder,
    this.child,
    this.fetch = false
  }) :userId=userId,user=user,
      super(key:key ?? Key(userId ?? user?.userId ?? ''));

  final String? userId;
  final TUser? user;
  final ValueWidgetBuilder<TUser?> builder;
  final Widget? child;
  final bool fetch;

  Widget consumer(BuildContext context,TUser? user,Widget? child) => builder(context,user,child);

  @override
  Widget build(BuildContext context){
    return SfProviderEnhanced<SfUserState>(
      model: GetIt.instance<SfUserState>(),
      onModelReady: (vsync,model){
        if(this.user==null && this.userId!=null){
          model.queryUser(this.userId!,this.fetch);
        }
      },
      builder: (context,model,child) => consumer(context,this.user??model[this.userId!] as TUser,child),
      child: this.child,
    );
  }
}

class SfUserConsumerEx<TUser extends SfUser> extends SfUserConsumer<TUser>{
  SfUserConsumerEx({
    Key? key,
    String? userId,
    TUser? user,
    required ValueWidgetBuilder<TUser?> builder,
    Widget? child,
    bool fetch = false,
    this.onUserChanged
  }):super(key:key,userId:userId,user:user,builder:builder,child:child,fetch:fetch);
  final void Function(TUser? oldUser,TUser? newUser)? onUserChanged;

  Widget consumer(BuildContext context,TUser? user,Widget? child) => SfProvider<_SfUserConsumerExModel>(
    model: _SfUserConsumerExModel<TUser>(this,user),
    builder: (context,model,child) => super.consumer(context,user,child)
  );
}
class _SfUserConsumerExModel<TUser extends SfUser> extends SfViewState{
  _SfUserConsumerExModel(this.widget,this.user);
  SfUserConsumerEx<TUser> widget;
  TUser? user;

  @override
  Future initData() async {
    if(user!=null) widget.onUserChanged?.call(null,user);
  }
  @override
  void onRefactor(SfViewState newState){
    var model = newState as _SfUserConsumerExModel<TUser>;
    widget = model.widget;
    if(user != model.user){
      widget.onUserChanged?.call(user,model.user);
      user = model.user;
    }
  }
}