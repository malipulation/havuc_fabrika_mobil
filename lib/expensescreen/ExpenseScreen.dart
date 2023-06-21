import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:MHPro/utils/color_utils.dart';
import 'package:intl/intl.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:uuid/uuid.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}



class _ExpenseScreenState extends State<ExpenseScreen> {

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _date.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      });
    }
  }


  final _logoPath = 'assets/images/logo-no-background.png';
  final _whoWasExpense = TextEditingController();
  final _expenseAmount = TextEditingController();
  final _description = TextEditingController();
  final _date = TextEditingController();
  final _user = FirebaseAuth.instance.currentUser;

  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Giderler Ekranı'),
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
                      height: MediaQuery.of(context).size.height * 0.25,
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
                          controller: _whoWasExpense,
                          decoration: const InputDecoration(
                            labelText: 'Ödeme Nereye Yapıldı',
                            labelStyle: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.only(left: 20, top: 7),
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
                          keyboardType: TextInputType.number,
                          controller: _expenseAmount,
                          decoration: const InputDecoration(
                            labelText: 'Ne Kadar Ödeme Yapıldı.',
                            labelStyle: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.only(left: 20, top: 7),
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
                          controller: _description,
                          decoration: const InputDecoration(
                            labelText: 'Açıklama',
                            labelStyle: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.only(left: 20, top: 7),
                          ),
                          style: const TextStyle(color: Colors.black),
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                enabled: false,
                                controller: _date,
                                decoration: const InputDecoration(
                                  labelText: 'Seçilen Tarih',
                                  labelStyle: TextStyle(
                                    color: Colors.black45,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding:
                                  const EdgeInsets.only(left: 20, top: 7),
                                ),
                                style: const TextStyle(color: Colors.black),
                                textAlign: TextAlign.left,
                                textAlignVertical: TextAlignVertical.center,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _selectDate(context),
                              icon: Icon(Icons.calendar_today),
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_whoWasExpense.text.isNotEmpty && _expenseAmount.text.isNotEmpty) {
                          try {
                            String guid = const Uuid().v4();
                            final databaseReference =
                            FirebaseDatabase.instance.reference();
                            await databaseReference
                                .child(_user?.uid ?? '')
                                .child('odemelertbl')
                                .child(guid)
                                .set({
                              'Id' : Uuid().v4(),
                              'Date': _selectedDate.toString(),
                              'Description': _description.text,
                              'ExpenseAmount': int.parse(_expenseAmount.text),
                              'WhoWasExpense': _whoWasExpense.text,
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gider Eklendi.'), backgroundColor: Colors.green),
                            );
                            _whoWasExpense.text = "";
                            _expenseAmount.text = "";
                            _description.text = "";
                            _date.text = "";
                          } catch (e) {
                            print('Error: $e');
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Ödeme Yapılan Yer veya Miktar Boş Girilemez!'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                      ),
                      child: const Text('Gider Ekle'),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height -
                          272 -
                          MediaQuery.of(context).size.height * 0.33,
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
