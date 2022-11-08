import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

// This size work fine on my design, maybe you need some customization depends on your design

  // This isMobile, isTablet, isDesktop helep us later
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 850;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
          MediaQuery.of(context).size.width >= 850;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    // If our width is more than 1100 then we consider it a desktop
    if (_size.width >= 1100) {
      return desktop;
    }
    // If width it less then 1100 and more then 850 we consider it as tablet
    else if (_size.width >= 850 && tablet != null) {
      return tablet!;
    }
    // Or less then that we called it mobile
    else {
      return mobile;
    }
  }
}

doubleToString(double sum) {
  var f = NumberFormat("##0.00", "en_US");
  return (f.format(sum).toString());
}

doubleThreeToString(double sum) {
  var f = NumberFormat("##0.000", "en_US");
  return (f.format(sum).toString());
}

shortDateToString(DateTime date) {
  // Проверка на пустую дату
  if (date == DateTime(1900, 1, 1)) {
    return '';
  }
  // Отформатируем дату
  var f = DateFormat('dd.MM.yyyy');
  return (f.format(date).toString());
}

fullDateToString(DateTime date) {
  // Проверка на пустую дату
  if (date == DateTime(1900, 1, 1)) {
    return '';
  }
  // Отформатируем дату
  var f = DateFormat('dd.MM.yyyy HH:mm:ss');
  return (f.format(date).toString());
}

showMessage(String textMessage, context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      width: MediaQuery.of(context).size.width / 2,
      backgroundColor: Colors.blue,
      content: Text(textMessage, style: TextStyle(color: Colors.white)),
      duration: const Duration(seconds: 3),
    ),
  );
}

showErrorMessage(String textMessage, context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      width: MediaQuery.of(context).size.width / 2,
      backgroundColor: Colors.red,
      content: Text(textMessage, style: TextStyle(color: Colors.white)),
      duration: const Duration(seconds: 2),
    ),
  );
}