import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_b2b/constants.dart';
import 'package:wp_b2b/controllers/MenuController.dart';
import 'package:wp_b2b/controllers/api_controller.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/screens/login/login_screen.dart';
import 'package:wp_b2b/screens/side_menu/side_menu.dart';
import 'package:wp_b2b/system.dart';
import 'package:wp_b2b/widgets.dart';

class SettingsAdminScreen extends StatefulWidget {
  static const routeName = '/admin';

  @override
  State<SettingsAdminScreen> createState() => _SettingsAdminScreenState();
}

class _SettingsAdminScreenState extends State<SettingsAdminScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String profileName = '';

  List<String> listNotifications = [];

  /// Поле ввода: Server
  TextEditingController textFieldServerController = TextEditingController();
  TextEditingController textFieldPhotoServerController =
      TextEditingController();
  TextEditingController textFieldNameOrganizationController =
      TextEditingController();
  TextEditingController textFieldSloganOrganizationController =
      TextEditingController();

  _fillSettings() async {
    final SharedPreferences prefs = await _prefs;
    textFieldServerController.text =
        prefs.getString('settings_serverExchange') ?? '';
    textFieldPhotoServerController.text =
        prefs.getString('settings_photoServerExchange') ?? '';
    textFieldNameOrganizationController.text =
        prefs.getString('settings_nameOrganization') ?? 'Оптовий портал';
    textFieldSloganOrganizationController.text =
        prefs.getString('settings_sloganOrganization') ??
            'продаж та взаєморозрахунки';

    setState(() {});
  }

  _saveSettings() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('settings_serverExchange', textFieldServerController.text);
    prefs.setString(
        'settings_photoServerExchange', textFieldPhotoServerController.text);
    prefs.setString(
        'settings_nameOrganization', textFieldNameOrganizationController.text);
    prefs.setString('settings_sloganOrganization',
        textFieldSloganOrganizationController.text);
  }

  _loadProfileData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    profileName = pref.getString('profileName') ?? '';
  }

  @override
  void dispose() {
    _saveSettings();
    textFieldServerController.dispose();
    textFieldPhotoServerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fillSettings();
    _loadProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuController>().scaffoldNotificationsKey,
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
                                settingsList(),
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

  Widget headerPage() {
    return Container(
      height: 57,
      decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.3))),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 3,
              offset: const Offset(0, 2), // changes position of shadow
            ),
          ]),
      child: Column(
        children: [
          /// Name of page
          Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                children: [
                  if (!Responsive.isDesktop(context))
                    IconButton(
                      icon: Icon(Icons.menu, color: Colors.blue),
                      onPressed: context.read<MenuController>().controlMenu,
                    ),
                  Text('НАЛАШТУВАННЯ',
                      style: TextStyle(
                          color: fontColorDarkGrey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              )),
        ],
      ),
    );
  }

  Widget headerWidget() {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          if (!Responsive.isDesktop(context))
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: context.read<MenuController>().controlMenu,
            ),
          if (!Responsive.isMobile(context))
            Text(
              "Налаштування",
              style: Theme.of(context).textTheme.headline6,
            ),
          if (!Responsive.isMobile(context))
            Spacer(flex: Responsive.isDesktop(context) ? 1 : 1),

          //profileNameWidget(),
        ],
      ),
    );
  }

  Widget settingsList() {
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
          /// Адрес сервера
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Spacer(),
                              Text('Адреса сервера:'),
                              spaceBetweenColumn(),
                            ],
                          )),
                      Expanded(
                          flex: 5,
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              onChanged: (e) {
                                _saveSettings();
                              },
                              style: TextStyle(fontSize: 14),
                              keyboardType: TextInputType.text,
                              controller: textFieldServerController,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 24, 10, 0),
                                fillColor: bgColor,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(5)),
                                ),
                              ),
                            ),
                          ))
                    ],
                  )),
            ],
          ),
          spaceVertBetweenHeaderColumn(),

          /// Адрес сервера картинок
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Spacer(),
                              Text('Адреса картинок:'),
                              spaceBetweenColumn(),
                            ],
                          )),
                      Expanded(
                          flex: 5,
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              onChanged: (e) {
                                _saveSettings();
                              },
                              style: TextStyle(fontSize: 14),
                              keyboardType: TextInputType.text,
                              controller: textFieldPhotoServerController,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 24, 10, 0),
                                fillColor: bgColor,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(5)),
                                ),
                              ),
                            ),
                          ))
                    ],
                  )),
            ],
          ),
          spaceVertBetweenHeaderColumn(),

          /// Название кампании
          Row(
            children: [
              /// Назва порталу
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Spacer(),
                              Text('Название компании:'),
                              spaceBetweenColumn(),
                            ],
                          )),
                      Expanded(
                        flex: 5,
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            onChanged: (e) {
                              _saveSettings();
                            },
                            style: TextStyle(fontSize: 14),
                            keyboardType: TextInputType.text,
                            controller: textFieldNameOrganizationController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                              fillColor: bgColor,
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
          spaceVertBetweenHeaderColumn(),

          /// Слоган кампании
          Row(
            children: [
              /// Слога порталу
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Spacer(),
                              Text('Слоган компании:'),
                              spaceBetweenColumn(),
                            ],
                          )),
                      Expanded(
                        flex: 5,
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            onChanged: (e) {
                              _saveSettings();
                            },
                            style: TextStyle(fontSize: 14),
                            keyboardType: TextInputType.text,
                            controller: textFieldSloganOrganizationController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                              fillColor: bgColor,
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget profileNameWidget() {
    return Container(
      margin: EdgeInsets.only(left: defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
      child: SizedBox(
        height: 25,
        child: Row(
          children: [
            Image.asset(
              "assets/images/profile_pic.png",
              height: 38,
            ),
            if (!Responsive.isMobile(context))
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                child: Text(profileName),
              ),
            Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}
