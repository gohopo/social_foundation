import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_foundation/widgets/ticker_provider.dart';
import 'package:social_foundation/widgets/view_state.dart';

class SfProvider<T extends SfViewState> extends StatefulWidget{
  final T model;
  final ValueWidgetBuilder<T> builder;
  final Widget child;
  final Function(T model) onModelReady;
  final bool autoDispose;

  SfProvider({
    Key key,
    @required this.model,
    @required this.builder,
    this.child,
    this.onModelReady,
    this.autoDispose: true,
  }) : super(key: key);

  @override
  _SfProviderState<T> createState() => _SfProviderState<T>();
}
class _SfProviderState<T extends SfViewState> extends State<SfProvider<T>>{
  T model;

  @override
  void initState(){
    model = widget.model;
    widget.onModelReady?.call(model);
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

class SfProvider2<A extends ChangeNotifier,B extends ChangeNotifier> extends StatefulWidget{
  final A model1;
  final B model2;
  final Widget Function(BuildContext context, A model1, B model2, Widget child) builder;
  final Widget child;
  final Function(A model1,B model2) onModelReady;
  final bool autoDispose;

  SfProvider2({
    Key key,
    @required this.model1,
    @required this.model2,
    @required this.builder,
    this.child,
    this.onModelReady,
    this.autoDispose: true,
  }) : super(key: key);

  @override
  _SfProvider2State<A,B> createState() => _SfProvider2State<A,B>();
}
class _SfProvider2State<A extends ChangeNotifier,B extends ChangeNotifier> extends State<SfProvider2<A,B>>{
  A model1;
  B model2;

  @override
  void initState(){
    model1 = widget.model1;
    model2 = widget.model2;
    widget.onModelReady?.call(model1,model2);
    super.initState();
  }
  @override
  void dispose(){
    if(widget.autoDispose){
      model1.dispose();
      model2.dispose();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<A>.value(value: model1),
        ChangeNotifierProvider<B>.value(value: model2),
      ],
      child: Consumer2<A,B>(
        builder: widget.builder,
        child: widget.child
      )
    );
  }
}

class SfProviderEnhanced<T extends SfViewState> extends StatelessWidget{
  SfProviderEnhanced({
    Key key,
    @required this.model,
    @required this.builder,
    this.child,
    this.onModelReady,
    this.autoDispose: true,
  }) : super(key:key);
  final T model;
  final ValueWidgetBuilder<T> builder;
  final Widget child;
  final Function(TickerProviderStateMixin vsync,T model) onModelReady;
  final bool autoDispose;

  @override
  Widget build(BuildContext context) => SfProvider<T>(
    model: model,
    builder: (context,model,child) => SfTickerProvider(
      onReady: (vsync) => onModelReady?.call(vsync,model),
      builder: (context) => builder(context,model,child),
    ),
    child: child,
    autoDispose: autoDispose,
  );
}
class SfProviderEnhanced2<A extends ChangeNotifier,B extends ChangeNotifier> extends StatelessWidget{
  SfProviderEnhanced2({
    Key key,
    @required this.model1,
    @required this.model2,
    @required this.builder,
    this.child,
    this.onModelReady,
    this.autoDispose: true,
  }) : super(key:key);
  final A model1;
  final B model2;
  final Widget Function(BuildContext context, A model1, B model2, Widget child) builder;
  final Widget child;
  final Function(TickerProviderStateMixin vsync,A model1,B model2) onModelReady;
  final bool autoDispose;

  @override
  Widget build(BuildContext context) => SfProvider2<A,B>(
    model1: model1,
    model2: model2,
    builder: (context,model1,model2,child) => SfTickerProvider(
      onReady: (vsync) => onModelReady?.call(vsync,model1,model2),
      builder: (context) => builder(context,model1,model2,child),
    ),
    child: child,
    autoDispose: autoDispose,
  );
}