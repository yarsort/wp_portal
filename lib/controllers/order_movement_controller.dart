
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/doc_order_customer.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const orderMovementURL = '$baseURL/orders_movements';

// Get all order movement
Future<ApiResponse> getOrdersMovements() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(orderMovementURL),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Basic $token'
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
    apiResponse.error = serverError;
  }
  return apiResponse;
}