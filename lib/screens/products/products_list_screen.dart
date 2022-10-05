import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wp_b2b/constants.dart';
import 'package:wp_b2b/controllers/MenuController.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/product_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/accum_product_prices.dart';
import 'package:wp_b2b/models/accum_product_rests.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/models/ref_product.dart';
import 'package:wp_b2b/screens/login/login_screen.dart';
import 'package:wp_b2b/screens/side_menu/side_menu.dart';
import 'package:wp_b2b/system.dart';

import 'components/header.dart';

// Ціни товарів
List<AccumProductPrice> listProductPrice = [];

// Залишки товарів
List<AccumProductRest> listProductRest = [];

String uidPrice = 'fc605043-984d-11ea-89b3-180373c9c33b';
String uidWarehouse = '5235ab40-9855-11ea-89b3-180373c9c33b';

class ProductListScreen extends StatefulWidget {
  static const routeName = '/products';

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool showProductHierarchy = true;

  // Список товарів для вывода на экран
  List<Product> listDataProducts = []; // Список всіх товарів з сервера
  List<Product> listProducts = [];
  List<Product> listProductsForListView = [];

  // Список каталогов для построения иерархии
  List<Product> treeParentItems = [];

  // Список идентификаторов товарів для поиска цен и остатков
  List<String> listProductsUID = [];
  List<String> listPrices = [];
  List<String> listWarehouses = [];

  // Текущий выбранный каталог иерархии товарів
  Product parentProduct = Product();

  // Количество элементов в автозагрузке списка
  int _currentMax = 0;
  int countLoadItems = 20;

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
      logout().then((value) =>
          {Navigator.restorablePushNamed(context, LoginScreen.routeName)});
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
      listProductsForListView.clear(); // Список для отображения на форме
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
    //if (showProductHierarchy) {
    // Покажем товары текущего родителя
    listDataProducts = await _getProductsByParent(parentProduct.uid);
    // } else {
    //   String searchString = textFieldSearchCatalogController.text.trim().toLowerCase();
    //   if (searchString.toLowerCase().length >= 3) {
    //     // Покажем все товары для поиска
    //     listDataProducts = await dbReadProductsForSearch(searchString);
    //   } else {
    //     // Покажем все товары
    //     listDataProducts = await dbReadAllProducts();
    //   }
    // }

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

    await _loadAdditionalProductsToView();

