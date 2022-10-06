
class AccumPartnerDept {
  DateTime date = DateTime.now();
  String uidOrganization = '';
  String nameOrganization = '';
  String uidPartner = '';
  String namePartner = '';
  String uidContract = '';
  String nameContract = '';
  String uidDoc = '';
  String nameDoc = '';
  double balance = 0.0;
  double balanceUah = 0.0;

  AccumPartnerDept();

  AccumPartnerDept.fromJson(Map<String, dynamic> json) {
    date = DateTime.parse(json["date"]);
    uidOrganization = json["uidOrganization"]??'';
    nameOrganization = json["nameOrganization"]??'';
    uidPartner = json["uidPartner"]??'';
    namePartner = json["namePartner"]??'';
    uidContract = json["uidContract"]??'';
    nameContract = json["nameContract"]??'';
    uidDoc = json["uidDoc"]??'';
    nameDoc = json["nameDoc"]??'';
    balance = double.parse(json["balance"]??0.0);
    balanceUah = double.parse(json["balanceUah"]??0.0);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['uidOrganization'] = uidOrganization;
    data['nameOrganization'] = nameOrganization;
    data['uidPartner'] = uidPartner;
    data['namePartner'] = namePartner;
    data['uidContract'] = uidContract;
    data['nameContract'] = nameContract;
    data['uidDoc'] = uidDoc;
    data['nameDoc'] = nameDoc;
    data['balance'] = balance;
    data['balanceUah'] = balanceUah;
    return data;
  }
}
