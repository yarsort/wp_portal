
/// Справочник.Склады
class Warehouse {
  String uid = '';                // UID для 1С и связи с ТЧ
  String code = '';               // Код для 1С
  String name = '';               // Имя партнера

  Warehouse();

  Warehouse.fromJson(Map<String, dynamic> json) {
    uid = json['uid'] ?? '';
    code = json['code'] ?? '';
    name = json['name'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['code'] = code;
    data['name'] = name;
    return data;
  }
}
