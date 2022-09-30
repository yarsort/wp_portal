
/// Справочник.Договоры партнера
class Contract {
  int id = 0;                     // Инкремент
  int isGroup = 0;                // Пометка удаления
  String uid = '';                // UID для 1С и связи с ТЧ
  String code = '';               // Код для 1С
  String name = '';               // Имя партнера
  String uidParent = '';          // Посилання на группу
  double balance = 0.0;           // Баланс
  double balanceForPayment = 0.0; // Баланс к оплате
  String phone = '';              // Контакты
  String address = '';            // Адрес
  String comment = '';            // Коммментарий
  DateTime dateEdit = DateTime.now(); // Дата редактирования
  String uidOrganization = '';    // Посилання на организацию
  String namePartner = '';        // Имя партнера
  String uidPartner = '';         // Посилання на партнера
  String uidPrice = '';           // Посилання тип цены
  String namePrice = '';          // Имя типа цены
  String uidCurrency = '';        // Посилання валюты
  String nameCurrency = '';       // Имя валюты
  int schedulePayment = 0;        // Отсрочка платежа
  String visitDayOfWeek = '';     // Дни недели посещения менеджером: 1234567
  String visitDayOfMonth = '';    // Дни месяца посещения менеджером: 1-31(30,28,27)
  bool deniedSale = false;        // Запрещено продавать по договору
  bool deniedReturn = false;      // Запрещено возвращать по договору

  Contract();

  Contract.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    isGroup = 0;
    uid = json['uid'] ?? '';
    code = json['code'] ?? '';
    name = json['name'] ?? '';
    uidParent = json['uidParent'] ?? '';
    balance = json['balance'] ?? 0.0;
    balanceForPayment = json['balanceForPayment'] ?? 0.0;
    phone = json['phone'] ?? '';
    address = json['address'] ?? '';
    comment = json['comment'] ?? '';
    dateEdit = DateTime.parse(json['dateEdit'] ?? DateTime.now().toIso8601String());
    uidOrganization = json['uidOrganization'] ?? '';
    uidPartner = json['uidPartner'] ?? '';
    namePartner = json['namePartner'] ?? '';
    uidPrice = json['uidPrice'] ?? '';
    namePrice = json['namePrice'] ?? '';
    uidCurrency = json['uidCurrency'] ?? '';
    nameCurrency = json['nameCurrency'] ?? '';
    schedulePayment = json['schedulePayment'] ?? 0; // Отсрочка платежа в днях (int)
    visitDayOfWeek = json['visitDayOfWeek'] ?? '';
    visitDayOfMonth = json['visitDayOfMonth'] ?? '';
    deniedSale = json['deniedSale'] == 1;
    deniedReturn = json['deniedReturn']  == 1;
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
    data['uidParent'] = uidParent;
    data['balance'] = balance;
    data['balanceForPayment'] = balanceForPayment;
    data['phone'] = phone;
    data['address'] = address;
    data['comment'] = comment;
    data['dateEdit'] = dateEdit.toIso8601String();
    data['uidOrganization'] = uidOrganization;
    data['uidPartner'] = uidPartner;
    data['namePartner'] = namePartner;
    data['uidPrice'] = uidPrice;
    data['namePrice'] = namePrice;
    data['uidCurrency'] = uidCurrency;
    data['nameCurrency'] = nameCurrency;
    data['schedulePayment'] = schedulePayment;
    data['visitDayOfWeek'] = visitDayOfWeek;
    data['visitDayOfMonth'] = visitDayOfMonth;
    data['deniedSale'] = deniedSale ? 1 : 0;
    data['deniedReturn'] = deniedReturn ? 1 : 0;
    return data;
  }
}