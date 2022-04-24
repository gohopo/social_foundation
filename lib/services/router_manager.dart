import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:social_foundation/pages/photo_viewer.dart';
import 'package:social_foundation/utils/aliyun_oss.dart';
import 'package:social_foundation/widgets/cached_image_provider.dart';
import 'package:social_foundation/widgets/page_route.dart';

class SfRouteName {
  static const String photo_viewer = 'photo_viewer';
}

class SfRouterManager extends NavigatorObserver{
  void showPhotoViewer({List<ImageProvider> images,int index,String heroPrefix,PageController controller,bool canSave,SfLoadStateChanged loadStateChanged}) => navigator.pushNamed(SfRouteName.photo_viewer,arguments:{
    'images':images,'index':index,'heroPrefix':heroPrefix,'controller':controller,
    'canSave':canSave,'loadStateChanged':loadStateChanged
  });
  void showPhotoViewer2({List<String> imageKeys,int index,String heroPrefix,PageController controller,bool canSave,SfLoadStateChanged loadStateChanged}) => showPhotoViewer(
    images:imageKeys.map((fileKey) => SfCacheManager.provider(SfAliyunOss.getImageUrl(fileKey))).toList(),
    index:index,heroPrefix:heroPrefix,controller:controller,canSave:canSave,
    loadStateChanged:(index,state) => state.extendedImageLoadState==LoadState.completed ? null : Center(
      child: SfCachedImage(
        imagePath: SfAliyunOss.getImageUrl(imageKeys[index],width:500,height:500),
        fit: BoxFit.cover,
      )
    )
  );

  void didPop(Route route, Route previousRoute) {
    super.didPush(route, previousRoute);
    final focus = FocusManager.instance.primaryFocus;
    focus?.unfocus();
  }
  Route<dynamic> generateRoute(RouteSettings settings){
    switch (settings.name) {
      case SfRouteName.photo_viewer:
        return SfFadeRoute(SfPhotoGalleryViewer(settings.arguments));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}')
            )
          )
        );
    }
  }
}