import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_b2b/constants.dart';
import 'package:wp_b2b/controllers/MenuController.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/order_customer_controller.dart';
import 'package:wp_b2b/controllers/organization_controller.dart';
import 'package:wp_b2b/controllers/partner_controller.dart';
import 'package:wp_b2b/controllers/price_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/controllers/warehouse_controller.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/models/doc_order_customer.dart';
import 'package:wp_b2b/models/ref_organization.dart';
import 'package:wp_b2b/models/ref_partner.dart';
import 'package:wp_b2b/models/ref_price.dart';
import 'package:wp_b2b/models/ref_product.dart';
import 'package:wp_b2b/models/ref_warehouse.dart';
import 'package:wp_b2b/screens/login/login_screen.dart';
import 'package:wp_b2b/screens/products/products_list_selection_screen.dart';
import 'package:wp_b2b/screens/side_menu/side_menu.dart';
import 'package:wp_b2b/system.dart';
import 'package:wp_b2b/widgets.dart';

String pathPicture = '';

class OrderCustomerItemScreen extends StatefulWidget {
  final OrderCustomer orderCustomer;

  const OrderCustomerItemScreen({Key? key, required this.orderCustomer}) : super(key: key);

  static const routeName = '/order_customer';

  @override
  State<OrderCustomerItemScreen> createState() => _OrderCustomerItemScreenState();
}

class _OrderCustomerItemScreenState extends State<OrderCustomerItemScreen> {
  bool loadingData = false;
  String profileName = '';

  TextEditingController textFieldSearchCatalogController = TextEditingController();

  List<Organization> listOrganizations = [];
  List<Partner> listPartners = [];
  List<Warehouse> listWarehouses = [];
  List<Price> listPrices = [];

  /// ???????? ??????????: ???????? ??????????????????
  TextEditingController textFieldDateController = TextEditingController();

  /// ???????? ??????????: ??????????????????????
  TextEditingController textFieldOrganizationController = TextEditingController();

  /// ???????? ??????????: ??????????????
  TextEditingController textFieldPartnerController = TextEditingController();

  /// ???????? ??????????: ?????????????? (???????????????? ??????????)
  TextEditingController textFieldContractController = TextEditingController();

  /// ???????? ??????????: ?????????????? (???????????????? ??????????)
  TextEditingController textFieldStoreController = TextEditingController();

  /// ???????? ??????????: ?????? ????????
  TextEditingController textFieldPriceController = TextEditingController();

  /// ???????? ??????????: ??????????
  TextEditingController textFieldWarehouseController = TextEditingController();

  /// ???????? ??????????: ???????? ??????????????????
  TextEditingController textFieldSumController = TextEditingController();

  /// ???????? ??????????: ???????? ??????????????????
  TextEditingController textFieldWeightController = TextEditingController();

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
                child: Column(
                  children: [
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
                                textFieldsDocumentDesktop(),
                                spaceVertBetweenHeaderColumn(),
                                itemsOrderCustomerList(),
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
    await _loadPathPictureData();
    await _loadProfileData();
    setState(() {});
    await _loadItemsOrderCustomer();
    await _loadOrganizations();
    await _loadPartners();
    await _loadWarehouses();
    await _loadPrices();
    await _updateHeader();
  }

  _loadPathPictureData() async {
    pathPicture = await getBasePhotoUrl();
  }

  _loadProfileData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    profileName = pref.getString('settings_profileName') ?? '';
  }

