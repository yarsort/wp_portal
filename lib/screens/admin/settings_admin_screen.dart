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
  TextEditingController textFieldPhotoServerController = TextEditingController();
  TextEditingController textFieldNameOrganizationController = TextEditingController();
  TextEditingController textFieldSloganOrganizationController = TextEditingController();

  _fillSettings() async {
    final SharedPreferences prefs = await _prefs;
    textFieldServerController.text = prefs.getString('settings_serverExchange') ?? '';
    textFieldPhotoServerController.text = prefs.getString('settings_photoServerExchange') ?? '';
    textFieldNameOrganizationController.text = prefs.getString('settings_nameOrganization') ?? 'Оптовий портал';
    textFieldSloganOrganizationController.text = prefs.getString('settings_sloganOrganization') ?? 'продаж та взаєморозрахунки';

    setState(() {});
  }

  _saveSettings() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('settings_serverExchange', textFieldServerController.text);
    prefs.setString('settings_photoServerExchange', textFieldPhotoServerController.text);
    prefs.setString('settings_nameOrganization', textFieldNameOrganizationController.text);
    prefs.setString('settings_sloganOrganization', textFieldSloganOrganizationController.text);
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
                padding: EdgeInsets.all(defaultPadding),
                child: Column(
                  children: [
                    // Desktop view
                    headerWidget(),
                    SizedBox(height: defaultPadding),
                    Row(
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
          if (!Responsive.isMobile(context)) Spacer(flex: Responsive.isDesktop(context) ? 1 : 1),

          //profileNameWidget(),
        ],
      ),
    );
  }

  Widget settingsList() {
    return Column(
      children: [
        Row(
          children: [
            /// Адрес сервера
            Expanded(
                flex: 1,
                child: IntrinsicHeight(
                  child: TextField(
                    onChanged: (e) {
                      _saveSettings();
                    },
                    keyboardType: TextInputType.text,
                    controller: textFieldServerController,
                    decoration: InputDecoration(
                      isDense: true,
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 2,
                        minHeight: 2,
                      ),
                      border: const OutlineInputBorder(),
                      labelStyle: const TextStyle(
                        color: Colors.blueGrey,
                      ),
                      labelText: 'Ім\'я сервера підключення',
                    ),
                  ),
                )),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            /// Адрес сервера
            Expanded(
                flex: 1,
                child: IntrinsicHeight(
                  child: TextField(
                    onChanged: (e) {
                      _saveSettings();
                    },
                    keyboardType: TextInputType.text,
                    controller: textFieldPhotoServerController,
                    decoration: InputDecoration(
                      isDense: true,
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 2,
                        minHeight: 2,
                      ),
                      border: const OutlineInputBorder(),
                      labelStyle: const TextStyle(
                        color: Colors.blueGrey,
                      ),
                      labelText: 'Ім\'я сервера для відображення фотографій',
                    ),
                  ),
                )),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            /// Назва порталу
            Expanded(
                flex: 1,
                child: IntrinsicHeight(
                  child: TextField(
                    onChanged: (e) {
                      _saveSettings();
                    },
                    keyboardType: TextInputType.text,
                    controller: textFieldNameOrganizationController,
                    decoration: InputDecoration(
                      isDense: true,
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 2,
                        minHeight: 2,
                      ),
                      border: const OutlineInputBorder(),
                      labelStyle: const TextStyle(
                        color: Colors.blueGrey,
                      ),
                      labelText: 'Назва організації B2B порталу',
                    ),
                  ),
                )),
            SizedBox(
              width: 16,
            ),
            /// Слога порталу
            Expanded(
                flex: 1,
                child: IntrinsicHeight(
                  child: TextField(
                    onChanged: (e) {
                      _saveSettings();
                    },
                    keyboardType: TextInputType.text,
                    controller: textFieldSloganOrganizationController,
                    decoration: InputDecoration(
                      isDense: true,
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 2,
                        minHeight: 2,
                      ),
                      border: const OutlineInputBorder(),
                      labelStyle: const TextStyle(
                        color: Colors.blueGrey,
                      ),
                      labelText: 'Слоган компанії',
                    ),
                  ),
                )),
          ],
        ),
      ],
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
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                child: Text(profileName),
              ),
            Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}
