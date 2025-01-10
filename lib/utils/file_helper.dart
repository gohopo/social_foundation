import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:social_foundation/services/locator_manager.dart';
import 'package:social_foundation/widgets/cached_image_provider.dart';

class SfFileHelper{
  static bool isUrl(String path) => path.startsWith(RegExp(r'http[s]?://'));
  static bool isHttpsUrl(String url) => url.startsWith('https');
  static String getFileName(String path) => p.basename(path);
  static String getFileNameWithoutExt(String path) => p.basenameWithoutExtension(path);
  static String getFileExt(String path) => p.extension(path);
  static String getDirname(String path) => p.dirname(path);
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
  static Future saveFile(String filePath,{String? name,bool isReturnPathOfIOS=false}) async {
    var status = await SfLocatorManager.appState.getPermission(Permission.manageExternalStorage);
    if(!status.isGranted) throw '没有存储权限!';
    return ImageGallerySaver.saveFile(filePath,name:name,isReturnPathOfIOS:isReturnPathOfIOS);
  }
  static Future saveFileFromUrl(String url,{String? name,bool isReturnPathOfIOS=false}) async {
    var status = await SfLocatorManager.appState.getPermission(Permission.manageExternalStorage);
    if(!status.isGranted) throw '没有存储权限!';
    var file = await SfCacheManager().getSingleFile(url);
    return saveFile(file.path,name:name,isReturnPathOfIOS:isReturnPathOfIOS);
  }
}