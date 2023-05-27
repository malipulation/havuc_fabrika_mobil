import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:havuc_fabrika_mobil/utils/color_utils.dart';
import 'package:uuid/uuid.dart';

class AddWorkerScreen extends StatefulWidget {
  const AddWorkerScreen({Key? key}) : super(key: key);

  @override
  State<AddWorkerScreen> createState() => _AddWorkerScreenState();


}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  final _logoPath = 'assets/images/logo-no-background.png';
  final _workerNameSurnameController = TextEditingController();
  final _workerPhoneNumberController = TextEditingController();
  final _user =FirebaseAuth.instance.currentUser;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('İşçi Ekleme Ekranı'),
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
                          controller: _workerNameSurnameController,
                          decoration: const InputDecoration(
                            labelText: 'İşçi Adı Giriniz',
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
                          controller: _workerPhoneNumberController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Telefon Numarası Giriniz',
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
                    ElevatedButton(
                      onPressed: () async {
                        String workerNameSurname = _workerNameSurnameController.text;
                        String workerPhoneNumber = _workerPhoneNumberController.text;

                        if (workerNameSurname.isNotEmpty && workerPhoneNumber.isNotEmpty && workerPhoneNumber.length==10) {
                          try {
                            final databaseReference = FirebaseDatabase.instance.reference();
                            await databaseReference
                                .child(_user?.uid ?? '')
                                .child('iscilertbl')
                                .child(workerNameSurname)
                                .set({
                              'NameSurname': workerNameSurname,
                              'PhoneNumber': workerPhoneNumber,
                              'Id': Uuid().v4().toString(),
                              'OverSupply': 0,
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('İşçi Eklendi.'),backgroundColor: Colors.green,),
                            );
                            _workerNameSurnameController.text="";
                            _workerPhoneNumberController.text="";

                          } catch (e) {
                            print('Error: $e');
                          }
                        }
                        else {
                          if(workerNameSurname.isEmpty || workerPhoneNumber.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Lütfen Alanları Boş Bırakmayınız!'),backgroundColor: Colors.red,),
                            );
                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Telefon Numarası 10 Haneli Olmalıdır!'),backgroundColor: Colors.red,),
                            );
                          }

                        }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text('Ekle'),
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
