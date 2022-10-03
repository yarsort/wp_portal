
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wp_b2b/models/user.dart';

const authURL = '$baseURL/auth';
const registerURL = '$baseURL/register';

Future<ApiResponse> login (String email, String password) async {
  ApiResponse apiResponse = ApiResponse();

  String basicAuth = 'Basic ' + base64Encode(utf8.encode('$email:$password'));

  // Get data from server
  try {
    final response = await http.get(Uri.parse(authURL),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: basicAuth,
        });

    switch(response.statusCode){
      case 200:
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString('token', basicAuth);
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

// Register
Future<ApiResponse> register(String name, String email, String password) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(
        Uri.parse(registerURL),
        headers: {'Accept': 'application/json'},
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password
        });

    switch(response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)][0];
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  }
  catch (e) {
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// Get token
Future<String> getToken() async {

  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('token') ?? '';

  // String username = 'Администратор';
  // String password = 'Lofege74';
  // String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
  // return basicAuth;
}

// logout
Future<bool> logout() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return await pref.remove('token');
}