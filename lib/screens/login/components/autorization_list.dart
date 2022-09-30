import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_b2b/constants.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/models/user.dart';
import 'package:wp_b2b/screens/order_customer/order_customer_list_screen.dart';

class AuthList extends StatefulWidget {
  const AuthList({Key? key}) : super(key: key);

  @override
  State<AuthList> createState() => _AuthListState();
}

class _AuthListState extends State<AuthList> {

  // editing controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token);
    await pref.setInt('userId', user.id);
    Navigator.restorablePushNamed(context, OrderCustomerScreen.routeName);
  }

  void _loginUser() async {
    ApiResponse response = await login(emailController.text, passwordController.text);
    if (response.error == null){
      _saveAndRedirectToHome(response.data as User);
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${response.error}')
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          emailField(),
          passwordField(),
          login2Button(),
        ],
      ),
    );
  }

  Widget emailField() {

    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 15, 36, 0),
      child: TextFormField(
          autofocus: false,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value!.isEmpty) {
              return ('Введіть E-Mail');
            }
            // reg expression for email validation
            if (!RegExp('^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]')
                .hasMatch(value)) {
              return ('Будь ласка, введіть правильний E-mail');
            }
            return null;
          },
          onSaved: (value) {
            emailController.text = value!;
          },
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.mail),
            contentPadding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            //labelText: 'E-mail',
            hintText: 'E-mail',
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(5.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(5.0),
            ),
          )),
    );

  }

  Widget passwordField(){

    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 15, 36, 0),
      child: TextFormField(
          autofocus: false,
          controller: passwordController,
          obscureText: true,
          validator: (value) {
            RegExp regex = RegExp(r'^.{6,}$');
            if (value!.isEmpty) {
              return ('Вкажіть пароль');
            }
            if (!regex.hasMatch(value)) {
              return ('Введіть пароль (мінімум 6 символів)');
            }
            //return ('Невід');
          },
          onSaved: (value) {
            passwordController.text = value!;
          },
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.vpn_key),
            contentPadding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            hintText: 'Пароль',
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(5.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(5.0),
            ),
          )
      ),
    );

  }

  Widget login2Button(){

    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 15, 36, 0),
      child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.teal[200]),
          ),
          onPressed: () async {
            _loginUser();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(height: 50,),
              Text('Увійти',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),),
              SizedBox(height: 50,),
            ],
          )),
    );

  }
}
