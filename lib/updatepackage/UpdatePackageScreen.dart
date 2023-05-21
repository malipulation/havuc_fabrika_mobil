import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:havuc_fabrika_mobil/utils/color_utils.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class UpdatePackageScreen extends StatefulWidget {
  const UpdatePackageScreen({Key? key}) : super(key: key);

  @override
  State<UpdatePackageScreen> createState() => _UpdatePackageScreenState();
}

class Employee {
  final String nameSurname;
  final String id;
  final String date;
  final String? queNumber;
  List<Category> categories; // Değişiklik burada

  Employee({
    required this.nameSurname,
    required this.id,
    required this.date,
    required this.queNumber,
    List<Category>? categories, // İsteğe bağlı kategori listesi
  }) : categories = categories ?? []; // Boş liste olarak başlat

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

class PackageMade {
  final String packageCount;

  PackageMade({required this.packageCount});

  Map<String, dynamic> toMap() {
    return {'PackageCount': packageCount};
  }
}

class Category {
  final String categoryName;
  final String wageCount;

  Category({
    required this.categoryName,
    required this.wageCount,
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

class _UpdatePackageScreenState extends State<UpdatePackageScreen> {
  final _logoPath = 'assets/images/logo-no-background.png';
  List<List<TextEditingController>> controllers = [];
  List<Employee> _dataList = [];
  List<Category> _categoryList = [];
  List<Employee> _searchResults = [];
  final _searchController =
      TextEditingController(); // Textfield için controller

  @override
  void dispose() {
    _searchController.dispose();
    // Dispose all individual text controllers
    controllers.forEach((row) {
      row.forEach((controller) => controller.dispose());
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
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
            .child('${user.uid}/günlükKategori$dateString')
            .once();
        final dataMap1 = dataSnapshot1.snapshot.value as Map<dynamic, dynamic>;

        final categoryList = dataMap1.entries.map((entry) {
          final id = entry.key;
          final data = entry.value as Map<dynamic, dynamic>;
          return Category(
              categoryName: data['CategoryName'].toString(),
              wageCount: data['WageCount']);
        }).toList();

        final dataSnapshot = await FirebaseDatabase.instance
            .reference()
            .child('${user.uid}/isegelenlertbl$dateString')
            .once();
        final dataMap = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;

        final employeeList = dataMap.entries.map((entry) {
          final id = entry.key;
          final data = entry.value as Map<dynamic, dynamic>;
          return Employee(
            nameSurname: data['NameSurname'],
            date: data['Date'],
            id: data['Id'].toString(),
            queNumber: data['QueNumber'],
          );
        }).toList();
        setState(() {
          _dataList = employeeList;
          _dataList.sort((a, b) => a.queNumber != null && b.queNumber != null
              ? a.queNumber!.compareTo(b.queNumber!)
              : 0); // Sıralama yap
          _searchResults = employeeList;
          _categoryList = categoryList;
          // Generate controllers for each employee
          controllers = List.generate(
            _dataList.length,
            (_) => _categoryList.map((_) => TextEditingController()).toList(),
          );
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

  Future<void> _showSummaryModal() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final now = DateTime.now();
        final dateFormat = DateFormat('dd-MM-yyyy');
        final dateString = dateFormat.format(now);

        final dataSnapshot = await FirebaseDatabase.instance
            .reference()
            .child('${user.uid}/isegelenlertbl$dateString')
            .once();
        final dataMap = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;

        final dataSnapshot21 = await FirebaseDatabase.instance
            .reference()
            .child('${user.uid}/iscilertbl')
            .once();
        final dataMap21 =
            dataSnapshot21.snapshot.value as Map<dynamic, dynamic>;

        var workerOSList = dataMap21.entries.map((entry) {
          final id = entry.key;
          final data = entry.value as Map<dynamic, dynamic>;
          return WorkerOS(
            nameSurname: data['NameSurname'].toString(),
            phoneNumber: data['PhoneNumber'].toString(),
            id: data['Id'].toString(),
            overSupply: (data['OverSupply']).toString(),
          );
        }).toList();
        final emplist = dataMap.entries.map((entry) {
          final id = entry.key;
          final data = entry.value as Map<dynamic, dynamic>;
          return Employee(
            nameSurname: data['NameSurname'],
            date: data['Date'],
            id: data['Id'].toString(),
            queNumber: data['QueNumber'],
          );
        }).toList();

        // İşlem başladı, ilerleme göstergesi göster
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        for (final emp in emplist) {
          for (final cat in _categoryList) {
            var tempsnap = await FirebaseDatabase.instance
                .reference()
                .child('${user.uid}/isegelenlertbl$dateString')
                .child(emp.nameSurname)
                .child(cat.categoryName)
                .once();
            var tempmap = tempsnap.snapshot.value as Map<dynamic, dynamic>;
            var tempcat = PackageMade(
              packageCount: tempmap['PackageCount'],
            );
            emp.categories.add(Category(
              categoryName: cat.categoryName,
              wageCount: tempcat.packageCount,
            ));
          }
        }

        // İşlem tamamlandı, ilerleme göstergesini kapat
        Navigator.pop(context);

        // Modal açılışında kullanılacak olan DataTable oluşturuluyor
        final dataTable = DataTable(
          columns: [
            DataColumn(label: Text('Sıra Numarası')),
            DataColumn(label: Text('Adı Soyadı')),
            ..._categoryList
                .map((cat) => DataColumn(label: Text(cat.categoryName))),
          ],
          rows: emplist
              .map((emp) => DataRow(
                    cells: [
                      DataCell(Text(emp.queNumber.toString())),
                      DataCell(Text(emp.nameSurname)),
                      ...emp.categories
                          .map((cat) => DataCell(Text(cat.wageCount))),
                    ],
                  ))
              .toList(),
        );

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: Text('Gün Özeti'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dividerThickness: 1.0,
                      columns: [
                        DataColumn(
                          label: Container(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Sıra Numarası'),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Adı Soyadı'),
                          ),
                        ),
                        ..._categoryList.map(
                          (cat) => DataColumn(
                            label: Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(cat.categoryName),
                            ),
                          ),
                        ),
                      ],
                      rows: emplist.map(
                        (emp) {
                          return DataRow(cells: [
                            DataCell(
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                        width: 1.0, color: Colors.black),
                                    bottom: BorderSide(
                                        width: 1.0, color: Colors.black),
                                  ),
                                ),
                                child: Text(emp.queNumber.toString()),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                        width: 1.0, color: Colors.black),
                                    bottom: BorderSide(
                                        width: 1.0, color: Colors.black),
                                  ),
                                ),
                                child: Text(emp.nameSurname),
                              ),
                            ),
                            ...emp.categories.map(
                              (cat) => DataCell(
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                          width: 1.0, color: Colors.black),
                                      bottom: BorderSide(
                                          width: 1.0, color: Colors.black),
                                    ),
                                  ),
                                  child: Text(cat.wageCount),
                                ),
                              ),
                            ),
                          ]);
                        },
                      ).toList(),
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Tamam'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata'),
            content: Text(
                'Verileri listeleme sırasında bir hata oluştu. Lütfen Bizimle İletişime Geçin'),
            actions: <Widget>[
              TextButton(
                child: Text('Tamam'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      print('Error fetching data: $error');
    }
  }

  Future<void> _saveDataToFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final now = DateTime.now();
        final dateFormat = DateFormat('dd-MM-yyyy');
        final dateString = dateFormat.format(now);

        final dataSnapshot = await FirebaseDatabase.instance
            .reference()
            .child('${user.uid}/isegelenlertbl$dateString')
            .once();
        final dataMap = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;

        final dataSnapshot21 = await FirebaseDatabase.instance
            .reference()
            .child('${user.uid}/iscilertbl')
            .once();
        final dataMap21 =
            dataSnapshot21.snapshot.value as Map<dynamic, dynamic>;

        var workerOSList = dataMap21.entries.map((entry) {
          final id = entry.key;
          final data = entry.value as Map<dynamic, dynamic>;
          return WorkerOS(
            nameSurname: data['NameSurname'].toString(),
            phoneNumber: data['PhoneNumber'].toString(),
            id: data['Id'].toString(),
            overSupply: (data['OverSupply']).toString(),
          );
        }).toList();
        final emplist = dataMap.entries.map((entry) {
          final id = entry.key;
          final data = entry.value as Map<dynamic, dynamic>;
          return Employee(
            nameSurname: data['NameSurname'],
            date: data['Date'],
            id: data['Id'].toString(),
            queNumber: data['QueNumber'],
          );
        }).toList();

        // İşlem başladı, ilerleme göstergesi göster
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        for (final emp in emplist) {
          for (final cat in _categoryList) {
            var tempsnap = await FirebaseDatabase.instance
                .reference()
                .child('${user.uid}/isegelenlertbl$dateString')
                .child(emp.nameSurname)
                .child(cat.categoryName)
                .once();
            var tempmap = tempsnap.snapshot.value as Map<dynamic, dynamic>;
            var tempcat = PackageMade(
              packageCount: tempmap['PackageCount'],
            );
            emp.categories.add(Category(
              categoryName: cat.categoryName,
              wageCount: tempcat.packageCount,
            ));
          }
        }

        // İşlem tamamlandı, ilerleme göstergesini kapat
        Navigator.pop(context);

        /*for (final employee in emplist) {
        print('NameSurname: ${employee.nameSurname}');
        print('Id: ${employee.id}');
        print('Date: ${employee.date}');
        print('QueNumber: ${employee.queNumber}');
        if (employee.categories != null) {
          for (final category in employee.categories!) {
            print('CategoryName: ${category.categoryName}');
            print('WageCount: ${category.wageCount}');
          }
        }
      }*/

        final databaseReference = FirebaseDatabase.instance.reference();
        //Emplist dbden çekilen _datalist buradaki
        for (final employee in emplist) {
          for (final dbemp in _dataList) {
            if (employee.nameSurname == dbemp.nameSurname &&
                employee.queNumber == dbemp.queNumber) {
              if (dbemp.categories.length != 0) {
                for (final cat in employee.categories) {
                  if (dbemp.categories
                          .where((element) =>
                              element.categoryName == cat.categoryName)
                          .first
                          .wageCount
                          .length !=
                      0) {
                    databaseReference
                        .child('${user.uid}/isegelenlertbl$dateString')
                        .child(employee.nameSurname)
                        .child(cat.categoryName)
                        .set({
                      'PackageCount': cat.wageCount +
                          dbemp.categories
                              .where((element) =>
                                  element.categoryName == cat.categoryName)
                              .first
                              .wageCount +
                          '-'
                    });
                    var emp = workerOSList
                        .where((element) =>
                            element.nameSurname == employee.nameSurname)
                        .first;
                    var oscount = double.parse(_categoryList
                        .where((element) =>
                            element.categoryName == cat.categoryName)
                        .first
                        .wageCount);
                    //TODO buraya onlukla ilgili parametreler eklenecek
                    oscount = (110 / oscount) *
                        double.parse(dbemp.categories
                            .where((element) =>
                                element.categoryName == cat.categoryName)
                            .first
                            .wageCount);
                    databaseReference
                        .child('${user.uid}/iscilertbl')
                        .child(employee.nameSurname)
                        .set({
                      'Id': emp.id,
                      'NameSurname': emp.nameSurname,
                      'PhoneNumber': emp.phoneNumber,
                      'OverSupply':
                          (double.parse(emp.overSupply) + oscount).toString()
                    });

                    final dataSnapshot21 = await FirebaseDatabase.instance
                        .reference()
                        .child('${user.uid}/iscilertbl')
                        .once();
                    final dataMap21 =
                        dataSnapshot21.snapshot.value as Map<dynamic, dynamic>;

                    workerOSList = dataMap21.entries.map((entry) {
                      final id = entry.key;
                      final data = entry.value as Map<dynamic, dynamic>;
                      return WorkerOS(
                        nameSurname: data['NameSurname'].toString(),
                        phoneNumber: data['PhoneNumber'].toString(),
                        id: data['Id'].toString(),
                        overSupply: (data['OverSupply']).toString(),
                      );
                    }).toList();
                  }
                }
              }
            }
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paket Güncelleme İşlemi Başarılı!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => UpdatePackageScreen()),
        );
      }
    } catch (error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata'),
            content: Text(
                'Verileri kaydetme sırasında bir hata oluştu. Lütfen Bizimle İletişime Geçin'),
            actions: <Widget>[
              TextButton(
                child: Text('Tamam'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Paket Güncelleme Ekranı'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFCB2B93),
              Color(0xFF9546C4),
              Color(0xFF5E61F4),
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
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Ara',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchResults = _searchData(value);
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Sıra Numarası')),
                            DataColumn(label: Text('İsim Soyisim')),
                            ..._categoryList.map(
                              (category) => DataColumn(
                                  label: Text(category.categoryName)),
                            ),
                          ],
                          rows: _searchResults.map(
                            (employee) {
                              final employeeIndex =
                                  _searchResults.indexOf(employee);

                              return DataRow(
                                cells: [
                                  DataCell(Text(employee.queNumber.toString())),
                                  DataCell(Text(employee.nameSurname)),
                                  ..._categoryList.asMap().entries.map(
                                    (entry) {
                                      final categoryIndex = entry.key;
                                      final Category category = entry.value;
                                      final TextEditingController controller =
                                          controllers[employeeIndex]
                                              [categoryIndex];

                                      return DataCell(
                                        TextFormField(
                                          controller: controller,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(),
                                          onChanged: (value) {
                                            setState(() {
                                              employee.categories =
                                                  _categoryList.map(
                                                (category) {
                                                  final categoryIndex =
                                                      _categoryList
                                                          .indexOf(category);
                                                  final wageCount =
                                                      controllers[employeeIndex]
                                                              [categoryIndex]
                                                          .text;

                                                  return Category(
                                                    categoryName:
                                                        category.categoryName,
                                                    wageCount: wageCount,
                                                  );
                                                },
                                              ).toList();
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ],
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                BottomAppBar(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    height: 56.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _saveDataToFirebase,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.all(16),
                            primary: Colors.blue,
                          ),
                          child: Text('Kaydet'),
                        ),
                        ElevatedButton(
                          onPressed: _showSummaryModal,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.all(16),
                            primary: Colors.green,
                          ),
                          child: Text('Özet'),
                        ),
                      ],
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
