import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_b2b/constants.dart';
import 'package:wp_b2b/controllers/MenuController.dart';
import 'package:wp_b2b/system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class Header extends StatefulWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  String profileName = '';

  TextEditingController textFieldSearchCatalogController =
  TextEditingController();

  @override
  void initState() {
    _loadProfileData();
    super.initState();
  }

  _loadProfileData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    profileName = pref.getString('profileName') ?? '';
  }

  @override
  Widget build(BuildContext context) {
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
              "Переміщення товарів",
              style: Theme.of(context).textTheme.headline6,
            ),
          if (!Responsive.isMobile(context))
            Spacer(flex: Responsive.isDesktop(context) ? 1 : 1),
          Expanded(child: searchFieldWidget()),
          //profileNameWidget(),
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

  Widget searchFieldWidget() {
    return TextField(
      controller: textFieldSearchCatalogController,
      onSubmitted: (text) async {
        if (textFieldSearchCatalogController.text == '') {
          //await _renewItem();
          return;
        }
        //await _renewItem();
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(0, 0, 10, 0),
        hintText: "Пошук",
        fillColor: secondaryColor,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
          child: InkWell(
            onTap: () async {
              if (textFieldSearchCatalogController.text == '') {
                //await _renewItem();
                return;
              }
              //await _renewItem();
            },
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
          ),
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          child: InkWell(
            onTap: () async {
              if (textFieldSearchCatalogController.text == '') {
                return;
              }
              textFieldSearchCatalogController.text = '';
              //await _renewItem();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
