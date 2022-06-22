import 'package:flutter/material.dart';

class SfTickerProvider extends StatefulWidget{
  const SfTickerProvider({
    Key? key,
    required this.onReady,
    required this.builder,
  }) : super(key: key);
  final ValueSetter<TickerProviderStateMixin> onReady;
  final WidgetBuilder builder;

  @override
  _SfTickerProviderState createState() => _SfTickerProviderState();
}

class _SfTickerProviderState extends State<SfTickerProvider> with TickerProviderStateMixin{
  @override
  void initState(){
    widget.onReady.call(this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) => widget.builder(context);
}