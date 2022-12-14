import 'package:flutter/material.dart';
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
import 'package:wp_b2b/widgets.dart';

class OrderMovementScreen extends StatefulWidget {
  static const routeName = '/orders_movements';

  @override
  State<OrderMovementScreen> createState() => _OrderMovementScreenState();
}

class _OrderMovementScreenState extends State<OrderMovementScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  TextEditingController textFieldSearchCatalogController = TextEditingController();
  TextEditingController textFieldPeriodController = TextEditingController();

  String profileName = '';
  String namePage = 'ПЕРЕМІЩЕННЯ ТОВАРІВ';
  bool loadingData = false;

  List<OrderMovement> listOrderMovement = [];

  /// Начало периода отбора
  String startPeriodDocsString = '';
  DateTime startPeriodDocs = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 6);

  /// Конец периода отбора
  String finishPeriodDocsString = '';
  DateTime finishPeriodDocs = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59);

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
      key: context.read<MenuController>().scaffoldOrderMovementKey,
      drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              Expanded(
                flex: 1,
                child: SideMenu(),
              ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                primary: true,
                child: Column(
                  children: [
                    // Desktop view
                    headerPage(),
                    Container(
                      height: MediaQuery.of(context).size.height,
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
                                orderMovementList(),
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

  /// LOADING DATA

  _loadData() async {
    await _loadProfileData();
    await _loadPeriod();
    setState(() {});
    await _loadListOrdersMovements();
  }

  _loadProfileData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    profileName = pref.getString('settings_profileName') ?? '';
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

  /// HEADER

  Widget headerPage() {
    return Container(
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
              children: [
                portalSearchWidget(),
                Spacer(),
                PortalDebtsPartners(),
                PortalPhonesAddresses(),
                PortalProfileName()
              ],
            ),
          ),

          /// Divider
          Divider(),

          /// Name of page
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: Row(
              children: [
                if (!Responsive.isDesktop(context))
                  GestureDetector(
                    child: Icon(
                      Icons.menu,
                      color: Colors.blue,
                    ),
                    onTap: context.read<MenuController>().controlMenu,
                  ),
                SizedBox(
                  width: 40,
                  child: Icon(
                    Icons.receipt_long,
                    color: Colors.blue,
                  ),
                ),
                Text(namePage, style: TextStyle(color: fontColorDarkGrey, fontSize: 16, fontWeight: FontWeight.bold)),
                //Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget portalSearchWidget() {
    return PortalSearch(
      textFieldSearchController: textFieldSearchCatalogController,
      onSubmittedSearch: (text) async {
        if (textFieldSearchCatalogController.text == '') {
          return;
        }
      },
      onTapClear: () {
        if (textFieldSearchCatalogController.text != '') {
          textFieldSearchCatalogController.text = '';
        }
      },
    );
  }

  Widget periodDocuments() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        border: Border.all(color: Colors.white10),
      ),
      child: SizedBox(
        height: 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(textFieldPeriodController.text),
            SizedBox(width: defaultPadding),
            GestureDetector(
              onTap: () async {
                var _datePick = await showDateRangePicker(
                    context: context,
                    initialDateRange: DateTimeRange(start: startPeriodDocs, end: finishPeriodDocs),
                    helpText: 'Виберіть період',
                    firstDate: DateTime(2021, 1, 1),
                    lastDate: DateTime.now(),
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
                  textFieldPeriodController.text =
                      shortDateToString(startPeriodDocs) + ' - ' + shortDateToString(finishPeriodDocs);

                  startPeriodDocsString = shortDateToString1C(startPeriodDocs);
                  finishPeriodDocsString = shortDateToString1C(finishPeriodDocs);

                  /// Save period
                  final SharedPreferences prefs = await _prefs;
                  prefs.setString('forms_orders_movements_periodDocuments', textFieldPeriodController.text);

                  /// Show documents
                  _loadListOrdersMovements();
                  setState(() {});
                }
              },
              child: Icon(Icons.date_range, color: iconColor),
            ),
          ],
        ),
      ),
    );
  }

  /// LISTS

  Widget orderMovementList() {
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
                Text('Список документів', style: TextStyle(color: fontColorDarkGrey, fontSize: 16)),
                Spacer(),
                periodDocuments(),
                SizedBox(width: defaultPadding),
                SizedBox(
                  height: 30,
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
                        await _loadListOrdersMovements();
                      },
                      child: Text('Додати документ')),
                ),
              ],
            ),
          ),

          /// Header
          Container(
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  top: BorderSide(color: Colors.grey.withOpacity(0.3))),
              color: bgColorHeader,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(defaultPadding, defaultPadding, defaultPadding * 2, defaultPadding),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text('',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 3,
                    child: Text('Дата',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 3,
                    child: Text('Статус',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 3,
                    child: Text('Організація',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 3,
                    child: Text('Відправник',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 2,
                    child: Text('Отримувач',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                ],
              ),
            ),
          ),

          /// List of documents
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
                          return rowDataOrderMovement(orderCustomer);
                        })
                    : SizedBox(height: 50, child: Center(child: Text('Список документів порожній!'))),
              )
            ],
          ),

          /// Footer
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

  Widget rowDataOrderMovement(OrderMovement orderMovement) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderMovementItemScreen(orderMovement: orderMovement),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          color: secondaryColor,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, defaultPadding, 0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Icon(Icons.description, color: iconColor, size: 20),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 3,
                child: Text(
                  fullDateToString(orderMovement.date!),
                ),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 3,
                child: Text(orderMovement.status!),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 3,
                child: Text(orderMovement.nameOrganization!.trim()),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 3,
                child: Text(orderMovement.nameWarehouseSender!.trim()),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(orderMovement.nameWarehouseReceiver!.trim()),
              ),
              spaceBetweenColumn(),
            ],
          ),
        ),
      ),
    );
  }
}
