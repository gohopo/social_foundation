import 'package:path/path.dart' as p;

class SfFileHelper{
  static bool isUrl(String path) => path.startsWith(RegExp(r'http[s]?://'));
  static String getFileName(String path) => p.basename(path);
  static String getFileNameWithoutExt(String path) => p.basenameWithoutExtension(path);
  static String getFileExt(String path) => p.extension(path);
  static String getUrlWithoutQueries(String url){
    var index = url.lastIndexOf('?');
    if(index != -1){
      url = url.substring(0,index);
    }
    return url;
  }
  static String getUrlName(String url) => getFileName(getUrlWithoutQueries(url));
  static String getUrlNameWithoutExt(String url) => getFileNameWithoutExt(getUrlWithoutQueries(url));
  static String getUrlExt(String url) => getFileExt(getUrlWithoutQueries(url));
}