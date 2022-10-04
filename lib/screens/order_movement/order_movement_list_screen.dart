import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wp_b2b/constants.dart';
import 'package:wp_b2b/controllers/MenuController.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/order_movement_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/models/doc_order_movement.dart';
import 'package:wp_b2b/screens/login/login_screen.dart';
import 'package:wp_b2b/screens/order_movement/order_movement_item_screen.dart';
import 'package:wp_b2b/screens/side_menu/side_menu.dart';
import 'package:wp_b2b/system.dart';

import 'componen'
    ''
    'ts/header.dart';

class OrderMovementScreen extends StatefulWidget {
  static const routeName = '/orders_movements';

  @override
  State<OrderMovementScreen> createState() => _OrderMovementScreenState();
}

class _OrderMovementScreenState extends State<OrderMovementScreen> {
  bool loadingData = false;
  List<OrderMovement> listOrderMovement = [];

  loadListOrdersCustomers() async {
    // Request to server
    ApiResponse response = await getOrdersMovements();

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          listOrderMovement.add(item);
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
    loadListOrdersCustomers();
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
                              orderCustomerList(),
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

  Widget orderCustomerList() {
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
                ),
                Expanded(
                  flex: 3,
                  child: Text("Дата", textAlign: TextAlign.left),
                ),
                Expanded(
                  flex: 3,
                  child: Text("Статус", textAlign: TextAlign.left),
                ),
                Expanded(
                  flex: 3,
                  child: Text("Організація", textAlign: TextAlign.left),
                ),
                Expanded(
                  flex: 3,
                  child: Text("Відправник", textAlign: TextAlign.left),
                ),
                Expanded(
                  flex: 3,
                  child: Text("Отримувач", textAlign: TextAlign.left),
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
                    itemCount: listOrderMovement.length,
                    itemBuilder: (context, index) {
                      final orderCustomer = listOrderMovement[index];
                      return recentOrderMovementDataRow(orderCustomer);
                    }),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget recentOrderMovementDataRow(OrderMovement orderMovement) {
    return ListTile(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OrderMovementItemScreen(orderMovement: orderMovement),
          ),
        );
      },
      contentPadding: EdgeInsets.all(0.0),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: 50,
                child: SvgPicture.asset(
                  'assets/icons/menu_doc.svg',
                  height: 25,
                  color: Colors.lightBlue,
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Flexible(
                        child: Text(fullDateToString(orderMovement.date!),
                            style: TextStyle(color: Colors.white))),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(orderMovement.status!,
                    style: TextStyle(color: Colors.white)),
              ),
              Expanded(
                flex: 3,
                child: Text(orderMovement.nameOrganization!,
                    style: TextStyle(color: Colors.white)),
              ),
              Expanded(
                flex: 3,
                child: Text(orderMovement.nameWarehouseSender!,
                    style: TextStyle(color: Colors.white)),
              ),
              Expanded(
                flex: 3,
                child: Text(orderMovement.nameWarehouseReceiver!,
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
