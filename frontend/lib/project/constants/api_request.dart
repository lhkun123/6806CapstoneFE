import 'dart:convert';
import 'package:dio/dio.dart';
class ApiRequest{
  final Dio dio=Dio();
  Future<Response> getRequest(Map<String,dynamic> query) async {
        final response =await dio.get(
            query["url"],
            queryParameters: query["parameters"],
            options: Options(headers: {
              "Content-Type": "application/json",
              "Authorization": query["token"],
            })
        );
        return response;
  }

  Future<Response> postRequest(Map<String,dynamic> query) async {
    final response =await dio.post(
        query["url"],
        options: Options(headers: {
        "Content-Type": "application/json",
          "Authorization": query["token"],
        }),
        data: jsonEncode(query["body"]),
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
  Future<Response> deleteRequest(Map<String,dynamic> query) async {
    final response =await dio.delete(
        query["url"],
        queryParameters: query["parameters"],
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": query["token"],
        })
    );
    return response;
  }



}