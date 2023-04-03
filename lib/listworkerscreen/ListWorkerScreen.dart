import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class ListWorkerScreen extends StatefulWidget {
  const ListWorkerScreen({Key? key}) : super(key: key);

  @override
  State<ListWorkerScreen> createState() => _ListWorkerScreenState();
}

class Employee {
  final String nameSurname;
  final String phoneNumber;
  final String overSupply;
  final int? queNumber;

  Employee({
    required this.nameSurname,
    required this.phoneNumber,
    required this.overSupply,
    this.queNumber
  });

  Map<String, dynamic> toMap() {
    return {
      'NameSurname': nameSurname,
      'PhoneNumber': phoneNumber,
      'OverSupply': overSupply,
      'QueNumber': queNumber
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

class _ListWorkerScreenState extends State<ListWorkerScreen> {
  final _logoPath = 'assets/images/logo-no-background.png';
  List<TextEditingController> controllers = [];

  List<Employee> _dataList = [];
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
    List<TextEditingController> controllers = List.generate(_dataList.length, (_) => TextEditingController());

  }

  void _fetchData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final dataSnapshot = await FirebaseDatabase.instance
            .reference()
            .child(user.uid)
            .child('iscilertbl')
            .once();

        final dataMap = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;

        final employeeList = dataMap.entries.map((entry) {
          final id = entry.key;
          final data = entry.value as Map<dynamic, dynamic>;
          return Employee(
            nameSurname: data['NameSurname'],
            phoneNumber: data['PhoneNumber'],
            overSupply: data['OverSupply'].toString(),
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

  List<Employee> _searchData(String query) {
    return _dataList.where((employee) {
      final nameSurnameLower = employee.nameSurname.toLowerCase();
      final queryLower = query.toLowerCase();
      return nameSurnameLower.contains(queryLower);
    }).toList();
  }

  void _saveDataToFirebase() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();
    final dateFormat = DateFormat('dd-MM-yyyy');
    final dateString = dateFormat.format(now);
    final databaseRef = FirebaseDatabase.instance
        .reference()
        .child('${currentUser?.uid}/isegelenlertbl$dateString');
    for (final data in _dataList) {
      if (controllers[_dataList.indexOf(data)].text != '') {
        databaseRef.child(data.nameSurname).set({
          'nameSurname': data.nameSurname,
          'overSupply': data.overSupply,
          'queNumber': controllers[_dataList.indexOf(data)].text
        });
      }
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
            colors: [
              Color(0xFFCB2B93),
              Color(0xFF9546C4),
              Color(0xFF5E61F4)
            ],
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
                              label: Text('İşe Geldi Mi?'),
                              tooltip: 'Worked',
                            ),
                            DataColumn(
                              label: Text('İşçi Adı'),
                              tooltip: 'NameSurname',
                            ),
                            DataColumn(
                              label: Text('Telefon Numarası'),
                              tooltip: 'PhoneNumber',
                            ),
                            DataColumn(
                              label: Text('Fazlalık'),
                              tooltip: 'OverSupply',
                            ),
                          ],
                          rows: _searchController.text.isEmpty
                              ? _dataList
                              .map(
                                (data) => DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: controllers[_dataList.indexOf(data)],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Sıra',
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(data.nameSurname)),
                                DataCell(Text(data.phoneNumber)),
                                DataCell(Text(data.overSupply))
                              ],
                            ),
                          )
                              .toList()
                              : _dataList
                              .where((data) => data.nameSurname
                              .toLowerCase()
                              .contains(_searchController.text))
                              .map(
                                (data) => DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: controllers[_dataList.indexOf(data)],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Sıra',
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(data.nameSurname)),
                                DataCell(Text(data.phoneNumber)),
                                DataCell(Text(data.overSupply)),
                              ],
                            ),
                          )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveDataToFirebase,
                  child: const Text('Günü Başlat'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
