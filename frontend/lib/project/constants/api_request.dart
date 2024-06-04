import 'package:dio/dio.dart';
class ApiRequest{
  final Dio dio=Dio();

  Future<Response> getRequest(Map<String,dynamic> query) async {
        final response =await dio.get(
            query["url"],
            queryParameters: query["parameters"],
            options: Options(headers: {
              "Content-Type": "application/json",
              "Authorization":
              query["token"],
            })

        );
        return response;
  }

  Future<Response> postRequest(Map<String,dynamic> query) async {
    final response =await dio.post(
        query["url"],
        queryParameters: query["parameters"]
    );
    return response;
  }
  Future<Response> putRequest(Map<String,dynamic> query) async {
    final response =await dio.put(
        query["url"],
        queryParameters: query["parameters"]
    );
    return response;
  }



}