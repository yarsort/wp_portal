import 'package:wp_b2b/controllers/MenuController.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wp_b2b/screens/admin/login_admin_screen.dart';
import 'package:wp_b2b/screens/admin/settings_admin_screen.dart';
import 'package:wp_b2b/screens/login/login_screen.dart';
import 'package:wp_b2b/screens/notification/notifications_list_screen.dart';
import 'package:wp_b2b/screens/order_customer/order_customer_list_screen.dart';
import 'package:wp_b2b/screens/order_movement/order_movement_list_screen.dart';
import 'package:wp_b2b/screens/products/products_list_screen.dart';
import 'package:wp_b2b/screens/settings/settings_screen.dart';

import 'screens/finances/finances_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MenuController(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'B2B кабінет клієнта',
        // theme: ThemeData.dark().copyWith(
        //   scaffoldBackgroundColor: bgColor,
        //
        //   textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
        //       .apply(bodyColor: Colors.black),
        //   canvasColor: secondaryColor,
        // ),
        onGenerateRoute: (RouteSettings routeSettings) {
          return MaterialPageRoute<void>(
            settings: routeSettings,
            builder: (BuildContext context) {
              switch (routeSettings.name) {
                case LoginScreen.routeName:
                  return LoginScreen();
                case SettingsScreen.routeName:
                  return SettingsScreen();
                case OrderCustomerScreen.routeName:
                  return OrderCustomerScreen();
                case OrderMovementScreen.routeName:
                  return OrderMovementScreen();
                case FinancesScreen.routeName:
                  return FinancesScreen();
                case ProductListScreen.routeName:
                  return ProductListScreen();
                case NotificationListScreen.routeName:
                  return NotificationListScreen();

                case SettingsAdminScreen.routeName:
                  return SettingsAdminScreen();
                case LoginAdminScreen.routeName:
                  return LoginAdminScreen();
                default:
                  return SettingsAdminScreen();
                  //return LoginScreen();
              }
            },
          );
        },
      ),
    );
  }
}