    setState(() {});
  }

  _loadAccumProductPriceByUIDProducts(listPrices, listProductsUID) async {
    List<AccumProductPrice> listToReturn = [];

    // Request to server
    ApiResponse response =
        await getAccumProductPriceByUIDProducts(listPrices, listProductsUID);

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          listToReturn.add(item);
        }
      });
    } else if (response.error == unauthorized) {
      logout().then((value) =>
          {Navigator.restorablePushNamed(context, LoginScreen.routeName)});
    } else {
      showErrorMessage('${response.error}', context);
    }

    return listToReturn;
  }

  _loadAccumProductRestByUIDProducts(listWarehouses, listProductsUID) async {
    List<AccumProductRest> listToReturn = [];

    // Request to server
    ApiResponse response =
        await getAccumProductRestByUIDProducts(listWarehouses, listProductsUID);

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          listToReturn.add(item);
        }
      });
    } else if (response.error == unauthorized) {
      logout().then((value) =>
          {Navigator.restorablePushNamed(context, LoginScreen.routeName)});
    } else {
      showErrorMessage('${response.error}', context);
    }

    return listToReturn;
  }

  _loadPriceAndRests() async {
    if (listProductsUID.isEmpty) {
      debugPrint('Немає UIDs для виведення залишківс та цін...');
      return;
    }

    if (listPrices.isEmpty) {
      listPrices.add(uidPrice);
    }

    if (listWarehouses.isEmpty) {
      listWarehouses.add(uidWarehouse);
    }

    /// Ціни товарів
    listProductPrice =
        await _loadAccumProductPriceByUIDProducts(listPrices, listProductsUID);

    /// Залишки товарів
    listProductRest = await _loadAccumProductRestByUIDProducts(listWarehouses, listProductsUID);

    debugPrint('Ціни товарів: ' + listProductPrice.length.toString());
    debugPrint('Залишки товарів: ' + listProductRest.length.toString());

    setState(() {
      debugPrint('Оновлено...');
    });
  }

  _loadAdditionalProductsToView() async {
    /// Получим первые товары на экран
    for (int i = _currentMax; i < _currentMax + countLoadItems; i++) {
      if (i < listProducts.length) {
        listProductsForListView.add(listProducts[i]);
        debugPrint('Добавлен товар: ' + listProducts[i].name);
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

    ///Немає даних - нет вывода на форму
    if (listProductsUID.isEmpty) {
      debugPrint('Ні товарів для отображения цен и остатков! Товаров: ' +
          listProductsForListView.length.toString());
    } else {
      debugPrint('Есть товары для отображения цен и остатков! Товаров: ' +
          listProductsForListView.length.toString());
    }

    await _loadPriceAndRests();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _renewItem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuController>().scaffoldOrderMovementKey,
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
                padding: EdgeInsets.all(defaultPadding),
                child: Column(
                  children: [
                    // Desktop view
                    Header(),
                    SizedBox(height: defaultPadding),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              productList(),
                            ],
                          ),
                        ),
                      ],
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

  Widget productList() {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                ),
                Expanded(
                  flex: 10,
                  child: Text("Товар", textAlign: TextAlign.left),
                ),
                Expanded(
                  flex: 3,
                  child: Text("Од. вим.", textAlign: TextAlign.left),
                ),
                Expanded(
                  flex: 3,
                  child: Text("Ціна", textAlign: TextAlign.left),
                ),
                Expanded(
                  flex: 3,
                  child: Text("Залишок"),
                ),
                SizedBox(
                  width: 60,
                ),
              ],
            ),
          ),
          Divider(color: Colors.white24, thickness: 0.5),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: ListView.builder(
                    padding: EdgeInsets.all(0.0),
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: listProductsForListView.length,
                    itemBuilder: (context, index) {
                      var productItem = listProductsForListView[index];
                      var price = 0.0;
                      var countOnWarehouse = 0.0;

                      var indexItemPrice = listProductPrice.indexWhere(
                          (element) =>
                              element.uidProduct == productItem.uid &&
                              element.uidPrice == uidPrice);
                      if (indexItemPrice >= 0) {
                        var itemList = listProductPrice[indexItemPrice];
                        price = itemList.price;
                      } else {
                        price = 0.0;
                      }

                      var indexItemRest = listProductRest.indexWhere(
                          (element) =>
                              element.uidProduct == productItem.uid &&
                              element.uidWarehouse == uidWarehouse);
                      if (indexItemRest >= 0) {
                        var itemList = listProductRest[indexItemRest];
                        countOnWarehouse = itemList.count;
                      } else {
                        countOnWarehouse = 0.000;
                      }

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Card(
                          color: productItem.uid != parentProduct.uid
                              ? tileColor
                              : tileSelectedColor,
                          elevation: 5,
                          child: (productItem.uid == '')
                              ? MoreItemListView(
                                  textItem: 'Показать больше',
                                  tap: () {
                                    // Удалим пункт "Показать больше"
                                    _currentMax--; // Для пункта "Показать больше"
                                    listProductsForListView
                                        .remove(listProductsForListView[index]);
                                    _loadAdditionalProductsToView();
                                    setState(() {});
                                  },
                                )
                              : (productItem.isGroup == 1)
                                  ? DirectoryItemListView(
                                      parentProduct: parentProduct,
                                      product: productItem,
                                      tap: () {
                                        if (productItem.uid ==
                                            parentProduct.uid) {
                                          if (treeParentItems.isNotEmpty) {
                                            // Назначим нового родителя выхода из узла дерева
                                            parentProduct = treeParentItems[
                                                treeParentItems.length - 1];

                                            // Удалим старого родителя для будущего узла
                                            treeParentItems.remove(
                                                treeParentItems[
                                                    treeParentItems.length -
                                                        1]);
                                          } else {
                                            // Отправим дерево на его самый главный узел
                                            parentProduct = Product();
                                          }
                                          _renewItem();
                                        } else {
                                          treeParentItems.add(parentProduct);
                                          parentProduct = productItem;
                                          _renewItem();
                                        }
                                      },
                                      popTap: () {},
                                    )
                                  : ProductItemListView(
                                      price: price,
                                      countOnWarehouse: countOnWarehouse,
                                      product: productItem,
                                      tap: () async {
                                        // await Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) =>
                                        //         ScreenProductItem(productItem: productItem),
                                        //   ),
                                        // );
                                      },
                                    ),
                        ),
                      );
                    }),
              )
            ],
          )
        ],
      ),
    );
  }
}

