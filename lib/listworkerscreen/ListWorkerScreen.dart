import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

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

  Employee(
      {required this.nameSurname,
      required this.phoneNumber,
      required this.overSupply,
      this.queNumber});

  Map<String, dynamic> toMap() {
    return {
      'NameSurname': nameSurname,
      'PhoneNumber': phoneNumber,
      'OverSupply': overSupply,
      'QueNumber': queNumber
    };
  }
}

class Category {
  final String categoryName;
  final String wageCount;
  bool isChecked;

  Category({
    required this.categoryName,
    required this.wageCount,
    this.isChecked = false, // Varsayılan değeri false olarak ayarlayın
  });

  Map<String, dynamic> toMap() {
    return {'CategoryName': categoryName, 'WageCount': wageCount};
  }
}

extension IterableExtension<E> on Iterable<E> {
  Map<int, E> asMap() {
    var index = 0;
    return Map.fromIterable(this,
        key: (item) => index++, value: (item) => item);
  }
}
List<Category> _dataListCategory = [];

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
            .child('iscilertbl')
            .once();
        final dataSnapshot2 = await FirebaseDatabase.instance
            .reference()
            .child(user.uid)
            .child('kategoritbl')
            .once();
        final dataMap = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
        final dataMap2 = dataSnapshot2.snapshot.value as Map<dynamic, dynamic>;

        final employeeList = dataMap.entries.map((entry) {
          final id = entry.key;
          final data = entry.value as Map<dynamic, dynamic>;
          return Employee(
            nameSurname: data['NameSurname'],
            phoneNumber: data['PhoneNumber'],
            overSupply: data['OverSupply'].toString(),
          );
        }).toList();
        final categoryList = dataMap2.entries.map((entry) {
          final id = entry.key;
          final data = entry.value as Map<dynamic, dynamic>;
          return Category(
            categoryName: data['CategoryName'],
            wageCount: data['WageCount'],
          );
        }).toList();

        setState(() {
          _dataList = employeeList;
          _dataListCategory = categoryList;
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

  Future<void> _saveDataToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final now = DateTime.now();
      final dateFormat = DateFormat('dd-MM-yyyy');
      final dateString = dateFormat.format(now);
      final dataSnapshot = await FirebaseDatabase.instance
          .reference()
          .child('${user.uid}/günlükKategori$dateString')
          .once();
      if(dataSnapshot.snapshot.value==null){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen Önce Kategori Seçiniz.')),
        );
        return;
      }
      else{
        final dataMap = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
        final categoryList = dataMap.entries.map((entry) {
          final id = entry.key;
          final data = entry.value as Map<dynamic, dynamic>;
          return Category(
            categoryName: data['CategoryName'],
            wageCount: data['WageCount'],
          );
        }).toList();
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
              'Date': DateTime.now().toString(),
              'Id' : Uuid().v4().toString(),
              'NameSurname': data.nameSurname,
              'QueNumber': controllers[_dataList.indexOf(data)].text
            });
            for(final category in categoryList){
              databaseRef.child(data.nameSurname).child(category.categoryName).set({
                'PackageCount':''
              });
            }
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gün Başlatıldı.')),
        );
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
                                              controller: controllers[
                                                  _dataList.indexOf(data)],
                                              keyboardType:
                                                  TextInputType.number,
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
                                              controller: controllers[
                                                  _dataList.indexOf(data)],
                                              keyboardType:
                                                  TextInputType.number,
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
                Row(
                  children: [
                    SizedBox(width: 20),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return _CategoryDialog(
                              dataListCategory: _dataListCategory,
                            );
                          },
                        );
                      },
                      child: const Text('Kategori Ekle'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                      ),
                    ),
                    SizedBox(width: 60),
                    ElevatedButton(
                      onPressed: _saveDataToFirebase,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.redAccent, // Kırmızı renk
                      ),
                      child: const Text('Günü Başlat'),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  final List<Category> dataListCategory;

  const _CategoryDialog({required this.dataListCategory});

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Günlük Kategori Ekle'),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DataTable(
                columns: const [
                  DataColumn(
                    label: Text('Seç'),
                  ),
                  DataColumn(
                    label: Text('Kategori Adı'),
                  ),
                  DataColumn(
                    label: Text('Fire Miktarı'),
                  ),
                ],
                rows: widget.dataListCategory.map((category) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Checkbox(
                          value: category.isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              category.isChecked = value!;
                            });
                          },
                        ),
                      ),
                      DataCell(Text(category.categoryName)),
                      DataCell(Text(category.wageCount)),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (widget.dataListCategory
                    .where((element) => element.isChecked)
                    .length == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lütfen Kategori Seçiniz!!!')),
              );
            }
            else
            {
              final currentUser = FirebaseAuth.instance.currentUser;
              final now = DateTime.now();
              final dateFormat = DateFormat('dd-MM-yyyy');
              final dateString = dateFormat.format(now);
              final databaseRef = FirebaseDatabase.instance
                  .reference()
                  .child('${currentUser?.uid}/günlükKategori$dateString');
              for (final data in widget.dataListCategory.where((element) => element.isChecked)) {
                  databaseRef.child(data.categoryName).set({
                    'CategoryName': data.categoryName,
                    'WageCount': data.wageCount
                  });
              }
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Günlük Kategori Eklendi. Artık Günlük Personel Ekleyebilirsiniz.')),
              );


            }
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.lightGreen,
          ),
          child: const Text('Ekle'),
        ),
        TextButton(
          child: const Text('Kapat'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
