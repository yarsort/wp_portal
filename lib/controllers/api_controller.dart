
// Errors
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_b2b/models/ref_contact.dart';

const serverError = 'Помилка отримання даних. Сервер не доступний!';
const serverAuthError = 'Помилка авторизації. Сервер не доступний!';
const unauthorized = 'Помилка авторизації!';
const somethingWentWrong = 'Помилка сервера, спробуйте повторити дію!';

// Get base url
Future<String> getBaseUrl() async {
  var nameServer = Uri.base.host;

  // 1 - rsv-moto
  // 2 - techUa
  // 3 - tlt

  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString('settings_serverExchange', 'http://'+nameServer);

  switch(nameServer) {
    case 'portal.yarsoft.com.ua':
      return 'http://api-tehno.yarsoft.com.ua:35844/moto/hs/portal';

    case 'portal.tehnikaua.com.ua':
      return 'http://api-teh.yarsoft.com.ua/baza/hs/portal';

    default:
      return 'http://api-teh.yarsoft.com.ua/baza/hs/portal';
  }
}

// Get photo base url
Future<String> getBasePhotoUrl() async {
  var nameServer = Uri.base.host;

  // 1 - rsv-moto
  // 2 - techUa
  // 3 - tlt

  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString('settings_photoServerExchange', 'http://'+nameServer+'/images');

  switch(nameServer) {
    case 'portal.yarsoft.com.ua':
      return 'http://portal.yarsoft.com.ua/images';

    case 'portal.tehnikaua.com.ua':
      return 'http://portal.tehnikaua.com.ua/images';

    default:
      return 'http://portal.tehnikaua.com.ua/images';
  }
}

// Get phone numbers of company
Future<List<Contact>> getCompanyPhones() async {
  var nameServer = Uri.base.host;
  // 1 - rsv-moto
  // 2 - techUa
  // 3 - tlt

  List<Contact> listContacts = [];

  switch(nameServer) {
    case 'portal.yarsoft.com.ua':
      Contact contact1 = Contact();
      contact1.phone = '+38(073)128-22-88';
      contact1.name = 'RSV-MOTO';

      Contact contact2 = Contact();
      contact2.phone = 'support@rsvmoto.com.ua';
      contact2.name = 'Пошта';

      listContacts.add(contact1);
      listContacts.add(contact2);

      return listContacts;
    case 'portal.tehnikaua.com.ua':
      Contact contact1 = Contact();
      contact1.phone = '+38(068)627-31-71';
      contact1.name = 'Олександр';

      Contact contact2 = Contact();
      contact2.phone = '+38(097)759-55-20';
      contact2.name = 'Яна';

      Contact contact3 = Contact();
      contact3.phone = '+38(098)320-10-66';
      contact3.name = 'Ольга';

      Contact contact4 = Contact();
      contact4.phone = '+38(096)331-26-42';
      contact4.name = 'Людмила';

      Contact contact5 = Contact();
      contact5.phone = '+38(096)686-79-54';
      contact5.name = 'Владислав';

      Contact contact6 = Contact();
      contact6.phone = '+38(098)248-70-22';
      contact6.name = 'Владислав';

      Contact contact7 = Contact();
      contact7.phone = 'nazarenko0013@gmail.com';
      contact7.name = '';

      Contact contact8 = Contact();
      contact8.phone = 'Україна, Вінниця, Келецька 50Б';
      contact8.name = '';

      listContacts.add(contact1);
      listContacts.add(contact2);
      listContacts.add(contact3);
      listContacts.add(contact4);
      listContacts.add(contact5);
      listContacts.add(contact6);
      listContacts.add(contact7);
      listContacts.add(contact8);

      return listContacts;
    default:
      Contact contact1 = Contact();
      contact1.phone = '+38(068)627-31-71';
      contact1.name = 'Олександр';

      Contact contact2 = Contact();
      contact2.phone = '+38(097)759-55-20';
      contact2.name = 'Яна';

      Contact contact3 = Contact();
      contact3.phone = '+38(098)320-10-66';
      contact3.name = 'Ольга';

      Contact contact4 = Contact();
      contact4.phone = '+38(096)331-26-42';
      contact4.name = 'Людмила';

      Contact contact5 = Contact();
      contact5.phone = '+38(096)686-79-54';
      contact5.name = 'Владислав';

      Contact contact6 = Contact();
      contact6.phone = '+38(098)248-70-22';
      contact6.name = 'Владислав';

      Contact contact7 = Contact();
      contact7.phone = 'nazarenko0013@gmail.com';
      contact7.name = '';

      Contact contact8 = Contact();
      contact8.phone = 'Україна, Вінниця, Келецька 50Б';
      contact8.name = '';

      listContacts.add(contact1);
      listContacts.add(contact2);
      listContacts.add(contact3);
      listContacts.add(contact4);
      listContacts.add(contact5);
      listContacts.add(contact6);
      listContacts.add(contact7);
      listContacts.add(contact8);

      return listContacts;
  }
}
