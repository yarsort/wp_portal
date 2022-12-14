import 'dart:convert';

class OrderCustomer {
  int id = 0;                   // Инкремент
  int postingMode = 0;          // 0-Записан, 1-Проведен, 2-Удален
  String status = '';           //
  DateTime? date = DateTime.now(); // Дата создания замовлення
  String uid = '';              // UID для 1С и связи с ТЧ
  String uidOrganization = '';  // Посилання на организацию
  String? nameOrganization = ''; // Имя организации
  String uidPartner = '';       // Посилання на контрагента
  String? namePartner = '';      // Имя контрагента
  String uidContract = '';      // Посилання на договір контрагента
  String? nameContract = '';     // Имя контрагента
  String uidStore = '';         // Посилання на магазин
  String? nameStore = '';        // Имя магазина
  String uidPrice = '';         // Посилання на тип цены номенклатуры продажи контрагенту
  String? namePrice = '';        // Наименование типа цены номенклатуры
  String uidWarehouse = '';     // Посилання на склад
  String? nameWarehouse = '';    // Наименование склада
  String uidCurrency = '';      // Посилання на валюту замовлення
  String? nameCurrency = '';     // Наименование валюты замовлення
  String uidCashbox = '';       // Посилання на кассу
  String? nameCashbox = '';      // Наименование кассы
  double? sum = 0.0;             // Сума документа
  String comment = '';          // Коментар замовлення
  String coordinates = '';      // Координаты создания записи
  DateTime? dateSending = DateTime(1900, 1, 1);      // Дата планируемой відгрузки замовлення
  DateTime? datePaying = DateTime(1900, 1, 1);       // Дата планируемой оплати замовлення
  int sendYesTo1C = 0; // Булево: "Отправлено в 1С" - для фильтрации в списках
  int sendNoTo1C = 0;  // Булево: "Отправлено в 1С" - для фильтрации в списках
  DateTime dateSendingTo1C = DateTime(1900, 1, 1); // Дата отправки замовлення в 1С из мобильного устройства
  String numberFrom1C = '';
  //int countItems = 0;           // Количество товарів
  List<ItemOrderCustomer> itemsOrderCustomer = [];

  OrderCustomer({this.date, this.nameOrganization, this.namePartner, this.nameWarehouse, this.namePrice, this.sum});

