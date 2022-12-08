import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_b2b/constants.dart';
import 'package:wp_b2b/controllers/MenuController.dart';
import 'package:wp_b2b/controllers/accum_partner_debts_controller.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/accum_partner_depts.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/screens/login/login_screen.dart';
import 'package:wp_b2b/screens/side_menu/side_menu.dart';
import 'package:wp_b2b/system.dart';
import 'package:wp_b2b/widgets.dart';

import 'components/header.dart';

class FinancesScreen extends StatefulWidget {
  static const routeName = '/finances';

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String profileName = '';
  String namePage = 'ВЗАЄМОРОЗРАХУНКИ';
  bool loadingData = false;

  TextEditingController textFieldSearchCatalogController = TextEditingController();
  TextEditingController textFieldPeriodController = TextEditingController();

  List<AccumPartnerDept> listAccumPartnerDept = [];

  String startPeriodDocsString = '';
  String finishPeriodDocsString = '';

  /// Начало периода отбора
  DateTime startPeriodDocs =
  DateTime(DateTime
      .now()
      .year, DateTime
      .now()
      .month, DateTime
      .now()
      .day-6);

  /// Конец периода отбора
  DateTime finishPeriodDocs = DateTime(DateTime
      .now()
      .year,
      DateTime
          .now()
          .month, DateTime
          .now()
          .day, 23, 59, 59);


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
                      //height: MediaQuery.of(context).size.height,
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
                                financesList(),
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

  _loadData() async {
    await _loadProfileData();
    await _loadPeriod();
    setState(() {});
    await _loadListAccumPartnerDebts();
  }

  /// LOADING DATA

  _loadProfileData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    profileName = pref.getString('settings_profileName') ?? '';
  }

  _loadListAccumPartnerDebts() async {
    // Request to server
    ApiResponse response = await getAccumPartnerDebts('00000000-0000-0000-0000-000000000000');

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          listAccumPartnerDept.add(item);
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

  _loadPeriod() async {
    final SharedPreferences prefs = await _prefs;

    textFieldPeriodController.text = prefs.getString('forms_finance_periodDocuments') ?? '';

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
                  if (!Responsive.isDesktop(context))
                    GestureDetector(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: Icon(
                          Icons.menu,
                          color: Colors.blue,
                        ),
                      ),
                      onTap: context.read<MenuController>().controlMenu,
                    ),
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: Icon(
                      Icons.receipt_long,
                      color: Colors.blue,
                    ),
                  ),
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
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                child: Text(profileName)),
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
                  prefs.setString('forms_finance_periodDocuments', textFieldPeriodController.text);

                  /// Show documents
                  _loadListAccumPartnerDebts();
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

  Widget financesList() {
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
                    child: Text('', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 2,
                    child: Text('Дата', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 2,
                    child:
                    Text('Організація', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 2,
                    child: Text('Контрагент', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 2,
                    child: Text('Договір', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 4,
                    child: Text('Документ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 1,
                    child: Text('Баланс (валюта)', style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 1,
                    child: Text('Баланс (грн)', style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
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
                child: listAccumPartnerDept.isNotEmpty
                    ? ListView.builder(
                    padding: EdgeInsets.all(0.0),
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: listAccumPartnerDept.length,
                    itemBuilder: (context, index) {
                      final finance = listAccumPartnerDept[index];
                      return rowDataFinance(finance);
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

  Widget rowDataFinance(AccumPartnerDept accumPartnerDept) {
    return GestureDetector(
      onTap: () async {},
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
                flex: 2,
                child: Text(fullDateToString(accumPartnerDept.date!),
                ),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(accumPartnerDept.nameOrganization!.trim()),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(accumPartnerDept.namePartner!.trim()),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(accumPartnerDept.nameContract!.trim()),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 4,
                child: Text(accumPartnerDept.nameDoc!.trim()),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 1,
                child: Text(doubleToString(accumPartnerDept.balance!)),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 1,
                child: Text(doubleToString(accumPartnerDept.balanceUah!)),
              ),
              spaceBetweenColumn(),
            ],
          ),
        ),
      ),
    );
  }


  Widget financesList2() {
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
                  flex: 2,
                  child: Text("Дата", textAlign: TextAlign.left),
                ),
                spaceBetweenColumn(),
                Expanded(
                  flex: 2,
                  child: Text("Організація", textAlign: TextAlign.left),
                ),
                spaceBetweenColumn(),
                Expanded(
                  flex: 2,
                  child: Text("Контрагент", textAlign: TextAlign.left),
                ),
                spaceBetweenColumn(),
                Expanded(
                  flex: 2,
                  child: Text("Договір", textAlign: TextAlign.left),
                ),
                spaceBetweenColumn(),
                Expanded(
                  flex: 4,
                  child: Text("Документ", textAlign: TextAlign.left),
                ),
                spaceBetweenColumn(),
                Expanded(
                  flex: 2,
                  child: Text("Баланс (валюта)", textAlign: TextAlign.left),
                ),
                spaceBetweenColumn(),
                Expanded(
                  flex: 2,
                  child: Text("Баланс (грн)"),
                ),
              ],
            ),
          ),
          Divider(color: Colors.blueGrey, thickness: 0.5),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: ListView.builder(
                    padding: EdgeInsets.all(0.0),
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: listAccumPartnerDept.length,
                    itemBuilder: (context, index) {
                      final accumPartnerDept = listAccumPartnerDept[index];
                      return recentAccumPartnerDeptDataRow(accumPartnerDept);
                    }),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget recentAccumPartnerDeptDataRow(AccumPartnerDept accumPartnerDept) {
    return ListTile(
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
                flex: 2,
                child: Text(fullDateToString(accumPartnerDept.date),
                    style: TextStyle(color: fontColorBlack)),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(accumPartnerDept.nameOrganization,
                    style: TextStyle(color: fontColorBlack)),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(accumPartnerDept.namePartner,
                    style: TextStyle(color: fontColorBlack)),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(accumPartnerDept.nameContract,
                    style: TextStyle(color: fontColorBlack)),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 4,
                child: Text(accumPartnerDept.nameDoc,
                    style: TextStyle(color: fontColorBlack)),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(doubleToString(accumPartnerDept.balance),
                    style: TextStyle(
                        color: fontColorBlack, overflow: TextOverflow.fade)),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(doubleToString(accumPartnerDept.balanceUah),
                    style: TextStyle(color: fontColorBlack)),
              ),
            ],
          ),
          SizedBox(
            height: 1,
          ),
          Divider(color: Colors.blueGrey, thickness: 0.5),
        ],
      ),
    );
  }

}
