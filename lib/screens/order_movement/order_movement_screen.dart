
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wp_b2b/constants.dart';
import 'package:flutter/material.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/order_movement_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/models/doc_order_movement.dart';
import 'package:wp_b2b/screens/login/login_screen.dart';
import 'package:wp_b2b/screens/side_menu/side_menu.dart';
import 'package:wp_b2b/system.dart';
import 'components/header.dart';

class OrderMovementScreen extends StatefulWidget {

  static const routeName = '/order_movement';

  @override
  State<OrderMovementScreen> createState() => _OrderMovementScreenState();
}

class _OrderMovementScreenState extends State<OrderMovementScreen> {

  bool loadingData = false;
  List<OrderMovement> listOrderMovement = [];

  loadOrderMovement() async {
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
      logout().then((value) => {
        Navigator.restorablePushNamed(context, LoginScreen.routeName)
      });
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
      //drawer: SideMenu(),
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
                              orderMovementList(),
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

  Widget orderMovementList() {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   'Замовлення покупців',
          //   style: Theme.of(context).textTheme.subtitle1,
          // ),
          SizedBox(
            height: (listOrderMovement.length * 51) + 56,
            child: DataTable2(
              columnSpacing: 10,
              minWidth: 400,
              columns: [
                DataColumn(
                  label: Text("Дата"),
                ),
                DataColumn(
                  label: Text("Організація"),
                ),
                DataColumn(
                  label: Text("Контрагент"),
                ),
                DataColumn(
                  label: Text("Тип ціни"),
                ),
                DataColumn(
                  label: Text("Сума"),
                ),
              ],
              rows: List.generate(
                listOrderMovement.length,
                    (index) => recentOrderMovementDataRow(listOrderMovement[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

DataRow recentOrderMovementDataRow(OrderMovement orderMovement) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            SvgPicture.asset(
              'assets/icons/doc_file.svg',
              height: 30,
              width: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(fullDateToString(orderMovement.date!)),
            ),
          ],
        ),
      ),
      DataCell(Text(fullDateToString(orderMovement.date!))),
      DataCell(Text(orderMovement.nameOrganization!)),
      DataCell(Text(orderMovement.namePartner!)),
      DataCell(Text(orderMovement.namePrice!)),
      DataCell(Text(doubleToString(orderMovement.sum!))),
    ],
  );
}
