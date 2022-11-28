
import 'package:shared_preferences/shared_preferences.dart';

// Errors
const serverError = 'Помилка отримання даних. Сервер не доступний!';
const serverAuthError = 'Помилка авторизації. Сервер не доступний!';
const unauthorized = 'Помилка авторизації!';
const somethingWentWrong = 'Помилка сервера, спробуйте повторити дію!';

// Get base url
Future<String> getBaseUrl() async {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;
  var baseURL = prefs.getString('settings_serverExchange') ?? '';
  return baseURL;
}