import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_b2b/constants.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/screens/admin/settings_admin_screen.dart';
import 'package:wp_b2b/screens/finances/finances_list_screen.dart';
import 'package:wp_b2b/screens/login/login_screen.dart';
import 'package:wp_b2b/screens/notification/notifications_list_screen.dart';
import 'package:wp_b2b/screens/order_customer/order_customer_list_screen.dart';
import 'package:wp_b2b/screens/order_movement/order_movement_list_screen.dart';
import 'package:wp_b2b/screens/products/products_list_selection_screen.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  static const routeName = '/product_selection';

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String nameOrganization = '';
  String sloganOrganization = '';

  _fillSettings() async {
    final SharedPreferences prefs = await _prefs;
    nameOrganization = prefs.getString('settings_nameOrganization') ?? 'Оптовий портал';
    sloganOrganization = prefs.getString('settings_sloganOrganization') ?? 'торгівля та розрахунки';
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fillSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color.fromRGBO(64, 81, 137, 1),
      child: ListView(
        children: [
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_tree_outlined, color: iconColor, size: 50,),
                SizedBox(height: 18,),
                Text(nameOrganization, style: TextStyle(color: fontColorWhite, fontSize: 20)),
                Text(sloganOrganization, style: TextStyle(color: fontColorWhite, fontSize: 12)),
              ],
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, OrderCustomerScreen.routeName, (route) => false);
            },
            horizontalTitleGap: 0.0,
            leading: Icon(Icons.home, size: 25, color: iconColorWhite),
            title: Text(
              "Головна",
              style: TextStyle(color: fontColorWhite),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, OrderCustomerScreen.routeName, (route) => false);
            },
            horizontalTitleGap: 0.0,
            leading: Icon(Icons.receipt_long, size: 25, color: iconColorWhite),
            title: Text(
              "Замовлення",
              style: TextStyle(color: fontColorWhite),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, OrderMovementScreen.routeName, (route) => false);
            },
            horizontalTitleGap: 0.0,
            leading: Icon(Icons.move_down, size: 25, color: iconColorWhite),
            title: Text(
              "Переміщення",
              style: TextStyle(color: fontColorWhite),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, FinancesScreen.routeName, (route) => false);
            },
            horizontalTitleGap: 0.0,
            leading: Icon(Icons.real_estate_agent, size: 25, color: iconColorWhite),
            title: Text(
              "Розрахунки",
              style: TextStyle(color: fontColorWhite),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, ProductListSelectionScreen.routeName, (route) => false);
            },
            horizontalTitleGap: 0.0,
            leading: Icon(Icons.wallet_giftcard_outlined, size: 25, color: iconColorWhite),
            title: Text(
              "Товари",
              style: TextStyle(color: fontColorWhite),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, NotificationListScreen.routeName, (route) => false);
            },
            horizontalTitleGap: 0.0,
            leading: Icon(Icons.notifications, size: 25, color: iconColorWhite),
            title: Text(
              "Нагадування",
              style: TextStyle(color: fontColorWhite),
            ),
          ),
          Divider(color: Colors.grey),
          ListTile(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, SettingsAdminScreen.routeName, (route) => false);
            },
            horizontalTitleGap: 0.0,
            leading: Icon(Icons.settings, size: 25, color: iconColorWhite),
            title: Text(
              "Налаштування",
              style: TextStyle(color: fontColorWhite),
            ),
          ),
          Divider(color: Colors.grey),
          ListTile(
            onTap: () async {
              bool valueResult = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: const Text('Вийти з аккаунту?'),
                      actions: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(context).pop(true);
                                },
                                child: Center(child: Text('Вийти'))),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.red)),
                                onPressed: () async {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text('Відміна'))
                          ],
                        ),
                      ],
                    );
                  }) as bool;

              if (valueResult) {
                logout();
                Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false);
              }
            },
            horizontalTitleGap: 0.0,
            leading: Icon(Icons.exit_to_app_rounded, size: 25, color: iconColorWhite),
            title: Text(
              "Вихід",
              style: TextStyle(color: fontColorWhite),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
          color: Colors.lightBlue,
        height: 22,
      ),
      title: Text(
        title,
        style: TextStyle(color: fontColorWhite),
      ),
    );
  }
}