  _loadItemsOrderCustomer() async {
    // Item without UUID - new item
    if (widget.orderCustomer.uid == '') {
      return;
    }

    // Request to server
    ApiResponse response = await getItemsOrderCustomerByUID(widget.orderCustomer.uid);

    // Read response
    if (response.error == null) {
      setState(() {
        widget.orderCustomer.itemsOrderCustomer.clear();
        for (var item in response.data as List<dynamic>) {
          widget.orderCustomer.itemsOrderCustomer.add(item);
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

  _loadOrganizations() async {
    // If document is in the database already
    if (widget.orderCustomer.uid.isNotEmpty) {
      return;
    }

    // Request to server
    ApiResponse response = await getOrganizations();

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          listOrganizations.add(item);
        }

        // Default value
        if (listOrganizations.isNotEmpty) {
          if (widget.orderCustomer.uidOrganization.isEmpty) {
            Organization defaultOrganization = listOrganizations[0];
            widget.orderCustomer.uidOrganization = defaultOrganization.uid;
            widget.orderCustomer.nameOrganization = defaultOrganization.name;
          }
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

  _loadPartners() async {
    // If document is in the database already
    if (widget.orderCustomer.uid.isNotEmpty) {
      return;
    }

    // Request to server
    ApiResponse response = await getPartners();

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          listPartners.add(item);
        }

        // Default value
        if (listPartners.isNotEmpty) {
          if (widget.orderCustomer.uidPartner.isEmpty) {
            Partner defaultPartner = listPartners[0];
            widget.orderCustomer.uidPartner = defaultPartner.uid;
            widget.orderCustomer.namePartner = defaultPartner.name;
          }
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

  _loadWarehouses() async {
    // If document is in the database already
    if (widget.orderCustomer.uid.isNotEmpty) {
      return;
    }

    // Request to server
    ApiResponse response = await getWarehouses();

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          listWarehouses.add(item);
        }

        // Default value
        if (listWarehouses.isNotEmpty) {
          if (widget.orderCustomer.uidWarehouse.isEmpty) {
            Warehouse defaultWarehouse = listWarehouses[0];
            widget.orderCustomer.uidWarehouse = defaultWarehouse.uid;
            widget.orderCustomer.nameWarehouse = defaultWarehouse.name;
          }
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

  _loadPrices() async {
    // If document is in the database already
    if (widget.orderCustomer.uid.isNotEmpty) {
      return;
    }

    // Request to server
    ApiResponse response = await getPrices();

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          listPrices.add(item);
        }

        // Default value
        if (listPrices.isNotEmpty) {
          if (widget.orderCustomer.uidPrice.isEmpty) {
            Price defaultPrice = listPrices[0];
            widget.orderCustomer.uidPrice = defaultPrice.uid;
            widget.orderCustomer.namePrice = defaultPrice.name;
          }
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

  _saveTempDocumentOrderCustomer() async {
    var jsonDoc = widget.orderCustomer.toJson();
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (widget.orderCustomer.itemsOrderCustomer.isNotEmpty) {
      await pref.setString('tempOrderCustomer', jsonEncode(jsonDoc));
    } else {
      _clearTempDocumentOrderCustomer();
    }
  }

  _clearTempDocumentOrderCustomer() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('tempOrderCustomer', '');
  }

  _updateHeader() async {
    textFieldDateController.text = fullDateToString(widget.orderCustomer.date ?? DateTime.parse(''));
    textFieldOrganizationController.text = widget.orderCustomer.nameOrganization ?? '';
    textFieldPartnerController.text = widget.orderCustomer.namePartner ?? '';
    textFieldContractController.text = widget.orderCustomer.nameContract ?? '';
    textFieldStoreController.text = widget.orderCustomer.nameStore ?? '';
    textFieldPriceController.text = widget.orderCustomer.namePrice ?? '';
    textFieldWarehouseController.text = widget.orderCustomer.nameWarehouse ?? '';
    textFieldSumController.text = doubleToString(widget.orderCustomer.sum ?? 0.0);
  }

  _postOrderCustomer() async {
    // Request to server
    ApiResponse response = await postOrderCustomer(widget.orderCustomer);

    // Read response
    if (response.error == null) {

        for (var item in response.data as List<dynamic>) {
          widget.orderCustomer.uid = item.uid;
          widget.orderCustomer.uidOrganization = item.uidOrganization;
          widget.orderCustomer.nameOrganization = item.nameOrganization;
          widget.orderCustomer.uidPartner = item.uidPartner;
          widget.orderCustomer.namePartner = item.namePartner;
          widget.orderCustomer.uidContract = item.uidContract;
          widget.orderCustomer.nameContract = item.nameContract;
          widget.orderCustomer.uidPrice = item.uidPrice;
          widget.orderCustomer.namePrice = item.namePrice;
          widget.orderCustomer.uidWarehouse = item.uidWarehouse;
          widget.orderCustomer.nameWarehouse = item.nameWarehouse;
          widget.orderCustomer.date = item.date;
          widget.orderCustomer.sum = item.sum;
          widget.orderCustomer.numberFrom1C = item.numberFrom1C;
          break; // Only one item in there
        }

        loadingData = loadingData ? !loadingData : loadingData;

        await _updateHeader();

        await _clearTempDocumentOrderCustomer();

        showMessage('???????????????? ??????????????????????!', context);

        setState(() {});
    } else if (response.error == unauthorized) {
      logout().then((value) => {Navigator.restorablePushNamed(context, LoginScreen.routeName)});
    } else {
      showErrorMessage('${response.error}', context);
    }

    setState(() {
      loadingData = false;
    });
  }

  _printItem() {}

  _downloadItem() {}

  /// HEADER

  Widget getItemSmallPictureWithPopup(item) {
    return FutureBuilder(
      // Paste your image URL inside the htt.get method as a parameter
      future: http.get(Uri.parse(pathPicture + '/${item.uid}_0.png'), headers: {
        HttpHeaders.accessControlAllowOriginHeader: '*',
      }),
      builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Icon(
              Icons.image,
              color: Colors.white24,
            );
          case ConnectionState.active:
            return Icon(
              Icons.image,
              color: Colors.white24,
            );
          case ConnectionState.waiting:
            return SizedBox(
              height: 50,
              width: 50,
              child: Center(
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: Colors.blue.withOpacity(0.5),
                  ),
                ),
              ),
            );
          case ConnectionState.done:
            if (snapshot.hasError)
              return SizedBox(
                height: 50,
                width: 50,
                child: Icon(
                  Icons.image,
                  color: Colors.blue.withOpacity(0.5),
                ),
              );

            // when we get the data from the http call, we give the bodyBytes to Image.memory for showing the image
            if (snapshot.data!.statusCode == 200) {
              return GestureDetector(
                  onTap: () async {
                    await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            content: Text(item.name, style: TextStyle(color: Colors.black)),
                            actions: <Widget>[
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 300, height: 300, child: Image.memory(snapshot.data!.bodyBytes)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                                          onPressed: () async {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: const Text('??????????????'))
                                    ],
                                  )
                                ],
                              ),
                            ],
                          );
                        });
                  },
                  child: SizedBox(height: 50, width: 50, child: Image.memory(snapshot.data!.bodyBytes)));
            } else {
              return SizedBox(
                height: 50,
                width: 50,
                child: Icon(
                  Icons.image,
                  color: Colors.blue.withOpacity(0.5),
                ),
              );
            }
        }
      },
    );
  }

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
            padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
            child: Row(
              children: [
                searchFieldWidget(),
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
            child: SizedBox(
              height: 30,
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
                  spaceBetweenHeaderColumn(),
                  Text(
                      widget.orderCustomer.uid.isNotEmpty
                          ? "???????????????????? ???" + widget.orderCustomer.numberFrom1C
                          : "?????????????????? ????????????????????",
                      style: TextStyle(color: fontColorDarkGrey, fontSize: 16, fontWeight: FontWeight.bold)),

                  /// Space between name of page and buttons
                  Spacer(),

                  /// Download item
                  IconButtonPortal(
                      icon: Icons.download,
                      active: true,
                      onTap: () async {
                        if (widget.orderCustomer.uid != '') {
                          return;
                        }

                        bool valueResult = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: const Text('?????????????????????? ?????????????????'),
                                actions: <Widget>[
                                  Center(child: Text('???????????????????? ?? ????????????????...')),
                                  spaceVertBetweenHeaderColumn(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: Center(child: Text('??????'))),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ElevatedButton(
                                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                                          onPressed: () async {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: const Text('????'))
                                    ],
                                  ),
                                ],
                              );
                            }) as bool;

                        if (valueResult) {
                          _downloadItem();
                        }
                      }),
                  spaceBetweenHeaderColumn(),

                  /// Print item
                  IconButtonPortal(
                      icon: Icons.print,
                      active: true,
                      onTap: () async {
                        if (widget.orderCustomer.uid != '') {
                          return;
                        }

                        bool valueResult = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: const Text('???????????????????????? ?????????????????'),
                                actions: <Widget>[
                                  Center(child: Text('???????????????????? ?? ????????????????...')),
                                  spaceVertBetweenHeaderColumn(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: Center(child: Text('??????'))),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ElevatedButton(
                                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                                          onPressed: () async {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: const Text('????'))
                                    ],
                                  ),
                                ],
                              );
                            }) as bool;

                        if (valueResult) {
                          _downloadItem();
                        }
                      }),
                  spaceBetweenHeaderColumn(),

                  /// Send to 1C database
                  ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                      onPressed: () async {
                        if (widget.orderCustomer.uid != '') {
                          showErrorMessage('?????????????????????? ?????????????????? ????????????????????!', context);
                          return;
                        }

                        if (widget.orderCustomer.itemsOrderCustomer.length == 0) {
                          showErrorMessage('???????????????? ????????????????! ?????????????????? ??????????????????.', context);
                          return;
                        }

                        var valueResult = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: const Text('???????????????????? ???????????????? ???????????????????????????'),
                                actions: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: Center(child: Text('????????????????????'))),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ElevatedButton(
                                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                                          onPressed: () async {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: const Text('??????????????'))
                                    ],
                                  ),
                                ],
                              );
                            });

                        if (valueResult != null) {
                          if (valueResult) {
                            await _postOrderCustomer();
                          }
                        }
                      },
                      child: Text('???????????????????? ??????????????????????????')),
                  spaceBetweenHeaderColumn(),

                  /// Close item
                  ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                      onPressed: () async {
                        if (widget.orderCustomer.uid != '') {
                          Navigator.of(context).pop();
                          return;
                        }

                        var valueResult = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: const Text('?????????????? ????????????????? \n\n???????????????? ?????????? ?????????????? ?????????????????? ??????????????????????.'),
                                actions: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () async {
                                            await _saveTempDocumentOrderCustomer();
                                            Navigator.of(context).pop(true);
                                          },
                                          child: Center(child: Text('??????'))),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ElevatedButton(
                                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                                          onPressed: () async {
                                            await _saveTempDocumentOrderCustomer();
                                            Navigator.of(context).pop(false);
                                          },
                                          child: const Text('????'))
                                    ],
                                  ),
                                ],
                              );
                            });

                        if (valueResult != null) {
                          if (valueResult) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child: Text('??????????????')),
                  spaceBetweenHeaderColumn(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget searchFieldWidget() {
    return Container(
      height: 35,
      width: 300,
      margin: EdgeInsets.only(left: defaultPadding),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () async {
              if (textFieldSearchCatalogController.text == '') {
                return;
              }
              //await _loadListOrdersCustomers();
            },
            child: SizedBox(
              width: 35,
              child: Icon(Icons.search, color: iconColor),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 33,
                width: 225,
                child: TextField(
                  controller: textFieldSearchCatalogController,
                  onSubmitted: (text) async {
                    if (textFieldSearchCatalogController.text == '') {
                      return;
                    }
                    //await _loadListOrdersCustomers();
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    hintText: '??????????',
                    hintStyle: TextStyle(color: fontColorGrey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          InkWell(
              onTap: () async {
                textFieldSearchCatalogController.text = '';
                //await _loadListOrdersCustomers();
              },
              child: SizedBox(width: 35, child: Icon(Icons.delete, color: iconColorGrey.withOpacity(0.5)))),
        ],
      ),
    );
  }

  Widget textFieldsDocumentDesktop() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 35,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Date
                SizedBox(
                    width: 255,
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Spacer(),
                                Text('????????:'),
                                spaceBetweenColumn(),
                              ],
                            )),
                        Expanded(
                            flex: 5,
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                style: TextStyle(fontSize: 14),
                                readOnly: true,
                                controller: textFieldDateController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                                  fillColor: bgColor,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                                  ),
                                ),
                              ),
                            ))
                      ],
                    )),
                spaceBetweenHeaderColumn(),

                /// Organization
                Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Spacer(),
                                Text('??????????????????????:'),
                                spaceBetweenColumn(),
                              ],
                            )),
                        Expanded(
                            flex: 5,
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                style: TextStyle(fontSize: 14),
                                readOnly: true,
                                controller: textFieldOrganizationController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                                  fillColor: bgColor,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                                  ),
                                  suffixIcon: PopupMenuButton<Organization>(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                    onSelected: (Organization value) {
                                      setState(() {
                                        widget.orderCustomer.uidOrganization = value.uid;
                                        widget.orderCustomer.nameOrganization = value.name;
                                      });
                                      _updateHeader();
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return listOrganizations.map<PopupMenuItem<Organization>>((Organization value) {
                                        return PopupMenuItem(child: Text(value.name), value: value);
                                      }).toList();
                                    },
                                  ),
                                ),
                              ),
                            ))
                      ],
                    )),
                spaceBetweenHeaderColumn(),

                /// Partner
                Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Spacer(),
                                Text('??????????????:'),
                                spaceBetweenColumn(),
                              ],
                            )),
                        Expanded(
                            flex: 5,
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                style: TextStyle(fontSize: 14),
                                readOnly: true,
                                controller: textFieldPartnerController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                                  fillColor: bgColor,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                                  ),
                                  suffixIcon: PopupMenuButton<Partner>(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                    onSelected: (Partner value) {
                                      setState(() {
                                        widget.orderCustomer.uidPartner = value.uid;
                                        widget.orderCustomer.namePartner = value.name;
                                      });
                                      _updateHeader();
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return listPartners.map<PopupMenuItem<Partner>>((Partner value) {
                                        return PopupMenuItem(child: Text(value.name), value: value);
                                      }).toList();
                                    },
                                  ),
                                ),
                              ),
                            ))
                      ],
                    )),
              ],
            ),
          ),
          spaceVertBetweenHeaderColumn(),
          SizedBox(
            height: 35,
            child: Row(
              children: [
                /// Sum
                SizedBox(
                    width: 255,
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Spacer(),
                                Text('????????:'),
                                spaceBetweenColumn(),
                              ],
                            )),
                        Expanded(
                            flex: 5,
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                style: TextStyle(fontSize: 14),
                                readOnly: true,
                                controller: textFieldSumController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                                  fillColor: bgColor,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                                  ),
                                ),
                              ),
                            ))
                      ],
                    )),
                spaceBetweenHeaderColumn(),

                /// Warehouse
                Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Spacer(),
                                Text('??????????:'),
                                spaceBetweenColumn(),
                              ],
                            )),
                        Expanded(
                            flex: 5,
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                style: TextStyle(fontSize: 14),
                                readOnly: true,
                                controller: textFieldWarehouseController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                                  fillColor: bgColor,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                                  ),
                                  suffixIcon: PopupMenuButton<Warehouse>(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                    onSelected: (Warehouse value) {
                                      setState(() {
                                        widget.orderCustomer.uidWarehouse = value.uid;
                                        widget.orderCustomer.nameWarehouse = value.name;
                                      });
                                      _updateHeader();
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return listWarehouses.map<PopupMenuItem<Warehouse>>((Warehouse value) {
                                        return PopupMenuItem(child: Text(value.name), value: value);
                                      }).toList();
                                    },
                                  ),
                                ),
                              ),
                            ))
                      ],
                    )),
                spaceBetweenHeaderColumn(),

                /// Price
                Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Spacer(),
                                Text('?????? ????????:'),
                                spaceBetweenColumn(),
                              ],
                            )),
                        Expanded(
                            flex: 5,
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                style: TextStyle(fontSize: 14),
                                readOnly: true,
                                controller: textFieldPriceController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                                  fillColor: bgColor,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                                  ),
                                  suffixIcon: PopupMenuButton<Price>(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                    onSelected: (Price value) {
                                      setState(() {
                                        widget.orderCustomer.uidPrice = value.uid;
                                        widget.orderCustomer.namePrice = value.name;
                                      });
                                      _updateHeader();
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return listPrices.map<PopupMenuItem<Price>>((Price value) {
                                        return PopupMenuItem(child: Text(value.name), value: value);
                                      }).toList();
                                    },
                                  ),
                                ),
                              ),
                            ))
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// LISTS

  Widget itemsOrderCustomerList() {
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
          actionsOrderCustomerList(),

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
                    child: Text('????????',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 1,
                    child: Text('N',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 6,
                    child: Text('??????????',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 2,
                    child: Text('??????????????',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 3,
                    child: Text('??????????????????',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 3,
                    child: Text('????. ??????.',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 2,
                    child: Text('????????',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 2,
                    child: Text('????????????',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 2,
                    child: Text('????????', style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  Expanded(
                    child: Text(''),
                  ),
                  Expanded(
                    child: Text(''),
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
                child: widget.orderCustomer.itemsOrderCustomer.isNotEmpty
                    ? ListView.builder(
                        padding: EdgeInsets.all(0.0),
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: widget.orderCustomer.itemsOrderCustomer.length,
                        itemBuilder: (context, index) {
                          final itemOrderCustomer = widget.orderCustomer.itemsOrderCustomer[index];
                          return rowDataItemOrderCustomer(itemOrderCustomer);
                        })
                    : SizedBox(height: 50, child: Center(child: Text('???????????? ?????????????? ????????????????!'))),
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

  Widget actionsOrderCustomerList() {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding * 1.5),
      child: Row(
        children: [
          Text('???????????? ??????????????', style: TextStyle(color: fontColorDarkGrey, fontSize: 16)),

          /// Space
          Spacer(),

          /// Add products
          SizedBox(
              height: 30,
              child: ElevatedButton(
                  onPressed: () async {
                    if (widget.orderCustomer.uid != '') {
                      showErrorMessage('?????????????????????? ?????????????????? ????????????????????!', context);
                      return;
                    }
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListSelectionScreen(orderCustomer: widget.orderCustomer),
                      ),
                    );

                    OrderCustomer().allSum(widget.orderCustomer);

                    await _saveTempDocumentOrderCustomer();

                    _updateHeader();

                    setState(() {});
                  },
                  child: Text('???????????? ??????????'))),

          /// Space
          SizedBox(width: defaultPadding),

          /// Clear list
          SizedBox(
              height: 30,
              child: ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey)),
                  onPressed: () async {
                    if (widget.orderCustomer.uid != '') {
                      showErrorMessage('?????????????????????? ?????????????????? ????????????????????!', context);
                      return;
                    }
                    bool valueResult = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: const Text('???????????????? ???????????? ???????????????'),
                            actions: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: Center(child: Text('????????????????'))),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                                      onPressed: () async {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: const Text('??????????????'))
                                ],
                              ),
                            ],
                          );
                        }) as bool;

                    if (valueResult) {
                      setState(() {
                        widget.orderCustomer.itemsOrderCustomer.clear();
                        OrderCustomer().allSum(widget.orderCustomer);
                      });
                    }
                  },
                  child: Text('???????????????? ????????????'))),
        ],
      ),
    );
  }

  Widget rowDataItemOrderCustomer(ItemOrderCustomer item) {
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
                child: getItemSmallPictureWithPopup(item),
              ),
              spaceBetweenColumn(),
              spaceBetweenColumn(),
              Expanded(
                flex: 1,
                child: Text(item.numberRow.toString()),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 6,
                child: Text(item.name),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(item.nameCharacteristic.isNotEmpty ? item.nameCharacteristic : '-'),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 3,
                child: Text(doubleToString(item.count)),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 3,
                child: Text(item.nameUnit),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(doubleToString(item.price)),
              ),
              spaceBetweenColumn(),
              Expanded(
                flex: 2,
                child: Text(doubleToString(item.discount)),
              ),
              Expanded(
                flex: 2,
                child: Text(doubleToString(item.sum)),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                    onPressed: () async {
                      if (widget.orderCustomer.uid != '') {
                        showErrorMessage('?????????????????????? ?????????????????? ????????????????????!', context);
                        return;
                      }

                      Product product = Product();
                      product.name = item.name;
                      product.uid = item.uid;

                      ProductCharacteristic productCharacteristic = ProductCharacteristic();
                      productCharacteristic.name = item.nameCharacteristic;
                      productCharacteristic.uid = item.uidCharacteristic;

                      await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                content: CountWindow(
                                    orderCustomer: widget.orderCustomer,
                                    product: product,
                                    productCharacteristic: productCharacteristic,
                                    price: item.price,
                                    countOnWarehouse: item.count),
                              ));

                      OrderCustomer().allSum(widget.orderCustomer);

                      await _saveTempDocumentOrderCustomer();

                      setState(() {});
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Colors.grey,
                    )),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                    onPressed: () async {
                      if (widget.orderCustomer.uid != '') {
                        showErrorMessage('?????????????????????? ?????????????????? ????????????????????!', context);
                        return;
                      }
                      widget.orderCustomer.itemsOrderCustomer.remove(item);

                      OrderCustomer().allSum(widget.orderCustomer);

                      await _saveTempDocumentOrderCustomer();

                      setState(() {});
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.grey,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
