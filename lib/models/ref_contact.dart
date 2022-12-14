
/// Справочник. Контакти портала
class Contact {

  String phone = ''; // Номер
  String name = '';  // Имя
  String region = ''; // Регіон
  int sort = 0;      // Порядок

  Contact();

  Contact.fromJson(Map<String, dynamic> json) {
    phone = json['phone'] ?? '';
    name = json['name'] ?? '';
    region = json['region'] ?? '';
    sort = json['sort'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['phone'] = phone;
    data['name'] = name;
    data['region'] = region;
    data['sort'] = sort;
    return data;
  }
}