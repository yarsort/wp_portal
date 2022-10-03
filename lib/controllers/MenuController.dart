import 'package:flutter/material.dart';

class MenuController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldOrderCustomerKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldOrderMovementKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldItemOrderCustomerKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldOrderCustomerKey => _scaffoldOrderCustomerKey;
  GlobalKey<ScaffoldState> get scaffoldOrderMovementKey => _scaffoldOrderMovementKey;
  GlobalKey<ScaffoldState> get scaffoldItemOrderCustomerKey => _scaffoldItemOrderCustomerKey;

  void controlMenu() {
    if (!_scaffoldOrderCustomerKey.currentState!.isDrawerOpen) {
      _scaffoldOrderCustomerKey.currentState!.openDrawer();
    }
    if (!_scaffoldOrderMovementKey.currentState!.isDrawerOpen) {
      _scaffoldOrderMovementKey.currentState!.openDrawer();
    }
    if (!_scaffoldItemOrderCustomerKey.currentState!.isDrawerOpen) {
      _scaffoldItemOrderCustomerKey.currentState!.openDrawer();
      }
  }
}
