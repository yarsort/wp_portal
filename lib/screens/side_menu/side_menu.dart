import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wp_b2b/constants.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/screens/admin/settings_admin_screen.dart';
import 'package:wp_b2b/screens/finances/finances_list_screen.dart';
import 'package:wp_b2b/screens/admin/login_admin_screen.dart';
import 'package:wp_b2b/screens/login/login_screen.dart';
import 'package:wp_b2b/screens/notification/notifications_list_screen.dart';
import 'package:wp_b2b/screens/order_customer/order_customer_list_screen.dart';
import 'package:wp_b2b/screens/order_movement/order_movement_list_screen.dart';
import 'package:wp_b2b/screens/products/products_list_screen.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.motorcycle_outlined, color: iconColor, size: 50,),
                Text('RSV MOTO', style: TextStyle(color: Colors.white, fontSize: 26)),
                Text('Race, Save, Velocity', style: TextStyle(color: Colors.blueGrey, fontSize: 14)),
              ],
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, OrderCustomerScreen.routeName, (route) => false);
            },
            horizontalTitleGap: 0.0,
            leading: Icon(Icons.home, size: 25, color: iconColor),
            title: Text(
              "Головна",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, OrderCustomerScreen.routeName, (route) => false);
            },
            horizontalTitleGap: 0.0,
            leading: Icon(Icons.receipt_long, size: 25, color: iconColor),
            title: Text(
              "Замовлення",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, OrderMovementScreen.routeName, (route) => false);
            },
            horizontalTitleGap: 0.0,
            leading: Icon(Icons.move_down, size: 25, color: iconColor),
            title: Text(
              "Переміщення",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, FinancesScreen.routeName, (route) => false);
            },
            horizontalTitleGap: 0.0,
            leading: Icon(Icons.real_estate_agent, size: 25, color: iconColor),
            title: Text(
              "Розрахунки",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, ProductListScreen.routeName, (route) => false);
            },
            horizontalTitleGap: 0.0,
            leading: Icon(Icons.wallet_giftcard_outlined, size: 25, color: iconColor),
            title: Text(
              "Товари",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, NotificationListScreen.routeName, (route) => false);
            },
            horizontalTitleGap: 0.0,
            leading: Icon(Icons.notifications, size: 25, color: iconColor),
            title: Text(
              "Нагадування",
              style: TextStyle(color: Colors.white),
            ),
          ),
          Divider(),
          ListTile(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, SettingsAdminScreen.routeName, (route) => false);
            },
            horizontalTitleGap: 0.0,
            leading: Icon(Icons.settings, size: 25, color: iconColor),
            title: Text(
              "Налаштування",
              style: TextStyle(color: Colors.white),
            ),
          ),
          Divider(),
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
            leading: Icon(Icons.exit_to_app_rounded, size: 25, color: iconColor),
            title: Text(
              "Вихід",
              style: TextStyle(color: Colors.white),
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
