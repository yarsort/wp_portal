import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_b2b/constants.dart';
import 'package:wp_b2b/controllers/MenuController.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/order_customer_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/models/doc_order_customer.dart';
import 'package:wp_b2b/screens/login/login_screen.dart';
import 'package:wp_b2b/screens/order_customer/order_customer_item_screen.dart';
import 'package:wp_b2b/screens/side_menu/side_menu.dart';
import 'package:wp_b2b/system.dart';
import 'package:wp_b2b/widgets.dart';

class OrderCustomerScreen extends StatefulWidget {
  static const routeName = '/orders_customers';

  @override
  State<OrderCustomerScreen> createState() => _OrderCustomerScreenState();
}

class _OrderCustomerScreenState extends State<OrderCustomerScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  TextEditingController textFieldSearchCatalogController = TextEditingController();
  TextEditingController textFieldPeriodController = TextEditingController();

  String profileName = '';
  String namePage = 'ЗАМОВЛЕННЯ КЛІЄНТА';
  bool loadingData = false;

  List<OrderCustomer> listOrderCustomer = [];

  /// Начало периода отбора
  String startPeriodDocsString = '';
  DateTime startPeriodDocs = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 6);

  /// Конец периода отбора
  String finishPeriodDocsString = '';
  DateTime finishPeriodDocs = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59);

  /// MAIN

  @override
  void initState() {
    _loadListOrdersCustomers();
    _loadProfileData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuController>().scaffoldOrderCustomerKey,
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
                //padding: EdgeInsets.all(defaultPadding),
                child: Column(
                  children: [
                    // Desktop view
                    headerPage(),
                    Container(
                      height: MediaQuery.of(context).size.height-115,
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
                                orderCustomerList(),
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
  _loadListOrdersCustomers() async {
    /// Restore or get dates
    await _loadPeriod();

    /// Request to server
    ApiResponse response = await getOrdersCustomers(startPeriodDocsString, finishPeriodDocsString);

    // Read response
    if (response.error == null) {
      setState(() {
        listOrderCustomer.clear();

        for (var item in response.data as List<dynamic>) {
          listOrderCustomer.add(item);
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

  _loadProfileData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    profileName = pref.getString('profileName') ?? '';
  }

  _loadPeriod() async {
    final SharedPreferences prefs = await _prefs;

    textFieldPeriodController.text = prefs.getString('forms_orders_customers_periodDocuments') ?? '';

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

  /// HEADER

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
                  Text(namePage,
                      style: TextStyle(color: fontColorDarkGrey, fontSize: 16, fontWeight: FontWeight.bold)),
                  Spacer(),
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
            //await _renewItem();
            return;
          }
          //await _renewItem();
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
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
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
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2), child: Text('Стрижаков Ярослав')),
            Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
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
                  textFieldPeriodController.text =
                      shortDateToString(startPeriodDocs) + ' - ' + shortDateToString(finishPeriodDocs);

                  /// Save period
                  final SharedPreferences prefs = await _prefs;
                  prefs.setString('forms_orders_customers_periodDocuments', textFieldPeriodController.text);

                  /// Show documents
                  _loadListOrdersCustomers();
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

  Widget orderCustomerList() {
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
                        OrderCustomer orderCustomer = OrderCustomer();
                        orderCustomer.date = DateTime.now();

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderCustomerItemScreen(orderCustomer: orderCustomer),
                          ),
                        );
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
              color: Colors.grey.withOpacity(0.3),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(defaultPadding, defaultPadding, defaultPadding * 2, defaultPadding),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text('', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 3,
                    child: Text('Дата', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 3,
                    child: Text('Статус', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 3,
                    child:
                        Text('Організація', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 3,
                    child: Text('Контрагент', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 2,
                    child: Text('Склад', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 2,
                    child: Text('Тип ціни', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 2,
                    child: Text('Сума', style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                ],
              ),
            ),
          ),

          /// List of documents
          Row(
            children: [
              Expanded(
                flex: 1,
                child: listOrderCustomer.isNotEmpty
                    ? ListView.builder(
                        padding: EdgeInsets.all(0.0),
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: listOrderCustomer.length,
                        itemBuilder: (context, index) {
                          final orderCustomer = listOrderCustomer[index];
                          return rowDataOrderCustomer(orderCustomer);
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

  Widget rowDataOrderCustomer(OrderCustomer orderCustomer) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderCustomerItemScreen(orderCustomer: orderCustomer),
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
                  fullDateToString(orderCustomer.date!),
                ),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 3,
                child: Text(orderCustomer.status!),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 3,
                child: Text(orderCustomer.nameOrganization!.trim()),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 3,
                child: Text(orderCustomer.namePartner!.trim()),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(orderCustomer.nameWarehouse!.trim()),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(orderCustomer.namePrice!.trim()),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(doubleToString(orderCustomer.sum!)),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
