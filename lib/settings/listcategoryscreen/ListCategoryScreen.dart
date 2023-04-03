import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:havuc_fabrika_mobil/utils/color_utils.dart';

class ListCategoryScreen extends StatefulWidget {
  const ListCategoryScreen({Key? key}) : super(key: key);

  @override
  State<ListCategoryScreen> createState() => _ListCategoryScreenState();
}

class Category {
  final String categoryName;
  final String kilogram;
  final String outagePercent;
  final String wageCount;

  Category(
      {required this.categoryName,
      required this.kilogram,
      required this.outagePercent,
      required this.wageCount});

  Map<String, dynamic> toMap() {
    return {
      'CategoryName': categoryName,
      'Kilogram': kilogram,
      'OutagePercent': outagePercent,
      'WageCount': wageCount
    };
  }
}

class _ListCategoryScreenState extends State<ListCategoryScreen> {
  final _logoPath = 'assets/images/logo-no-background.png';
  final _user = FirebaseAuth.instance.currentUser;
  List<Category> _dataList = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
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
              kilogram: data['Kilogram'].toString());
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
        title: const Text('İşçi Listeleme Ekranı'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFCB2B93), Color(0xFF9546C4), Color(0xFF5E61F4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // İşçi listesi logoyla birlikte görüntülenir.
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
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                            columns: const [
                              DataColumn(
                                label: Text('Kategori Adı'),
                              ),
                              DataColumn(
                                label: Text('Fire Miktarı'),
                              ),
                              DataColumn(
                                label: Text('1 Yevmiye Kaç Pakettir'),
                              ),
                              DataColumn(
                                label: Text('Kilogram'),
                              ),
                            ],
                            rows: _dataList
                                .map(
                                  (data) => DataRow(
                                    cells: [
                                      DataCell(Text(data.categoryName)),
                                      DataCell(Text(data.outagePercent)),
                                      DataCell(Text(data.wageCount)),
                                      DataCell(Text(data.kilogram)),
                                    ],
                                  ),
                                )
                                .toList()),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
