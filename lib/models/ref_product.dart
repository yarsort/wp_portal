
/// Справочник.Товары
class Product {
  int isGroup = 0;                // Пометка удаления
  String uid = '';                // UID для 1С и связи с ТЧ
  String code = '';               // Код для 1С
  String name = '';               // Имя
  String nameForSearch = '';      // Имя для поиска
  String vendorCode = '';         // Артикул товара в 1С
  String uidParent = '';          // Посилання на группу
  bool useCharacteristic = false; // Имя
  String uidUnit = '';            // Посилання на единицу измерения
  String nameUnit = '';           // Имя ед. изм.
  String uidProductGroup = '';    // Посилання на номенклатурную групу
  String nameProductGroup = '';   // Имя номенклатурной группы
  String codeUKTZED = '';         // Код УКТЗЕД ліцензійного товару
  String barcode = '';            // Имя ед. изм.
  String numberTaxGroup = '1';    // Номер податкової групи
  String description = '';        // Опис товару
  String comment = '';            // Коммментарий
  DateTime dateEdit = DateTime.now(); // Дата редактирования

  Product();

  Product.fromJson(Map<String, dynamic> json) {
    isGroup = int.parse(json['isGroup']??0);
    uid = json['uid'] ?? '';
    code = json['code'] ?? '';
    name = json['name'] ?? '';
    nameForSearch = json['name'].toLowerCase() ?? '';
    vendorCode = json['vendorCode'] ?? '';
    uidParent = json['uidParent'] ?? '';
    useCharacteristic = (json['useCharacteristic'] == '1') ? true : false;
    uidUnit = json['uidUnit'] ?? '';
    nameUnit = json['nameUnit'] ?? '';
    uidProductGroup = json['uidProductGroup'] ?? '';
    nameProductGroup = json['nameProductGroup'] ?? '';
    numberTaxGroup = json['numberTaxGroup'] ?? '1';
    codeUKTZED = json['codeUKTZED'] ?? '';
    barcode = json['barcode'] ?? '';
    description = json['description'] ?? '';
    comment = json['comment'] ?? '';
    dateEdit = DateTime.parse(json['dateEdit'] ?? DateTime.now().toIso8601String());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isGroup'] = isGroup;
    data['uid'] = uid;
    data['code'] = code;
    data['name'] = name;
    data['nameForSearch'] = nameForSearch;
    data['vendorCode'] = vendorCode;
    data['uidParent'] = uidParent;
    data['useCharacteristic'] = useCharacteristic ? '1' : '0';
    data['uidUnit'] = uidUnit;
    data['nameUnit'] = nameUnit;
    data['uidProductGroup'] = uidProductGroup;
    data['nameProductGroup'] = nameProductGroup;
    data['numberTaxGroup'] = numberTaxGroup;
    data['barcode'] = barcode;
    data['codeUKTZED'] = codeUKTZED;
    data['description'] = description;
    data['comment'] = comment;
    data['dateEdit'] = dateEdit.toIso8601String();
    return data;
  }
}

/// Справочник.ХарактеристикиТоваров
class ProductCharacteristic {
  String uid = '';                // UID для 1С и связи с ТЧ
  String name = '';               // Имя
  String uidProduct = '';          // Посилання на родителя (Товар)
  String comment = '';            // Коммментарий

  ProductCharacteristic();

  ProductCharacteristic.fromJson(Map<String, dynamic> json) {
    uid = json['uid'] ?? '';
    name = json['name'] ?? '';
    uidProduct = json['uidProduct'] ?? '';
    comment = json['comment'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['name'] = name;
    data['uidProduct'] = uidProduct;
    data['comment'] = comment;
    return data;
  }
}
