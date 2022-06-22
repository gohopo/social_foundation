import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

class SfRequestManager{
  SfRequestManager(BaseOptions options):dio=Dio(options);
  Dio dio;

  Future<dynamic> invokeFunction(String controller,String function,Map body) async {
    try{
      var path = controller.isNotEmpty ? p.join(controller,function) : function;
      var response = await dio.post(path,data: body);
      return response.data;
    }
    catch(e){
      if(e is DioError){
        if(e.response==null) throw '网络异常';
        throw e.response?.data['errorMessage'];
      }
    }
  }
}