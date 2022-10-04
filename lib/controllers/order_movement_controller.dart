
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/doc_order_movement.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:http/http.dart' as http;
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
    final response = await http.get(Uri.parse(ordersMovementsURL),
        headers: {
          HttpHeaders.accessControlAllowOriginHeader: '*',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: basicAuth,
        });

    switch(response.statusCode){
      case 200:

        var bodyResponse = jsonDecode(response.body);

        apiResponse.data = bodyResponse['data'].map((p) => OrderMovement.fromJson(p)).toList();

        debugPrint('Отримано елементів: ' + bodyResponse['count'].toString());

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
    final response = await http.get(Uri.parse(orderMovementURL+'/'+uidOrderMovement),
        headers: {
          HttpHeaders.accessControlAllowOriginHeader: '*',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: basicAuth,
        });

    switch(response.statusCode){
      case 200:

        var bodyResponse = jsonDecode(response.body);

        apiResponse.data = bodyResponse['data'][0]['items'].map((p) => ItemOrderMovement.fromJson(p)).toList();

        debugPrint('Отримано елементів: ' + bodyResponse['count'].toString());

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