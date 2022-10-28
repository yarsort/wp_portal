import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wp_b2b/constants.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/order_customer_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/models/doc_order_customer.dart';
import 'package:wp_b2b/screens/login/login_screen.dart';
import 'package:wp_b2b/screens/products/products_list_selection_screen.dart';
import 'package:wp_b2b/screens/side_menu/side_menu.dart';
import 'package:wp_b2b/system.dart';

class OrderCustomerItemScreen extends StatefulWidget {
  final OrderCustomer orderCustomer;

  const OrderCustomerItemScreen({Key? key, required this.orderCustomer}) : super(key: key);

  static const routeName = '/order_customer';

  @override
  State<OrderCustomerItemScreen> createState() => _OrderCustomerItemScreenState();
}

class _OrderCustomerItemScreenState extends State<OrderCustomerItemScreen> {
  bool loadingData = false;

  /// Поле ввода: Дата документа
  TextEditingController textFieldDateController = TextEditingController();

  /// Поле ввода: Организация
  TextEditingController textFieldOrganizationController = TextEditingController();

  /// Поле ввода: Партнер
  TextEditingController textFieldPartnerController = TextEditingController();

  /// Поле ввода: Договір (Торговая точка)
  TextEditingController textFieldContractController = TextEditingController();

  /// Поле ввода: Магазин (Торговая точка)
  TextEditingController textFieldStoreController = TextEditingController();

  /// Поле ввода: Тип цены
  TextEditingController textFieldPriceController = TextEditingController();

  /// Поле ввода: Склад
  TextEditingController textFieldWarehouseController = TextEditingController();

  /// Поле ввода: Сума документа
  TextEditingController textFieldSumController = TextEditingController();

  /// Поле ввода: Вага документа
  TextEditingController textFieldWeightController = TextEditingController();

