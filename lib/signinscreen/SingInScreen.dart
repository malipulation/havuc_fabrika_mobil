import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havuc_fabrika_mobil/homescreen/HomeScreen.dart';
import 'package:havuc_fabrika_mobil/utils/color_utils.dart';

import '../reusable_widgets/ReusableWidget.dart';
import '../singupscreen/SignUpScreen.dart';

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
                50, MediaQuery
                .of(context)
                .size
                .height * 0.2, 40, 1000),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/logo-no-background.png"),
                const SizedBox(
                  height: 40,
                ),
                reusableTextField("Kullanıcı Adı", Icons.person_outline, false,
                    _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                    "Şifre", Icons.lock_outline, true, _passwordTextController),
                const SizedBox(
                  height: 20,
                ),
                signInSignUpButton(context, true, () {
                  //if(FirebaseAuth.instance.currentUser!.emailVerified){
                    FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _emailTextController.text,
                        password: _passwordTextController.text).then((value){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => GridMenu()));
                    } );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Giriş Başarılı.")),
                    );
                  //}
                  /*else
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Lütfen Mail Adresinizden Hesabınızı Doğrulayın!")),
                      );
                    }*/
                }),
                signUpOption()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Hesabınız yok mu?"),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: const Text(
            "  Kayıt Ol",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
