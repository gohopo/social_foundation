import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef SfSliverStickyBuilder = Widget Function(BuildContext context, double shrinkOffset, bool overlapsContent);

class SfSliverStickyDelegate extends SliverPersistentHeaderDelegate{
  SfSliverStickyDelegate({
    required this.collapsedHeight,
    required this.expandedHeight,
    required this.builder
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
    required this.height
  });
  SfSliverStickyDelegateBuilder.preferredSize({
    required PreferredSizeWidget child
  }):this(child:child,height:child.preferredSize.height);
  final Widget? child;
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
    this.actions = const [],
    this.actionsBuilder,
    this.background,
    this.barBackgroundColor = Colors.white,
    this.collapsedBrightness = Brightness.dark,
    this.collapsedHeight = 32,
    this.collapsedIconColor = Colors.white,
    this.collapsedTextColor = Colors.transparent,
    this.expandedBrightness = Brightness.light,
    required this.expandedHeight,
    this.expandedColor = Colors.black,
    this.goBackBuilder,
    this.iconSize = 20,
    this.shrinkOffsetThreshold = 50,
    this.paddingTop = 0,
    this.title,
    this.titleBuilder,
  });
  final List<Widget> actions;
  final List<Widget> Function(SfSliverStickyAppBarDelegate delegate,BuildContext context,double shrinkOffset,bool overlapsContent)? actionsBuilder;
  final Widget? background;
  final Color barBackgroundColor;
  final Brightness collapsedBrightness;
  final double collapsedHeight;
  final Color collapsedIconColor;
  final Color collapsedTextColor;
  final Brightness expandedBrightness;
  final Color expandedColor;
  final double expandedHeight;
  final Widget Function(SfSliverStickyAppBarDelegate delegate,BuildContext context,double shrinkOffset,bool overlapsContent)? goBackBuilder;
  final double iconSize;
  final double shrinkOffsetThreshold;
  final double paddingTop;
  final String? title;
  final Widget Function(SfSliverStickyAppBarDelegate delegate,BuildContext context,double shrinkOffset,bool overlapsContent)? titleBuilder;
  Brightness? statusBarBrightness;
  @override
  double get maxExtent => expandedHeight;
  @override
  double get minExtent => collapsedHeight + paddingTop;
  @override
  Widget build(BuildContext context,double shrinkOffset,bool overlapsContent){
    this.updateStatusBarBrightness(shrinkOffset);
    return SizedBox(
      width:MediaQuery.of(context).size.width,height:expandedHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if(background!=null) background!,
          Positioned(
            left:0,top:0,right:0,
            child: Container(
              padding: EdgeInsets.only(top:paddingTop),
              color: getBarBackgroundColor(shrinkOffset),
              child: SizedBox(
                height: collapsedHeight,
                child: buildBar(context,shrinkOffset,overlapsContent)
              )
            )
          )
        ],
      ),
    );
  }
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
  Widget buildBar(BuildContext context,double shrinkOffset,bool overlapsContent) => IconTheme(
    data: IconThemeData(color:getIconColor(shrinkOffset),size:iconSize),
    child: Row(
      children: [
        if(Navigator.canPop(context)) Padding(
          padding: EdgeInsets.only(left:15),
          child: buildGoBackButton(context,shrinkOffset,overlapsContent),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal:10),
            child: buildTitle(context,shrinkOffset,overlapsContent),
          )
        ),
        Padding(
          padding: EdgeInsets.only(right:15),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: buildActions(context,shrinkOffset,overlapsContent),
          ),
        )
      ],
    )
  );
  Widget buildGoBackButton(BuildContext context,double shrinkOffset,bool overlapsContent) => GestureDetector(
    onTap: () => Navigator.pop(context),
    child: goBackBuilder?.call(this,context,shrinkOffset,overlapsContent) ?? Icon(Icons.arrow_back_ios,size:iconSize),
  );
  Widget buildTitle(BuildContext context,double shrinkOffset,bool overlapsContent) => titleBuilder?.call(this,context,shrinkOffset,overlapsContent) ?? Text(title??'',style:TextStyle(fontSize:iconSize,fontWeight:FontWeight.w500,color:getTextColor(shrinkOffset)));
  List<Widget> buildActions(BuildContext context,double shrinkOffset,bool overlapsContent) => actionsBuilder?.call(this,context,shrinkOffset,overlapsContent) ?? actions;
  double getOpacity(double shrinkOffset) => shrinkOffset / (this.maxExtent - this.minExtent);
  Color getBarBackgroundColor(double shrinkOffset) => barBackgroundColor.withOpacity(getOpacity(shrinkOffset));
  Color getIconColor(double shrinkOffset) => shrinkOffset<=shrinkOffsetThreshold ? collapsedIconColor : expandedColor.withOpacity(getOpacity(shrinkOffset));
  Color getTextColor(double shrinkOffset) => shrinkOffset<=shrinkOffsetThreshold ? collapsedTextColor : expandedColor.withOpacity(getOpacity(shrinkOffset));
  void updateStatusBarBrightness(double shrinkOffset){
    if(shrinkOffset<=collapsedHeight && statusBarBrightness!=collapsedBrightness) {
      statusBarBrightness = collapsedBrightness;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarBrightness:collapsedBrightness,statusBarIconBrightness:collapsedBrightness));
    }
    else if(shrinkOffset>collapsedHeight && statusBarBrightness!=expandedBrightness) {
      statusBarBrightness = expandedBrightness;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarBrightness:expandedBrightness,statusBarIconBrightness:expandedBrightness));
    }
  }
}