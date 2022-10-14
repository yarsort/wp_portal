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

class NotificationListScreen extends StatefulWidget {
  static const routeName = '/notifications';

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  String profileName = '';

  List<String> listNotifications = [];

  _renewItem() async {
    setState(() {});
  }

  _loadProfileData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    profileName = pref.getString('profileName') ?? '';
  }

  @override
  void initState() {
    super.initState();
    _renewItem();
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
                              productList(),
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
              "Нагадування",
              style: Theme.of(context).textTheme.headline6,
            ),
          if (!Responsive.isMobile(context))
            Spacer(flex: Responsive.isDesktop(context) ? 1 : 1),

          //profileNameWidget(),
        ],
      ),
    );
  }

  Widget productList() {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: listNotifications.length != 0
          ? ListView.builder(
              padding: EdgeInsets.all(0.0),
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: listNotifications.length,
              itemBuilder: (context, index) {
                var item = listNotifications[index];
                return Container();
              })
          : SizedBox(
              height: 50,
              child: Center(child: Text('Список повідомлень порожній!'))),
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
