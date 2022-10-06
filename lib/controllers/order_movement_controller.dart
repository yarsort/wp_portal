
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/doc_order_movement.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

const ordersMovementsURL = '$baseURL/orders_movements';
const orderMovementURL = '$baseURL/order_movement';

// Get all order customer
Future<ApiResponse> getOrdersMovements() async {
  ApiResponse apiResponse = ApiResponse();

  // Authorization
  String basicAuth = await getToken();

  // Get data from server
  try {

    var dio = Dio();
    final response = await dio.get(ordersMovementsURL,
        options: Options(headers: {
          'Access-Control-Allow-Origin': '*',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: basicAuth,
        }));

    switch(response.statusCode){
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
  }
  catch (e){
    debugPrint(e.toString());
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// Get order customer
Future<ApiResponse> getItemsOrderMovementByUID(uidOrderMovement) async {
  ApiResponse apiResponse = ApiResponse();

  // Authorization
  String basicAuth = await getToken();

  // Get data from server
  try {

    var dio = Dio();
    final response = await dio.get(orderMovementURL+'/'+uidOrderMovement,
        options: Options(headers: {
          'Access-Control-Allow-Origin': '*',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: basicAuth,
        }));

    switch(response.statusCode){
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
  }
  catch (e){
    apiResponse.error = serverError;
  }
  return apiResponse;
}