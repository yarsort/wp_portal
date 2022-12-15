
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
import 'package:wp_b2b/models/system_sort.dart';

// Get all products
Future<ApiResponse> getProductsByParent(uidParentProduct, Sort sortDefault) async {
  ApiResponse apiResponse = ApiResponse();

  /// Адрес подключения: отправка!!!
  final connectionUrl = await getBaseUrl() + '/products';

  /// Authorization
  String basicAuth = await getToken();
  if (basicAuth == ''){
    apiResponse.error = unauthorized;
    return apiResponse;
  }
    
  /// Get data from server
  try {

    var dio = Dio();
    final response = await dio.get(connectionUrl + '/' + uidParentProduct + '?sort=${sortDefault.code}',
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

// Get all items for search
Future<ApiResponse> getProductsForSearch(searchString) async {
  ApiResponse apiResponse = ApiResponse();

  /// Адрес подключения: отправка!!!
  final connectionUrl = await getBaseUrl() + '/products_search';

  /// Authorization
  String basicAuth = await getToken();
  if (basicAuth == ''){
    apiResponse.error = unauthorized;
    return apiResponse;
  }

  /// Get data from server
  try {
    // Екрануваня символів
    //searchString = jsonEncode(searchString);

    // Запит до сервера
    var dio = Dio();
    final response = await dio.get(connectionUrl + '/' + searchString,
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

// Get all product characteristics
Future<ApiResponse> getProductCharacteristic(uidProduct) async {
  ApiResponse apiResponse = ApiResponse();

  /// Адрес подключения: отправка!!!
  final connectionUrl = await getBaseUrl() + '/product_characteristics';

  /// Authorization
  String basicAuth = await getToken();
  if (basicAuth == ''){
    apiResponse.error = unauthorized;
    return apiResponse;
  }

  /// Get data from server
  try {

    var dio = Dio();
    final response = await dio.get(connectionUrl + '/' + uidProduct,
        options: Options(headers: {
          'Access-Control-Allow-Origin': '*',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: basicAuth,
        }));

    switch(response.statusCode){
      case 200:
        apiResponse.data = response.data['data'].map((p) => ProductCharacteristic.fromJson(p)).toList();
        // We get list of order customer, so we need to map each item to OrderCustomer model
        apiResponse.data as List<dynamic>;
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = 'Помилка отримання списку характеристик товару';
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
Future<ApiResponse> getAccumProductPriceByUIDProducts(List<String> listPricesUID, List<String> listProductsUID) async {
  ApiResponse apiResponse = ApiResponse();

  /// Адрес подключения: отправка!!!
  final connectionUrl = await getBaseUrl() + '/products_prices';

  /// Authorization
  String basicAuth = await getToken();
  if (basicAuth == ''){
    apiResponse.error = unauthorized;
    return apiResponse;
  }

  /// Get data from server
  try {

    Map dataMap = {
      'uidPrices' : listPricesUID,
      'uidProducts' : listProductsUID,
    };

    var dio = Dio();
    final response = await dio.post(connectionUrl,
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

// Get rests of products
Future<ApiResponse> getAccumProductRestByUIDProducts(List<String> listWarehousesUID, List<String> listProductsUID) async {
  ApiResponse apiResponse = ApiResponse();

  /// Адрес подключения: отправка!!!
  final connectionUrl = await getBaseUrl() + '/products_rests';

  /// Authorization
  String basicAuth = await getToken();
  if (basicAuth == ''){
    apiResponse.error = unauthorized;
    return apiResponse;
  }

  /// Get data from server
  try {

    Map dataMap = {
      'uidWarehouses' : listWarehousesUID,
      'uidProducts' : listProductsUID,
    };

    var dio = Dio();
    final response = await dio.post(connectionUrl,
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
