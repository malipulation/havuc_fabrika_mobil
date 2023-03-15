import 'package:flutter/material.dart';
import 'package:havuc_fabrika_mobil/signinscreen/SingInScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text("Çıkış(Test)"),
          onPressed: (){
            Navigator.push(context,
            MaterialPageRoute(builder: (context)=>SignInScreen()));
          },
        ),
      ),
    );
  }
}
