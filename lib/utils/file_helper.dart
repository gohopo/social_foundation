import 'package:path/path.dart' as p;

class SfFileHelper{
  static String getFileName(String path) => p.basename(path);
  static String getFileNameWithoutExt(String path) => p.basenameWithoutExtension(path);
  static String getFileExt(String path) => p.extension(path);
}