  OrderCustomer.fromJson(Map<String, dynamic> json) {
    postingMode = int.parse(json["postingMode"]??'0');
    status = json['status'] ?? '';
    date = DateTime.parse(json['date']);
    uid = json['uid'] ?? '';
    uidOrganization = json['uidOrganization'] ?? '';
    nameOrganization = json['nameOrganization'] ?? '';
    uidPartner = json['uidPartner'] ?? '';
    namePartner = json['namePartner'] ?? '';
    uidContract = json['uidContract'] ?? '';
    nameContract = json['nameContract'] ?? '';
    uidStore = json['uidStore'] ?? '';
    nameStore = json['nameStore'] ?? '';
    uidPrice = json['uidPrice'] ?? '';
    namePrice = json['namePrice'] ?? '';
    uidWarehouse = json['uidWarehouse'] ?? '';
    nameWarehouse = json['nameWarehouse'] ?? '';
    uidCurrency = json['uidCurrency'] ?? '';
    nameCurrency = json['nameCurrency'] ?? '';
    uidCashbox = json['uidCashbox'] ?? '';
    nameCashbox = json['nameCashbox'] ?? '';
    sum = double.parse(json["sum"]??'0.0');
    comment = json['comment'] ?? '';
    numberFrom1C = json['numberFrom1C'] ?? '';

    if (json['itemsOrderCustomer'] != null) {
      itemsOrderCustomer = List<dynamic>.from(json['itemsOrderCustomer'])
          .map((i) => ItemOrderCustomer.fromJson(i))
          .toList();
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['postingMode'] = postingMode.toString();
    data['status'] = status.toString();
    data['date'] = date?.toIso8601String();
    data['uid'] = uid;
    data['uidOrganization'] = uidOrganization.isNotEmpty?uidOrganization:'00000-0000-0000-0000-000000000000000';
    data['nameOrganization'] = nameOrganization;
    data['uidPartner'] = uidPartner.isNotEmpty?uidPartner:'00000-0000-0000-0000-000000000000000';
    data['namePartner'] = namePartner;
    data['uidContract'] = uidContract.isNotEmpty?uidContract:'00000-0000-0000-0000-000000000000000';
    data['nameContract'] = nameContract;
    data['uidStore'] = uidStore.isNotEmpty?uidStore:'00000-0000-0000-0000-000000000000000';
    data['nameStore'] = nameStore;
    data['uidPrice'] = uidPrice.isNotEmpty?uidPrice:'00000-0000-0000-0000-000000000000000';
    data['namePrice'] = namePrice;
    data['uidWarehouse'] = uidWarehouse.isNotEmpty?uidWarehouse:'00000-0000-0000-0000-000000000000000';
    data['nameWarehouse'] = nameWarehouse;
    data['uidCurrency'] = uidCurrency.isNotEmpty?uidCurrency:'00000-0000-0000-0000-000000000000000';
    data['nameCurrency'] = nameCurrency;
    data['uidCashbox'] = uidCashbox.isNotEmpty?uidCashbox:'00000-0000-0000-0000-000000000000000';
    data['nameCashbox'] = nameCashbox;
    data['sum'] = sum.toString();
    data['comment'] = comment.toString();
    data['coordinates'] = coordinates;
    data['dateSending'] = dateSending?.toIso8601String();
    data['datePaying'] = datePaying?.toIso8601String();
    data['sendYesTo1C'] = sendYesTo1C.toString();
    data['sendNoTo1C'] = sendNoTo1C.toString();
    data['dateSendingTo1C'] = dateSendingTo1C.toIso8601String();
    data['numberFrom1C'] = numberFrom1C.toString();
    data['itemsOrderCustomer'] = itemsOrderCustomer.map((e) => e.toJson()).toList();
    return data;
  }

  allSum (OrderCustomer orderCustomer) {
    /// Сума документа
    double allSum = 0.0;
    for (var item in orderCustomer.itemsOrderCustomer) {
      allSum = allSum + item.sum;
    }
    orderCustomer.sum = allSum;
  }
}

/// ТЧ Товары, Документы.ЗаказПокупателя
class ItemOrderCustomer {
  int numberRow = 0;                   // Инкремент
  String uidOrderCustomer = '';      // ID владельца ТЧ (документ)
  String uid = '';              // UID для 1С и связи с ТЧ
  String name = '';             // Название товара
  String uidCharacteristic = ''; // UID для 1С и связи с ТЧ
  String nameCharacteristic = '';// Название товара
  String uidUnit = '';          // Посилання на единицу измерения товарв
  String nameUnit = '';         //( Название единицы измерения
  double count = 0.0;           // Количество товара
  double price = 0.0;           // Цена товара
  double discount = 0.0;        // Скидка/наценка на товар
  double sum = 0.0;             // Сума товарів

  ItemOrderCustomer({
    required this.numberRow,
    required this.uidOrderCustomer,
    required this.uid,
    required this.name,
    required this.uidCharacteristic,
    required this.nameCharacteristic,
    required this.uidUnit,
    required this.nameUnit,
    required this.count,
    required this.price,
    required this.discount,
    required this.sum,
  });

  ItemOrderCustomer.fromJson(Map<String, dynamic> json) {
    numberRow = int.parse(json['numberRow']??'0.0');
    uidOrderCustomer = json['uidOrderCustomer']??'';
    uid = json['uid']??'';
    name = json['name']??'';
    uidCharacteristic = json['uidCharacteristic']??'';
    nameCharacteristic = json['nameCharacteristic']??'';
    uidUnit = json['uidUnit']??'';
    nameUnit = json['nameUnit']??'';
    count = double.parse(json['count']??'0.0');
    price = double.parse(json['price']??'0.0');
    //discount = double.parse(json['discount']??0.0);
    sum = double.parse(json['sum']??'0.0');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['numberRow'] = numberRow.toString();
    data['uidOrderCustomer'] = uidOrderCustomer;
    data['uid'] = uid;
    data['name'] = name;
    data['uidCharacteristic'] = uidCharacteristic;
    data['nameCharacteristic'] = nameCharacteristic;
    data['uidUnit'] = uidUnit;
    data['nameUnit'] = nameUnit;
    data['count'] = count.toString();
    data['price'] = price.toString();
    data['discount'] = discount.toString();
    data['sum'] = sum.toString();
    return data;
  }
}
