import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/models/api_response.dart';

Future<ApiResponse> login(String username, String password) async {
  ApiResponse apiResponse = ApiResponse();
  if (username.isEmpty) {
    apiResponse.error = unauthorized;
    return apiResponse;
  }
  if (password.isEmpty) {
    apiResponse.error = unauthorized;
    return apiResponse;
  }

  /// Адрес подключения
  String connectionUrl = await getBaseUrl() + '/auth';

  String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));

  // Get data from server
  try {
    var dio = Dio();

    dio.options.headers[HttpHeaders.accessControlAllowOriginHeader] = '*';
    dio.options.headers[HttpHeaders.contentTypeHeader] = 'application/json';
    dio.options.headers[HttpHeaders.authorizationHeader] = basicAuth;
    dio.options.headers[HttpHeaders.wwwAuthenticateHeader] = basicAuth;

    final response = await dio.get(connectionUrl);

    switch (response.statusCode) {
      case 200:
        SharedPreferences pref = await SharedPreferences.getInstance();

        await pref.setString('settings_profileName', response.data['data'][0]['name']);
        await pref.setString('token', basicAuth);

        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } on DioError catch (e) {
    debugPrint(e.toString());

    switch (e.response?.statusCode) {
      case 401:
        apiResponse.error = unauthorized;
        break;
      case 406:
        apiResponse.error = serverAuthError;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  }
  return apiResponse;
}

// Get token
Future<String> getToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('token') ?? '';

  // String username = 'Администратор';
  // String password = 'jkloofege74';
  // String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
  // return basicAuth;
}

// logout
Future<bool> logout() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return await pref.remove('token');
}
