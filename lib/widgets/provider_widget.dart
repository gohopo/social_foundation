import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfProvider<T extends SfViewState> extends StatelessWidget{
  SfProvider({
    this.key,
    @required this.model,
    @required this.builder,
    this.child,
    this.autoDispose = true,
  });
  final Key key;
  final T model;
  final ValueWidgetBuilder<T> builder;
  final Widget child;
  final bool autoDispose;

  @override
  Widget build(BuildContext context) {
    return SfProviderEnhanced<T>(
      onModelReady: (vsync, model) => model.initDataVsync(vsync),
      key:key,model:model,builder:builder,autoDispose:autoDispose,
    );
  }
}

class SfProviderEnhanced<T extends SfViewState> extends StatefulWidget{
  SfProviderEnhanced({
    Key key,
    @required this.model,
    @required this.builder,
    this.child,
    this.onModelReady,
    this.autoDispose = false,
  }) : super(key:key);
  final T model;
  final ValueWidgetBuilder<T> builder;
  final Widget child;
  final Function(TickerProviderStateMixin vsync,T model) onModelReady;
  final bool autoDispose;

  @override
  _SfProviderEnhancedState<T> createState() => _SfProviderEnhancedState<T>();
}
class _SfProviderEnhancedState<T extends SfViewState> extends State<SfProviderEnhanced<T>> with TickerProviderStateMixin{
  T model;

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
  Widget build(BuildContext context){
    return ChangeNotifierProvider<T>.value(
      value: model,
      child: Consumer<T>(
        builder: widget.builder,
        child: widget.child
      ),
    );
  }
}