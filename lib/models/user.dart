
/// Користувач
class User {
  int id = 0;                     // Инкремент
  int isActive = 0;               // Пометка удаления
  String uid = '';                // UID для 1С и связи с ТЧ
  String code = '';               // Код для 1С
  String name = '';               // Имя
  String nickname = '';           // Псевдонім
  String description = '';        // Опис автомобіля
  DateTime birthday = DateTime(1900,1,1); // Дата народження
  int hideBirthday = 0;           // Сховати день народження
  int rating = 0;                 // Рейтинг користувача
  String comment = '';            // Коммментарий
  String picture = '';            // Картинка головна
  String avatar = '';             // Аватарка головна
  DateTime dateEdit = DateTime.now(); // Дата редактирования
  String token = '';
  int countryId = 0;
  int cityId = 0;
  String phone = '';              // Номер телефону
  String email = '';              // Пошта
  int yearStartDriving = 0;       // Год початку керування авто

  User();

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    isActive = 0;
    uid = json['uid'] ?? '';
    code = json['code'] ?? '';
    name = json['name'] ?? '';
    nickname = json['nickname'] ?? '';
    description = json['description'] ?? '';
    birthday = DateTime.parse(json['birthday'] ?? DateTime(1900,1,1).toIso8601String());
    rating = json['rating'] ?? 0;
    comment = json['comment'] ?? '';
    picture = json['picture'] ?? '';
    dateEdit = DateTime.parse(json['dateEdit'] ?? DateTime.now().toIso8601String());
    token = json['token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != 0) {
      data['id'] = id;
    }
    data['isGroup'] = 0;
    data['uid'] = uid;
    data['code'] = code;
    data['name'] = name;
    data['nickname'] = nickname;
    data['description'] = description;
    data['birthday'] = birthday.toIso8601String();
    data['rating'] = rating;
    data['comment'] = comment;
    data['picture'] = picture;
    data['dateEdit'] = dateEdit.toIso8601String();
    return data;
  }
}
