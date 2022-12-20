class OrderMovement {
  int id = 0;                   // Инкремент
  int postingMode = 0;          // 0-Записан, 1-Проведен, 2-Удален
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
  List<ItemOrderMovement> itemsOrderMovement = [];

  OrderMovement(
      {this.date,
      this.nameOrganization,
      this.nameWarehouseSender,
      this.nameWarehouseReceiver,
      this.status});

  OrderMovement.fromJson(Map<String, dynamic> json) {
    postingMode = int.parse(json["postingMode"]??'0');
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
    numberFrom1C = json['numberFrom1C'] ?? '';
    countItems = json['countItems'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['postingMode'] = postingMode;
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
    data['itemsOrderMovement'] = itemsOrderMovement.map((e) => e.toJson()).toList();
    return data;
  }
}

/// ТЧ Товары, Документы.ЗаказПокупателя
class ItemOrderMovement {
  int numberRow = 0; //
  String uidOrderMovement = ''; // UID для 1С и связи с ТЧ
  String uid = ''; // UID для 1С и связи с ТЧ
  String name = ''; // Название товара
  String uidCharacteristic = ''; // UID для 1С и связи с ТЧ
  String nameCharacteristic = ''; // Название товара
  String uidUnit = ''; // Посилання на единицу измерения товарв
  String nameUnit = ''; // Название единицы измерения
  double countPrepare = 0.0; // Количество товара запланировано
  double countSend = 0.0; //  Количество товара отправлено
  double countReceived = 0.0; // Количество товара получено

  ItemOrderMovement({
    required this.numberRow,
    required this.uidOrderMovement,
    required this.uid,
    required this.name,
    required this.uidCharacteristic,
    required this.nameCharacteristic,
    required this.uidUnit,
    required this.nameUnit,
    required this.countPrepare,
    required this.countSend,
    required this.countReceived,
  });

  ItemOrderMovement.fromJson(Map<String, dynamic> json) {
    numberRow = int.parse(json['numberRow']??'0.0');
    uidOrderMovement = json['uidOrderMovement'];
    uid = json['uid'] ?? '';
    name = json['name'] ?? '';
    uidCharacteristic = json['uidCharacteristic'] ?? '';
    nameCharacteristic = json['nameCharacteristic'] ?? '';
    uidUnit = json['uidUnit'] ?? '';
    nameUnit = json['nameUnit'] ?? '';
    countPrepare = double.parse(json['countPrepare']??'0.0');
    countSend = double.parse(json['countSend']??'0.0');
    countReceived = double.parse(json['countReceived']??'0.0');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uidOrderMovement'] = uidOrderMovement;
    data['uid'] = uid;
    data['name'] = name;
    data['uidCharacteristic'] = uidCharacteristic;
    data['nameCharacteristic'] = nameCharacteristic;
    data['uidUnit'] = uidUnit;
    data['nameUnit'] = nameUnit;
    data['countPrepare'] = countPrepare;
    data['countSend'] = countSend;
    data['countReceived'] = countReceived;
    return data;
  }
}
