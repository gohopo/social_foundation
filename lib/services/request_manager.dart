import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

class SfRequestManager{
  SfRequestManager(BaseOptions options) : _dio=Dio(options);
  Dio _dio;

  Future<dynamic> invokeFunction(String controller,String function,Map body) async {
    try{
      var path = controller.isNotEmpty ? p.join(controller,function) : function;
      var response = await _dio.post(path,data: body);
      return response.data;
    }
    catch(e){
      if(e.response==null) throw '网络异常';
      throw e.response.data['errorMessage'];
    }
  }
}