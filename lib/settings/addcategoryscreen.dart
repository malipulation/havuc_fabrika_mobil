import 'package:flutter/material.dart';
import 'package:havuc_fabrika_mobil/settings/addcategoryscreen.dart';
import 'package:havuc_fabrika_mobil/utils/color_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({Key? key}) : super(key: key);

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  @override
  final _logoPath = 'assets/images/logo-no-background.png';
  final _categoryname = TextEditingController();
  final _outagepercent = TextEditingController();
  final _kilogram = TextEditingController();
  final _wagecount = TextEditingController();
  final _user = FirebaseAuth.instance.currentUser;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Kategori Ekleme Ekranı'),
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
                          controller: _categoryname,
                          decoration: const InputDecoration(
                            labelText: 'Kategori Adını Giriniz',
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
                          controller: _outagepercent,
                          decoration: const InputDecoration(
                            labelText: 'Fire Miktarını Giriniz',
                            labelStyle: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w500,
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
                          controller: _kilogram,
                          decoration: const InputDecoration(
                            labelText: 'Kilogramı Giriniz',
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
                          controller: _wagecount,
                          decoration: const InputDecoration(
                            labelText: '1 Yevmiye Kaç Pakettir',
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
                        String categoryname = _categoryname.text;
                        String outagepercent = _outagepercent.text;
                        String kilogram = _kilogram.text;
                        String wagecount = _wagecount.text;

                        if (categoryname.isNotEmpty && outagepercent.isNotEmpty && wagecount.isNotEmpty && kilogram.isNotEmpty)  {
                          try {
                            final databaseReference = FirebaseDatabase.instance.reference();
                            await databaseReference
                                .child(_user?.uid ?? '')
                                .child('kategoritbl')
                                .child(categoryname)
                                .set({
                              'CategoryName': categoryname,
                              'Id': UniqueKey().toString(),
                              'OutagePercent': outagepercent,
                              'Kilogram': kilogram,
                              'WageCount': wagecount
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Kategori Eklendi.')),
                            );
                            _categoryname.text="";
                            _outagepercent.text="";
                            _wagecount.text="";
                            _kilogram.text="";

                          } catch (e) {
                            print('Error: $e');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                      ),
                      child: const Text('Kaydet'),
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
