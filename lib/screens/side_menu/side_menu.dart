import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wp_b2b/screens/order_customer/order_customer_list_screen.dart';
import 'package:wp_b2b/screens/order_movement/order_movement_screen.dart';

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
            child: Image.asset("assets/images/logo.png"),
          ),
          DrawerListTile(
            title: "Головна",
            svgSrc: "assets/icons/menu_dashbord.svg",
            press: () {
              Navigator.restorablePushNamed(context, OrderCustomerScreen.routeName);
            },
          ),
          DrawerListTile(
            title: "Замовлення",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {
              Navigator.restorablePushNamed(context, OrderCustomerScreen.routeName);
            },
          ),
          DrawerListTile(
            title: "Переміщення товарів",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {
              Navigator.restorablePushNamed(context, OrderMovementScreen.routeName);
            },
          ),
          DrawerListTile(
            title: "Розрахунки",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Товари",
            svgSrc: "assets/icons/menu_store.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Нагадування",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Профіль",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Налаштування",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () {},
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
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
