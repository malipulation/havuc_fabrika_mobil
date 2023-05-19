import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:havuc_fabrika_mobil/utils/color_utils.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
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
        DataCell(Text(category.categoryName)),
        DataCell(Text(category.wageCount)),
        DataCell(Text(category.outagePercent)),
        DataCell(Text(category.kilogram)),
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
      'WhoWasExpense': categoryName,
      'ExpenseAmount': kilogram,
      'Description': outagePercent,
      'Date': wageCount
    };
  }
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
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
      return category.categoryName.toLowerCase().contains(keyword.toLowerCase());
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
            .child('odemelertbl')
            .once();

        final dataMap = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;

        final categoryList = dataMap.entries.map((entry) {
          final id = entry.key;
          final data = entry.value as Map<dynamic, dynamic>;
          return Category(
            categoryName: data['WhoWasExpense'].toString(),
            wageCount: data['ExpenseAmount'].toString(),
            outagePercent: data['Description'].toString(),
            kilogram: data['Date'].toString().substring(0, data['Date'].toString().length - 10),
          );
        }).toList();

        setState(() {
          _dataList = categoryList;
          _dataSource = _CategoryDataSource(_dataList);
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
      // Show an error message to the user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Error fetching data: $error'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Gider Listeleme Ekranı'),
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
                    labelText: 'Gider Ara',
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
                          header: const Text('Detaylı Gider Listesi'),
                          columns: const [
                            DataColumn(
                              label: Text('Ödeme Kime Yapıldı'),
                            ),
                            DataColumn(
                              label: Text('Ödeme Tutarı'),
                            ),
                            DataColumn(
                              label: Text('Açıklama'),
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

