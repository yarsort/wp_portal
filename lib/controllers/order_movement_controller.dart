import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/models/doc_order_movement.dart';

// Get all order customer
Future<ApiResponse> getOrdersMovements(startPeriodDocs, finishPeriodDocs) async {
  ApiResponse apiResponse = ApiResponse();

  /// Address connection
  String connectionUrl =
      await getBaseUrl() + '/orders_movements' + '?startPeriodDocs=$startPeriodDocs&finishPeriodDocs=$finishPeriodDocs';

  /// Authorization
  String basicAuth = await getToken();
  if (basicAuth == '') {
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

    switch (response.statusCode) {
      case 200:
        apiResponse.data = response.data['data'].map((p) => OrderMovement.fromJson(p)).toList();

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

// Get order customer
Future<ApiResponse> getItemsOrderMovementByUID(uidOrderMovement) async {
  ApiResponse apiResponse = ApiResponse();

  /// Адрес подключения
  String connectionUrl = await getBaseUrl() + '/order_movement/' + uidOrderMovement;

  /// Authorization
  String basicAuth = await getToken();
  if (basicAuth == '') {
    apiResponse.error = unauthorized;
    return apiResponse;
  }

  // Get data from server
  try {
    var dio = Dio();
    final response = await dio.get(connectionUrl,
        options: Options(headers: {
          'Access-Control-Allow-Origin': '*',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: basicAuth,
        }));

    switch (response.statusCode) {
      case 200:
        apiResponse.data = response.data['data'][0]['items'].map((p) => ItemOrderMovement.fromJson(p)).toList();

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
