
import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/accum_product_prices.dart';
import 'package:wp_b2b/models/accum_product_rests.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/models/ref_product.dart';

const productsURL = '$baseURL/products';
const products_pricesURL = '$baseURL/products_prices';
const products_restsURL = '$baseURL/products_rests';

// Get all order customer
Future<ApiResponse> getProductsByParent(uidParentProduct) async {
  ApiResponse apiResponse = ApiResponse();

  // Authorization
  String basicAuth = await getToken();

  // Get data from server
  try {

    var dio = Dio();
    final response = await dio.get(productsURL+'/'+uidParentProduct,
        options: Options(headers: {
          'Access-Control-Allow-Origin': '*',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: basicAuth,
        }));

    switch(response.statusCode){
      case 200:
        apiResponse.data = response.data['data'].map((p) => Product.fromJson(p)).toList();
        // We get list of order customer, so we need to map each item to OrderCustomer model
        apiResponse.data as List<dynamic>;
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = 'Помилка отримання списку товарів';
        break;
    }
  }
  catch (e){
    debugPrint(e.toString());
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// Get prices
Future<ApiResponse> getAccumProductPriceByUIDProducts(List<String> listPricesUID, List<String> listProductsUID) async {
  ApiResponse apiResponse = ApiResponse();

  // Authorization
  String basicAuth = await getToken();

  /// Get data from server
  try {

    Map dataMap = {
      'uidPrices' : listPricesUID,
      'uidProducts' : listProductsUID,
    };

    var dio = Dio();
    final response = await dio.post(products_pricesURL,
        options: Options(
            headers: {
          'Access-Control-Allow-Origin': '*',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: basicAuth,
        }),
        data: jsonEncode(dataMap)
    );

    switch(response.statusCode){
      case 200:
        apiResponse.data = response.data['data'].map((p) => AccumProductPrice.fromJson(p)).toList();
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

// Get rests
Future<ApiResponse> getAccumProductRestByUIDProducts(List<String> listWarehousesUID, List<String> listProductsUID) async {
  ApiResponse apiResponse = ApiResponse();

  // Authorization
  String basicAuth = await getToken();

  // Get data from server
  try {

    Map dataMap = {
      'uidWarehouses' : listWarehousesUID,
      'uidProducts' : listProductsUID,
    };

    var dio = Dio();
    final response = await dio.post(products_restsURL,
        options: Options(headers: {
          'Access-Control-Allow-Origin': '*',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: basicAuth,
        }),
        data: jsonEncode(dataMap));

    switch(response.statusCode){
      case 200:
        apiResponse.data = response.data['data'].map((p) => AccumProductRest.fromJson(p)).toList();
        // We get list of order customer, so we need to map each item to OrderCustomer model
        apiResponse.data as List<dynamic>;
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = 'Помилка отримання залишків';
        break;
    }
  }
  catch (e){
    debugPrint(e.toString());
    apiResponse.error = serverError;
  }
  return apiResponse;
}