class DirectoryItemListView extends StatelessWidget {
  final Product parentProduct;
  final Product product;
  final Function tap;
  final Function? popTap;

  const DirectoryItemListView({
    Key? key,
    required this.parentProduct,
    required this.product,
    required this.tap,
    this.popTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // tileColor: product.uid != parentProduct.uid
      //     ? tileColor
      //     : tileSelectedColor,
      onTap: () => tap(),
      //onLongPress: popTap == null ? null : popTap,

      contentPadding: const EdgeInsets.all(0),
      minLeadingWidth: 20,
      leading: const Padding(
        padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
        child: Icon(
          Icons.folder,
          color: Colors.blueAccent,
        ),
      ),
      title: Text(
        product.name,
        style: const TextStyle(
          fontSize: 16,
        ),
        maxLines: 2,
      ),
      trailing: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: product.uid != parentProduct.uid
            ? const Icon(Icons.navigate_next)
            : const Icon(Icons.keyboard_arrow_down),
      ),
    );
  }
}

class MoreItemListView extends StatelessWidget {
  final String textItem;
  final Function tap;

  const MoreItemListView({
    Key? key,
    required this.textItem,
    required this.tap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      //tileColor: const Color.fromRGBO(227, 242, 253, 1.0),
      onTap: () => tap(),
      title: Center(
        child: Text(
          textItem,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.blueAccent,
          ),
          maxLines: 2,
        ),
      ),
    );
  }
}

class ProductItemListView extends StatelessWidget {
  final Product product;
  final Function tap;
  final double countOnWarehouse;
  final double price;

  const ProductItemListView({
    Key? key,
    required this.product,
    required this.tap,
    required this.countOnWarehouse,
    required this.price,
  }) : super(key: key);

  Widget getItemSmallPicture() {
    if (product.isGroup == 1) {
      return Icon(
        Icons.two_wheeler,
        color: Colors.white24,
      );
    }

    return FutureBuilder(
      // Paste your image URL inside the htt.get method as a parameter
      future: http.get(
          Uri.parse(
              'https://rsvmoto.com.ua/files/resized/products/${product.uid}_1.55x55.png'),
          headers: {
            HttpHeaders.accessControlAllowOriginHeader: '*',
          }),
      builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Icon(
              Icons.two_wheeler,
              color: Colors.white24,
            );
          case ConnectionState.active:
            return SizedBox(
              child: Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              height: 45,
              width: 45,
            );
          case ConnectionState.waiting:
            return SizedBox(
              child: Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              height: 45,
              width: 45,
            );
          case ConnectionState.done:
            if (snapshot.hasError)
              return SizedBox(
                child: Icon(
                  Icons.two_wheeler,
                  color: Colors.white24,
                ),
                height: 45,
                width: 45,
              );

            // when we get the data from the http call, we give the bodyBytes to Image.memory for showing the image
            if (snapshot.data!.statusCode == 200) {
              return SizedBox(
                child: Image.memory(snapshot.data!.bodyBytes),
                height: 45,
                width: 45,
              );
            } else {
              return SizedBox(
                child: Icon(
                  Icons.two_wheeler,
                  color: Colors.white24,
                ),
                height: 45,
                width: 45,
              );
            }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => tap(),
      //onLongPress: popTap == null ? null : popTap,
      contentPadding: const EdgeInsets.all(0),
      leading: Padding(
        padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
        child: getItemSmallPicture(),
      ),
      title: Row(
        children: [
          Expanded(
            flex: 10,
            child: Text(product.name, textAlign: TextAlign.left),
          ),
          Expanded(
            flex: 3,
            child: Text(product.nameUnit, textAlign: TextAlign.left),
          ),
          Expanded(
            flex: 3,
            child: Text(
              doubleToString(price),
              textAlign: TextAlign.left,
              style: price > 0
                   ? const TextStyle(fontSize: 15, color: Colors.white)
                   : const TextStyle(fontSize: 15, color: Colors.blueGrey),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              doubleThreeToString(countOnWarehouse),
              textAlign: TextAlign.left,
              style: countOnWarehouse > 0
                  ? const TextStyle(fontSize: 15, color: Colors.white)
                  : const TextStyle(fontSize: 15, color: Colors.blueGrey),
            ),
          ),
        ],
      ),
      trailing: const Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: Icon(Icons.navigate_next),
      ),
    );
  }
}
