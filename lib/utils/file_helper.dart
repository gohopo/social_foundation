class SfFileHelper{
  static String getFileName(String path){
    return path.substring(path.lastIndexOf('/')+1,path.length);
  }
}