
import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/doc_order_customer.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:dio/dio.dart';

const ordersCustomersURL = '$baseURL/orders_customers';
const orderCustomerURL = '$baseURL/order_customer';

// Get all order customer
Future<ApiResponse> getOrdersCustomers() async {
  ApiResponse apiResponse = ApiResponse();

  // Authorization
  String basicAuth = await getToken();
  if (basicAuth == ''){
    apiResponse.error = unauthorized;
    return apiResponse;
  }

  // Get data from server
  try {

    var dio = Dio();
    final response = await dio.get(ordersCustomersURL,
        options: Options(headers: {
          'Access-Control-Allow-Origin': '*',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: basicAuth,
        }));

    switch(response.statusCode){
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
  }
  catch (e){
    debugPrint(e.toString());
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// Get order customer
Future<ApiResponse> getItemsOrderCustomerByUID(uidOrderCustomer) async {
  ApiResponse apiResponse = ApiResponse();

  // Authorization
  String basicAuth = await getToken();
  if (basicAuth == ''){
    apiResponse.error = unauthorized;
    return apiResponse;
  }

  // Get data from server
  try {
    var dio = Dio();
    final response = await dio.get(orderCustomerURL+'/'+uidOrderCustomer,
        options: Options(headers: {
          'Access-Control-Allow-Origin': '*',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: basicAuth,
        }));

    switch(response.statusCode){
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
  }
  catch (e){
    debugPrint(e.toString());
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// Get prices of products
Future<ApiResponse> postOrderCustomer(OrderCustomer orderCustomer) async {
  ApiResponse apiResponse = ApiResponse();

  // Authorization
  String basicAuth = await getToken();
  if (basicAuth == ''){
    apiResponse.error = unauthorized;
    return apiResponse;
  }

  /// Post data from server
  try {

    var dio = Dio();
    final response = await dio.post(orderCustomerURL,
        options: Options(
            headers: {
              'Access-Control-Allow-Origin': '*',
              HttpHeaders.contentTypeHeader: 'application/json',
              HttpHeaders.authorizationHeader: basicAuth,
            }),
        data: jsonEncode(orderCustomer.toJson())
    );

    switch(response.statusCode){
      case 200:
        apiResponse.data = response.data['data'].map((p) => OrderCustomer.fromJson(p)).toList();
        // We get list of order customer, so we need to map each item to OrderCustomer model
        apiResponse.data as List<dynamic>;
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = 'Помилка отримання цін';
        break;
    }
  }
  catch (e){
    debugPrint(e.toString());
    apiResponse.error = serverError;
  }
  return apiResponse;
}
