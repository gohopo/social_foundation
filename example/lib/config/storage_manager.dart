import 'dart:io';

import 'package:path_provider/path_provider.dart';

class StorageManager {
  static Directory temporaryDirectory;
  static init() async {
    temporaryDirectory = await getTemporaryDirectory();
  }
}

class DatabaseManager {
  
}