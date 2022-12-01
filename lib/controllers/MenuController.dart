import 'package:flutter/material.dart';

class MenuController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldOrderCustomerKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldItemOrderCustomerKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldOrderMovementKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldItemOrderMovementKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldFinanceKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldProductsKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldNotificationsKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldSettingsKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldOrderCustomerKey => _scaffoldOrderCustomerKey;
  GlobalKey<ScaffoldState> get scaffoldItemOrderCustomerKey => _scaffoldItemOrderCustomerKey;
  GlobalKey<ScaffoldState> get scaffoldOrderMovementKey => _scaffoldOrderMovementKey;
  GlobalKey<ScaffoldState> get scaffoldItemOrderMovementKey => _scaffoldItemOrderMovementKey;
  GlobalKey<ScaffoldState> get scaffoldProductsKey => _scaffoldProductsKey;
  GlobalKey<ScaffoldState> get scaffoldFinanceKey => _scaffoldFinanceKey;
  GlobalKey<ScaffoldState> get scaffoldNotificationsKey => _scaffoldNotificationsKey;
  GlobalKey<ScaffoldState> get scaffoldSettingsKey => _scaffoldSettingsKey;

  void controlMenu() {
    if(_scaffoldOrderCustomerKey.currentState != null) {
      if (!_scaffoldOrderCustomerKey.currentState!.isDrawerOpen) {
        _scaffoldOrderCustomerKey.currentState!.openDrawer();
      }
    }

    if (_scaffoldOrderMovementKey.currentState != null) {
      if (!_scaffoldOrderMovementKey.currentState!.isDrawerOpen) {
        _scaffoldOrderMovementKey.currentState!.openDrawer();
      }
    }

    if (_scaffoldItemOrderCustomerKey.currentState != null) {
      if (!_scaffoldItemOrderCustomerKey.currentState!.isDrawerOpen) {
        _scaffoldItemOrderCustomerKey.currentState!.openDrawer();
      }
    }

    if (_scaffoldFinanceKey.currentState != null) {
      if (!_scaffoldFinanceKey.currentState!.isDrawerOpen) {
        _scaffoldFinanceKey.currentState!.openDrawer();
      }
    }

    if (_scaffoldProductsKey.currentState != null) {
      if (!_scaffoldProductsKey.currentState!.isDrawerOpen) {
        _scaffoldProductsKey.currentState!.openDrawer();
      }
    }

    if (_scaffoldNotificationsKey.currentState != null){
      if (!_scaffoldNotificationsKey.currentState!.isDrawerOpen) {
        _scaffoldNotificationsKey.currentState!.openDrawer();
      }
    }

    if(_scaffoldSettingsKey.currentState != null){
      if (!_scaffoldSettingsKey.currentState!.isDrawerOpen) {
        _scaffoldSettingsKey.currentState!.openDrawer();
      }
    }
  }
}
