
import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/doc_order_customer.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:http/http.dart' as http;

const ordersCustomersURL = '$baseURL/orders_customers';
const orderCustomerURL = '$baseURL/order_customer';

// Get all order customer
Future<ApiResponse> getOrdersCustomers() async {
  ApiResponse apiResponse = ApiResponse();

  // Authorization
  String basicAuth = await getToken();

  // Get data from server
  try {
    final response = await http.get(Uri.parse(ordersCustomersURL),
        headers: {
          HttpHeaders.accessControlAllowOriginHeader: '*',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: basicAuth,
        });

    switch(response.statusCode){
      case 200:
        apiResponse.data = jsonDecode(response.body)['data'].map((p) => OrderCustomer.fromJson(p)).toList();
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

  // Get data from server
  try {
    final response = await http.get(Uri.parse(orderCustomerURL+'/'+uidOrderCustomer),
        headers: {
          HttpHeaders.accessControlAllowOriginHeader: '*',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: basicAuth,
        });

    switch(response.statusCode){
      case 200:
        apiResponse.data = jsonDecode(response.body)['data'][0]['items'].map((p) => ItemOrderCustomer.fromJson(p)).toList();
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