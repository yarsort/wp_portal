
import 'dart:io';
import 'package:flutter/cupertino.dart'; // show messages
import 'package:dio/dio.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/models/ref_warehouse.dart';

// Get all available partners
Future<ApiResponse> getWarehouses() async {
  ApiResponse apiResponse = ApiResponse();

  /// Адрес подключения: отправка!!!
  final connectionUrl = await getBaseUrl() + '/warehouses';

  /// Authorization
  String basicAuth = await getToken();
  if (basicAuth == ''){
    apiResponse.error = unauthorized;
    return apiResponse;
  }

  /// Get data from server
  try {

    var dio = Dio();
    final response = await dio.get(connectionUrl,
        options: Options(headers: {
          'Access-Control-Allow-Origin': '*',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: basicAuth,
        }));

    switch(response.statusCode){
      case 200:
        apiResponse.data = response.data['data'].map((p) => Warehouse.fromJson(p)).toList();
        // We get list of order customer, so we need to map each item to OrderCustomer model
        apiResponse.data as List<dynamic>;
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
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  }
  return apiResponse;
}
