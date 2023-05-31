import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:MHPro/homescreen/HomeScreen.dart';
import 'package:MHPro/reusable_widgets/ReusableWidget.dart';
import 'package:MHPro/signinscreen/SingInScreen.dart';
import 'package:MHPro/utils/color_utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _nameSurnameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Kayıt Ol",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: MediaQuery
            .of(context)
            .size
            .height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height*0.33, 20, 0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              reusableTextField(
                "İsim Soyisim",
                Icons.person_outline,
                false,
                _nameSurnameTextController,
              ),
              const SizedBox(height: 20),
              reusableTextField(
                "Mail Adresi",
                Icons.person_outline,
                false,
                _emailTextController,
              ),
              const SizedBox(height: 20),
              reusableTextField(
                "Şifre",
                Icons.lock_outline,
                true,
                _passwordTextController,
              ),
              const SizedBox(height: 20),
              signInSignUpButton(context, false, () async {
                try {
                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: _emailTextController.text,
                    password: _passwordTextController.text,
                  );

                  User? user = userCredential.user;
                  if (user != null) {
                    await user.sendEmailVerification();

                    await user.updateDisplayName(
                        _nameSurnameTextController.text);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Hesap Oluşturuldu. E-Postanıza Doğrulama Mesajı Yollanmıştır. (Spam Klasörünü Kontrol Ediniz)",
                        ),
                      ),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignInScreen(),
                      ),
                    );
                  }
                } catch (error) {
                  print("Error: ${error.toString()}");
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}