
/// Справочник.Партнеры
class Partner {
  String uid = '';                // UID для 1С и связи с ТЧ
  String code = '';               // Код для 1С
  String name = '';               // Имя партнера
  String nameForSearch = '';      // Имя партнера
  String uidParent = '';          // Посилання на группу
  String nameParent = '';         // Посилання на группу

  Partner();

  Partner.fromJson(Map<String, dynamic> json) {
    uid = json['uid'] ?? '';
    code = json['code'] ?? '';
    name = json['name'] ?? '';
    nameForSearch = json['name'].toLowerCase() ?? '';
    uidParent = json['uidParent'] ?? '';
    nameParent = json['nameParent'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['code'] = code;
    data['name'] = name;
    data['nameForSearch'] = nameForSearch;
    data['uidParent'] = uidParent;
    data['nameParent'] = nameParent;
    return data;
  }
}
