import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:MHPro/utils/color_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bs_flutter_datatable/bs_flutter_datatable.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _obscureTextold = true;
  bool _obscureTextnew = true;
  bool _obscureTextnewrepeat = true;
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _newPasswordRepeatController = TextEditingController();
  late User _user;
  DatabaseReference? _userRef;
  Uint8List? _imageBytes;
  final String _defaultImageUrl = 'https://via.placeholder.com/150';

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _userRef =
        FirebaseDatabase.instance.reference().child('users').child(_user.uid);
    _userRef!.child('profileImage').onValue.listen((event) {
      final data = event.snapshot.value;
      setState(() {
        if (data != null) {
          _imageBytes = base64Decode(data.toString());
        }
      });
    });
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final bytes = await file.readAsBytes();
        final String base64Image = base64Encode(bytes);
        _userRef!.child('profileImage').set(base64Image);
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image')),
      );
    }
  }
  Future<void> _changePassword() async {
    try {
      // Get the current user's email address
      final email = _user.email;

      // Get the entered password values from the text fields
      final oldPassword = _oldPasswordController.text;
      final newPassword = _newPasswordController.text;
      final newPasswordRepeat = _newPasswordRepeatController.text;

      // Validate that the new password and confirmation match
      if (newPassword != newPasswordRepeat) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yeni Girdiğiniz Şifreler Farklı!')),
        );
        return;
      }

      // Reauthenticate the user with their current credentials
      final credential = EmailAuthProvider.credential(email: email!, password: oldPassword);
      await _user.reauthenticateWithCredential(credential);

      // Update the user's password to the new value
      await _user.updatePassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifreniz Başarıyla Değiştirildi!')),

      );
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ProfileScreen()));

    } catch (e) {
      print('Error changing password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Girdiğiniz Bilgileri Kontrol Ediniz!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Kullanıcı Bilgileri'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                  _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                  child: _imageBytes == null
                      ? Image.network(_defaultImageUrl)
                      : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hexStringToColor("3e77b6"),
                  ),
                  child: const Text('Seçiniz'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.99,
                  child: TextFormField(
                    obscureText: _obscureTextold,
                    controller: _oldPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Eski Şifre',
                      labelStyle: TextStyle(color: Colors.black),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureTextold ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscureTextold = !_obscureTextold;
                          });
                        },
                      ), // yeni satır
                    ),
                    style: const TextStyle(color: Colors.black),
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    expands: false,
                    maxLines: 1,
                    maxLength: null,
                    maxLengthEnforcement: MaxLengthEnforcement.none,
                    onChanged: (value) {},
                    validator: (value) {},
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.99,
                  child: TextFormField(
                    obscureText: _obscureTextnew,
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Yeni Şifre',
                      labelStyle: TextStyle(color: Colors.black),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureTextnew ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscureTextnew = !_obscureTextnew;
                          });
                        },
                      ), // yeni satır
                    ),
                    style: const TextStyle(color: Colors.black),
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    expands: false,
                    maxLines: 1,
                    maxLength: 15,
                    maxLengthEnforcement: MaxLengthEnforcement.none,
                    onChanged: (value) {},
                    validator: (value) {},
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.99,
                  child: TextFormField(
                    obscureText: _obscureTextnewrepeat,
                    controller: _newPasswordRepeatController,
                    decoration: InputDecoration(
                      labelText: 'Yeni Şifre Tekrar',
                      labelStyle: TextStyle(color: Colors.black),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureTextnewrepeat ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscureTextnewrepeat = !_obscureTextnewrepeat;
                          });
                        },
                      ), // yeni satır
                    ),
                    style: const TextStyle(color: Colors.black),

                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    expands: false,
                    maxLines: 1,
                    maxLength: 15,
                    maxLengthEnforcement: MaxLengthEnforcement.none,
                    onChanged: (value) {},
                    validator: (value) {},

                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await _changePassword();
                  },
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                  child: const Text('Şifre Değiştir'),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

}
