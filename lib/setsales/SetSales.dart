import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:havuc_fabrika_mobil/utils/color_utils.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SetSales extends StatefulWidget {
  const SetSales({Key? key}) : super(key: key);

  @override
  State<SetSales> createState() => _SetSalesState();
}

class Company {
  final String companyName;
  final String dept;
  final String received;

  Company({
    required this.companyName,
    required this.dept,
    required this.received,
  });

  Map<String, dynamic> toMap() {
    return {'CompanyName': companyName, 'Dept': dept, 'Received': received};
  }
}

class Category {
  final String categoryName;
  final String outagePercent;

  Category({required this.categoryName, required this.outagePercent});

  Map<String, dynamic> toMap() {
    return {'CategoryName': categoryName, 'OutagePercent': outagePercent};
  }
}

class _SetSalesState extends State<SetSales> {
  final _logoPath = 'assets/images/logo-no-background.png';
  final _companyname = TextEditingController();
  final _categoryname = TextEditingController();
  final _saleamount = TextEditingController();
  final _salesprice = TextEditingController();
  final _description = TextEditingController();
  int _selectedOption = 0;
  final _user = FirebaseAuth.instance.currentUser;
  String? _selectedCategory;
  List<Company> _dataList = [];
  List<Category> _categoryList = [];
  final _searchController =
      TextEditingController(); // Textfield için controller

