import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfProvider<T extends SfViewState> extends StatelessWidget{
  SfProvider({
    this.stateKey,
    required this.model,
    required this.builder,
    this.child,
    this.autoDispose = true,
  });
  final Key? stateKey;
  final T model;
  final ValueWidgetBuilder<T> builder;
  final Widget? child;
  final bool autoDispose;

  @override
  Widget build(_) => SfProviderEnhanced<T>(
    onModelReady: (vsync, model) => model.initDataVsync(vsync),
    onModelRefactor: (model, newModel) => model.onRefactor(newModel),
    key:stateKey,model:model,builder:builder,child:child,autoDispose:autoDispose,
  );
}

class SfProviderEnhanced<T extends SfViewState> extends StatefulWidget{
  SfProviderEnhanced({
    Key? key,
    required this.model,
    required this.builder,
    this.child,
    this.onModelReady,
    this.onModelRefactor,
    this.autoDispose = false,
  }) : super(key:key);
  final T model;
  final ValueWidgetBuilder<T> builder;
  final Widget? child;
  final Function(TickerProviderStateMixin vsync,T model)? onModelReady;
  final Function(T model,T newModel)? onModelRefactor;
  final bool autoDispose;

  @override
  SfProviderEnhancedState<T> createState() => SfProviderEnhancedState<T>();
}
class SfProviderEnhancedState<T extends SfViewState> extends State<SfProviderEnhanced<T>> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  late T model;

  @override
  void initState(){
    model = widget.model;
    widget.onModelReady?.call(this,model);
    super.initState();
  }
  @override
  void dispose(){
    if(widget.autoDispose) model.dispose();
    super.dispose();
  }
  @override
  void didUpdateWidget(oldWidget){
    super.didUpdateWidget(oldWidget);
    if(model!=widget.model) widget.onModelRefactor?.call(model,widget.model);
  }
  @override
  bool get wantKeepAlive => model.wantKeepAlive;

  @override
  Widget build(BuildContext context){
    super.build(context);
    updateKeepAlive();
    return ChangeNotifierProvider<T>.value(
      value: model,
      child: Consumer<T>(
        builder: widget.builder,
        child: widget.child
      ),
    );
  }
}