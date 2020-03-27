import 'package:flutter/widgets.dart';

class SfKeepAlive extends StatefulWidget{
  SfKeepAlive({
    Key key,
    this.child
  }) : super(key:key);
  final Widget child;

  @override
  SfKeepAliveState createState() => SfKeepAliveState();
}

class SfKeepAliveState extends State<SfKeepAlive> with AutomaticKeepAliveClientMixin{
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
  @override
  bool get wantKeepAlive => true;
}