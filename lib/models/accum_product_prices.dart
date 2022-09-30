
class AccumProductPrice {
  int id = 0;
  String uidPrice = '';
  String uidProduct = '';
  String uidProductCharacteristic = '';
  String uidUnit = '';
  double price = 0.0;

  AccumProductPrice();

  AccumProductPrice.fromJson(Map<String, dynamic> json) {
    uidPrice = json["uidPrice"]??'';
    uidProduct = json["uidProduct"]??'';
    uidProductCharacteristic = json["uidProductCharacteristic"]??'';
    uidUnit = json["uidUnit"]??'';
    price = json["price"].toDouble()??0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != 0) {
      data['id'] = id;
    }
    data['uidPrice'] = uidPrice;
    data['uidProduct'] = uidProduct;
    data['uidProductCharacteristic'] = uidProductCharacteristic;
    data['uidUnit'] = uidUnit;
    data['price'] = price;
    return data;
  }
}
