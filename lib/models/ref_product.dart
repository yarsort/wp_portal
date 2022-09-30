
/// Справочник.Товары
class Product {
  int id = 0;                     // Инкремент
  int isGroup = 0;                // Пометка удаления
  String uid = '';                // UID для 1С и связи с ТЧ
  String code = '';               // Код для 1С
  String name = '';               // Имя
  String nameForSearch = '';      // Имя для поиска
  String vendorCode = '';         // Артикул товара в 1С
  String uidParent = '';          // Посилання на группу
  String uidUnit = '';            // Посилання на единицу измерения
  String nameUnit = '';           // Имя ед. изм.
  String uidProductGroup = '';    // Посилання на номенклатурную групу
  String nameProductGroup = '';   // Имя номенклатурной группы
  String codeUKTZED = '';         // Код УКТЗЕД ліцензійного товару
  String barcode = '';            // Имя ед. изм.
  String numberTaxGroup = '1';    // Номер податкової групи
  String comment = '';            // Коммментарий
  DateTime dateEdit = DateTime.now(); // Дата редактирования

  Product();

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    isGroup = json['isGroup'];
    uid = json['uid'] ?? '';
    code = json['code'] ?? '';
    name = json['name'] ?? '';
    nameForSearch = json['name'].toLowerCase() ?? '';
    vendorCode = json['vendorCode'] ?? '';
    uidParent = json['uidParent'] ?? '';
    uidUnit = json['uidUnit'] ?? '';
    nameUnit = json['nameUnit'] ?? '';
    uidProductGroup = json['uidProductGroup'] ?? '';
    nameProductGroup = json['nameProductGroup'] ?? '';
    numberTaxGroup = json['numberTaxGroup'] ?? '1';
    codeUKTZED = json['codeUKTZED'] ?? '';
    barcode = json['barcode'] ?? '';
    comment = json['comment'] ?? '';
    dateEdit = DateTime.parse(json['dateEdit'] ?? DateTime.now().toIso8601String());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != 0) {
      data['id'] = id;
    }
    data['isGroup'] = isGroup;
    data['uid'] = uid;
    data['code'] = code;
    data['name'] = name;
    data['nameForSearch'] = nameForSearch;
    data['vendorCode'] = vendorCode;
    data['uidParent'] = uidParent;
    data['uidUnit'] = uidUnit;
    data['nameUnit'] = nameUnit;
    data['uidProductGroup'] = uidProductGroup;
    data['nameProductGroup'] = nameProductGroup;
    data['numberTaxGroup'] = numberTaxGroup;
    data['barcode'] = barcode;
    data['codeUKTZED'] = codeUKTZED;
    data['comment'] = comment;
    data['dateEdit'] = dateEdit.toIso8601String();
    return data;
  }
}
