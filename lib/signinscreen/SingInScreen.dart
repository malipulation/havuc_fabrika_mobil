import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:havuc_fabrika_mobil/homescreen/HomeScreen.dart';
import 'package:havuc_fabrika_mobil/utils/color_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMeStatus();
  }

  void _loadRememberMeStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('rememberMe') ?? false;
    setState(() {
      _rememberMe = rememberMe;
      if (_rememberMe) {
        _loadEmailAndPassword();
      }
    });
  }

  void _loadEmailAndPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');
    setState(() {
      _emailTextController.text = savedEmail ?? '';
      _passwordTextController.text = savedPassword ?? '';
    });
  }

  void _saveRememberMeStatus(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', value);
  }

  void _saveEmailAndPassword(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  void _signIn() async {
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailTextController.text,
        password: _passwordTextController.text,
      );

      if (_rememberMe) {
        // Save the remember me status and email/password
        _saveRememberMeStatus(true);
        _saveEmailAndPassword(
            _emailTextController.text, _passwordTextController.text);
      } else {
        // Reset the remember me status and email/password
        _saveRememberMeStatus(false);
        _saveEmailAndPassword('', '');
      }

      if (userCredential.user!.emailVerified) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GridMenu()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Giriş Başarılı.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Lütfen Mail Adresinizden Hesabınızı Doğrulayın!",
            ),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hatalı giriş. Şifrenizi kontrol edin."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4")
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              50,
              MediaQuery.of(context).size.height * 0.1,
              40,
              MediaQuery.of(context).size.height - 686,
            ),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/logo-no-background.png"),
                const SizedBox(height: 40),
                reusableTextField(
                  "Kullanıcı Adı",
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
                CheckboxListTile(
                  title: Text("Beni Hatırla"),
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 20),
                signInSignUpButton(context, true, _signIn),
                signUpOption(),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUpScreen()),
            );
          },
          child: const Text(
            " Kayıt Ol",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
