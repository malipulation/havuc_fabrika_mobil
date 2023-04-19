import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
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
  final _user = FirebaseAuth.instance.currentUser;
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

  Future<void> TakePayment(String CompanyName, String PaymentAmount) async {
    if (PaymentAmount.isNotEmpty && int.tryParse(PaymentAmount) != null) {
      Company data = _dataList
          .where((element) => element.companyName == CompanyName)
          .first;
      int Payment = int.parse(PaymentAmount);
      final databaseReference = FirebaseDatabase.instance.reference();
      await databaseReference
          .child(_user?.uid ?? '')
          .child('sirkettbl')
          .child(CompanyName)
          .set({
        'CompanyName': data.companyName,
        'Dept': int.parse(data.Debt) >= Payment
            ? (int.parse(data.Debt) - Payment).toString()
            : "0",
        'Received': int.parse(data.Debt) >= Payment
            ? data.Received
            : (int.parse(data.Received) + Payment - int.parse(data.Debt))
                .toString()
      });
      if (CompanyName != null && PaymentAmount!=null)  {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$CompanyName Şirketinden $PaymentAmount TL Ödeme Alınmıştır.')),
        );
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => Companies()),
      );
    }
    else{
      if(PaymentAmount.isEmpty)
        {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alınan Ödeme Boş Girilemez!'),backgroundColor: Colors.red),
          );
        }
      else
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alınan Ödemeye Geçerli Bir Sayı Giriniz!'),backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> MakePayment(String CompanyName, String PaymentAmount) async {
    if (PaymentAmount.isNotEmpty && int.tryParse(PaymentAmount) != null) {
      Company data = _dataList
          .where((element) => element.companyName == CompanyName)
          .first;
      int Payment = int.parse(PaymentAmount);
      final databaseReference = FirebaseDatabase.instance.reference();
      await databaseReference
          .child(_user?.uid ?? '')
          .child('sirkettbl')
          .child(CompanyName)
          .set({
        'CompanyName': data.companyName,
        'Dept': int.parse(data.Received)>=Payment ? data.Debt : (int.parse(data.Debt)+Payment-int.parse(data.Received)).toString(),
        'Received': int.parse(data.Received)>=Payment ? (int.parse(data.Received)-Payment).toString() : "0"
      });
      if (CompanyName != null && PaymentAmount!=null)  {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$CompanyName Şirketine $PaymentAmount TL Ödeme Yapılmıştır.')),
        );
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => Companies()),
      );
    }
    else{
      if(PaymentAmount.isEmpty)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yapılan Ödeme Boş Girilemez!'),backgroundColor: Colors.red),
        );
      }
      else
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yapılan Ödemeye Geçerli Bir Sayı Giriniz!'),backgroundColor: Colors.red),
        );
      }
    }
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
    final _amount = TextEditingController();
    final _companyName = TextEditingController();
    final _debt = TextEditingController();
    final _received = TextEditingController();
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
                          dataRowHeight: 60,
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
                                                          title:
                                                              Text('Ödeme Al'),
                                                          content:
                                                              TextFormField(
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            controller: _amount,
                                                            decoration:
                                                                const InputDecoration(
                                                              labelText:
                                                                  'Alınan Miktar',
                                                              labelStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .black45,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 20,
                                                                      top: 7),
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                            textAlign:
                                                                TextAlign.left,
                                                            textAlignVertical:
                                                                TextAlignVertical
                                                                    .center,
                                                          ),
                                                          actions: [
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                TakePayment(
                                                                    data
                                                                        .companyName,
                                                                    _amount
                                                                        .text);
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .lightGreen,
                                                              ),
                                                              child: const Text(
                                                                  'Kaydet'),
                                                            ),
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
                                                          title:
                                                              Text('Ödeme Yap'),
                                                          content:
                                                              TextFormField(
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            controller: _amount,
                                                            decoration:
                                                                const InputDecoration(
                                                              labelText:
                                                                  'Ödenen Miktar',
                                                              labelStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .black45,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 20,
                                                                      top: 7),
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                            textAlign:
                                                                TextAlign.left,
                                                            textAlignVertical:
                                                                TextAlignVertical
                                                                    .center,
                                                          ),
                                                          actions: [
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                MakePayment(
                                                                    data
                                                                        .companyName,
                                                                    _amount
                                                                        .text);
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .lightGreen,
                                                              ),
                                                              child: const Text(
                                                                  'Kaydet'),
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  'Kapat'),
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
                                                          title:
                                                              Text('Ödeme Al'),
                                                          content:
                                                              TextFormField(
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            controller: _amount,
                                                            decoration:
                                                                const InputDecoration(
                                                              labelText:
                                                                  'Alınan Miktar',
                                                              labelStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .black45,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 20,
                                                                      top: 7),
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                            textAlign:
                                                                TextAlign.left,
                                                            textAlignVertical:
                                                                TextAlignVertical
                                                                    .center,
                                                          ),
                                                          actions: [
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                TakePayment(
                                                                    data
                                                                        .companyName,
                                                                    _amount
                                                                        .text);
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .lightGreen,
                                                              ),
                                                              child: const Text(
                                                                  'Kaydet'),
                                                            ),
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
                                                          title:
                                                              Text('Ödeme Yap'),
                                                          content:
                                                              TextFormField(
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            controller: _amount,
                                                            decoration:
                                                                const InputDecoration(
                                                              labelText:
                                                                  'Ödenen Miktar',
                                                              labelStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .black45,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 20,
                                                                      top: 7),
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                            textAlign:
                                                                TextAlign.left,
                                                            textAlignVertical:
                                                                TextAlignVertical
                                                                    .center,
                                                          ),
                                                          actions: [
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                MakePayment(
                                                                    data
                                                                        .companyName,
                                                                    _amount
                                                                        .text);
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .lightGreen,
                                                              ),
                                                              child: const Text(
                                                                  'Kaydet'),
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  'Kapat'),
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
                ElevatedButton(
                    onPressed: ()async{
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Şirket Ekle'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: _companyName,
                                  decoration: const InputDecoration(
                                    labelText: 'Şirket Adı',
                                    labelStyle: TextStyle(
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(left: 20, top: 7),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                  textAlign: TextAlign.left,
                                  textAlignVertical: TextAlignVertical.center,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _debt,
                                  decoration: const InputDecoration(
                                    labelText: 'Borç',
                                    labelStyle: TextStyle(
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(left: 20, top: 7),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                  textAlign: TextAlign.left,
                                  textAlignVertical: TextAlignVertical.center,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _received,
                                  decoration: const InputDecoration(
                                    labelText: 'Alacak',
                                    labelStyle: TextStyle(
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(left: 20, top: 7),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                  textAlign: TextAlign.left,
                                  textAlignVertical: TextAlignVertical.center,
                                ),
                              ],
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () async {
                                  String companyName = _companyName.text;
                                  String debt = _debt.text;
                                  String received = _received.text;

                                  if (companyName.isNotEmpty && debt.isNotEmpty && received.isNotEmpty && int.tryParse(debt)!=null && int.tryParse(received)!=null)  {
                                    try {
                                      final databaseReference = FirebaseDatabase.instance.reference();
                                      await databaseReference
                                          .child(_user?.uid ?? '')
                                          .child('sirkettbl')
                                          .child(companyName)
                                          .set({
                                        'CompanyName': companyName,
                                        'Dept': int.parse(debt)>=int.parse(received) ? (int.parse(debt)-int.parse(received)).toString() : "0",
                                        'Received': int.parse(debt)<int.parse(received) ? (int.parse(received)-int.parse(debt)).toString() : "0"
                                      });

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Şirket Eklendi.')),
                                      );
                                      // ignore: use_build_context_synchronously
                                      Navigator.pop(context,
                                        MaterialPageRoute(builder: (BuildContext context) => Companies()),
                                      );
                                      // ignore: use_build_context_synchronously
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (BuildContext context) => Companies()),
                                      );
                                    } catch (e) {
                                      print('Error: $e');
                                    }
                                  }
                                  else{
                                    if(!companyName.isNotEmpty)
                                    {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Şirket Adı Boş Girilemez!.')),
                                      );
                                    }
                                    else if(!debt.isNotEmpty)
                                    {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Borç Miktarı Boş Girilemez!.')),
                                      );
                                    }
                                    else if(!received.isNotEmpty)
                                    {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Alacak Miktarı Boş Girilemez!.')),
                                      );
                                    }
                                    else
                                    {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Borç ve Alacak Kısmına Sadece Sayı Girebilirsiniz!.')),
                                      );
                                    }

                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightGreen,
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
                        },
                      );
                    },
                    child: const Text('Şirket Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
