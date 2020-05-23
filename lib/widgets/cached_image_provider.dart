import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cache_manager/src/compat/file_service_compat.dart';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';
import 'package:social_foundation/services/storage_manager.dart';
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