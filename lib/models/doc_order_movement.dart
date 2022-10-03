class OrderMovement {
  String? status = '';
  DateTime? date = DateTime.now(); // Дата создания замовлення
  String uid = ''; // UID для 1С и связи с ТЧ
  String uidOrganization = ''; // Посилання на организацию
  String? nameOrganization = ''; // Имя организации
  String uidStore = ''; // Посилання на магазин
  String? nameStore = ''; // Имя магазина
  String uidWarehouseSender = ''; // Посилання на склад отправителя
  String? nameWarehouseSender = ''; // Наименование склада отправителя
  String uidWarehouseReceiver = ''; // Посилання на склад получателя
  String? nameWarehouseReceiver = ''; // Наименование склада получателя
  String comment = ''; // Коментар замовлення
  DateTime dateSendingTo1C = DateTime(
      1900, 1, 1); // Дата отправки замовлення в 1С из мобильного устройства
  String numberFrom1C = '';
  int countItems = 0; // Количество товарів

  OrderMovement(
      {this.date,
      this.nameOrganization,
      this.nameWarehouseSender,
      this.nameWarehouseReceiver,
      this.status});

  OrderMovement.fromJson(Map<String, dynamic> json) {
    status = json['status'] ?? '';
    date = DateTime.parse(json['date']);
    uid = json['uid'] ?? '';
    uidOrganization = json['uidOrganization'] ?? '';
    nameOrganization = json['nameOrganization'] ?? '';
    uidStore = json['uidStore'] ?? '';
    nameStore = json['nameStore'] ?? '';
    uidWarehouseSender = json['uidWarehouseSender'] ?? '';
    nameWarehouseSender = json['nameWarehouseSender'] ?? '';
    uidWarehouseReceiver = json['uidWarehouseReceiver'] ?? '';
    nameWarehouseReceiver = json['nameWarehouseReceiver'] ?? '';
    comment = json['comment'] ?? '';
    dateSendingTo1C = DateTime.parse(json['dateSendingTo1C']);
    numberFrom1C = json['numberFrom1C'] ?? '';
    countItems = json['countItems'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['date'] = date?.toIso8601String();
    data['uid'] = uid;
    data['uidOrganization'] = uidOrganization.isNotEmpty
        ? uidOrganization
        : '00000-0000-0000-0000-000000000000000';
    data['nameOrganization'] = nameOrganization;
    data['uidStore'] =
        uidStore.isNotEmpty ? uidStore : '00000-0000-0000-0000-000000000000000';
    data['nameStore'] = nameStore;
    data['uidWarehouseSender'] = uidWarehouseSender.isNotEmpty
        ? uidWarehouseSender
        : '00000-0000-0000-0000-000000000000000';
    data['nameWarehouseSender'] = nameWarehouseSender;
    data['uidWarehouseReceiver'] = uidWarehouseReceiver.isNotEmpty
        ? uidWarehouseReceiver
        : '00000-0000-0000-0000-000000000000000';
    data['nameWarehouseReceiver'] = nameWarehouseReceiver;
    data['comment'] = comment;
    data['dateSendingTo1C'] = dateSendingTo1C.toIso8601String();
    data['numberFrom1C'] = numberFrom1C;
    data['countItems'] = countItems;
    return data;
  }
}

/// ТЧ Товары, Документы.ЗаказПокупателя
class ItemOrderMovement {
  int id = 0; // Инкремент
  int idOrderCustomer = 0; // ID владельца ТЧ (документ)
  String uid = ''; // UID для 1С и связи с ТЧ
  String name = ''; // Название товара
  String uidCharacteristic = ''; // UID для 1С и связи с ТЧ
  String nameCharacteristic = ''; // Название товара
  String uidUnit = ''; // Посилання на единицу измерения товарв
  String nameUnit = ''; // Название единицы измерения
  double count = 0.0; // Количество товара
  double price = 0.0; // Цена товара
  double discount = 0.0; // Скидка/наценка на товар
  double sum = 0.0; // Сума товарів

//<editor-fold desc="Data Methods">

  ItemOrderMovement({
    required this.id,
    required this.idOrderCustomer,
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

  ItemOrderMovement.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idOrderCustomer = json['idOrderCustomer'];
    uid = json['uid'] ?? '';
    name = json['name'] ?? '';
    uidCharacteristic = json['uidCharacteristic'] ?? '';
    nameCharacteristic = json['nameCharacteristic'] ?? '';
    uidUnit = json['uidUnit'] ?? '';
    nameUnit = json['nameUnit'] ?? '';
    count = json['count'];
    price = json['price'];
    discount = json['discount'];
    sum = json['sum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != 0) {
      data['id'] = id;
    }
    data['idOrderCustomer'] = idOrderCustomer;
    data['uid'] = uid;
    data['name'] = name;
    data['uidCharacteristic'] = uidCharacteristic;
    data['nameCharacteristic'] = nameCharacteristic;
    data['uidUnit'] = uidUnit;
    data['nameUnit'] = nameUnit;
    data['count'] = count;
    data['price'] = price;
    data['discount'] = discount;
    data['sum'] = sum;
    return data;
  }
}
