import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_b2b/constants.dart';
import 'package:wp_b2b/controllers/accum_partner_debts_controller.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/accum_partner_depts.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/models/doc_order_customer.dart';
import 'package:wp_b2b/models/doc_order_movement.dart';
import 'package:wp_b2b/models/ref_contact.dart';
import 'package:wp_b2b/models/ref_product.dart';
import 'package:wp_b2b/screens/login/login_screen.dart';
import 'package:wp_b2b/system.dart';

///*****************************
/// Системные: Отступы (гор. и верт.)
///*****************************

Widget spaceBetweenColumn() {
  return SizedBox(width: 5);
}

Widget spaceBetweenHeaderColumn() {
  return SizedBox(width: 8);
}

Widget spaceVertBetweenHeaderColumn() {
  return SizedBox(height: 8);
}

///*****************************
/// Товары. Фото товара
///*****************************

class ProductImage extends StatefulWidget {
  const ProductImage({Key? key, required this.product}) : super(key: key);

  final Product product;

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  String pathPicture = '';
  String picture = '';

  _loadPathPictureData() async {
    pathPicture = await getBasePhotoUrl();
    picture = '/${widget.product.uid}_0.png';
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadPathPictureData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: http.get(Uri.parse(pathPicture + picture), headers: {
        HttpHeaders.accessControlAllowOriginHeader: '*',
      }),
      builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Icon(
              Icons.image,
              color: Colors.white24,
            );
          case ConnectionState.active:
            return Icon(
              Icons.image,
              color: Colors.white24,
            );
          case ConnectionState.waiting:
            return SizedBox(
              height: 50,
              width: 50,
              child: Center(
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: Colors.blue.withOpacity(0.5),
                  ),
                ),
              ),
            );
          case ConnectionState.done:
            if (snapshot.hasError)
              return SizedBox(
                height: 50,
                width: 50,
                child: Icon(
                  Icons.image,
                  color: Colors.blue.withOpacity(0.5),
                ),
              );

            // when we get the data from the http call, we give the bodyBytes to Image.memory for showing the image
            if (snapshot.data!.statusCode == 200) {
              return GestureDetector(
                  onTap: () async {
                    await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            content: Text(widget.product.name, style: TextStyle(color: Colors.black)),
                            actions: <Widget>[
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 300, height: 300, child: Image.memory(snapshot.data!.bodyBytes)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                                          onPressed: () async {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: const Text('Відміна'))
                                    ],
                                  )
                                ],
                              ),
                            ],
                          );
                        });
                  },
                  child: SizedBox(height: 50, width: 50, child: Image.memory(snapshot.data!.bodyBytes)));
            } else {
              return SizedBox(
                height: 50,
                width: 50,
                child: Icon(
                  Icons.image,
                  color: Colors.blue.withOpacity(0.5),
                ),
              );
            }
        }
      },
    );
  }
}

///*****************************
/// Товары. Окно ввода количества товара
///*****************************

class CountWindow extends StatefulWidget {
  final OrderCustomer? orderCustomer;
  final OrderMovement? orderMovement;
  final Product product;
  final ProductCharacteristic productCharacteristic;
  final double countOnWarehouse;
  final double price;

  const CountWindow(
      {Key? key,
      this.orderCustomer,
      this.orderMovement,
      required this.product,
      required this.productCharacteristic,
      required this.countOnWarehouse,
      required this.price})
      : super(key: key);

  @override
  State<CountWindow> createState() => _CountWindowState();
}

class _CountWindowState extends State<CountWindow> {
  TextEditingController textFieldProductController = TextEditingController();
  TextEditingController textFieldProductCharacteristicController = TextEditingController();
  TextEditingController textFieldPriceController = TextEditingController();
  TextEditingController textFieldCountController = TextEditingController();

