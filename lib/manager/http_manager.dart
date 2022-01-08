import 'dart:async';

import 'package:dio/dio.dart';

/// 请求管理
class HttpManager {
  static HttpManager? _instance;

  static HttpManager get instance => _getInstance();

  static const String METHOD_GET = "get";
  static const String METHOD_POST = "post";
  static const String METHOD_DELETE = "delete";
  static const String METHOD_PUT = "put";

  //网络请求
  static late Dio _httpClient;

  ///暴露给外部的网络请求变量
  Dio get httpClient => _httpClient;

  int httpTimeout = 12000;

  HttpManager() {
    _httpClient = Dio();
    _httpClient.options
      ..connectTimeout = httpTimeout
      ..receiveTimeout = httpTimeout
      ..headers = {
        "Connection": "keep-alive",
        'Accept': '*/*',
        'Accept-Encoding': 'gzip, deflate, br'
      };
  }

  static HttpManager _getInstance() {
    _instance ??= HttpManager();
    return _instance!;
  }

  /// get请求
  /// 通用参数描述:
  /// [url]:请求地址
  /// [params]: FormData类型数据(get请求将自动转换成urlEncode)
  /// [data]: RequestBody类型数据
  /// [headers]: 请求头
  /// [method]: 请求方法
  Future<Response?> getRequest(String url,
      {Map<String, dynamic>? params,
      Map<String, dynamic>? headers,
      dynamic data,
      String method = METHOD_GET}) async {
    Response<dynamic>? result = await _request(url, method,
        params: params, headers: headers, data: data);
    return result;
  }

  ///基础请求
  Future<Response?> _request(String url, String method,
      {Map<String, dynamic>? params,
      Map<String, dynamic>? headers,
      dynamic data}) async {
    Response? response;
    try {
      if (headers != null) _httpClient.options.headers = headers;
      switch (method) {
        case METHOD_GET:
          if (params != null && params.isNotEmpty) {
            StringBuffer sb = new StringBuffer("?");
            params.forEach(
                (key, value) => sb.write("$key" + "=" + "$value" + "&"));
            url += sb.toString().substring(0, sb.toString().length - 1);
          }
          response = await _httpClient.get(url);
          break;
        case METHOD_POST:
          if (params != null && params.isNotEmpty)
            response = await _httpClient.post(url, queryParameters: params);
          else if (data != null)
            response = await _httpClient.post(url, data: data);
          else
            response = await _httpClient.post(url);
          break;
        case METHOD_DELETE:
          if (params != null && params.isNotEmpty)
            response = await _httpClient.delete(url, queryParameters: params);
          else if (data != null)
            response = await _httpClient.delete(url, data: data);
          else
            response = await _httpClient.delete(url);
          break;
        case METHOD_PUT:
          if (params != null && params.isNotEmpty)
            response = await _httpClient.put(url, queryParameters: params);
          else if (data != null)
            response = await _httpClient.put(url, data: data);
          else
            response = await _httpClient.put(url);
          break;
      }
    } on DioError catch (e) {}
    return response;
  }
}
