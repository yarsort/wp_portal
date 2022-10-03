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
import 'package:wp_b2b/models/doc_order_customer.dart';
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
  List<ItemOrderCustomer> listItemsOrderMovement = [];

  loadOneOrderCustomer() async {
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

  @override
  void initState() {
    super.initState();
    loadOneOrderCustomer();
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

  Widget itemsOrderCustomerList() {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
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
                  width: 50,
                  child: Text("N"),
                ),
                spaceBetweenColumn(),
                SizedBox(
                  width: 50,
                  child: Text(""),
                ),
                spaceBetweenColumn(),
                spaceBetweenColumn(),
                Expanded(
                  flex: 2,
                  child: Text("Товар"),
                ),
                spaceBetweenColumn(),
                Expanded(
                  flex: 1,
                  child: Text("Варіант"),
                ),
                spaceBetweenColumn(),
                Expanded(
                  flex: 1,
                  child: Text("Кількість"),
                ),
                spaceBetweenColumn(),
                Expanded(
                  flex: 1,
                  child: Text("Од. вим."),
                ),
                spaceBetweenColumn(),
                Expanded(
                  flex: 1,
                  child: Text("Ціна"),
                ),
                spaceBetweenColumn(),
                Expanded(
                  flex: 1,
                  child: Text("Знижка"),
                ),
                spaceBetweenColumn(),
                Expanded(
                  flex: 1,
                  child: Text("Сума"),
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
                      return recentOrderCustomerDataRow(item);
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

  Widget recentOrderCustomerDataRow(ItemOrderCustomer item) {
    return ListTile(
      onTap: () {},
      contentPadding: EdgeInsets.all(0.0),
      subtitle: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(item.numberRow.toString(),
                    style: TextStyle(color: Colors.white)),
              ),
              spaceBetweenColumn(),
              SizedBox(
                height: 50,
                width: 50,
                child: FutureBuilder(
                  // Paste your image URL inside the htt.get method as a parameter
                  future: http.get(Uri.parse(
                      'https://rsvmoto.com.ua/files/resized/products/${item.uid}_1.55x55.png'),
                      headers: {
                        HttpHeaders.accessControlAllowOriginHeader: '*',
                      }),
                  builder: (BuildContext context,
                      AsyncSnapshot<http.Response> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return Icon(Icons.two_wheeler, color: Colors.white24,);
                      case ConnectionState.active:
                        return SizedBox(
                          child: CircularProgressIndicator(),
                          height: 10,
                          width: 10,
                        );
                      case ConnectionState.waiting:
                        return SizedBox(
                          child: CircularProgressIndicator(),
                          height: 10,
                          width: 10,
                        );
                      case ConnectionState.done:
                        if (snapshot.hasError) return Icon(Icons.two_wheeler, color: Colors.white24,);

                        // when we get the data from the http call, we give the bodyBytes to Image.memory for showing the image
                        if (snapshot.data!.statusCode == 200){
                          return Image.memory(snapshot.data!.bodyBytes);
                        } else {
                          return Icon(Icons.two_wheeler, color: Colors.white24,);
                        }
                    }
                  },
                ),
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
                child: Text(item.nameCharacteristic,
                    style: TextStyle(color: Colors.white)),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 1,
                child: Text(doubleToString(item.count),
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
                child: Text(doubleToString(item.price),
                    style: TextStyle(color: Colors.white)),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 1,
                child: Text(doubleToString(item.discount),
                    style: TextStyle(color: Colors.white)),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 1,
                child: Text(doubleToString(item.sum),
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          SizedBox(
            height: 1,
          ),
          Divider(color: Colors.white24, thickness: 0.5),
        ],
      ),
    );
  }
}
