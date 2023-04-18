import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Companies extends StatefulWidget {
  const Companies({Key? key}) : super(key: key);

  @override
  State<Companies> createState() => _CompaniesState();
}

class Company {
  final String companyName;
  final String Debt;
  final String Received;

  Company({
    required this.companyName,
    required this.Debt,
    required this.Received,
  });

  Map<String, dynamic> toMap() {
    return {
      'CompanyName': companyName,
      'Dept': Debt,
      'Received': Received,
    };
  }
}

extension IterableExtension<E> on Iterable<E> {
  Map<int, E> asMap() {
    var index = 0;
    return Map.fromIterable(this,
        key: (item) => index++, value: (item) => item);
  }
}

class _CompaniesState extends State<Companies> {
  final _logoPath = 'assets/images/logo-no-background.png';
  List<TextEditingController> controllers = [];

  List<Company> _dataList = [];
  final _searchController =
      TextEditingController(); // Textfield için controller

  @override
  void dispose() {
    _searchController.dispose(); // Controller'ın bellekten atılması
    controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    List<TextEditingController> controllers =
        List.generate(_dataList.length, (_) => TextEditingController());
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

        final employeeList = dataMap.entries.map((entry) {
          final id = entry.key;
          final data = entry.value as Map<dynamic, dynamic>;
          return Company(
            companyName: data['CompanyName'],
            Debt: data['Dept'] != null ? data['Dept'].toString() : "0",
            Received:
                data['Received'] != null ? data['Received'].toString() : "0",
          );
        }).toList();
        setState(() {
          _dataList = employeeList;
          controllers =
              List.generate(_dataList.length, (_) => TextEditingController());
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  List<Company> _searchData(String query) {
    return _dataList.where((employee) {
      final nameSurnameLower = employee.companyName.toLowerCase();
      final queryLower = query.toLowerCase();
      return nameSurnameLower.contains(queryLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Şirket İşlemleri Ekranı'),
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(
                          () {}); // Yeniden render için setState() çağırılıyor
                    },
                    decoration: InputDecoration(
                      labelText: 'İşçi Adı Ara',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
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
                              label: Text('Ödeme Al / Ödeme Yap'),
                              tooltip: 'Update',
                            ),
                            DataColumn(
                              label: Text('Şirket Adı'),
                              tooltip: 'NameSurname',
                            ),
                            DataColumn(
                              label: Text('Borç'),
                              tooltip: 'Debt',
                            ),
                            DataColumn(
                              label: Text('Alacak'),
                              tooltip: 'Received',
                            ),
                          ],
                          rows: _searchController.text.isEmpty
                              ? _dataList
                                  .map(
                                    (data) => DataRow(
                                      cells: [
                                        DataCell(
                                          Row(
                                            children: [
                                              Ink(
                                                decoration: ShapeDecoration(
                                                  color: Colors.green,
                                                  shape: CircleBorder(),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons.add),
                                                  color: Colors.white,
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                      context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              'Ödeme Al'),
                                                          actions: [
                                                            TextButton(
                                                              child:
                                                              Text('Kapat'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                    context)
                                                                    .pop();
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                              SizedBox(width: 35),
                                              Ink(
                                                decoration: ShapeDecoration(
                                                  color: Colors.redAccent,
                                                  shape: CircleBorder(),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons.remove),
                                                  color: Colors.white,
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                      context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              'Ödeme Yap'),
                                                          actions: [
                                                            TextButton(
                                                              child:
                                                              Text('Kapat'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                    context)
                                                                    .pop();
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(Text(data.companyName)),
                                        DataCell(Text(data.Debt.toString())),
                                        DataCell(Text(data.Received.toString()))
                                      ],
                                    ),
                                  )
                                  .toList()
                              : _dataList
                                  .where((data) => data.companyName
                                      .toLowerCase()
                                      .contains(_searchController.text))
                                  .map(
                                    (data) => DataRow(
                                      cells: [
                                        DataCell(
                                          Row(
                                            children: [
                                              Ink(
                                                decoration: const ShapeDecoration(
                                                  color: Colors.green,
                                                  shape: CircleBorder(),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons.add),
                                                  color: Colors.white,
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                      context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              'Ödeme Al'),
                                                          actions: [
                                                            TextButton(
                                                              child:
                                                              Text('Kapat'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                    context)
                                                                    .pop();
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 35),
                                              Ink(
                                                decoration: const ShapeDecoration(
                                                  color: Colors.redAccent,
                                                  shape: CircleBorder(),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons.remove),
                                                  color: Colors.white,
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              'Ödeme Yap'),
                                                          actions: [
                                                            TextButton(
                                                              child:
                                                                  Text('Kapat'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(Text(data.companyName)),
                                        DataCell(Text(data.Debt.toString())),
                                        DataCell(
                                            Text(data.Received.toString())),
                                      ],
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                /*ElevatedButton(
                    onPressed: {},
                    child: const Text('Günü Başlat'),
                  ),*/
              ],
            ),
          ],
        ),
      ),
    );
  }
}
