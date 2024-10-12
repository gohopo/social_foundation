import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

class SfRequestManager{
  SfRequestManager(BaseOptions options):dio=Dio(options);
  Dio dio;
  Future invokeFunction(String controller,String function,Map? body) => requestFunction(
    'POST',controller,function,data:body
  );
  Future<T?> fetch<T>(RequestOptions requestOptions) async {
    try{
      var response = await dio.fetch<T>(requestOptions);
      return response.data;
    }
    catch(error){
      onError(error);
    }
    return null;
  }
  Future<T?> request<T>(Options options,String path,{data,Map<String, dynamic>? queryParameters}) => fetch(options.compose(
    dio.options,path,data:data,queryParameters:queryParameters));
  Future<T?> requestMethod<T>(String method,String path,{data,Map<String, dynamic>? queryParameters}) => request<T>(
    Options(method:method),path,data:data,queryParameters:queryParameters
  );
  Future<T?> requestFunction<T>(String method,String controller,String function,{data,Map<String, dynamic>? queryParameters}){
    var path = controller.isNotEmpty ? p.join(controller,function) : function;
    return requestMethod<T>(method,path,data:data,queryParameters:queryParameters);
  }
  void onError(Object error){
    if(error is DioException){
      if(error.response==null) throw '网络异常';
      throw error.response?.data['errorMessage'];
    }
  }
}