  @override
  void initState() {
    _loadData();

    textFieldCountController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: textFieldCountController.text.length,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 252,
      child: Column(
        children: [
          SizedBox(
            height: 20,
            width: 350,
            child: Text('Назва товару'),
          ),
          SizedBox(
            height: 40,
            width: 350,
            child: TextField(
              style: TextStyle(fontSize: 14),
              readOnly: true,
              controller: textFieldProductController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                fillColor: bgColor,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
              ),
            ),
          ),
          spaceVertBetweenHeaderColumn(),
          SizedBox(
            height: 20,
            width: 350,
            child: Text('Характеристика товару'),
          ),
          SizedBox(
            height: 40,
            width: 350,
            child: TextField(
              style: TextStyle(fontSize: 14),
              readOnly: true,
              controller: textFieldProductCharacteristicController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                fillColor: bgColor,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
              ),
            ),
          ),
          spaceVertBetweenHeaderColumn(),
          Row(
            children: [
              SizedBox(
                height: 20,
                width: 170,
                child: Text('Ціна'),
              ),
              spaceBetweenColumn(),
              spaceBetweenColumn(),
              SizedBox(
                height: 20,
                width: 170,
                child: Text('Кількість'),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                height: 40,
                width: 170,
                child: TextField(
                  style: TextStyle(fontSize: 14),
                  readOnly: true,
                  controller: textFieldPriceController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                    fillColor: bgColor,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ),
              ),
              spaceBetweenColumn(),
              spaceBetweenColumn(),
              SizedBox(
                height: 40,
                width: 170,
                child: TextField(
                  onSubmitted: (value) async {
                    await _addToDocument();
                    Navigator.of(context).pop(false);
                  },
                  style: TextStyle(fontSize: 14),
                  autofocus: true,
                  keyboardType: TextInputType.numberWithOptions(),
                  controller: textFieldCountController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                    fillColor: bgColor,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ),
              )
            ],
          ),
          spaceVertBetweenHeaderColumn(),
          spaceVertBetweenHeaderColumn(),
          Row(
            children: [
              SizedBox(
                height: 40,
                width: 170,
                child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blue)),
                    onPressed: () async {
                      await _addToDocument();
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Додати')),
              ),
              spaceBetweenColumn(),
              spaceBetweenColumn(),
              SizedBox(
                height: 40,
                width: 170,
                child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                    onPressed: () async {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Відміна')),
              )
            ],
          ),
        ],
      ),
    );
  }

  _loadData() {
    textFieldProductController.text = widget.product.name;
    textFieldProductCharacteristicController.text = widget.productCharacteristic.name;
    textFieldPriceController.text = doubleToString(widget.price);

    // Найдем индекс строки товара в документе по товару который добавляем
    var indexItem = widget.orderCustomer?.itemsOrderCustomer.indexWhere((element) =>
            element.uid == widget.product.uid && element.uidCharacteristic == widget.productCharacteristic.uid) ??
        -1;

    // Если нашли товар в списке документа
    double count = 0;
    if (indexItem >= 0) {
      var itemList = widget.orderCustomer?.itemsOrderCustomer[indexItem];
      count = itemList?.count ?? 0 + 1;
    } else {
      count = 1;
    }

    textFieldCountController.text = doubleToString(count);
  }

  _addToDocument() {
    double count = 0;
    try {
      count = double.parse(textFieldCountController.text);
    } on Error catch (e) {
      showErrorMessage(e.toString(), context);
    }

    String uidUnit = widget.product.uidUnit;
    String nameUnit = widget.product.nameUnit;
    double price = widget.price;
    double discount = 0.0;
    double sum = price * count;

    // Найдем индекс строки товара в документе по товару который добавляем
    var indexItem = widget.orderCustomer?.itemsOrderCustomer.indexWhere((element) =>
            element.uid == widget.product.uid && element.uidCharacteristic == widget.productCharacteristic.uid) ??
        -1;

    // Если нашли товар в списке документа
    if (indexItem >= 0) {
      var itemList = widget.orderCustomer?.itemsOrderCustomer[indexItem];
      itemList?.price = price;
      itemList?.count = count;
      itemList?.discount = discount;
      itemList?.sum = count * price;
    } else {
      var countElements = widget.orderCustomer?.itemsOrderCustomer.length ?? 0;

      ItemOrderCustomer itemOrderCustomer = ItemOrderCustomer(
          uidOrderCustomer: widget.orderCustomer?.uid ?? '',
          numberRow: countElements + 1,
          uid: widget.product.uid,
          name: widget.product.name,
          uidCharacteristic: widget.productCharacteristic.uid,
          nameCharacteristic: widget.productCharacteristic.name,
          uidUnit: uidUnit,
          nameUnit: nameUnit,
          count: count,
          price: price,
          discount: discount,
          sum: sum);

      widget.orderCustomer?.itemsOrderCustomer.add(itemOrderCustomer);
    }
    showMessage('В документ додано товар: ' + widget.product.name, context);

    setState(() {});
  }
}

///*****************************
/// Профиль: Поиск данных
///*****************************

class PortalSearch extends StatefulWidget {
  const PortalSearch(
      {Key? key, required this.onSubmittedSearch, required this.onTapClear, required this.textFieldSearchController})
      : super(key: key);

  final void Function(String) onSubmittedSearch;
  final void Function() onTapClear;
  final TextEditingController textFieldSearchController;

