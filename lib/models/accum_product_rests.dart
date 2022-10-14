
class AccumProductRest {
  String uidWarehouse = '';
  String nameWarehouse = '';
  String uidProduct = '';
  String uidProductCharacteristic = '';
  String uidUnit = '';
  double count = 0.0;

  AccumProductRest();

  AccumProductRest.fromJson(Map<String, dynamic> json) {
    uidWarehouse = json["uidWarehouse"]??'';
    nameWarehouse = json["nameWarehouse"]??'';
    uidProduct = json["uidProduct"]??'';
    uidProductCharacteristic = json["uidProductCharacteristic"]??'';
    uidUnit = json["uidUnit"]??'';
    count = double.parse(json["count"]??0.0);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uidWarehouse'] = uidWarehouse;
    data['nameWarehouse'] = nameWarehouse;
    data['uidProduct'] = uidProduct;
    data['uidProductCharacteristic'] = uidProductCharacteristic;
    data['uidUnit'] = uidUnit;
    data['count'] = count;
    return data;
  }
}