  @override
  void dispose() {
    _searchController.dispose(); // Controller'ın bellekten atılması
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void setSales(String companyName) {
    _dataList.forEach((company) {
      if (company.companyName == companyName) {}
    });
  }

  void _fetchData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final dataSnapshot = await FirebaseDatabase.instance
            .reference()
            .child(user.uid)
            .child('sirkettbl')
            .once();

        final dataMap = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;

        final dataSnapshot1 = await FirebaseDatabase.instance
            .reference()
            .child(user.uid)
            .child('kategoritbl')
            .once();

        final dataMap1 = dataSnapshot1.snapshot.value as Map<dynamic, dynamic>;

        final companyList = dataMap.entries.map((entry) {
          final id = entry.key;
          final data = entry.value as Map<dynamic, dynamic>;
          return Company(
            companyName: data['CompanyName'].toString(),
            dept: data['Dept'].toString(),
            received: data['Received'].toString(),
          );
        }).toList();

        final categoryList = dataMap1.entries.map((entry) {
          final id = entry.key;
          final data = entry.value as Map<dynamic, dynamic>;
          return Category(
            categoryName: data['CategoryName'].toString(),
            outagePercent: data['OutagePercent'].toString(),
          );
        }).toList();
        print("categoryList.first.categoryName");
        setState(() {
          _dataList = companyList;
          _categoryList = categoryList;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Satış Yapma Ekranı'),
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
                      height: MediaQuery.of(context).size.height * 0.15,
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
                          child: TypeAheadField(
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: _companyname,
                              decoration: InputDecoration(
                                labelText: 'Şirket Seçin',
                              ),
                            ),
                            suggestionsCallback: (pattern) async {
                              return _dataList
                                  .where((company) => company.companyName
                                      .toLowerCase()
                                      .contains(pattern.toLowerCase()))
                                  .map((company) => company.companyName)
                                  .toList();
                            },
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                title: Text(suggestion),
                              );
                            },
                            onSuggestionSelected: (suggestion) {
                              setState(() {
                                _companyname.text = suggestion;
                              });
                            },
                          )),
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
                        child: DropdownButtonFormField(
                          value: _selectedCategory,
                          items: _categoryList.map((data) {
                            return DropdownMenuItem(
                              value: data.categoryName,
                              child: Text(data.categoryName),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Kategori Seçin',
                            labelStyle: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          },
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
                          controller: _saleamount,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Satış Miktarı Giriniz(Adet)',
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
                          controller: _salesprice,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Satış Fiyatı',
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
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05),
                        Expanded(
                          child: ListTile(
                            title: const Text('Nakit'),
                            leading: Radio<int>(
                              value: 1,
                              groupValue: _selectedOption,
                              onChanged: (value) {
                                setState(() {
                                  _selectedOption = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('Veresiye'),
                            leading: Radio<int>(
                              value: 2,
                              groupValue: _selectedOption,
                              onChanged: (value) {
                                setState(() {
                                  _selectedOption = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        bool islegit = false;
                        _dataList.forEach((company) async {
                          if (company.companyName == _companyname.text) {
                            islegit = true;
                            if (_selectedCategory != null &&
                                _saleamount.text.isNotEmpty &&
                                _salesprice.text.isNotEmpty &&
                                _selectedOption != 0) {
                              if (_selectedOption == 1) {
                                try {
                                  final databaseReference =
                                  FirebaseDatabase.instance.reference();
                                  await databaseReference
                                      .child(_user?.uid ?? '')
                                      .child('satistbl')
                                      .child(
                                      '${DateTime.now().toString().replaceAll('.', '-')} ${_companyname.text}')
                                      .set({
                                    'CompanyName': _companyname.text,
                                    'Date': DateTime.now().toString(),
                                    'SalePrice': _salesprice.text,
                                    'SalesAmount': (int.parse(_saleamount.text)- (int.parse(_categoryList.where((element) => element.categoryName==_selectedCategory).first.outagePercent)/100)*(int.parse(_saleamount.text))).toString() ,
                                    'WhatIs': _selectedCategory,
                                    'Description': _description.text
                                  });
                                  String Companyname = _companyname.text;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            '$Companyname Şirketine Satış Yapıldı!'),
                                        backgroundColor: Colors.green),
                                  );

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            SetSales()),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Satış Yapılamadı! Teknik Desteğe Başvurun!'),
                                        backgroundColor: Colors.red),
                                  );
                                }
                              }
                              //veresiye
                              else{
                                try {
                                  final databaseReference =
                                  FirebaseDatabase.instance.reference();
                                  await databaseReference
                                      .child(_user?.uid ?? '')
                                      .child('satistbl')
                                      .child(
                                      '${DateTime.now().toString().replaceAll('.', '-')} ${_companyname.text}')
                                      .set({
                                    'CompanyName': _companyname.text,
                                    'Date': DateTime.now().toString(),
                                    'SalePrice': _salesprice.text,
                                    'SalesAmount': (int.parse(_saleamount.text)- (int.parse(_categoryList.where((element) => element.categoryName==_selectedCategory).first.outagePercent)/100)*(int.parse(_saleamount.text))).toString() ,
                                    'WhatIs': _selectedCategory,
                                    'Description': _description.text
                                  });

                                  final databaseReference1 =
                                  FirebaseDatabase.instance.reference();
                                  var company = _dataList.where((element) => element.companyName==_companyname.text).first;
                                  var lastkilo = (int.parse(_saleamount.text)- (int.parse(_categoryList.where((element) => element.categoryName==_selectedCategory).first.outagePercent)/100)*(int.parse(_saleamount.text))).toString();
                                  await databaseReference1
                                      .child(_user?.uid ?? '')
                                      .child('sirkettbl')
                                      .child(_companyname.text)
                                      .set({
                                    'CompanyName': _companyname.text,
                                    'Dept': int.parse(company.dept) !=0 ||  (double.parse(lastkilo)*int.parse(_salesprice.text))>= int.parse(company.received)   ? int.parse(company.dept)+ (double.parse(lastkilo)*int.parse(_salesprice.text)) - int.parse(company.received) : company.dept ,
                                    'Received': int.parse(company.received)!=0 && (double.parse(lastkilo)*int.parse(_salesprice.text))< int.parse(company.received) ? int.parse(company.received)-(double.parse(lastkilo)*int.parse(_salesprice.text)) : '0'
                                  });

                                  String Companyname = _companyname.text;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            '$Companyname Şirketine Veresiye Satış Yapıldı!'),
                                        backgroundColor: Colors.green),
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            SetSales()),
                                  );
                                } catch (e) {
                                  print(e);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Satış Yapılamadı! Teknik Desteğe Başvurun!'),
                                        backgroundColor: Colors.red),
                                  );
                                }
                              }
                            }
                            else {
                              if (_selectedCategory == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Lütfen Kategori Seçiniz!!!'),
                                      backgroundColor: Colors.red),
                                );
                              } else if (_saleamount.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Lütfen Satış Miktarı Giriniz!!!'),
                                      backgroundColor: Colors.red),
                                );
                              } else if (_salesprice.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Lütfen Satış Fiyatı Giriniz!!!'),
                                      backgroundColor: Colors.red),
                                );
                              } else if (_selectedOption == 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Lütfen Ödeme Tipi Giriniz!!!'),
                                      backgroundColor: Colors.red),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Satış Yapılamadı!'),
                                      backgroundColor: Colors.red),
                                );
                              }
                            }
                          }
                        });
                        if (!islegit) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Lütfen Geçerli Bir Şirket Seçiniz!!!'),
                                backgroundColor: Colors.red),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Satış Yap'),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height -
                          272 -
                          MediaQuery.of(context).size.height * 0.569,
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
