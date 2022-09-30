
import 'package:shared_preferences/shared_preferences.dart';

const baseURL = 'http://91.218.88.160:35844/moto/hs/portal';
const loginURL = '$baseURL/login';
const registerURL = '$baseURL/register';
const logoutURL = '$baseURL/logout';
const userURL = '$baseURL/user';

// Errors
const serverError = 'Server error';
const unauthorized = 'Unauthorized';
const somethingWentWrong = 'Something went wrong, try again!';
