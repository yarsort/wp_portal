import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_b2b/constants.dart';
import 'package:wp_b2b/controllers/MenuController.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/price_controller.dart';
import 'package:wp_b2b/controllers/product_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/controllers/warehouse_controller.dart';
import 'package:wp_b2b/models/accum_product_prices.dart';
import 'package:wp_b2b/models/accum_product_rests.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/models/doc_order_customer.dart';
import 'package:wp_b2b/models/doc_order_movement.dart';
import 'package:wp_b2b/models/ref_price.dart';
import 'package:wp_b2b/models/ref_product.dart';
import 'package:wp_b2b/models/ref_warehouse.dart';
import 'package:wp_b2b/screens/login/login_screen.dart';
import 'package:wp_b2b/screens/side_menu/side_menu.dart';
import 'package:wp_b2b/system.dart';
import 'package:wp_b2b/widgets.dart';

// Ціни товарів
List<AccumProductPrice> listProductPrice = [];

// Залишки товарів
List<AccumProductRest> listProductRest = [];

String uidPrice = '';
String uidWarehouse = '';
String pathPicture = '';

//'https://rsvmoto.com.ua/files/resized/products/${widget.product.uid}_1.55x55.png'

bool showOnlyWithRests = false;

class ProductListSelectionScreen extends StatefulWidget {
  final OrderCustomer? orderCustomer;
  final OrderMovement? orderMovement;

  static const routeName = '/products';

  const ProductListSelectionScreen({Key? key, this.orderCustomer, this.orderMovement}) : super(key: key);

  @override
  State<ProductListSelectionScreen> createState() => _ProductListSelectionScreenState();
}

class _ProductListSelectionScreenState extends State<ProductListSelectionScreen> {
  bool loadingData = false;
  String profileName = '';
  bool showProductHierarchy = true;

  TextEditingController textFieldSearchCatalogController = TextEditingController();

  /// Поле ввода: Тип цены
  TextEditingController textFieldPriceController = TextEditingController();

  /// Поле ввода: Склад
  TextEditingController textFieldWarehouseController = TextEditingController();

  // Список товарів для вывода на экран
  List<Product> listDataProducts = []; // Список всіх товарів з сервера
  List<Product> listProducts = [];
  List<Product> listProductsForListView = [];

  // Список каталогов для построения иерархии
  List<Product> treeParentItems = [];

  // Список идентификаторов товарів для поиска цен и остатков
  List<String> listProductsUID = [];
  List<String> listPricesUID = [];
  List<String> listWarehousesUID = [];

  List<Warehouse> listWarehouses = [];
  List<Price> listPrices = [];

  // Текущий выбранный каталог иерархии товарів
  Product parentProduct = Product();

  // Количество элементов в автозагрузке списка
  int _currentMax = 0;
  int countLoadItems = 35;

  Warehouse warehouse = Warehouse();
  Price price = Price();

  /// MAIN

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      key: context.read<MenuController>().scaffoldProductsKey,
      drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              Expanded(
                flex: 1,
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(),
              ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                primary: true,
                child: Column(
                  children: [
                    headerPage(),
                    Container(
                      //height: MediaQuery.of(context).size.height,
                      color: bgColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: defaultPadding,
                        vertical: defaultPadding,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                textFieldsDocumentDesktop(),
                                spaceVertBetweenHeaderColumn(),
                                itemsProductList()
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _loadData() async {
    await _loadPathPictureData();
    await _loadProfileData();
    setState(() {});
    await _renewItem();
    await _loadWarehouses();
    await _loadPrices();
    await _updateHeader();
  }

  _loadPathPictureData() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    pathPicture = prefs.getString('settings_photoServerExchange') ?? '';
  }

  _loadProfileData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    profileName = pref.getString('settings_profileName') ?? '';
  }

  _loadWarehouses() async {
    ApiResponse response = await getWarehouses();

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          // Skip warehouse if item not from document 'Order customer'
          if (widget.orderCustomer != null) {
            if (widget.orderCustomer!.uidWarehouse != item.uid) {
              continue;
            }
          }
          // Skip warehouse if item not from document 'Order movement'
          if (widget.orderMovement != null) {
            if (widget.orderMovement!.uidWarehouseSender != item.uid) {
              continue;
            }
          }

          listWarehouses.add(item);
        }

        warehouse = listWarehouses[0];

        loadingData = loadingData ? !loadingData : loadingData;
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {Navigator.restorablePushNamed(context, LoginScreen.routeName)});
    } else {
      showErrorMessage('${response.error}', context);
    }

