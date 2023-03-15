import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havuc_fabrika_mobil/utils/color_utils.dart';

import '../reusable_widgets/ReusableWidget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringToColor("CB2B93"),
          hexStringToColor("9546C4"),
          hexStringToColor("5E61F4")
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                100, MediaQuery.of(context).size.height * 0.2, 100, 1000),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/logo-no-background.png"),
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("Kullanıcı Adı", Icons.person_outline, false, _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Şifre", Icons.lock_outline, true, _passwordTextController),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


