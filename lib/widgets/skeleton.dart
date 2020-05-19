import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_foundation/social_foundation.dart';

class SfSkeletonList extends StatelessWidget{
  SfSkeletonList({
    this.length = 7,
    this.padding = const EdgeInsets.all(7),
    @required this.builder
  });
  final int length;
  final EdgeInsetsGeometry padding;
  final IndexedWidgetBuilder builder;

  @override
  Widget build(BuildContext context){
    var theme = Theme.of(context);
    bool isDark = theme.brightness == Brightness.dark;
    return Shimmer.fromColors(
      period: Duration(milliseconds:1200),
      baseColor: isDark ? Colors.grey[700] : Colors.grey[350],
      highlightColor: isDark ? Colors.grey[500] : Colors.grey[200],
      child: ListView.builder(
        padding: padding,
        physics: NeverScrollableScrollPhysics(),
        itemCount: length,
        itemBuilder: builder,
      )
    );
  }
}

class SfSkeletonDecoration extends BoxDecoration{
  SfSkeletonDecoration({
    isCircle = false,
    isDark = false,
  }) : super(
    color: !isDark ? Colors.grey[350] : Colors.grey[700],
    shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
  );
}

class SfSkeletonItem extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    var width = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      decoration: BoxDecoration(
        border: Border(
          bottom: Divider.createBorderSide(
            context,
            width: 0.7,color:Colors.redAccent
          )
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 20,
                width: 20,
                decoration: SfSkeletonDecoration(isCircle: true, isDark: isDark),
              ),
              Container(
                margin: EdgeInsets.only(left: 10),
                height: 5,
                width: 100,
                decoration: SfSkeletonDecoration(isDark: isDark),
              ),
              Expanded(child: SizedBox.shrink()),
              Container(
                height: 5,
                width: 30,
                decoration: SfSkeletonDecoration(isDark: isDark),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Container(
                height: 6.5,
                width: width * 0.7,
                decoration: SfSkeletonDecoration(isDark: isDark),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 6.5,
                width: width * 0.8,
                decoration: SfSkeletonDecoration(isDark: isDark),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 6.5,
                width: width * 0.5,
                decoration: SfSkeletonDecoration(isDark: isDark),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10),
                height: 8,
                width: 20,
                decoration: SfSkeletonDecoration(isDark: isDark),
              ),
              Container(
                height: 8,
                width: 80,
                decoration: SfSkeletonDecoration(isDark: isDark),
              ),
              Expanded(child: SizedBox.shrink()),
              Container(
                height: 20,
                width: 20,
                decoration: SfSkeletonDecoration(isDark: isDark),
              ),
            ],
          ),
        ],
      )
    );
  }
}

class SfEasySkeletonList extends StatelessWidget{
  SfEasySkeletonList({
    this.length = 7,
    this.padding = const EdgeInsets.all(7),
  });
  final int length;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SfSkeletonList(
      length: length,
      padding: padding,
      builder: (context,index) => SfSkeletonItem(),
    );
  }
}