    setState(() {
      loadingData = false;
    });
  }

  _loadPrices() async {
    // Request to server
    ApiResponse response = await getPrices();

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          listPrices.add(item);
        }

        price = listPrices[0];

        loadingData = loadingData ? !loadingData : loadingData;
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {Navigator.restorablePushNamed(context, LoginScreen.routeName)});
    } else {
      showErrorMessage('${response.error}', context);
    }

    setState(() {
      loadingData = false;
    });
  }

  _updateHeader() async {
    textFieldPriceController.text = price.name;
    textFieldWarehouseController.text = warehouse.name;
  }

  Future<List<Product>> _getProductsByParent(uidParentProduct) async {
    List<Product> listToReturn = [];

    // Request to server
    ApiResponse response = await getProductsByParent(uidParentProduct);

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          listToReturn.add(item);
        }
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {Navigator.restorablePushNamed(context, LoginScreen.routeName)});
    } else {
      showErrorMessage('${response.error}', context);
    }

    return listToReturn;
  }

  Future<List<Product>> _getProductsForSearch(searchString) async {
    List<Product> listToReturn = [];

    // Request to server
    ApiResponse response = await getProductsForSearch(searchString);

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          listToReturn.add(item);
        }
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {Navigator.restorablePushNamed(context, LoginScreen.routeName)});
    } else {
      showErrorMessage('${response.error}', context);
    }

    return listToReturn;
  }

  _renewItem() async {
    _currentMax = 0;

    // Главный каталог всегда будет с таким идентификатором
    if (parentProduct.uid == '') {
      parentProduct.uid = '00000000-0000-0000-0000-000000000000';
    }

    /// Очистка данных
    setState(() {
      listProducts.clear();
      listProductsUID.clear();

      /// Получим остатки и цены по найденным товарам
      listProductPrice.clear();
      listProductRest.clear();
    });

    ///Первым в список добавим каталог товарів, если он есть
    if (showProductHierarchy) {
      if (parentProduct.uid != '00000000-0000-0000-0000-000000000000') {
        listProducts.add(parentProduct);
      }
    }

    /// Завантаження даних з сервера
    if (showProductHierarchy) {
      // Покажем товары текущего родителя
      listDataProducts = await _getProductsByParent(parentProduct.uid);
    } else {
      String searchString = textFieldSearchCatalogController.text.trim().toLowerCase();
      if (searchString.toLowerCase().length >= 3) {
        // Покажем все товары для поиска
        listDataProducts = await _getProductsForSearch(searchString);
      } else {
        // Покажем все товары
        listDataProducts = await _getProductsByParent('00000000-0000-0000-0000-000000000000');
      }
    }

    /// Сортировка списка: сначала каталоги, потом элементы
    listDataProducts.sort((a, b) => a.name.compareTo(b.name));
    listDataProducts.sort((b, a) => a.isGroup.compareTo(b.isGroup));

    /// Заполним список товарів для отображения на форме
    for (var newItem in listDataProducts) {
      // Пропустим сам каталог, потому что он добавлен первым до заполнения
      if (newItem.uid == parentProduct.uid) {
        continue;
      }

      // Если надо показывать иерархию элементов
      if (showProductHierarchy) {
        // Если у товара родитель не является текущим выбранным каталогом
        if (newItem.uidParent != '00000000-0000-0000-0000-000000000000') {
          if (newItem.uidParent != parentProduct.uid) {
            continue;
          }
        }
      } else {
        // Без иерархии показывать каталоги нельзя!
        if (newItem.isGroup == 1) {
          continue;
        }
      }

      // Вывод только каталогов
      if (newItem.isGroup == 0) {
        continue;
      }

      // Добавим товар
      listProducts.add(newItem);
    }

    /// Заполним список товарів для отображения на форме
    for (var newItem in listDataProducts) {
      // Вивід тільки товарів
      if (newItem.isGroup == 1) {
        continue;
      }

      // Добавим товар
      listProducts.add(newItem);
    }

    listProductsForListView.clear(); // Список для отображения на форме
    await _loadAdditionalProductsToView();

    setState(() {});
  }

  _loadAccumProductPriceByUIDProducts(listPrices, listProductsUID) async {
    List<AccumProductPrice> listToReturn = [];

    // Request to server
    ApiResponse response = await getAccumProductPriceByUIDProducts(listPrices, listProductsUID);

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          listToReturn.add(item);
        }
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {Navigator.restorablePushNamed(context, LoginScreen.routeName)});
    } else {
      showErrorMessage('${response.error}', context);
    }

    return listToReturn;
  }

  _loadAccumProductRestByUIDProducts(listWarehouses, listProductsUID) async {
    List<AccumProductRest> listToReturn = [];

    // Request to server
    ApiResponse response = await getAccumProductRestByUIDProducts(listWarehouses, listProductsUID);

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          listToReturn.add(item);
        }
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {Navigator.restorablePushNamed(context, LoginScreen.routeName)});
    } else {
      showErrorMessage('${response.error}', context);
    }

    return listToReturn;
  }

  _loadPriceAndRests() async {
    if (listProductsUID.isEmpty) {
      //debugPrint('Немає UIDs для виведення залишківс та цін...');
      return;
    }

    if (widget.orderCustomer != null) {
      uidPrice = widget.orderCustomer!.uidPrice;
    }
    if (widget.orderCustomer != null) {
      uidWarehouse = widget.orderCustomer!.uidWarehouse;
    }

    if (listPricesUID.isEmpty) {
      listPricesUID.add(uidPrice);
    }

    if (listWarehousesUID.isEmpty) {
      listWarehousesUID.add(uidWarehouse);
    }

    /// Ціни товарів
    listProductPrice = await _loadAccumProductPriceByUIDProducts(listPricesUID, listProductsUID);

    /// Залишки товарів
    listProductRest = await _loadAccumProductRestByUIDProducts(listWarehousesUID, listProductsUID);

    setState(() {});
  }

  _loadAdditionalProductsToView() async {
    /// Получим первые товары на экран
    for (int i = _currentMax; i < _currentMax + countLoadItems; i++) {
      if (i < listProducts.length) {
        listProductsForListView.add(listProducts[i]);
      }
    }

    _currentMax = _currentMax + countLoadItems;
    _currentMax++; // Для пункта "Показать больше"

    // Добавим пункт "Показать больше"
    if (listProducts.length > listProductsForListView.length) {
      listProductsForListView.add(Product()); // Добавим пустой товар
    }

    /// Получим список товарів для которых надо показать цены и остатки
    for (var itemList in listProductsForListView) {
      // Проверка на каталог. Если товар, то грузим.
      if (itemList.isGroup == 0) {
        listProductsUID.add(itemList.uid); // Добавим для поиска цен и остатков
        //debugPrint('Получение товара: ' + itemList.name);
      }
    }

    await _loadPriceAndRests();

    setState(() {});
  }

  addItemToDocument(product, productCharacteristic, countOnWarehouse, priceOnWarehouse) {
    // Контроль добавления товара, если на остатке его нет
    // bool deniedAddProductWithoutRest =
    // prefs.getBool('settings_deniedAddProductWithoutRest')!;
    // if (deniedAddProductWithoutRest) {
    //   if (count * selectedUnit.multiplicity > countOnWarehouse) {
    //     showErrorMessage('Товару недостатньо на залишку!', context);
    //     return false;
    //   }
    // }
    // if (price == 0.0) {
    //   showErrorMessage('Товар без ціни!', context);
    //   return false;
    // }

    if (productCharacteristic.uid != '') {
      // Обнулення!
      countOnWarehouse = 0.0;

      // Знайдемо загальні залишки по виду товару
      var selectedListProductRest =
          listProductRest.where((element) => element.uidProductCharacteristic == productCharacteristic.uid).toList();

      for (var itemList in selectedListProductRest) {
        countOnWarehouse = countOnWarehouse + itemList.count;
      }
    }

    if (countOnWarehouse == 0) {
      showErrorMessage('Товару недостатньо на залишку!', context);
      return false;
    }

    String uidUnit = product.uidUnit;
    String nameUnit = product.nameUnit;

    double price = priceOnWarehouse;
    double count = 1;
    double discount = 0.0;
    double sum = price * count;

    // Найдем индекс строки товара в документе по товару который добавляем
    var indexItem = widget.orderCustomer?.itemsOrderCustomer.indexWhere(
            (element) => element.uid == product.uid && element.uidCharacteristic == productCharacteristic.uid) ??
        -1;

    // Если нашли товар в списке документа
    if (indexItem >= 0) {
      var itemList = widget.orderCustomer?.itemsOrderCustomer[indexItem];

      count = itemList?.count ?? 0 + 1;
      count = count + 1;

      itemList?.price = price;
      itemList?.count = count;
      itemList?.discount = discount;
      itemList?.sum = count * price;
    } else {
      var countElements = widget.orderCustomer?.itemsOrderCustomer.length ?? 0;

      ItemOrderCustomer itemOrderCustomer = ItemOrderCustomer(
          uidOrderCustomer: widget.orderCustomer?.uid ?? '',
          numberRow: countElements + 1,
          uid: product.uid,
          name: product.name,
          uidCharacteristic: productCharacteristic.uid,
          nameCharacteristic: productCharacteristic.name,
          uidUnit: uidUnit,
          nameUnit: nameUnit,
          count: count,
          price: price,
          discount: discount,
          sum: sum);

      widget.orderCustomer?.itemsOrderCustomer.add(itemOrderCustomer);
    }
    showMessage('В документ додано товар: ' + product.name, context);
  }

  /// HEADER

  Widget getItemSmallPicture(item) {
    return FutureBuilder(
      // Paste your image URL inside the htt.get method as a parameter
      future: http.get(Uri.parse(pathPicture + '/${item.uid}_0.png'), headers: {
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
              height: 25,
              width: 25,
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
                height: 25,
                width: 25,
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
                            content: Text(item.name, style: TextStyle(color: Colors.black)),
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
                height: 25,
                width: 25,
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

  Widget headerPage() {
    return Container(
      height: 115,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.3))),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 3,
              offset: const Offset(0, 2), // changes position of shadow
            ),
          ]),
      child: Column(
        children: [
          /// Search
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [searchFieldWidget(), Spacer(), profileNameWidget()],
            ),
          ),

          /// Divider
          Divider(),

          /// Name of page
          Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                children: [
                  /// If this window use like separated windows without document
                  if (widget.orderCustomer != null || widget.orderMovement != null)
                    GestureDetector(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.blue,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),

                  /// Show icon if not for selection goods to document
                  if (widget.orderCustomer == null && widget.orderMovement == null)
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: Icon(
                        Icons.receipt_long,
                        color: Colors.blue,
                      ),
                    ),
                  if (widget.orderCustomer != null && widget.orderMovement == null)
                    Text('ПІДБІР ТОВАРІВ В ЗАМОВЛЕННЯ ПОКУПЦЯ',
                        style: TextStyle(color: fontColorDarkGrey, fontSize: 16, fontWeight: FontWeight.bold)),
                  if (widget.orderCustomer == null && widget.orderMovement != null)
                    Text('ПІДБІР ТОВАРІВ В ПЕРЕМІЩЕННЯ ТОВАРІВ',
                        style: TextStyle(color: fontColorDarkGrey, fontSize: 16, fontWeight: FontWeight.bold)),
                  if (widget.orderCustomer == null && widget.orderMovement == null)
                    Text('ТОВАРИ ТА ПОСЛУГИ',
                        style: TextStyle(color: fontColorDarkGrey, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              )),
        ],
      ),
    );
  }

  Widget searchFieldWidget() {
    return SizedBox(
      height: 40,
      width: 400,
      child: TextField(
        controller: textFieldSearchCatalogController,
        onSubmitted: (text) async {
          if (textFieldSearchCatalogController.text == '') {
            showProductHierarchy = true;
            parentProduct = Product();
            treeParentItems.clear();
            await _renewItem();
            return;
          }

          // Вимкнемо ієрархічний просмотр
          if (showProductHierarchy) {
            showProductHierarchy = false;
            parentProduct = Product();
            treeParentItems.clear();
            //showMessage('Ієрархія товарів вимкнена.', context);
          }
          await _renewItem();
        },
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
            child: InkWell(
              onTap: () async {
                if (textFieldSearchCatalogController.text == '') {
                  //await _renewItem();
                  return;
                }
                //await _renewItem();
              },
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
          ),
        ),
      ),
    );
  }

  Widget profileNameWidget() {
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
            Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget textFieldsDocumentDesktop() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Price
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Spacer(),
                              Text('Тип ціни:'),
                              spaceBetweenColumn(),
                            ],
                          )),
                      Expanded(
                          flex: 5,
                          child: SizedBox(
                            height: 40,
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
                                suffixIcon: PopupMenuButton<Price>(
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                  onSelected: (Price value) {
                                    setState(() {
                                      price = value;
                                    });
                                    _updateHeader();
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return listPrices.map<PopupMenuItem<Price>>((Price value) {
                                      return PopupMenuItem(child: Text(value.name), value: value);
                                    }).toList();
                                  },
                                ),
                              ),
                            ),
                          ))
                    ],
                  )),
              spaceBetweenHeaderColumn(),

              /// Warehouse
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Spacer(),
                              Text('Склад:'),
                              spaceBetweenColumn(),
                            ],
                          )),
                      Expanded(
                          flex: 5,
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              style: TextStyle(fontSize: 14),
                              readOnly: true,
                              controller: textFieldWarehouseController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                                fillColor: bgColor,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                                ),
                                suffixIcon: PopupMenuButton<Warehouse>(
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                  onSelected: (Warehouse value) {
                                    setState(() {
                                      warehouse = value;
                                    });
                                    _updateHeader();
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return listWarehouses.map<PopupMenuItem<Warehouse>>((Warehouse value) {
                                      return PopupMenuItem(child: Text(value.name), value: value);
                                    }).toList();
                                  },
                                ),
                              ),
                            ),
                          ))
                    ],
                  )),
              spaceBetweenHeaderColumn(),

              /// Checkboxes
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: checkboxColor,
                        checkColor: secondaryColor,
                        value: showOnlyWithRests,
                        onChanged: (value) {
                          setState(() {
                            setState(() {
                              showOnlyWithRests = !showOnlyWithRests;
                            });
                            //_renewItem();
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                        child: Text('В наявності'),
                      ),
                      Checkbox(
                        activeColor: checkboxColor,
                        checkColor: secondaryColor,
                        value: showProductHierarchy,
                        onChanged: (value) {
                          setState(() {
                            textFieldSearchCatalogController.text = '';
                            showProductHierarchy = !showProductHierarchy;
                            _renewItem();
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                        child: Text('Ієрархія'),
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }

  /// LISTS

  Widget itemsProductList() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Actions
          Padding(
            padding: const EdgeInsets.all(defaultPadding * 1.5),
            child: Row(
              children: [
                Text('Список товарів', style: TextStyle(color: fontColorDarkGrey, fontSize: 16)),

                /// Space
                Spacer(),
              ],
            ),
          ),

          /// Header of goods
          Container(
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  top: BorderSide(color: Colors.grey.withOpacity(0.3))),
              //color: Colors.grey.withOpacity(0.3),
              color: bgColorHeader,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(defaultPadding, defaultPadding, defaultPadding * 2, defaultPadding),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('Фото',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  Expanded(
                    flex: 9,
                    child: Text('Назва',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Артикул',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Од. вим.',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Кількість',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Залишок',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Ціна',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Сума', style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Icon(
                      Icons.add_shopping_cart_outlined,
                      color: fontColorDarkGrey,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// List of goods
          Row(
            children: [
              Expanded(
                flex: 1,
                child: listProductsForListView.isNotEmpty
                    ? ListView.builder(
                        padding: EdgeInsets.all(0.0),
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: listProductsForListView.length,
                        itemBuilder: (context, index) {
                          var productItem = listProductsForListView[index];
                          var count = 0.0;
                          var price = 0.0;
                          var countOnWarehouse = 0.0;

                          var indexItemPrice = listProductPrice.indexWhere(
                              (element) => element.uidProduct == productItem.uid && element.uidPrice == uidPrice);
                          if (indexItemPrice >= 0) {
                            var itemList = listProductPrice[indexItemPrice];
                            price = itemList.price;
                          } else {
                            price = 0.0;
                          }

                          /// Знайдемо загальні залишки
                          var selectedListProductRest =
                              listProductRest.where((element) => element.uidProduct == productItem.uid).toList();

                          for (var itemList in selectedListProductRest) {
                            countOnWarehouse = countOnWarehouse + itemList.count;
                          }

                          /// Якщо це строка "Показати більше"
                          if (productItem.uid == '') {
                            return rowDataMoreProducts(productItem);
                          }

                          /// Якщо це група товарів
                          if (productItem.isGroup == 1) {
                            return rowDataGroupItemProduct(productItem);
                          }

                          /// Якщо це товар і показувати тільки із залишком
                          if (productItem.isGroup == 0 && showOnlyWithRests && countOnWarehouse == 0) {
                            return Container();
                          }

                          /// Якщо це товар
                          if (productItem.isGroup == 0) {
                            return ProductItemListView(
                                product: productItem,
                                countOnWarehouse: countOnWarehouse,
                                price: price,
                                orderCustomer: widget.orderCustomer);
                          }

                          return Container();
                        })
                    : SizedBox(height: 50, child: Center(child: Text('Список товарів порожній!'))),
              )
            ],
          ),

          /// Footer of goods
          Container(
            decoration: BoxDecoration(
              border: Border(
                  //bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  //top: BorderSide(color: Colors.grey.withOpacity(0.3))
                  ),
              color: secondaryColor,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(defaultPadding, defaultPadding, defaultPadding * 2, defaultPadding),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text('', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget rowDataGroupItemProduct(Product item) {
    return GestureDetector(
      onTap: () async {
        if (item.uid == parentProduct.uid) {
          if (treeParentItems.isNotEmpty) {
            // Назначим нового родителя выхода из узла дерева
            parentProduct = treeParentItems[treeParentItems.length - 1];

            // Удалим старого родителя для будущего узла
            treeParentItems.remove(treeParentItems[treeParentItems.length - 1]);
          } else {
            // Отправим дерево на его самый главный узел
            parentProduct = Product();
          }
          _renewItem();
        } else {
          treeParentItems.add(parentProduct);
          parentProduct = item;
          _renewItem();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: defaultPadding,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          color: item.uid != parentProduct.uid ? tileColor : Color.fromRGBO(236, 238, 243, 1),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding,
                ),
                child: Icon(
                  Icons.folder,
                  color: Colors.blue,
                ),
              ),
            ),
            Expanded(
              flex: 20,
              child: Text(item.name),
            ),
            Expanded(
              flex: 1,
              child: Icon(
                Icons.add_shopping_cart_outlined,
                color: tileSelectedColor.withOpacity(0.5),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rowDataMoreProducts(Product item) {
    return GestureDetector(
      onTap: () async {
        // Удалим пункт "Показать больше"
        _currentMax--; // Для пункта "Показать больше"
        listProductsForListView.remove(item);
        _loadAdditionalProductsToView();
        setState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          // horizontal: defaultPadding,
          vertical: defaultPadding,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          color: tileColor,
        ),
        child: Text(
          'ПОКАЗАТИ БІЛЬШЕ ПОЗИЦІЙ',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
      ),
    );
  }
}

class ProductItemListView extends StatefulWidget {
  final OrderCustomer? orderCustomer;
  final OrderMovement? orderMovement;
  final Product product;
  final double countOnWarehouse;
  final double price;

  const ProductItemListView({
    Key? key,
    this.orderCustomer,
    this.orderMovement,
    required this.product,
    required this.countOnWarehouse,
    required this.price,
  }) : super(key: key);

  @override
  State<ProductItemListView> createState() => _ProductItemListViewState();
}

class _ProductItemListViewState extends State<ProductItemListView> {
  // Характеристики товарів
  List<ProductCharacteristic> listProductCharacteristic = [];

  // Залишки товарів по складам
  List<AccumProductRest> listRestsByWarehouse = [];

  bool visibleListCharacteristics = false;

  _loadData() async {
    await _getCharacteristics();
  }

  _getCharacteristics() async {
    if (listProductCharacteristic.length > 0) {
      return;
    }

    // Request to server
    ApiResponse response = await getProductCharacteristic(widget.product.uid);

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          listProductCharacteristic.add(item);
        }
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {Navigator.restorablePushNamed(context, LoginScreen.routeName)});
    } else {
      showErrorMessage('${response.error}', context);
    }
  }

  _getRestsByWarehouse(productCharacteristic) async {
    listRestsByWarehouse.clear();

    // Знайдемо загальні залишки
    var selectedListProductRest =
        listProductRest.where((element) => element.uidProductCharacteristic == productCharacteristic.uid).toList();

    // Заповнимо список залишків по складу для вибраного виду товару
    setState(() {
      listRestsByWarehouse.addAll(selectedListProductRest);
    });
  }

  _addItemToDocument(productCharacteristic, count, price) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              content: CountWindow(
                  orderCustomer: widget.orderCustomer,
                  orderMovement: widget.orderMovement,
                  product: widget.product,
                  productCharacteristic: productCharacteristic,
                  price: widget.price,
                  countOnWarehouse: widget.countOnWarehouse),
            ));
    setState(() {});
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        //horizontal: defaultPadding,
        //vertical: defaultPadding,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        color: tileColor,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: defaultPadding,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: getItemSmallPictureWithPopup(widget.product),
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Text(widget.product.name, textAlign: TextAlign.left),
                ),
                Expanded(
                  flex: 2,
                  child: Text(widget.product.vendorCode.isNotEmpty ? widget.product.vendorCode : '-',
                      textAlign: TextAlign.left),
                ),
                Expanded(
                  flex: 2,
                  child: Text(widget.product.nameUnit, textAlign: TextAlign.left),
                ),
                Expanded(
                  flex: 2,
                  child: Text(doubleToString(0.0), textAlign: TextAlign.left),
                ),
                Expanded(
                  flex: 2,
                  child: Text(doubleToString(widget.countOnWarehouse), textAlign: TextAlign.left),
                ),
                Expanded(
                  flex: 2,
                  child: Text(doubleToString(widget.price), textAlign: TextAlign.left),
                ),
                Expanded(
                  flex: 2,
                  child: Text(doubleToString(widget.price * widget.countOnWarehouse), textAlign: TextAlign.left),
                ),
                Expanded(
                  flex: 1,
                  child: listProductCharacteristic.isEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.add_shopping_cart_outlined,
                            color: iconColor,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              ProductCharacteristic productCharacteristic = ProductCharacteristic();
                              _addItemToDocument(productCharacteristic, widget.countOnWarehouse, widget.price);
                            });
                          })
                      : IconButton(
                          icon: Icon(
                            visibleListCharacteristics ? Icons.arrow_downward : Icons.arrow_back,
                            color: iconColor,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              visibleListCharacteristics = !visibleListCharacteristics;
                            });
                          }),
                ),
              ],
            ),
            if (listProductCharacteristic.isNotEmpty && visibleListCharacteristics)
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                        padding: EdgeInsets.all(0.0),
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: listProductCharacteristic.length,
                        itemBuilder: (context, index) {
                          var productCharacteristic = listProductCharacteristic[index];

                          var price = 0.0;
                          var countOnWarehouse = 0.0;

                          var indexItemPrice = listProductPrice.indexWhere((element) =>
                              element.uidProductCharacteristic == productCharacteristic.uid &&
                              element.uidPrice == uidPrice);
                          if (indexItemPrice >= 0) {
                            var itemList = listProductPrice[indexItemPrice];
                            price = itemList.price;
                          }

                          // Знайдемо загальні залишки
                          var selectedListProductRest = listProductRest
                              .where((element) => element.uidProductCharacteristic == productCharacteristic.uid)
                              .toList();

                          for (var itemList in selectedListProductRest) {
                            countOnWarehouse = countOnWarehouse + itemList.count;
                          }

                          /// Якщо це товар і показувати тільки із залишком
                          if (showOnlyWithRests && countOnWarehouse == 0) {
                            return Container();
                          }

                          return rowDataItemProductCharacteristic(productCharacteristic, 0, countOnWarehouse, price);
                        }),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget getItemSmallPictureWithPopup(item) {
    return FutureBuilder(
      // Paste your image URL inside the htt.get method as a parameter
      future: http.get(Uri.parse(pathPicture + '/${item.uid}_0.png'), headers: {
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
                            content: Text(item.name, style: TextStyle(color: Colors.black)),
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

  Widget getItemSmallPicture(item) {
    return FutureBuilder(
      // Paste your image URL inside the htt.get method as a parameter
      future: http.get(Uri.parse(pathPicture + '/${item.uid}_0.png'), headers: {
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
              height: 25,
              width: 25,
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
                height: 25,
                width: 25,
                child: Icon(
                  Icons.image,
                  color: Colors.blue.withOpacity(0.5),
                ),
              );

            // when we get the data from the http call, we give the bodyBytes to Image.memory for showing the image
            if (snapshot.data!.statusCode == 200) {
              return Image.memory(snapshot.data!.bodyBytes);
            } else {
              return SizedBox(
                height: 25,
                width: 25,
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

  Widget rowDataItemProductCharacteristic(ProductCharacteristic itemCharacteristic, count, countOnWarehouse, price) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        color: tileColor,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding,
                ),
                child: Text('', textAlign: TextAlign.left),
              ),
            ),
            Expanded(
              flex: 9,
              child: Text(itemCharacteristic.name, textAlign: TextAlign.left),
            ),
            Expanded(
              flex: 2,
              child: Text('', textAlign: TextAlign.left),
            ),
            Expanded(
              flex: 2,
              child: Text('', textAlign: TextAlign.left),
            ),
            Expanded(
              flex: 2,
              child: Text('', textAlign: TextAlign.left),
            ),
            Expanded(
              flex: 2,
              child: Text(doubleToString(countOnWarehouse), textAlign: TextAlign.left),
            ),
            Expanded(
              flex: 2,
              child: Text(doubleToString(price), textAlign: TextAlign.left),
            ),
            Expanded(
              flex: 2,
              child: Text('', textAlign: TextAlign.left),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                  icon: Icon(
                    Icons.add_shopping_cart_outlined,
                    color: iconColor,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _addItemToDocument(itemCharacteristic, count, price);
                    });
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

