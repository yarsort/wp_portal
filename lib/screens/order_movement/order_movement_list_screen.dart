import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

import 'components/header.dart';

class OrderMovementScreen extends StatefulWidget {
  static const routeName = '/orders_movements';

  @override
  State<OrderMovementScreen> createState() => _OrderMovementScreenState();
}

class _OrderMovementScreenState extends State<OrderMovementScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool loadingData = false;

  List<OrderMovement> listOrderMovement = [];

  /// Начало периода отбора
  String startPeriodDocsString = '';
  DateTime startPeriodDocs = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 6);

  /// Конец периода отбора
  String finishPeriodDocsString = '';
  DateTime finishPeriodDocs = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59);

  TextEditingController textFieldPeriodController = TextEditingController();

  _loadListOrdersMovements() async {
    //// Restore or get dates
    await _loadPeriod();

    /// Request to server
    ApiResponse response = await getOrdersMovements(startPeriodDocsString, finishPeriodDocsString);

    // Read response
    if (response.error == null) {
      setState(() {
        listOrderMovement.clear();

        for (var item in response.data as List<dynamic>) {
          listOrderMovement.add(item);
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

  _loadPeriod() async {
    final SharedPreferences prefs = await _prefs;

    textFieldPeriodController.text = prefs.getString('forms_orders_movements_periodDocuments') ?? '';

    if (textFieldPeriodController.text.isEmpty) {
      textFieldPeriodController.text = shortDateToString(startPeriodDocs) + ' - ' + shortDateToString(finishPeriodDocs);

      startPeriodDocsString = shortDateToString1C(startPeriodDocs);
      finishPeriodDocsString = shortDateToString1C(finishPeriodDocs);
    } else {
      String dayStart = textFieldPeriodController.text.substring(0, 2);
      String monthStart = textFieldPeriodController.text.substring(3, 5);
      String yearStart = textFieldPeriodController.text.substring(6, 10);
      startPeriodDocsString = yearStart + monthStart + dayStart;

      String dayFinish = textFieldPeriodController.text.substring(13, 15);
      String monthFinish = textFieldPeriodController.text.substring(16, 18);
      String yearFinish = textFieldPeriodController.text.substring(19, 23);
      finishPeriodDocsString = yearFinish + monthFinish + dayFinish;

      startPeriodDocs = DateTime.parse(startPeriodDocsString);
      finishPeriodDocs = DateTime.parse(finishPeriodDocsString);
    }
  }

  @override
  void initState() {
    _loadPeriod();
    _loadListOrdersMovements();
    super.initState();
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 40,
                          width: 260,
                          child: TextField(
                            controller: textFieldPeriodController,
                            readOnly: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                              fillColor: secondaryColor,
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                              ),
                              labelStyle: const TextStyle(
                                color: Colors.blueGrey,
                              ),
                              //labelText: 'Період',
                              suffixIcon: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min, //
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      var _datePick = await showDateRangePicker(
                                          context: context,
                                          initialDateRange:
                                              DateTimeRange(start: startPeriodDocs, end: finishPeriodDocs),
                                          helpText: 'Виберіть період',
                                          firstDate: DateTime(2021, 1, 1),
                                          lastDate: finishPeriodDocs,
                                          builder: (context, child) {
                                            return Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      maxWidth: 400.0,
                                                      maxHeight: 500.0,
                                                    ),
                                                    child: child,
                                                  )
                                                ],
                                              ),
                                            );
                                          });

                                      if (_datePick != null) {
                                        startPeriodDocs = _datePick.start;
                                        finishPeriodDocs = _datePick.end;
                                        textFieldPeriodController.text = shortDateToString(startPeriodDocs) +
                                            ' - ' +
                                            shortDateToString(finishPeriodDocs);

                                        /// Save period
                                        final SharedPreferences prefs = await _prefs;
                                        prefs.setString(
                                            'forms_orders_movements_periodDocuments', textFieldPeriodController.text);

                                        /// Show documents
                                        _loadListOrdersMovements();
                                        setState(() {});
                                      }
                                    },
                                    icon: const Icon(Icons.date_range, color: iconColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        SizedBox(
                            height: 40,
                            width: 120,
                            child: ElevatedButton(
                                onPressed: () async {
                                  OrderMovement orderMovement = OrderMovement();
                                  orderMovement.date = DateTime.now();

                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderMovementItemScreen(orderMovement: orderMovement),
                                    ),
                                  );
                                },
                                child: Text('Додати'))),
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
                  width: 50,
                ),
                spaceBetweenColumn(),
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
                child: listOrderMovement.isNotEmpty
                    ? ListView.builder(
                        padding: EdgeInsets.all(0.0),
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: listOrderMovement.length,
                        itemBuilder: (context, index) {
                          final orderCustomer = listOrderMovement[index];
                          return recentOrderMovementDataRow(orderCustomer);
                        })
                    : SizedBox(height: 50, child: Center(child: Text('Список документів порожній!'))),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget recentOrderMovementDataRow(OrderMovement orderMovement) {
    return Card(
      color: tileColor,
      elevation: 5,
      child: ListTile(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderMovementItemScreen(orderMovement: orderMovement),
            ),
          );
        },
        contentPadding: EdgeInsets.all(5.0),
        title: Row(
          children: [
            SizedBox(
              width: 50,
              child: SvgPicture.asset(
                'assets/icons/menu_doc.svg',
                height: 25,
                color: Colors.lightBlue,
              ),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Flexible(child: Text(fullDateToString(orderMovement.date!), style: TextStyle(color: Colors.white))),
                ],
              ),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 3,
              child: Text(orderMovement.status!, style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 3,
              child: Text(orderMovement.nameOrganization!, style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 3,
              child: Text(orderMovement.nameWarehouseSender!, style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 3,
              child: Text(orderMovement.nameWarehouseReceiver!, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget spaceBetweenColumn() {
    return SizedBox(width: 5);
  }
}
