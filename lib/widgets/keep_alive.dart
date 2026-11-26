import 'package:flutter/widgets.dart';

class SfKeepAlive extends StatefulWidget{
  const SfKeepAlive({
    super.key,
    required this.child,
    this.wantKeepAlive = true
  });
  final Widget child;
  final bool wantKeepAlive;

  @override
  SfKeepAliveState createState() => SfKeepAliveState();
}

class SfKeepAliveState extends State<SfKeepAlive> with AutomaticKeepAliveClientMixin{
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