import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// ignore: implementation_imports
import 'package:flutter_cache_manager/src/compat/file_service_compat.dart';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';
import 'package:social_foundation/services/storage_manager.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation/utils/aliyun_oss.dart';
import 'package:social_foundation/utils/utils.dart';
import 'package:svgaplayer_flutter/svgaplayer_flutter.dart';

class SfCacheManager extends CacheManager with ImageCacheManager {
  factory SfCacheManager() {
    if (_instance == null) {
      _instance = new SfCacheManager._();
    }
    return _instance;
  }
  SfCacheManager._() : super(Config(key,fileService:FileServiceCompat(_fileFetcher)));

  static CachedNetworkImageProvider provder(String url) => CachedNetworkImageProvider(url,cacheManager:SfCacheManager());
  static const key = "libCachedImageData";
  static SfCacheManager _instance;

  Future<String> getFilePath() async {
    return GetIt.instance<SfStorageManager>().imageDirectory;
  }
  static Future<FileFetcherResponse> _fileFetcher(String url,{Map<String, String> headers}) async {
    var httpResponse = await http.get(Uri.parse(url), headers: headers);
    var encrypt = SfAliyunOss.getEncryptFromFileUrl(url);
    if(encrypt > 0){
      switch(encrypt){
        case 1:
          SfUtils.encrypt(httpResponse.bodyBytes);
          break;
        default:
          throw '不支持的加密方式!';
      }
    }
    return new HttpFileFetcherResponse(httpResponse);
  }
}

class SfCachedNetworkImage extends StatelessWidget{
  SfCachedNetworkImage({
    Key key,
    this.placeholder,
    this.errorWidget,
    @required this.imageUrl,
    this.imageBuilder,
    this.fadeOutDuration,
    this.fadeOutCurve,
    this.fadeInDuration,
    this.fadeInCurve,
    this.width,
    this.height,
    this.fit,
    this.alignment,
    this.repeat,
    this.matchTextDirection,
    this.httpHeaders,
    this.useOldImageOnUrlChange,
    this.color,
    this.filterQuality,
    this.colorBlendMode,
    this.placeholderFadeInDuration,
  }) : super(key:key);
  final Widget placeholder;
  final Widget errorWidget;
  final String imageUrl;
  final ImageWidgetBuilder imageBuilder;
  final Duration fadeOutDuration;
  final Curve fadeOutCurve;
  final Duration fadeInDuration;
  final Curve fadeInCurve;
  final double width;
  final double height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final bool matchTextDirection;
  final Map<String, String> httpHeaders;
  final bool useOldImageOnUrlChange;
  final Color color;
  final FilterQuality filterQuality;
  final BlendMode colorBlendMode;
  final Duration placeholderFadeInDuration;
  Widget buildPlaceholder(BuildContext context, String url){
    return placeholder ?? Container(
      width: 60,
      height: 60,
      color: Color.fromARGB(255,48,50,66),
      child: Icon(Icons.image,color:Color.fromRGBO(172,175,192,0.8))
    );
  }
  Widget buildProgressIndicator(BuildContext context, String url, DownloadProgress progress){
    return buildPlaceholder(context,url);
  }
  Widget buildError(BuildContext context, String url, dynamic error){
    return errorWidget ?? buildPlaceholder(context,url);
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: imageBuilder,
      progressIndicatorBuilder: buildProgressIndicator,
      errorWidget: buildError,
      fadeOutDuration: fadeOutDuration ?? Duration(milliseconds: 1000),
      fadeOutCurve: fadeOutCurve ?? Curves.easeOut,
      fadeInDuration: fadeInDuration ?? Duration(milliseconds: 500),
      fadeInCurve: fadeInCurve ?? Curves.easeIn,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment ?? Alignment.center,
      repeat: repeat ?? ImageRepeat.noRepeat,
      matchTextDirection: matchTextDirection ?? false,
      httpHeaders: httpHeaders,
      cacheManager: SfCacheManager(),
      useOldImageOnUrlChange: useOldImageOnUrlChange ?? false,
      color: color,
      filterQuality: filterQuality ?? FilterQuality.low,
      colorBlendMode: colorBlendMode,
      placeholderFadeInDuration: placeholderFadeInDuration,
    );
  }
}

class SfCachedImage extends StatelessWidget{
  SfCachedImage({
    Key key,
    this.imagePath,
    this.fit,
    this.alignment,
    this.imageBuilder,
    this.svgaPlayerKey
  }):super(key:key??ValueKey(imagePath));
  final String imagePath;
  final BoxFit fit;
  final Alignment alignment;
  final ValueWidgetBuilder<ImageProvider> imageBuilder;
  final Key svgaPlayerKey;

  Widget _imageBuilder(BuildContext context,ImageProvider image,Widget child) => Image(
    image: image,
    fit: fit,
    alignment: alignment ?? Alignment.center,
  );
  Widget buildImage(BuildContext context,_SfCachedImageModel model){
    switch(model.ext){
      case '.png':
      case '.gif':
      case '.jpg':
      case '.webp':
        return (imageBuilder??_imageBuilder).call(context,model.file!=null?FileImage(model.file):AssetImage(imagePath),null);
      case '.svga':
        return SVGASimpleImage(
          key: svgaPlayerKey,
          assetsName: model.file!=null ? null : imagePath,
          file: model.file,
        );
      default:
        return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context){
    return SfProvider<_SfCachedImageModel>(
      model: _SfCachedImageModel(this),
      builder: (context,model,child) => imagePath==null || model.network&&model.file==null ? SizedBox() : buildImage(context,model)
    );
  }
}
class _SfCachedImageModel extends SfViewState{
  _SfCachedImageModel(this.widget);
  SfCachedImage widget;
  String ext;
  bool network;
  File file;

  void reload() async {
    if(widget.imagePath != null){
      ext = SfFileHelper.getUrlExt(widget.imagePath);
      network = SfFileHelper.isUrl(widget.imagePath);
      if(network) file = await SfCacheManager().getSingleFile(widget.imagePath);
    }
    notifyListeners();
  }

  @override
  Future initData() async => reload();
  @override
  void onRefactor(newState){
    var model = newState as _SfCachedImageModel;
    if(widget.imagePath!=model.widget.imagePath) reload();
  }
}