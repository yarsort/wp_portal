import 'package:flutter/material.dart';
import 'package:wp_b2b/constants.dart';
import 'package:wp_b2b/controllers/user_controller.dart';
import 'package:wp_b2b/models/api_response.dart';
import 'package:wp_b2b/screens/order_customer/order_customer_list_screen.dart';

class LoginScreen extends StatefulWidget {

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                primary: false,
                padding: EdgeInsets.all(defaultPadding),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height* 0.8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Header(),
                      SizedBox(height: defaultPadding),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                AuthList(),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthList extends StatefulWidget {
  const AuthList({Key? key}) : super(key: key);

  @override
  State<AuthList> createState() => _AuthListState();
}

class _AuthListState extends State<AuthList> {

  // Editing controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _loginUser() async {
    if (emailController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Логін не заповнено.')
      ));
    }
    if (passwordController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Пароль не заповнено.')
      ));
    }

    ApiResponse response = await login(emailController.text, passwordController.text);
    if (response.error == null){
      Navigator.pushNamedAndRemoveUntil(context, OrderCustomerScreen.routeName, (route) => false);
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${response.error}')
      ));
    }
  }

  void _checkAuth() async {
    String basicAuth = await getToken();
    if (basicAuth != ''){
      Navigator.pushNamedAndRemoveUntil(context, OrderCustomerScreen.routeName, (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(flex: 2, child: Text('Логін')),
              Expanded(flex: 5, child: emailField()),
            ],
          ),
          SizedBox(height: 16,),
          Row(
            children: [
              Expanded(flex: 2, child: Text('Пароль')),
              Expanded(flex: 5, child: passwordField()),
            ],
          ),
          login2Button(),
        ],
      ),
    );
  }

  Widget emailField() {

    return TextFormField(
        autofocus: false,
        controller: emailController,
        keyboardType: TextInputType.text,
        onSaved: (value) {
          emailController.text = value!;
        },
        textInputAction: TextInputAction.next,

        decoration: InputDecoration(
          filled: true,
          fillColor: secondaryColor,
          prefixIcon: const Icon(Icons.person),
          contentPadding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
          border: OutlineInputBorder(
            //borderSide: BorderSide.none,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
        ));

  }

  Widget passwordField(){

    return TextFormField(
        autofocus: false,
        controller: passwordController,
        obscureText: true,
        onSaved: (value) {
          passwordController.text = value!;
        },
        onEditingComplete: () {
          _loginUser();
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          filled: true,
          fillColor: secondaryColor,
          prefixIcon: const Icon(Icons.password),
          contentPadding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
          border: OutlineInputBorder(
            //borderSide: BorderSide.none,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
        ));

  }

  Widget login2Button(){

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
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