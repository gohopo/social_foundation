import 'package:flutter/material.dart';
import 'package:social_foundation/models/user.dart';
import 'package:social_foundation/utils/aliyun_oss.dart';
import 'package:social_foundation/widgets/cached_image_provider.dart';

typedef SfAvatarBuilder<T extends SfAvatar> = Widget Function(BuildContext context,T avatar,ImageProvider image);
class SfAvatar extends StatelessWidget{
  SfAvatar({
    Key? key,
    required this.user,
    this.width = 45,
    this.height = 45,
    this.onTap,
    this.border,
    this.borderRadius,
    this.defaultImage,
    this.defaultFemaleImage,
    this.fit = BoxFit.cover,
    this.builder,
    this.imageLongSide = 200
  }) : super(key:key);
  final SfUser? user;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final BoxBorder? border;
  final BorderRadius? borderRadius;
  final ImageProvider? defaultImage;
  final ImageProvider? defaultFemaleImage;
  final BoxFit fit;
  final SfAvatarBuilder<SfAvatar>? builder;
  final int imageLongSide;

  ImageProvider get imageProvider{
    return user?.icon!=null ? SfCacheManager.provider(SfAliyunOss.getImageUrl(user!.icon!,long:imageLongSide)) : (user?.gender==2?defaultFemaleImage:defaultImage)!;
  }
  onTapOverride(){
    onTap?.call();
  }
  Widget buildDecoration(BuildContext context,Widget child){
    return border!=null ? Container(
      decoration: BoxDecoration(
        border: border,
        borderRadius: borderRadius??BorderRadius.circular((width??height??0)/2),
      ),
      child: child
    ) : child;
  }
  Widget buildClip(BuildContext context,Widget child){
    return borderRadius!=null ? ClipRRect(
      borderRadius: borderRadius,
      child: child
    ) : ClipOval(
      child: child,
    );
  }
  Widget buildImage(BuildContext context){
    return builder!=null ? builder!(context,this,imageProvider) : Image(
      width: width,
      height: height,
      image: imageProvider,
      fit: this.fit
    );
  }
  

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: onTapOverride,
      child: buildDecoration(
        context,
        buildClip(
          context,
          buildImage(context)
        )
      )
    );
  }
}