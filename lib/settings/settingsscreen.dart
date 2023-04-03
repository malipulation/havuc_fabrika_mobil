import 'package:flutter/material.dart';
import 'package:havuc_fabrika_mobil/settings/addcategoryscreen/addcategoryscreen.dart';
import 'package:havuc_fabrika_mobil/settings/deletecategoryscreen/DeleteCategoryScreen.dart';
import 'package:havuc_fabrika_mobil/settings/listcategoryscreen/ListCategoryScreen.dart';
import 'package:havuc_fabrika_mobil/settings/updatecategoryscreen/UpdateCategoryScreen.dart';
import 'package:havuc_fabrika_mobil/utils/color_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  final _logoPath = 'assets/images/logo-no-background.png';
  final _wage = TextEditingController();
  final _user = FirebaseAuth.instance.currentUser;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Ayarlar Ekranı'),
      ),
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
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  _logoPath,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),

            SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.33,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: TextFormField(
                          controller: _wage,
                          decoration: const InputDecoration(
                            labelText: 'Yevmiye Ücretini Giriniz.',
                            labelStyle: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(left: 20, top: 7),
                          ),
                          style: const TextStyle(color: Colors.black),
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        String wage = _wage.text;

                        if (wage.isNotEmpty) {
                          try {
                            final databaseReference = FirebaseDatabase.instance.reference();
                            await databaseReference
                                .child(_user?.uid ?? '')
                                .child('yevmiyetbl')
                                .child('yevmiye')
                                .set({
                              'CurrentWage': int.parse(wage),
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Yevmiye Eklendi.')),
                            );
                            _wage.text="";

                          } catch (e) {
                            print('Error: $e');
                          }
                        }
                        else
                          {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Mevcut Yevmiye Boş Girilemez!')),
                            );
                          }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text('Kaydet'),
                    ),
                    ElevatedButton(
                      onPressed: ()  {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddCategoryScreen()),
                      );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                      ),
                      child: const Text('Kategori Ekle'),
                    ),
                    ElevatedButton(
                      onPressed: ()  {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DeleteCategoryScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Kategori Sil'),
                    ),
                    ElevatedButton(
                      onPressed: ()  {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ListCategoryScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                      ),
                      child: const Text('Kategori Listele'),
                    ),
                    ElevatedButton(
                      onPressed: ()  {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UpdateCategoryScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Kategori Düzenle'),
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height-272-MediaQuery.of(context).size.height*0.33,
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
