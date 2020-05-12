import 'package:flutter/material.dart';
import 'package:social_foundation/models/user.dart';
import 'package:social_foundation/utils/aliyun_oss.dart';
import 'package:social_foundation/widgets/cached_image_provider.dart';

class SfAvatar extends StatelessWidget{
  SfAvatar({
    Key key,
    @required this.user,
    this.width = 45,
    this.height = 45,
    this.onTap,
    this.borderRadius,
    this.defaultImage,
    this.fit = BoxFit.cover,
    this.builder
  }) : super(key:key);
  final SfUser user;
  final double width;
  final double height;
  final VoidCallback onTap;
  final BorderRadiusGeometry borderRadius;
  final ImageProvider defaultImage;
  final BoxFit fit;
  final Widget Function(BuildContext context,SfAvatar avatar,ImageProvider image) builder;

  onTapOverride(){
    onTap?.call();
  }
  Widget buildImage(BuildContext context){
    return builder!=null ? builder(context,this,buildImageProvider()) : Image(
      width: width,
      height: height,
      image: buildImageProvider(),
      fit: this.fit
    );
  }
  ImageProvider buildImageProvider(){
    return user?.icon!=null ? SfCacheManager.provder(SfAliyunOss.getImageUrl(user?.icon)) : defaultImage;
  }

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: onTapOverride,
      child: borderRadius==null ? ClipOval(
        child: buildImage(context),
      ) : ClipRRect(
        borderRadius: borderRadius,
        child: buildImage(context)
      ),
    );
  }
}