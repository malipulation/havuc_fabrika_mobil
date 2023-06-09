import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:MHPro/utils/color_utils.dart';

class DeleteCategoryScreen extends StatefulWidget {
  const DeleteCategoryScreen({Key? key}) : super(key: key);

  @override
  State<DeleteCategoryScreen> createState() => _DeleteCategoryScreenState();
}

class Category {
  final String categoryName;
  final String kilogram;
  final String outagePercent;
  final String wageCount;

  Category({
    required this.categoryName,
    required this.kilogram,
    required this.outagePercent,
    required this.wageCount
  });

  Map<String, dynamic> toMap() {
    return {
      'CategoryName': categoryName,
      'Kilogram': kilogram,
      'OutagePercent': outagePercent,
      'WageCount': wageCount
    };
  }
}


class _DeleteCategoryScreenState extends State<DeleteCategoryScreen> {
  final _logoPath = 'assets/images/logo-no-background.png';
  final _categoryname = TextEditingController();
  final _outagepercent = TextEditingController();
  final _kilogram = TextEditingController();
  final _wagecount = TextEditingController();
  final _user = FirebaseAuth.instance.currentUser;
  String? _selectedCategory;
  List<Category> _dataList = [];
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

  void fillTextFields(String categoryName)
  {
    _dataList.forEach((category) {
      if (category.categoryName == categoryName) {
        _kilogram.text = category.kilogram;
        _outagepercent.text = category.outagePercent;
        _wagecount.text = category.wageCount;
      }
    });
  }

  void _fetchData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final dataSnapshot = await FirebaseDatabase.instance
            .reference()
            .child(user.uid)
            .child('kategoritbl')
            .once();

        final dataMap = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;

        final categoryList = dataMap.entries.map((entry) {
          final id = entry.key;
          final data = entry.value as Map<dynamic, dynamic>;
          return Category(
            categoryName: data['CategoryName'].toString(),
            wageCount: data['WageCount'].toString(),
            outagePercent: data['OutagePercent'].toString(),
            kilogram: data['Kilogram'].toString()
          );
        }).toList();
        setState(() {
          _dataList = categoryList;
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
        title: const Text('Kategori Silme Ekranı'),
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
                      height: MediaQuery.of(context).size.height*0.17,
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
                        child: DropdownButtonFormField(
                          value: _selectedCategory,
                          items: _dataList.map((data) {
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
                              fillTextFields(_selectedCategory.toString());
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
                          enabled: false,
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
                          enabled: false,
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
                          enabled: false,
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
                        String outagepercent = _outagepercent.text;
                        String kilogram = _kilogram.text;
                        String wagecount = _wagecount.text;

                        if (_selectedCategory!=null && outagepercent.isNotEmpty && wagecount.isNotEmpty && kilogram.isNotEmpty)  {
                          try {
                            final databaseReference = FirebaseDatabase.instance.reference();
                            await databaseReference
                                .child(_user?.uid ?? '')
                                .child('kategoritbl')
                                .child(_selectedCategory.toString())
                                .remove();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Kategori Silindi!')),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (BuildContext context) => DeleteCategoryScreen()),
                            );
                          } catch (e) {
                            print('Error: $e');
                          }
                        }
                        else{
                          if(_selectedCategory ==null)
                          {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Kategori Adı Boş Girilemez!.')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Sil'),
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
