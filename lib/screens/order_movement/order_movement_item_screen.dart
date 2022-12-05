import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_b2b/constants.dart';
import 'package:wp_b2b/controllers/MenuController.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/order_movement_controller.dart';
import 'package:wp_b2b/controllers/organization_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/controllers/warehouse_controller.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/models/doc_order_movement.dart';
import 'package:wp_b2b/models/ref_organization.dart';
import 'package:wp_b2b/models/ref_warehouse.dart';
import 'package:wp_b2b/screens/login/login_screen.dart';
import 'package:wp_b2b/screens/products/products_list_selection_screen.dart';
import 'package:wp_b2b/screens/side_menu/side_menu.dart';
import 'package:wp_b2b/system.dart';
import 'package:wp_b2b/widgets.dart';

String pathPicture = '';

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
  String profileName = '';

  TextEditingController textFieldSearchCatalogController = TextEditingController();

  List<Organization> listOrganizations = [];
  List<ItemOrderMovement> listItemsOrderMovement = [];
  List<Warehouse> listWarehousesReceiver = [];
  List<Warehouse> listWarehousesSender = [];

  /// Поле ввода: Дата документа
  TextEditingController textFieldDateController = TextEditingController();

  /// Поле ввода: Организация
  TextEditingController textFieldOrganizationController = TextEditingController();

  /// Поле ввода: Склад отправитель
  TextEditingController textFieldWarehouseSenderController = TextEditingController();

  /// Поле ввода: Склад получатель
  TextEditingController textFieldWarehouseReceiverController = TextEditingController();

  /// Поле ввода: Сума документа
  TextEditingController textFieldSumController = TextEditingController();

  /// Поле ввода: Вага документа
  TextEditingController textFieldWeightController = TextEditingController();

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      key: context.read<MenuController>().scaffoldItemOrderMovementKey,
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
                //padding: EdgeInsets.all(defaultPadding),
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
                                itemsOrderMovementList(),
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
    await _loadItemsOrderMovement();
    await _loadOrganizations();
    await _loadWarehousesSender();
    await _loadWarehousesReceiver();
    await _updateHeader();
  }

  _loadPathPictureData() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    pathPicture = prefs.getString('settings_photoServerExchange') ?? '';
  }

  _loadProfileData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    profileName = pref.getString('settings_profileName') ?? '';
  }

  _loadItemsOrderMovement() async {
    // Item without UUID - new item
    if (widget.orderMovement.uid == '') {
      return;
    }

    // Request to server
    ApiResponse response = await getItemsOrderMovementByUID(widget.orderMovement.uid);

    // Read response
    if (response.error == null) {
      setState(() {
        widget.orderMovement.itemsOrderMovement.clear();
        for (var item in response.data as List<dynamic>) {
          widget.orderMovement.itemsOrderMovement.add(item);
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
    if (widget.orderMovement.uid.isNotEmpty) {
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
          if (widget.orderMovement.uidOrganization.isEmpty) {
            Organization defaultOrganization = listOrganizations[0];
            widget.orderMovement.uidOrganization = defaultOrganization.uid;
            widget.orderMovement.nameOrganization = defaultOrganization.name;
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

  _loadWarehousesSender() async {
    // If document is in the database already
    if (widget.orderMovement.uid.isNotEmpty) {
      return;
    }

    // Request to server
    ApiResponse response = await getWarehouses();

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          listWarehousesSender.add(item);
        }

        // Default value
        if (listWarehousesSender.isNotEmpty) {
          if (widget.orderMovement.uidWarehouseSender.isEmpty) {
            Warehouse defaultWarehouse = listWarehousesSender[0];
            widget.orderMovement.uidWarehouseSender = defaultWarehouse.uid;
            widget.orderMovement.nameWarehouseSender = defaultWarehouse.name;
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

  _loadWarehousesReceiver() async {
    // If document is in the database already
    if (widget.orderMovement.uid.isNotEmpty) {
      return;
    }

    // Request to server
    ApiResponse response = await getWarehouses();

    // Read response
    if (response.error == null) {
      setState(() {
        for (var item in response.data as List<dynamic>) {
          listWarehousesReceiver.add(item);
        }

        // Default value
        if (listWarehousesReceiver.isNotEmpty) {
          if (widget.orderMovement.uidWarehouseReceiver.isEmpty) {
            Warehouse defaultWarehouse = listWarehousesReceiver[0];
            widget.orderMovement.uidWarehouseReceiver = defaultWarehouse.uid;
            widget.orderMovement.nameWarehouseReceiver = defaultWarehouse.name;
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

  _updateHeader() async {
    textFieldDateController.text = fullDateToString(widget.orderMovement.date??DateTime.parse(''));
    textFieldOrganizationController.text =
    widget.orderMovement.nameOrganization!;
    textFieldWarehouseSenderController.text = widget.orderMovement.nameWarehouseSender!;
    textFieldWarehouseReceiverController.text = widget.orderMovement.nameWarehouseReceiver!;
  }

  /// HEADER

  Widget getItemSmallPicture(item) {
    return FutureBuilder(
      // Paste your image URL inside the htt.get method as a parameter
      future: http
          .get(Uri.parse(pathPicture+ '/${item.uid}_0.png'), headers: {
        HttpHeaders.accessControlAllowOriginHeader: '*',
      }),
      builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Icon(
              Icons.two_wheeler,
              color: Colors.white24,
            );
          case ConnectionState.active:
            return Icon(
              Icons.two_wheeler,
              color: Colors.white24,
            );
          case ConnectionState.waiting:
            return SizedBox(
              child: Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
              ),
              height: 20,
              width: 20,
            );
          case ConnectionState.done:
            if (snapshot.hasError)
              return Icon(
                Icons.image,
                color: Colors.blue.withOpacity(0.5),
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
                                      SizedBox(
                                          width: 300,
                                          height: 300,
                                          child: Image.memory(snapshot.data!.bodyBytes)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(Colors.red)),
                                          onPressed: () async {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: const Text('Відміна'))
                                    ],
                                  )
                                ],
                              ),
                            ],
                          );
                        });
                  },
                  child: Image.memory(snapshot.data!.bodyBytes));
            } else {
              return Icon(
                Icons.image,
                color: Colors.blue.withOpacity(0.2),
              );
            }
        }
      },
    );
  }

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
                  GestureDetector(
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.blue,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(widget.orderMovement.uid.isNotEmpty
                      ? "ПЕРЕМІЩЕННЯ ТОВАРІВ №" + widget.orderMovement.numberFrom1C
                      : "СТВОРЕННЯ ПЕРЕМІЩЕННЯ ТОВАРІВ",
                      style: TextStyle(color: fontColorDarkGrey, fontSize: 16, fontWeight: FontWeight.bold)),
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
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Date
              SizedBox(
                  width: 255,
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Row(
                        children: [
                          Spacer(),
                          Text('Дата:'),
                          spaceBetweenColumn(),
                        ],
                      )),
                      Expanded(flex: 5, child: SizedBox(
                        height: 40,
                        child: TextField(
                          style: TextStyle(fontSize:14),
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
                  )
              ),
              spaceBetweenHeaderColumn(),
              /// Organization
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Row(
                        children: [
                          Spacer(),
                          Text('Організація:'),
                          spaceBetweenColumn(),
                        ],
                      )),
                      Expanded(flex: 5, child: SizedBox(
                        height: 40,
                        child: TextField(
                          style: TextStyle(fontSize:14),
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
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.blue,
                                size: 30,
                              ),
                              onSelected: (Organization value) {
                                setState(() {
                                  widget.orderMovement.uidOrganization = value.uid;
                                  widget.orderMovement.nameOrganization = value.name;
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
                  )
              ),
              spaceBetweenHeaderColumn(),
              /// Sender
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Row(
                        children: [
                          Spacer(),
                          Text('Відправник:'),
                          spaceBetweenColumn(),
                        ],
                      )),
                      Expanded(flex: 5, child: SizedBox(
                          height: 40,
                          child: TextField(
                            style: TextStyle(fontSize:14),
                            readOnly: true,
                            controller: textFieldWarehouseSenderController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                              fillColor: bgColor,
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: const BorderRadius.all(Radius.circular(5)),
                              ),
                              suffixIcon: PopupMenuButton<Warehouse>(
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                                onSelected: (Warehouse value) {
                                  setState(() {
                                    widget.orderMovement.uidWarehouseSender = value.uid;
                                    widget.orderMovement.nameWarehouseSender = value.name;
                                  });
                                  _updateHeader();
                                },
                                itemBuilder: (BuildContext context) {
                                  return listWarehousesSender.map<PopupMenuItem<Warehouse>>((Warehouse value) {
                                    return PopupMenuItem(child: Text(value.name), value: value);
                                  }).toList();
                                },
                              ),
                            ),
                          )))
                    ],
                  )
              ),
              spaceBetweenHeaderColumn(),
            ],
          ),
          spaceVertBetweenHeaderColumn(),
          Row(
            children: [
              /// Empty
              SizedBox(
                  width: 255,
                  child: Container()),
              spaceBetweenHeaderColumn(),
              /// Empty
              Expanded(
                  flex: 1,
                  child: Container()),
              spaceBetweenHeaderColumn(),
              /// Receiver
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Row(
                        children: [
                          Spacer(),
                          Text('Отримувач:'),
                          spaceBetweenColumn(),
                        ],
                      )),
                      Expanded(flex: 5, child: SizedBox(
                        height: 40,
                        child: TextField(
                          style: TextStyle(fontSize:14),
                          readOnly: true,
                          controller: textFieldWarehouseReceiverController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                            fillColor: bgColor,
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: const BorderRadius.all(Radius.circular(5)),
                            ),
                            suffixIcon: PopupMenuButton<Warehouse>(
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.blue,
                                size: 30,
                              ),
                              onSelected: (Warehouse value) {
                                setState(() {
                                  widget.orderMovement.uidWarehouseReceiver = value.uid;
                                  widget.orderMovement.nameWarehouseReceiver = value.name;
                                });
                                _updateHeader();
                              },
                              itemBuilder: (BuildContext context) {
                                return listWarehousesReceiver.map<PopupMenuItem<Warehouse>>((Warehouse value) {
                                  return PopupMenuItem(child: Text(value.name), value: value);
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ))
                    ],
                  )
              ),
              spaceBetweenHeaderColumn(),
            ],
          ),
        ],
      ),
    );
  }

  Widget itemsOrderMovementList() {
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
                Text('Список товарів', style: TextStyle(color: fontColorDarkGrey, fontSize: 16)),
                /// Space
                Spacer(),
                // /// Send to 1C database
                // SizedBox(
                //     height: 30,
                //     child: ElevatedButton(
                //         style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                //         onPressed: () async {
                //           if(widget.orderMovement.uid != ''){
                //             showErrorMessage('Редагування документа заборонено!', context);
                //             return;
                //           }
                //
                //           bool valueResult = await showDialog<bool>(
                //               context: context,
                //               builder: (context) {
                //                 return AlertDialog(
                //                   content: const Text('Відправити документ постачальнику?'),
                //                   actions: <Widget>[
                //                     Row(
                //                       mainAxisAlignment: MainAxisAlignment.center,
                //                       children: [
                //                         ElevatedButton(
                //                             onPressed: () async {
                //                               Navigator.of(context).pop(true);
                //                             },
                //                             child: Center(child: Text('Відправити'))),
                //                         const SizedBox(
                //                           width: 10,
                //                         ),
                //                         ElevatedButton(
                //                             style: ButtonStyle(
                //                                 backgroundColor: MaterialStateProperty.all(Colors.red)),
                //                             onPressed: () async {
                //                               Navigator.of(context).pop(false);
                //                             },
                //                             child: const Text('Відміна'))
                //                       ],
                //                     ),
                //                   ],
                //                 );
                //               }) as bool;
                //
                //           if (valueResult) {
                //             //_postOrderCustomer();
                //           }
                //         },
                //         child: Text('Відправити постачальнику'))),
                // /// Space
                // SizedBox(width: defaultPadding),
                // /// Add products
                // SizedBox(
                //     height: 30,
                //     child: ElevatedButton(
                //         onPressed: () async {
                //           if(widget.orderMovement.uid != ''){
                //             showErrorMessage('Редагування документа заборонено!', context);
                //             return;
                //           }
                //           await Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (context) =>
                //                   ProductListSelectionScreen(orderMovement: widget.orderMovement),
                //             ),
                //           );
                //           setState(() {});
                //         },
                //         child: Text('Додати товар'))),
                // /// Space
                // SizedBox(width: defaultPadding),
                // /// Clear list
                // SizedBox(
                //     height: 30,
                //     child: ElevatedButton(
                //         style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                //         onPressed: () async {
                //           if(widget.orderMovement.uid != ''){
                //             showErrorMessage('Редагування документа заборонено!', context);
                //             return;
                //           }
                //           bool valueResult = await showDialog<bool>(
                //               context: context,
                //               builder: (context) {
                //                 return AlertDialog(
                //                   content: const Text('Очистити список товарів?'),
                //                   actions: <Widget>[
                //                     Row(
                //                       mainAxisAlignment: MainAxisAlignment.center,
                //                       children: [
                //                         ElevatedButton(
                //                             onPressed: () async {
                //                               Navigator.of(context).pop(true);
                //                             },
                //                             child: Center(child: Text('Очистити'))),
                //                         const SizedBox(
                //                           width: 10,
                //                         ),
                //                         ElevatedButton(
                //                             style: ButtonStyle(
                //                                 backgroundColor: MaterialStateProperty.all(Colors.red)),
                //                             onPressed: () async {
                //                               Navigator.of(context).pop(false);
                //                             },
                //                             child: const Text('Відміна'))
                //                       ],
                //                     ),
                //                   ],
                //                 );
                //               }) as bool;
                //
                //           if (valueResult) {
                //             setState(() {
                //               widget.orderMovement.itemsOrderMovement.clear();
                //             });
                //           }
                //         },
                //         child: Text('Очистити список'))),
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
                    child: Text('Фото', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 1,
                    child: Text('N', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 6,
                    child: Text('Товар', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 2,
                    child: Text('Варіант', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 3,
                    child:
                    Text('Кількість', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 3,
                    child: Text('Од. вим.', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 2,
                    child: Text('Ціна', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
                  ),
                  spaceBetweenColumn(),
                  Expanded(
                    flex: 2,
                    child: Text('Знижка', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, color: fontColorDarkGrey)),
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
                child: widget.orderMovement.itemsOrderMovement.isNotEmpty
                    ? ListView.builder(
                    padding: EdgeInsets.all(0.0),
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.orderMovement.itemsOrderMovement.length,
                    itemBuilder: (context, index) {
                      final itemsOrderMovement = widget.orderMovement.itemsOrderMovement[index];
                      return recentOrderMovementDataRow(itemsOrderMovement);
                    })
                    : SizedBox(height: 50, child: Center(child: Text('Список товарів порожній!'))),
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

  Widget recentOrderMovementDataRow(ItemOrderMovement item) {
    return Card(
      color: tileColor,
      elevation: 5,
      child: ListTile(
        onTap: () {},
        contentPadding: EdgeInsets.all(10.0),
        subtitle: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(item.numberRow.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            SizedBox(
              height: 50,
              width: 50,
              child: getItemSmallPicture(item),
            ),
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
              child:
                  Text(item.nameUnit, style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 1,
              child: Text(doubleToString(item.countPrepare),
                  style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 1,
              child: Text(doubleToString(item.countSend),
                  style: TextStyle(color: Colors.white)),
            ),
            spaceBetweenColumn(),
            Expanded(
              flex: 1,
              child: Text(doubleToString(item.countReceived),
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

}