  @override
  State<PortalSearch> createState() => _PortalSearchState();
}

class _PortalSearchState extends State<PortalSearch> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 400,
      child: TextField(
        controller: widget.textFieldSearchController,
        onSubmitted: widget.onSubmittedSearch,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 0, 10, 0),
          hintText: 'Пошук',
          hintStyle: TextStyle(color: fontColorGrey),
          fillColor: bgColor,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              child: Icon(
                Icons.search,
                color: iconColor,
              ),
            ),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
            child: InkWell(
              onTap: widget.onTapClear,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

///*****************************
/// Профиль: Долги партнера
///*****************************

class PortalDebtsPartners extends StatefulWidget {
  const PortalDebtsPartners({Key? key}) : super(key: key);

  @override
  State<PortalDebtsPartners> createState() => _PortalDebtsPartnersState();
}

class _PortalDebtsPartnersState extends State<PortalDebtsPartners> {
  bool loadingData = false;

  List<AccumPartnerDept> listAccumPartnerDept = [];

  double totalBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        border: Border.all(color: Colors.white10),
      ),
      child: SizedBox(
        height: 24,
        child: Row(
          children: [
            SizedBox(width: 26, child: Icon(Icons.monetization_on_outlined, color: iconColor)),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                child: Text(doubleToString(totalBalance))),
            SizedBox(
              width: 25,
              child: PopupMenuButton<AccumPartnerDept>(
                iconSize: 25,
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: iconColor,
                ),
                itemBuilder: (BuildContext context) {
                  return listAccumPartnerDept.map<PopupMenuItem<AccumPartnerDept>>((AccumPartnerDept value) {
                    return PopupMenuItem(
                        child: Text(value.namePartner + ' -  ${doubleToString(value.balanceUah)}'), value: value);
                  }).toList();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _loadData() async {
    await _loadAccumPartnerDebts();
    setState(() {});
  }

  /// LOADING DATA

  _loadAccumPartnerDebts() async {
    ApiResponse response = await getAccumPartnerDebts();

    // Read response
    if (response.error == null) {
      setState(() {
        totalBalance = 0.0;
        listAccumPartnerDept.clear();
        for (var item in response.data as List<dynamic>) {
          listAccumPartnerDept.add(item);
          totalBalance = totalBalance + item.balanceUah;
        }

        loadingData = loadingData ? !loadingData : loadingData;
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {Navigator.restorablePushNamed(context, LoginScreen.routeName)});
    } else {
      showErrorMessage('${response.error}', context);
    }

    loadingData = false;
  }
}

///*****************************
/// Профиль: Номера телефонов
///*****************************

class PortalPhonesAddresses extends StatefulWidget {
  const PortalPhonesAddresses({Key? key}) : super(key: key);

  @override
  State<PortalPhonesAddresses> createState() => _PortalPhonesAddressesState();
}

class _PortalPhonesAddressesState extends State<PortalPhonesAddresses> {
  List<Contact> listContacts = [];

  _addContacts() async {
    listContacts.addAll(await getCompanyPhones());

    setState(() {});
  }

  @override
  void initState() {
    _addContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        border: Border.all(color: Colors.white10),
      ),
      child: SizedBox(
        height: 24,
        child: Row(
          children: [
            SizedBox(width: 26, child: Icon(Icons.phone, color: iconColor)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2), child: Text('Телефони')),
            SizedBox(
              width: 25,
              child: PopupMenuButton<Contact>(
                iconSize: 25,
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: iconColor,
                ),
                itemBuilder: (BuildContext context) {
                  return listContacts.map<PopupMenuItem<Contact>>((Contact value) {
                    return PopupMenuItem(child: Text(value.phone + ' ${value.name}'), value: value);
                  }).toList();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///*****************************
/// Профиль: Имя пользователя
///*****************************

class PortalProfileName extends StatefulWidget {
  const PortalProfileName({Key? key}) : super(key: key);

  @override
  State<PortalProfileName> createState() => _PortalProfileNameState();
}

class _PortalProfileNameState extends State<PortalProfileName> {
  String profileName = '';

  _loadProfileData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    profileName = pref.getString('settings_profileName') ?? '';
    setState(() {});
  }

  @override
  void initState() {
    _loadProfileData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        border: Border.all(color: Colors.white10),
      ),
      child: SizedBox(
        height: 24,
        child: Row(
          children: [
            Icon(Icons.person, color: iconColor),
            Padding(padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2), child: Text(profileName)),
          ],
        ),
      ),
    );
  }
}
