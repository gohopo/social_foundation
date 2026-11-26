import 'package:flutter/material.dart';

class SfTickerProvider extends StatefulWidget{
  const SfTickerProvider({
    super.key,
    required this.onReady,
    required this.builder,
  });
  final ValueSetter<TickerProviderStateMixin> onReady;
  final WidgetBuilder builder;

  @override
  SfTickerProviderState createState() => SfTickerProviderState();
}

class SfTickerProviderState extends State<SfTickerProvider> with TickerProviderStateMixin{
  @override
  void initState(){
    widget.onReady.call(this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) => widget.builder(context);
}