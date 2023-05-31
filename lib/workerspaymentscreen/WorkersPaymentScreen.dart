import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:MHPro/utils/color_utils.dart';
import 'package:intl/intl.dart';

class WorkersPaymentScreen extends StatefulWidget {
  const WorkersPaymentScreen({Key? key}) : super(key: key);

  @override
  State<WorkersPaymentScreen> createState() => _WorkersPaymentScreenState();
}

class _CategoryDataSource extends DataTableSource {
  final List<DailyWorkerEmployeeDTO> _categoryList;
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
        DataCell(Text(category.queNumber.toString())),
        DataCell(Text(category.nameSurname)),
        DataCell(Text(category.phoneNumber)),
        DataCell(Text(category.ticketCount.toString())),
        DataCell(Text((double.parse(category.overSupply) - category.ticketCount * 110).toStringAsFixed(1))),
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

class Employee {
  final String nameSurname;
  final String id;
  final String date;
  final int queNumber;
  Employee({
    required this.nameSurname,
    required this.id,
    required this.date,
    required this.queNumber,
  });
  Map<String, dynamic> toMap() {
    return {
      'NameSurname': nameSurname,
      'Id': id,
      'Date': date,
      'QueNumber': queNumber,
    };
  }
}

class WorkerOS {
  final String nameSurname;
  final String id;
  final String overSupply;
  final String phoneNumber;

  WorkerOS(
      {required this.nameSurname,
      required this.id,
      required this.overSupply,
      required this.phoneNumber});

  Map<String, dynamic> toMap() {
    return {
      'NameSurname': nameSurname,
      'Id': id,
      'OverSupply': overSupply,
      'PhoneNumber': phoneNumber
    };
  }
}

class DailyWorkerEmployeeDTO {
  final int queNumber;
  final String nameSurname;
  final String overSupply;
  final String phoneNumber;
  final int ticketCount;
  final String id;

  DailyWorkerEmployeeDTO(
      {required this.nameSurname,
        required this.queNumber,
        required this.overSupply,
        required this.ticketCount,
        required this.phoneNumber,
        required this.id
      });
}

class _WorkersPaymentScreenState extends State<WorkersPaymentScreen> {
  final _logoPath = 'assets/images/logo-no-background.png';
  final _user = FirebaseAuth.instance.currentUser;
  List<DailyWorkerEmployeeDTO> _dataList = [];
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
    List<DailyWorkerEmployeeDTO> filteredList = _dataList.where((category) {
      return category.nameSurname.toLowerCase().contains(keyword.toLowerCase());
    }).toList();

    setState(() {
      _dataSource = _CategoryDataSource(filteredList);
    });
  }

  Future<void> _endDay() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final databaseReference = FirebaseDatabase.instance.reference();
        for(final employee in _dataList){
          databaseReference
              .child('${user.uid}/iscilertbl')
              .child(employee.nameSurname)
              .set({
            'Id': employee.id.toString(),
            'NameSurname': employee.nameSurname,
            'PhoneNumber': employee.phoneNumber,
            'OverSupply': (double.parse(employee.overSupply) - employee.ticketCount * 110).toString()
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İşçilerin Verilen Fiş Sonrasındaki Fazlalık Güncellemeleri Yapılmıştır.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => WorkersPaymentScreen()),
        );

      }
    } catch (error) {
      print(error);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('HATA'),
            content: Text('İşlem Sırasında Bir Hata Oluştu!'),
            actions: <Widget>[
              TextButton(
                child: const Text('Tamam'),
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

  Future<void> _fetchData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final now = DateTime.now();
        final dateFormat = DateFormat('dd-MM-yyyy');
        final dateString = dateFormat.format(now);
        final dataSnapshot1 = await FirebaseDatabase.instance
            .reference()
            .child('${user.uid}/isegelenlertbl$dateString')
            .once();
        final dataMap1 = dataSnapshot1.snapshot.value as Map<dynamic, dynamic>;

        final employeeList = dataMap1.entries.map((entry) {
          final id = entry.key;
          final data = entry.value as Map<dynamic, dynamic>;
          return Employee(
            nameSurname: data['NameSurname'],
            date: data['Date'],
            id: data['Id'].toString(),
            queNumber: data['QueNumber'],
          );
        }).toList();
        final dataSnapshot = await FirebaseDatabase.instance
            .reference()
            .child(user.uid)
            .child('iscilertbl')
            .once();

        final dataMap = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;

        final categoryList = dataMap.entries.map((entry) {
          final id = entry.key;
          final data = entry.value as Map<dynamic, dynamic>;
          return WorkerOS(
            nameSurname: data['NameSurname'].toString(),
            id: data['Id'].toString(),
            phoneNumber: data['PhoneNumber'].toString(),
            overSupply: data['OverSupply'].toString(),
          );
        }).toList();
        for(final employee in employeeList){
          for(final worker in categoryList){
            if(worker.nameSurname==employee.nameSurname){
              _dataList.add(DailyWorkerEmployeeDTO(nameSurname: employee.nameSurname, queNumber: employee.queNumber, overSupply: worker.overSupply, ticketCount: (double.parse(worker.overSupply)/110).toInt(), phoneNumber: worker.phoneNumber, id: worker.id));
            }
          }
        }
        _dataList.sort((a, b) => a.queNumber != null && b.queNumber != null
            ? a.queNumber!.compareTo(b.queNumber!)
            : 0); // Sıralama yap
        setState(() {

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
            title: const Text('HATA'),
            content: Text('Bu Ekran Günlük İşçilerin Listelendiği Ekrandır Lütfen Günü Başlattığınızdan Emin Olun!!!'),
            actions: <Widget>[
              TextButton(
                child: const Text('Tamam'),
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
        title: const Text('İşçi Ödeme Ekranı'),
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
                    labelText: 'İşçi Ara',
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
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            cardColor: Colors.transparent,
                            dividerColor: Colors.green,
                          ),
                          child: PaginatedDataTable(
                            header: const Text('İşçi Listesi'),
                            columns: const [
                              DataColumn(
                                label: Text('Sıra Numarası'),
                              ),
                              DataColumn(label: Text('İsim Soyisim')),
                              DataColumn(label: Text('Telefon Numarası')),
                              DataColumn(
                                label: Text('Fiş Miktarı'),
                              ),
                              DataColumn(
                                label: Text('Fazlalık'),
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
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _endDay,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.all(16),
                    primary: Colors.green,
                  ),
                  child: Text('Ödeme Yap'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
