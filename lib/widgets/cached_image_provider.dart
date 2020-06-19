import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cache_manager/src/compat/file_service_compat.dart';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';
import 'package:social_foundation/services/storage_manager.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation/utils/aliyun_oss.dart';
import 'package:social_foundation/utils/utils.dart';

class SfCacheManager extends BaseCacheManager {
  factory SfCacheManager() {
    if (_instance == null) {
      _instance = new SfCacheManager._();
    }
    return _instance;
  }
  SfCacheManager._() : super(key,fileService:FileServiceCompat(_fileFetcher));

  static CachedNetworkImageProvider provder(String url) => CachedNetworkImageProvider(url,cacheManager:SfCacheManager());
  static const key = "libCachedImageData";
  static SfCacheManager _instance;

  Future<String> getFilePath() async {
    return GetIt.instance<SfStorageManager>().imageDirectory;
  }
  static Future<FileFetcherResponse> _fileFetcher(String url,{Map<String, String> headers}) async {
    var httpResponse = await http.get(url, headers: headers);
    var encrypt = SfAliyunOss.isEncryptFileUrl(url);
    if(encrypt == 1){
      SfUtils.encrypt(httpResponse.bodyBytes);
    }
    else if(encrypt > 0){
      throw '不支持的加密方式!';
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
      placeholder: buildPlaceholder,
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