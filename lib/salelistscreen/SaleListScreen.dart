import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:havuc_fabrika_mobil/utils/color_utils.dart';

class SaleListScreen extends StatefulWidget {
  const SaleListScreen({Key? key}) : super(key: key);

  @override
  State<SaleListScreen> createState() => _SaleListScreenState();
}
class _CategoryDataSource extends DataTableSource {
  final List<Category> _categoryList;
  List<bool> selectedRows = [];

  int _selectedRowCount = 0;

  _CategoryDataSource(this._categoryList) {
    selectedRows = List<bool>.filled(_categoryList.length, false);
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _categoryList.length) {
      return null;
    }

    final category = _categoryList[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(category.companyName)),
        DataCell(Text(category.salesAmount)),
        DataCell(Text(category.salePrice)),
        DataCell(Text(category.desription)),
        DataCell(Text(category.whatIs)),
        DataCell(Text(category.date)),
      ],
    );
  }


  @override
  int get rowCount => _categoryList.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedRowCount;
}


class Category {
  final String companyName;
  final String date;
  final String desription;
  final String salePrice;
  final String salesAmount;
  final String whatIs;

  Category(
      {required this.companyName,
        required this.date,
        required this.desription,
        required this.whatIs,
        required this.salesAmount,
        required this.salePrice
      });

  Map<String, dynamic> toMap() {
    return {
      'CompanyName': companyName,
      'SalesAmount': salesAmount,
      'SalePrice': salePrice,
      'Description': desription,
      'Date': date,
      'WhatIs': whatIs
    };
  }
}

class _SaleListScreenState extends State<SaleListScreen> {
  final _logoPath = 'assets/images/logo-no-background.png';
  final _user = FirebaseAuth.instance.currentUser;
  List<Category> _dataList = [];
  _CategoryDataSource _dataSource = _CategoryDataSource([]);
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;


  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }
  void _filterTable(String keyword) {
    List<Category> filteredList = _dataList.where((category) {
      return category.companyName.toLowerCase().contains(keyword.toLowerCase());
    }).toList();

    setState(() {
      _dataSource = _CategoryDataSource(filteredList);
    });
  }

  Future<void> _fetchData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final dataSnapshot = await FirebaseDatabase.instance
            .reference()
            .child(user.uid)
            .child('satistbl')
            .once();

        final dataMap = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;

        final categoryList = dataMap.entries.map((entry) {
          final id = entry.key;
          final data = entry.value as Map<dynamic, dynamic>;
          return Category(
            companyName: data['CompanyName'].toString(),
            whatIs: data['WhatIs'].toString(),
            desription: data['Description'].toString(),
            salePrice: data['SalePrice'].toString(),
            salesAmount: data['SalesAmount'].toString(),
            date: data['Date'].toString().substring(0, data['Date'].toString().length - 10),
          );
        }).toList();

        setState(() {
          _dataList = categoryList;
          _dataSource = _CategoryDataSource(_dataList);
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
        title: const Text('Satış Listeleme Ekranı'),
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
                TextField(
                  onChanged: (value) {
                    _filterTable(value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Satış Ara',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child:Theme(
                          data: Theme.of(context)
                              .copyWith(cardColor: Colors.transparent, dividerColor: Colors.green),
                          child:
                          PaginatedDataTable(
                            header: const Text('Detaylı Satış Listesi'),
                            columns: const [
                              DataColumn(
                                label: Text('Satış Kime Yapıldı'),
                              ),
                              DataColumn(
                                label: Text('Satış Miktarı')
                              ),
                              DataColumn(
                                label: Text('Satış Fiyatı'),
                              ),
                              DataColumn(
                                label: Text('Açıklama'),
                              ),
                              DataColumn(
                                label: Text('Satılan Kategori'),
                              ),
                              DataColumn(
                                label: Text('Tarih'),
                              ),
                            ],
                            source: _dataSource,
                            rowsPerPage: 8,
                            arrowHeadColor: Colors.black45,
                          ),
                        ),
                      ),
                    ),
                  ),
                )],
            ),
          ],
        ),
      ),
    );
  }
}

