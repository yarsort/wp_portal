
/// Система.Сортировка
class Sort {
  int type = 0;                   // Тип сортировки
  String code = '';               // Код для 1С
  String name = '';               // Имя сортировки

  List<Sort> listSortProduct = [];

  Sort();

  Sort.fromJson(Map<String, dynamic> json) {
    type = 0;
    code = json['code'] ?? '';
    name = json['name'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = 0;
    data['code'] = code;
    data['name'] = name;
    return data;
  }

  getSortDefault() {
    getSortProducts();
    return listSortProduct[0];
  }

  getSortProducts() {

    listSortProduct.clear();

    Sort sort1 = Sort();
    sort1.type = 0;
    sort1.code = 'NameASC';
    sort1.name = 'По назві позиції (А-Я)';

    Sort sort2 = Sort();
    sort2.type = 0;
    sort2.code = 'NameDESC';
    sort2.name = 'По назві позиції (Я-А)';

    Sort sort3 = Sort();
    sort3.type = 1;
    sort3.code = 'PriceASC';
    sort3.name = 'Від дешевих до дорогих';

    Sort sort4 = Sort();
    sort4.type = 1;
    sort4.code = 'PriceDESC';
    sort4.name = 'Від дорогих до дешевих';

    listSortProduct.add(sort1);
    listSortProduct.add(sort2);
    listSortProduct.add(sort3);
    listSortProduct.add(sort4);

    return listSortProduct;

  }
}