  _loadOneOrderCustomer() async {
    // Item without UUID - new item
    if (widget.orderCustomer.uid == '') {
      return;
    }

    // Request to server
    ApiResponse response = await getItemsOrderCustomerByUID(widget.orderCustomer.uid);

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          widget.orderCustomer.itemsOrderCustomer.add(item);
        }

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
    textFieldDateController.text = fullDateToString(widget.orderCustomer.date ?? DateTime.parse(''));
    textFieldOrganizationController.text = widget.orderCustomer.nameOrganization ?? '';
    textFieldPartnerController.text = widget.orderCustomer.namePartner ?? '';
    textFieldContractController.text = widget.orderCustomer.nameContract ?? '';
    textFieldStoreController.text = widget.orderCustomer.nameStore ?? '';
    textFieldPriceController.text = widget.orderCustomer.namePrice ?? '';
    textFieldWarehouseController.text = widget.orderCustomer.nameWarehouse ?? '';
    textFieldSumController.text = doubleToString(widget.orderCustomer.sum ?? 0.0);
  }

  @override
  void initState() {
    _updateHeader();
    _loadOneOrderCustomer();
    super.initState();
  }

  _postOrderCustomer() async {
    // Request to server
    ApiResponse response = await postOrderCustomer(widget.orderCustomer);

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          widget.orderCustomer.uid = item.uid;
          break; // Only one item in there
        }

        loadingData = loadingData ? !loadingData : loadingData;
      });
    } else if (response.error == unauthorized) {
      logout().then((value) =>
      {Navigator.restorablePushNamed(context, LoginScreen.routeName)});
    } else {
      showErrorMessage('${response.error}', context);
    }

    setState(() {
      loadingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: context.read<MenuController>().scaffoldItemOrderCustomerKey,
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
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Замовлення №" + widget.orderCustomer.numberFrom1C,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ),
                    SizedBox(height: defaultPadding),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              if (Responsive.isDesktop(context) || Responsive.isTablet(context))
                                textFieldsDocumentDesktop(),
                              if (Responsive.isMobile(context)) textFieldsDocumentMobile(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: defaultPadding),
                    if (widget.orderCustomer.uid == '') Row(
                      children: [
                        SizedBox(
                            height: 40,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(Colors.green)),
                                onPressed: () async {

                                  bool valueResult = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: const Text('Відправити документ постачальнику?'),
                                          actions: <Widget>[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                    onPressed: () async {
                                                      Navigator.of(context).pop(true);
                                                    },
                                                    child: Center(child: Text('Відправити'))),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                        MaterialStateProperty.all(Colors.red)),
                                                    onPressed: () async {
                                                      Navigator.of(context).pop(false);
                                                    },
                                                    child: const Text('Відміна'))
                                              ],
                                            ),
                                          ],
                                        );
                                      }) as bool;

                                  if (valueResult) {
                                    _postOrderCustomer();
                                  }
                                },
                                child: Text('Відправити постачальнику'))),
                        Spacer(),
                        SizedBox(
                            height: 40,
                            child: ElevatedButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductListSelectionScreen(orderCustomer: widget.orderCustomer),
                                    ),
                                  );
                                  setState(() {});
                                },
                                child: Text('Додати товар'))),
                        SizedBox(width: defaultPadding),
                        SizedBox(
                            height: 40,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(Colors.red)),
                                onPressed: () async {

                                  bool valueResult = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: const Text('Очистити список товарів?'),
                                          actions: <Widget>[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                    onPressed: () async {
                                                      Navigator.of(context).pop(true);
                                                    },
                                                    child: Center(child: Text('Очистити'))),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                        MaterialStateProperty.all(Colors.red)),
                                                    onPressed: () async {
                                                      Navigator.of(context).pop(false);
                                                    },
                                                    child: const Text('Відміна'))
                                              ],
                                            ),
                                          ],
                                        );
                                      }) as bool;

                                  if (valueResult) {
                                    setState(() {
                                      widget.orderCustomer.itemsOrderCustomer.clear();
                                    });
                                  }
                                },
                                child: Text('Очистити список'))),
                      ],
                    ),
                    if (widget.orderCustomer.uid == '') SizedBox(height: defaultPadding),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              itemsOrderCustomerList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget textFieldsDocumentDesktop() {
    return Container(
      padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              /// Date
              Expanded(
                flex: 1,
                child: TextFieldWithText(textLabel: 'Дата документа', textEditingController: textFieldDateController),
              ),

              /// Organization
              Expanded(
                flex: 1,
                child:
                    TextFieldWithText(textLabel: 'Організація', textEditingController: textFieldOrganizationController),
              ),

              /// Partner
              Expanded(
                flex: 1,
                child: TextFieldWithText(textLabel: 'Партнер', textEditingController: textFieldPartnerController),
              ),
            ],
          ),
          Row(
            children: [
              /// Sum
              Expanded(
                flex: 1,
                child: TextFieldWithText(textLabel: 'Сума документа', textEditingController: textFieldSumController),
              ),

              /// Warehouse
              Expanded(
                flex: 1,
                child: TextFieldWithText(
                    textLabel: 'Склад відвантаження', textEditingController: textFieldWarehouseController),
              ),

              /// Price
              Expanded(
                flex: 1,
                child: TextFieldWithText(textLabel: 'Тип ціни', textEditingController: textFieldPriceController),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget textFieldsDocumentMobile() {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          TextFieldWithText(textLabel: 'Дата документа', textEditingController: textFieldDateController),

          /// Organization
          TextFieldWithText(textLabel: 'Організація', textEditingController: textFieldOrganizationController),

          /// Partner
          TextFieldWithText(textLabel: 'Партнер', textEditingController: textFieldPartnerController),

          /// Warehouse
          TextFieldWithText(textLabel: 'Склад відвантаження', textEditingController: textFieldWarehouseController),

          /// Price
          TextFieldWithText(textLabel: 'Тип ціни', textEditingController: textFieldPriceController),
          TextFieldWithText(textLabel: 'Сума документа', textEditingController: textFieldSumController),
        ],
      ),
    );
  }

  Widget itemsOrderCustomerList() {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
            child: Row(
              children: [
                SizedBox(
                  width: 15,
                  child: Text(""),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    "N",
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(""),
                ),
                spaceBetweenColumn(),
                Expanded(
                  flex: 2,
                  child: Text("Товар", overflow: TextOverflow.fade),
                ),
                Expanded(
                  flex: 1,
                  child: Text("Варіант", overflow: TextOverflow.fade),
                ),
                Expanded(
                  flex: 1,
                  child: Text("Кількість", overflow: TextOverflow.fade),
                ),
                Expanded(
                  flex: 1,
                  child: Text("Од. вим.", overflow: TextOverflow.fade),
                ),
                Expanded(
                  flex: 1,
                  child: Text("Ціна", overflow: TextOverflow.fade),
                ),
                Expanded(
                  flex: 1,
                  child: Text("Знижка", overflow: TextOverflow.fade),
                ),
                Expanded(
                  flex: 1,
                  child: Text("Сума", overflow: TextOverflow.fade),
                ),
                if (widget.orderCustomer.uid == '') Expanded(
                  flex: 1,
                  child: Text(""),
                ),
                SizedBox(
                  width: 12,
                  child: Text(""),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white24, thickness: 0.5),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: widget.orderCustomer.itemsOrderCustomer.length != 0
                    ? ListView.builder(
                        padding: EdgeInsets.all(0.0),
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: widget.orderCustomer.itemsOrderCustomer.length,
                        itemBuilder: (context, index) {
                          final item = widget.orderCustomer.itemsOrderCustomer[index];
                          return recentOrderCustomerDataRow(item);
                        })
                    : SizedBox(height: 50, child: Center(child: Text('Список товарів порожній!'))),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget spaceBetweenColumn() {
    return SizedBox(width: 5);
  }

  Widget recentOrderCustomerDataRow(ItemOrderCustomer item) {
    return Card(
      color: tileColor,
      elevation: 5,
      child: ListTile(
        onTap: () {},
        contentPadding: EdgeInsets.all(10.0),
        subtitle: Row(
          children: [
            SizedBox(
              width: 40,
              child:
                  Text(item.numberRow.toString(), textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
            ),
            SizedBox(
              height: 50,
              width: 50,
              child: getItemSmallPicture(item),
            ),
            spaceBetweenColumn(),
            spaceBetweenColumn(),
            Expanded(
              flex: 2,
              child: Text(item.name, style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 1,
              child: Text(item.nameCharacteristic.isNotEmpty ? item.nameCharacteristic : '-',
                  style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 1,
              child: Text(doubleToString(item.count), style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 1,
              child: Text(item.nameUnit, style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 1,
              child: Text(doubleToString(item.price), style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 1,
              child: Text(doubleToString(item.discount), style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 1,
              child: Text(doubleToString(item.sum), style: TextStyle(color: Colors.white)),
            ),
            if (widget.orderCustomer.uid == '') spaceBetweenColumn(),
            if (widget.orderCustomer.uid == '') Expanded(
              flex: 1,
              child: IconButton(icon: Icon(Icons.delete, color: Colors.red,), onPressed: () {
                setState(() {
                  widget.orderCustomer.itemsOrderCustomer.remove(item);
                });
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget getItemSmallPicture(ItemOrderCustomer item) {
    return FutureBuilder(
      // Paste your image URL inside the htt.get method as a parameter
      future: http.get(Uri.parse('https://rsvmoto.com.ua/files/resized/products/${item.uid}_1.55x55.png'), headers: {
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
            return Center(
              child: SizedBox(
                child: CircularProgressIndicator(
                  color: Colors.blueGrey,
                ),
                height: 20,
                width: 20,
              ),
            );
          case ConnectionState.waiting:
            return Center(
              child: SizedBox(
                child: CircularProgressIndicator(
                  color: Colors.blueGrey,
                ),
                height: 20,
                width: 20,
              ),
            );
          case ConnectionState.done:
            if (snapshot.hasError)
              return Icon(
                Icons.two_wheeler,
                color: Colors.white24,
              );

            // when we get the data from the http call, we give the bodyBytes to Image.memory for showing the image
            if (snapshot.data!.statusCode == 200) {
              return Image.memory(snapshot.data!.bodyBytes);
            } else {
              return Icon(
                Icons.two_wheeler,
                color: Colors.white24,
              );
            }
        }
      },
    );
  }
}

class TextFieldWithText extends StatelessWidget {
  final TextEditingController textEditingController;
  final String textLabel;
  final bool readOnly = true;

  const TextFieldWithText({
    Key? key,
    bool? readOnly,
    required this.textLabel,
    required this.textEditingController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(7, 7, 7, 7),
      child: IntrinsicHeight(
        child: TextField(
          keyboardType: TextInputType.text,
          readOnly: readOnly,
          controller: textEditingController,
          decoration: InputDecoration(
            isDense: true,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 2,
              minHeight: 2,
            ),
            //contentPadding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            border: const OutlineInputBorder(),
            labelStyle: const TextStyle(
              color: Colors.blueGrey,
            ),
            labelText: textLabel,
          ),
        ),
      ),
    );
  }
}
