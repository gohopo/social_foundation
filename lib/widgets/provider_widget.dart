import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
export 'package:provider/provider.dart';

class SfProviderWidget<T extends ChangeNotifier> extends StatefulWidget {
  final T model;
  final ValueWidgetBuilder<T> builder;
  final Widget child;
  final Function(T model) onModelReady;
  final bool autoDispose;

  SfProviderWidget({
    Key key,
    @required this.model,
    @required this.builder,
    this.child,
    this.onModelReady,
    this.autoDispose: true,
  }) : super(key: key);

  @override
  _SfProviderWidgetState<T> createState() => _SfProviderWidgetState<T>();
}

class _SfProviderWidgetState<T extends ChangeNotifier> extends State<SfProviderWidget<T>> {
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

class SfProviderWidget2<A extends ChangeNotifier,B extends ChangeNotifier> extends StatefulWidget {
  final A model1;
  final B model2;
  final Widget Function(BuildContext context, A model1, B model2, Widget child) builder;
  final Widget child;
  final Function(A model1,B model2) onModelReady;
  final bool autoDispose;

  SfProviderWidget2({
    Key key,
    @required this.model1,
    @required this.model2,
    @required this.builder,
    this.child,
    this.onModelReady,
    this.autoDispose: true,
  }) : super(key: key);

  @override
  _SfProviderWidget2State<A,B> createState() => _SfProviderWidget2State<A,B>();
}

class _SfProviderWidget2State<A extends ChangeNotifier,B extends ChangeNotifier> extends State<SfProviderWidget2<A,B>> {
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