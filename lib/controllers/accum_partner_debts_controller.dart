
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/accum_partner_depts.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:dio/dio.dart';

// Get all order customer
Future<ApiResponse> getAccumPartnerDebts(String uidPartner) async {
  ApiResponse apiResponse = ApiResponse();

  /// Адрес подключения: отправка!!!
  final connectionUrl = await getBaseUrl() + '/finances';

  /// Authorization
  String basicAuth = await getToken();
  if (basicAuth == ''){
    apiResponse.error = unauthorized;
    return apiResponse;
  }

  /// Get data from server
  try {

    var dio = Dio();
    final response = await dio.get(connectionUrl + '/' + uidPartner,
        options: Options(headers: {
          'Access-Control-Allow-Origin': '*',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: basicAuth,
        }));

    switch(response.statusCode){
      case 200:
        apiResponse.data = response.data['data'].map((p) => AccumPartnerDept.fromJson(p)).toList();
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
  }
  catch (e){
    debugPrint(e.toString());
    apiResponse.error = serverError;
  }
  return apiResponse;
}
