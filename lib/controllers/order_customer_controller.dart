import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/models/doc_order_customer.dart';

// Get base url
Future<String> _getBaseUrl() async {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;
  var baseURL = prefs.getString('settings_serverExchange') ?? '';
  return baseURL;
}

// Get all order customer
Future<ApiResponse> getOrdersCustomers(startPeriodDocs, finishPeriodDocs) async {
  ApiResponse apiResponse = ApiResponse();

  /// Адрес подключения
  String connectionUrl =
      await _getBaseUrl() + '/orders_customers' + '?startPeriodDocs=$startPeriodDocs&finishPeriodDocs=$finishPeriodDocs';

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
        apiResponse.data = response.data['data'].map((p) => OrderCustomer.fromJson(p)).toList();
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
Future<ApiResponse> getItemsOrderCustomerByUID(uidOrderCustomer) async {
  ApiResponse apiResponse = ApiResponse();

  /// Адрес подключения
  String connectionUrl = await _getBaseUrl() + '/order_customer/' + uidOrderCustomer;

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
        apiResponse.data = response.data['data'][0]['items'].map((p) => ItemOrderCustomer.fromJson(p)).toList();
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

// Get prices of products
Future<ApiResponse> postOrderCustomer(OrderCustomer orderCustomer) async {
  ApiResponse apiResponse = ApiResponse();

  /// Адрес подключения: отправка!!!
  final connectionUrl = await _getBaseUrl() + '/order_customer/00000-0000-0000-0000-000000000000000';

  /// Authorization
  String basicAuth = await getToken();
  if (basicAuth == '') {
    apiResponse.error = unauthorized;
    return apiResponse;
  }

  /// Post data from server
  try {
    var dio = Dio();
    final response = await dio.post(connectionUrl,
        options: Options(headers: {
          'Access-Control-Allow-Origin': '*',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: basicAuth,
        }),
        data: jsonEncode(orderCustomer.toJson()));

    switch (response.statusCode) {
      case 200:
        apiResponse.data = response.data['data'].map((p) => OrderCustomer.fromJson(p)).toList();
        // We get list of order customer, so we need to map each item to OrderCustomer model
        apiResponse.data as List<dynamic>;
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = 'Помилка отримання даних';
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
