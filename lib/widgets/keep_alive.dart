import 'package:flutter/widgets.dart';

class SfKeepAlive extends StatefulWidget{
  SfKeepAlive({
    Key? key,
    required this.child,
    this.wantKeepAlive = true
  }) : super(key:key);
  final Widget child;
  final bool wantKeepAlive;

  @override
  _SfKeepAliveState createState() => _SfKeepAliveState();
}

class _SfKeepAliveState extends State<SfKeepAlive> with AutomaticKeepAliveClientMixin{
  @override
  void didUpdateWidget(oldWidget){
    if(oldWidget.wantKeepAlive!=widget.wantKeepAlive) updateKeepAlive();
    super.didUpdateWidget(oldWidget);
  }
  @override
  bool get wantKeepAlive => widget.wantKeepAlive;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}