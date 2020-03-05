import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';
import 'package:social_foundation/services/storage_manager.dart';
import 'package:social_foundation/utils/aliyun_oss.dart';

class SfCachedImageProvider extends CachedNetworkImageProvider{
  SfCachedImageProvider(String url) : super(url,cacheManager:SfCacheManager());
}

class SfCacheManager extends BaseCacheManager {
  factory SfCacheManager() {
    if (_instance == null) {
      _instance = new SfCacheManager._();
    }
    return _instance;
  }
  SfCacheManager._() : super(key,fileFetcher:_fileFetcher);

  static const key = "libCachedImageData";
  static SfCacheManager _instance;

  Future<String> getFilePath() {
    return GetIt.instance<SfStorageManager>().getImageDirectory();
  }
  static Future<FileFetcherResponse> _fileFetcher(String url,{Map<String, String> headers}) async {
    var httpResponse = await http.get(url, headers: headers);
    var encrypt = SfAliyunOss.isEncryptFile(url);
    if(encrypt == 1){
      httpResponse.bodyBytes.replaceRange(0, httpResponse.bodyBytes.length, base64Decode(httpResponse.body));
    }
    else if(encrypt > 0){
      throw '不支持的加密方式!';
    }
    return new HttpFileFetcherResponse(httpResponse);
  }
}