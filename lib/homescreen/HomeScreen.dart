import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:MHPro/addworkerscreen/addworkerscreen.dart';
import 'package:MHPro/companies/Companies.dart';
import 'package:MHPro/expenselistscreen/ExpenseListScreen.dart';
import 'package:MHPro/expensescreen/ExpenseScreen.dart';
import 'package:MHPro/profilescreen/ProfileScreen.dart';
import 'package:MHPro/salelistscreen/SaleListScreen.dart';
import 'package:MHPro/setsales/SetSales.dart';
import 'package:MHPro/settings/settingsscreen.dart';
import 'package:MHPro/signinscreen/SingInScreen.dart';
import 'package:MHPro/updatepackage/UpdatePackageScreen.dart';
import 'package:MHPro/utils/color_utils.dart';
import 'package:MHPro/workerspaymentscreen/WorkersPaymentScreen.dart';
import '../listworkerscreen/ListWorkerScreen.dart';
import '../reusable_widgets/ReusableWidget.dart';

class GridMenu extends StatefulWidget {
  const GridMenu({Key? key}) : super(key: key);

  @override
  _GridMenuState createState() => _GridMenuState();
}

class _GridMenuState extends State<GridMenu> {
  final _auth = FirebaseAuth.instance;
  User? _user;
  DatabaseReference? _userRef;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _userRef = FirebaseDatabase.instance.ref().child('users').child(_user!.uid);
    _userRef!.child('profileImage').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          _imageBytes = base64Decode(data.toString());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        backgroundColor: Colors.deepPurple,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_user?.displayName ?? ''),
              accountEmail: Text(_user?.email ?? ''),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                  _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
              ),
              onDetailsPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Detaylı Gider Listesi'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExpenseListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Detaylı Satış Listesi'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SaleListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('İşçiler'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkersPaymentScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Şirketler'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Companies(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Çıkış'),
              onTap: () async {
                await _auth.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
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
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.3, // Logo'nun opaklığı ayarlanabilir
              child: Transform.scale(
                scale: 0.8, // Adjust the scale factor as desired (0.5 means 50% of the original size)
                child: Image.asset(
                  'assets/images/logo-no-background.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: GridView.count(
              crossAxisCount: 2, // Update this value with your desired number of items per row
              padding: const EdgeInsets.all(16.0),
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              children: [
                buildMenuItem(context, Icons.account_circle_sharp, 'İşçi Ekle'),
                buildMenuItem(context, Icons.checklist_rtl_rounded, 'Listele'),
                buildMenuItem(context, Icons.update, 'Paket Güncelle'),
                buildMenuItem(context, Icons.add_shopping_cart_rounded, 'Giderler'),
                buildMenuItem(context, Icons.point_of_sale_rounded, 'Satış Yap'),
                buildMenuItem(context, Icons.settings, 'Ayarlar'),
              ],
            ),
          ),
        ],
      ),
    );
  }





}

InkWell buildMenuItem(BuildContext context, IconData iconData, String title) {
  return InkWell(
    onTap: () {
      if (title == 'İşçi Ekle') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddWorkerScreen()),
        );
      } else if (title == 'Listele') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ListWorkerScreen()),
        );
      } else if (title == 'Ayarlar') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
      } else if (title == 'Giderler') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExpenseScreen()),
        );
      } else if (title == 'Satış Yap') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SetSales()),
        );
      } else if (title == 'Paket Güncelle') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UpdatePackageScreen()),
        );
      }
    },
    child: Card(
      color: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            color: Colors.white,
            iconData,
            size: 48.0,
          ),
          const SizedBox(height: 16.0),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
