import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
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

import 'components/header.dart';

class FinancesScreen extends StatefulWidget {
  static const routeName = '/finances';

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  bool loadingData = false;
  List<AccumPartnerDept> listAccumPartnerDept = [];

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

  TextEditingController textFieldPeriodController = TextEditingController();

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
    if (textFieldPeriodController.text.isEmpty) {
      textFieldPeriodController.text =
          shortDateToString(startPeriodDocs) +
              ' - ' +
              shortDateToString(finishPeriodDocs);
    }
  }

  @override
  void initState() {
    _loadPeriod();
    _loadListAccumPartnerDebts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuController>().scaffoldFinanceKey,
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
                                          initialDateRange: DateTimeRange(
                                              start: startPeriodDocs, end: finishPeriodDocs),
                                          helpText: 'Виберіть період',
                                          firstDate: DateTime(2021, 1, 1),
                                          lastDate: finishPeriodDocs,builder: (context, child) {
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
                                            shortDateToString(startPeriodDocs) +
                                                ' - ' +
                                                shortDateToString(finishPeriodDocs);

                                        _loadListAccumPartnerDebts();
                                        setState(() {});
                                      }
                                    },
                                    icon:
                                    const Icon(Icons.date_range, color: iconColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
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
                              financesList(),
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

  Widget financesList() {
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
          Divider(color: Colors.white24, thickness: 0.5),
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
      // onTap: () async {
      //   await Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) =>
      //           OrderCustomerItemScreen(orderCustomer: orderCustomer),
      //     ),
      //   );
      // },
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
                    style: TextStyle(color: Colors.white)),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(accumPartnerDept.nameOrganization,
                    style: TextStyle(color: Colors.white)),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(accumPartnerDept.namePartner,
                    style: TextStyle(color: Colors.white)),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(accumPartnerDept.nameContract,
                    style: TextStyle(color: Colors.white)),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 4,
                child: Text(accumPartnerDept.nameDoc,
                    style: TextStyle(color: Colors.white)),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(doubleToString(accumPartnerDept.balance),
                    style: TextStyle(
                        color: Colors.white, overflow: TextOverflow.fade)),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(doubleToString(accumPartnerDept.balanceUah),
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

  Widget spaceBetweenColumn() {
    return SizedBox(width: 5);
  }
}
