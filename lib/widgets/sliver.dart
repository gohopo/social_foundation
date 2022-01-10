import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef SfSliverStickyBuilder = Widget Function(BuildContext context, double shrinkOffset, bool overlapsContent);

class SfSliverStickyDelegate extends SliverPersistentHeaderDelegate{
  SfSliverStickyDelegate({
    this.collapsedHeight,
    this.expandedHeight,
    this.builder
  });
  final double collapsedHeight;
  final double expandedHeight;
  final SfSliverStickyBuilder builder;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => builder(context,shrinkOffset,overlapsContent);
  @override
  double get maxExtent => expandedHeight;
  @override
  double get minExtent => collapsedHeight;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

class SfSliverStickyDelegateBuilder{
  SfSliverStickyDelegateBuilder({
    this.child,
    this.height
  });
  SfSliverStickyDelegateBuilder.preferredSize({
    PreferredSizeWidget child
  }):this(child:child,height:child.preferredSize.height);
  final Widget child;
  final double height;

  SfSliverStickyDelegate build() => SfSliverStickyDelegate(
    collapsedHeight: height,
    expandedHeight: height,
    builder: (context,shrinkOffset,overlapsContent) => SizedBox(
      height:height,child:child
    ),
  );
}

class SfSliverStickyAppBarDelegate extends SliverPersistentHeaderDelegate{
  SfSliverStickyAppBarDelegate({
    this.collapsedHeight = 32,
    this.expandedHeight,
    this.paddingTop = 0,
    this.background,
    this.titleBuilder,
    this.title,
    this.actionProvider,
    this.actions = const [],
    this.iconSize = 20
  });
  final double collapsedHeight;
  final double expandedHeight;
  final double paddingTop;
  final Widget background;
  final Widget Function(BuildContext context,SfSliverStickyAppBarDelegate delegate) titleBuilder;
  final String title;
  final Widget Function(BuildContext context,SfSliverStickyAppBarDelegate delegate) actionProvider;
  final List<Widget> actions;
  final double iconSize;
  double shrinkOffset;
  bool overlapsContent;
  String statusBarMode = 'dark';
  Color textColor;
  Color iconColor;

  void updateStatusBarBrightness(){
    if(shrinkOffset<=collapsedHeight && this.statusBarMode=='dark') {
      this.statusBarMode = 'light';
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ));
    }
    else if(shrinkOffset>collapsedHeight && this.statusBarMode=='light') {
      this.statusBarMode = 'dark';
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ));
    }
  }
  Color makeBarBackgroundColor(){
    final int alpha = (shrinkOffset / (this.maxExtent - this.minExtent) * 255).clamp(0, 255).toInt();
    return Color.fromARGB(alpha, 255, 255, 255);
  }
  void updateBarTextColor(){
    if(shrinkOffset <= 50){
      textColor = Colors.transparent;
      iconColor = Colors.white;
    }
    else{
      final int alpha = (shrinkOffset / (this.maxExtent - this.minExtent) * 255).clamp(0, 255).toInt();
      textColor = iconColor = Color.fromARGB(alpha, 0, 0, 0);
    }
  }
  Widget buildBar(BuildContext context) => IconTheme(
    data: IconThemeData(color:iconColor,size:iconSize),
    child: Row(
      children: [
        if(Navigator.canPop(context)) Padding(
          padding: EdgeInsets.only(left:15),
          child: buildGoBackButton(context),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal:10),
            child: title!=null ? buildTitle(context) : null,
          )
        ),
        Padding(
        padding: EdgeInsets.only(right:15),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: buildActionList(context),
          ),
        )
      ],
    )
  );
  Widget buildGoBackButton(BuildContext context) => GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Icon(Icons.arrow_back_ios,size:iconSize),
  );
  Widget buildTitle(BuildContext context) => titleBuilder!=null ? titleBuilder(context,this) : Text(title,style:TextStyle(fontSize:iconSize,fontWeight:FontWeight.w500,color:textColor));
  List<Widget> buildActionList(BuildContext context) => actionProvider!=null ? actionProvider(context,this) : actions;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent){
    this.shrinkOffset = shrinkOffset;
    this.overlapsContent = overlapsContent;
    this.updateStatusBarBrightness();
    this.updateBarTextColor();
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: expandedHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if(background!=null) background,
          Positioned(
            left:0,top:0,right:0,
            child: Container(
              padding: EdgeInsets.only(top:paddingTop),
              color: makeBarBackgroundColor(),
              child: SizedBox(
                height: collapsedHeight,
                child: buildBar(context)
              )
            )
          )
        ],
      ),
    );
  }
  @override
  double get maxExtent => expandedHeight;
  @override
  double get minExtent => collapsedHeight + paddingTop;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}