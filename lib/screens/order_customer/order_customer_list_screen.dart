import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wp_b2b/constants.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/order_customer_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/models/doc_order_customer.dart';
import 'package:wp_b2b/screens/login/login_screen.dart';
import 'package:wp_b2b/screens/order_customer/order_customer_item_screen.dart';
import 'package:wp_b2b/screens/side_menu/side_menu.dart';
import 'package:wp_b2b/system.dart';

import 'components/header.dart';

class OrderCustomerScreen extends StatefulWidget {
  static const routeName = '/orders_customers';

  @override
  State<OrderCustomerScreen> createState() => _OrderCustomerScreenState();
}

class _OrderCustomerScreenState extends State<OrderCustomerScreen> {
  bool loadingData = false;
  List<OrderCustomer> listOrderCustomer = [];

  loadListOrdersCustomers() async {
    // Request to server
    ApiResponse response = await getOrdersCustomers();

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          listOrderCustomer.add(item);
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
      drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  child: Text("Організація", textAlign: TextAlign.left),
                ),
                Expanded(
                  flex: 4,
                  child: Text("Контрагент", textAlign: TextAlign.left),
                ),
                Expanded(
                  flex: 3,
                  child: Text("Тип ціни", textAlign: TextAlign.left),
                ),
                Expanded(
                  flex: 1,
                  child: Text("Сума"),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white24,thickness: 0.5),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: ListView.builder(
                    padding: EdgeInsets.all(0.0),
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: listOrderCustomer.length,
                    itemBuilder: (context, index) {
                      final orderCustomer = listOrderCustomer[index];
                      return recentOrderCustomerDataRow(orderCustomer);
                    }),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget recentOrderCustomerDataRow(OrderCustomer orderCustomer) {
    return ListTile(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OrderCustomerItemScreen(
                    orderCustomer: orderCustomer),
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
                  'assets/icons/doc_file.svg',
                  height: 30,
                  width: 30,
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Flexible(
                        child: Text(fullDateToString(orderCustomer.date!),
                            style: TextStyle(color: Colors.white))),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(orderCustomer.nameOrganization!,
                    style: TextStyle(color: Colors.white)),
              ),
              Expanded(
                flex: 4,
                child: Text(orderCustomer.namePartner!,
                    style: TextStyle(color: Colors.white)),
              ),
              Expanded(
                flex: 3,
                child: Text(orderCustomer.namePrice!,
                    style: TextStyle(color: Colors.white, overflow: TextOverflow.fade)),
              ),
              Expanded(
                flex: 1,
                child: Text(doubleToString(orderCustomer.sum!),
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          SizedBox(height: 1,),
          Divider(color: Colors.white24,thickness: 0.5),
        ],
      ),
    );
  }
}
