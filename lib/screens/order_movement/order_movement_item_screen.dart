import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wp_b2b/constants.dart';
import 'package:wp_b2b/controllers/MenuController.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/order_movement_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/models/doc_order_movement.dart';
import 'package:wp_b2b/screens/login/login_screen.dart';
import 'package:wp_b2b/screens/side_menu/side_menu.dart';
import 'package:wp_b2b/system.dart';

class OrderMovementItemScreen extends StatefulWidget {
  final OrderMovement orderMovement;

  const OrderMovementItemScreen({Key? key, required this.orderMovement})
      : super(key: key);

  static const routeName = '/order_customer';

  @override
  State<OrderMovementItemScreen> createState() =>
      _OrderMovementItemScreenState();
}

class _OrderMovementItemScreenState extends State<OrderMovementItemScreen> {
  bool loadingData = false;
  List<ItemOrderMovement> listItemsOrderMovement = [];

  /// Поле ввода: Дата документа
  TextEditingController textFieldDateController = TextEditingController();

  /// Поле ввода: Организация
  TextEditingController textFieldOrganizationController = TextEditingController();

  /// Поле ввода: Склад отправитель
  TextEditingController textFieldWarehouseSenderController = TextEditingController();

  /// Поле ввода: Склад получатель
  TextEditingController textFieldWarehouseReceiverController = TextEditingController();

  /// Поле ввода: Сума документа
  TextEditingController textFieldSumController = TextEditingController();

  /// Поле ввода: Вага документа
  TextEditingController textFieldWeightController = TextEditingController();

  _loadOneOrderCustomer() async {
    // Request to server
    ApiResponse response =
        await getItemsOrderMovementByUID(widget.orderMovement.uid);

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          listItemsOrderMovement.add(item);
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

  _updateHeader() async {
    textFieldDateController.text = fullDateToString(widget.orderMovement.date??DateTime.parse(''));
    textFieldOrganizationController.text =
    widget.orderMovement.nameOrganization!;
    textFieldWarehouseSenderController.text = widget.orderMovement.nameWarehouseSender!;
    textFieldWarehouseReceiverController.text = widget.orderMovement.nameWarehouseReceiver!;
  }

  @override
  void initState() {
    _updateHeader();
    _loadOneOrderCustomer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuController>().scaffoldItemOrderCustomerKey,
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
                          "Переміщення товарів №" + widget.orderMovement.numberFrom1C,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ),
                    SizedBox(height: defaultPadding),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              if (Responsive.isDesktop(context) || Responsive.isTablet(context))
                                textFieldsDocumentDesktop(),
                              if (Responsive.isMobile(context))
                                textFieldsDocumentMobile(),
                              SizedBox(height: defaultPadding),
                              itemsOrderCustomerList(),
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

  Widget textFieldsDocumentDesktop() {
    return Container(
      //width: MediaQuery.of(context).size.width*0.5,
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
                child: TextFieldWithText(
                    textLabel: 'Дата документа',
                    textEditingController: textFieldDateController),
              ),

              /// Organization
              Expanded(
                flex: 1,
                child: TextFieldWithText(
                    textLabel: 'Організація',
                    textEditingController: textFieldOrganizationController),
              ),

              /// Empty
              Expanded(
                flex: 1,
                child: Container()),
            ],
          ),
          Row(
            children: [
              /// Warehouse-sender
              Expanded(
                flex: 1,
                child: TextFieldWithText(
                    textLabel: 'Склад-відправник',
                    textEditingController: textFieldWarehouseSenderController),
              ),
              /// Warehouse-receiver
              Expanded(
                flex: 1,
                child: TextFieldWithText(
                    textLabel: 'Склад-отримувач',
                    textEditingController: textFieldWarehouseReceiverController),
              ),
              /// Empty
              Expanded(
                  flex: 1,
                  child: Container()),
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
          TextFieldWithText(
              textLabel: 'Дата документа',
              textEditingController: textFieldDateController),

          /// Organization
          TextFieldWithText(
              textLabel: 'Організація',
              textEditingController: textFieldOrganizationController),

          /// Warehouse-sender
          TextFieldWithText(
              textLabel: 'Склад-відправник',
              textEditingController: textFieldWarehouseSenderController),

          /// Warehouse-receiver
          TextFieldWithText(
              textLabel: 'Склад-отримувач',
              textEditingController: textFieldWarehouseReceiverController),
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
                  child: Text("N",
                    textAlign: TextAlign.center,),
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
                  child: Text("Од. вим.", overflow: TextOverflow.fade),
                ),
                Expanded(
                  flex: 1,
                  child: Text("Заплановано", overflow: TextOverflow.fade),
                ),
                Expanded(
                  flex: 1,
                  child: Text("Відправлено", overflow: TextOverflow.fade),
                ),
                Expanded(
                  flex: 1,
                  child: Text("Отримано", overflow: TextOverflow.fade),
                ),
                SizedBox(
                  width: 14,
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
                child: ListView.builder(
                    padding: EdgeInsets.all(0.0),
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: listItemsOrderMovement.length,
                    itemBuilder: (context, index) {
                      final item = listItemsOrderMovement[index];
                      return recentOrderMovementDataRow(item);
                    }),
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

  Widget recentOrderMovementDataRow(ItemOrderMovement item) {
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
              child: Text(item.numberRow.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            SizedBox(
              height: 50,
              width: 50,
              child: getItemSmallPicture(item),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 2,
              child: Text(item.name, style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 1,
              child: Text(item.nameCharacteristic,
                  style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 1,
              child:
                  Text(item.nameUnit, style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 1,
              child: Text(doubleToString(item.countPrepare),
                  style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 1,
              child: Text(doubleToString(item.countSend),
                  style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 1,
              child: Text(doubleToString(item.countReceived),
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget getItemSmallPicture(ItemOrderMovement item) {
    return FutureBuilder(
      // Paste your image URL inside the htt.get method as a parameter
      future: http.get(
          Uri.parse(
              'https://rsvmoto.com.ua/files/resized/products/${item.uid}_1.55x55.png'),
          headers: {
            HttpHeaders.accessControlAllowOriginHeader: '*',
          }),
      builder: (BuildContext context,
          AsyncSnapshot<http.Response> snapshot) {
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
