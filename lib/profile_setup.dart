import 'package:fatfood_project/home.dart';
import 'package:fatfood_project/menu.dart';
import 'package:fatfood_project/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

//Class stateful เรียกใช้การทํางานแบบโต้ตอบ
class Profilesetup extends StatefulWidget {
  static const String routeName = '/profile';
  final Map<String, dynamic>? userData;
  const Profilesetup({super.key, this.userData});
  @override
  State<Profilesetup> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Profilesetup> {
  Map<String, dynamic>? _userData;
//ส่วนเขียน Code ภาษา dart เพื่อรับค่าจากหน้าจอมาคํานวณหรือมาทําบางอย่างและส่งค่ากลับไป
//1) ประกาศตัวแปร formKey เป็ น globalkey เพื่อตรวจสอบการรับค่าที่ผู้ใช้ป้อนผ่านฟอร์ม
  final _formKey = GlobalKey<FormState>();
//2)ประกาศตัวแปรให้ไป TextEditingController เพื่อรับที่ผู้ป้อนผ่านฟอร์ม
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
//ถ้าเป็ น dropdown ประกาศ Array เก็บค่า
  final prefix = ['นาย', 'นาง', 'นางสาว'];
//ประกาศตัวแปรค่าการเลือก
  String? _selectedPrefix;
//3) สร้างฟังก์ชันสําหรับการเลือกวันที่เพื่อไปเรียกใช้
//ประกาศตัวแปรเก็บค่าการเลือกวันที่
  DateTime? birthdayDate;
//สร้างฟังก์ชันให้เลือกวันที่
  Future<void> pickProductionDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: birthdayDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != birthdayDate) {
      setState(() {
        birthdayDate = pickedDate;
        _birthDateController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  String? _profileImageUrl;
  //ฟังก์ชันเลือกรูปภาพแลพเก็บไว้ในตัวแปร _profileImage
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _profileImage = pickedFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Future<void> _uploadProfile(String uid) async {
    try {
      String? downloadUrl;
      if (_profileImage != null) {
        final storageRef =
            FirebaseStorage.instance.ref().child('profilesfatfood/$uid.jpg');
        if (kIsWeb) {
          await storageRef.putData(await _profileImage!.readAsBytes());
        } else {
          await storageRef.putFile(File(_profileImage!.path));
        }
        downloadUrl = await storageRef.getDownloadURL();
      } else {
        downloadUrl = _profileImageUrl;
      }
      await _dbRef.child('usersfatfood/$uid').set({
        'prefix': _selectedPrefix ?? '', // ถ้า null ให้ใช้ค่าว่าง
        'firstName': _firstName.text.trim(), // ตัดช่องว่างด้านหน้าและหลัง
        'lastName': _lastName.text.trim(),
        'username': _username.text.trim(),
        'phoneNumber': _phoneNumber.text.trim(),
        'birthDate':
            birthdayDate?.toIso8601String() ?? '', // ถ้า null ให้ส่งค่าว่าง
        'profileImage': downloadUrl ?? '', // ถ้า null ให้ส่งค่าว่าง
        'profileComplete': true,
      });
      setState(() {
        _profileImageUrl = downloadUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading profile: $e')),
      );
    }
  }

  void _submitForm() async {
    final user = AuthService().currentUser;
    if (_formKey.currentState!.validate() && user != null) {
      _formKey.currentState!.save();
      await _uploadProfile(user.uid);
// ส่งข้อมูลกลับไปยังหน้า HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => menu()),
      );
    }
  }

  void _saveprofile() {
    // บันทึกข้อมูลผู้ใช้
    Navigator.pop(context, true); // ส่งค่ากลับเป็น true เมื่อบันทึกเสร็จสิ้น
  }

//ฟังก์ชัน ค่าเริ่มต้น โดยดึงค่าเดิมจากฐานข้อมูลขึ้นมาแสดงผล
  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      _selectedPrefix = widget.userData?['prefix'] ?? 'นาย';
      _firstName.text = widget.userData?['firstName'] ?? '';
      _lastName.text = widget.userData?['lastName'] ?? '';
      _username.text = widget.userData?['username'] ?? '';
      _phoneNumber.text = widget.userData?['phoneNumber'] ?? '';
      _profileImageUrl = widget.userData?['profileImage'];
      if (widget.userData?['birthDate'] != null &&
          widget.userData!['birthDate'] != '') {
        birthdayDate = DateTime.parse(widget.userData!['birthDate']);
        _birthDateController.text =
            "${birthdayDate!.toLocal()}".split(' ')[0]; // Format date
      }
    }
    _dbRef.child('usersfatfood').onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          _userData = Map<String, dynamic>.from(event.snapshot.value as Map);
        });
      }
    });
  }

//ส่วนการออกแบบหน้าจอ
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูล'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
//4)ออกแบบฟอร์มรับค่า
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      builder: (context) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera),
                              title: const Text('ถ่ายรูป: Take a Photo'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text(
                                  'เลือกรูปจากแกลอรี่: Choose from Gallery'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    child: FutureBuilder<Uint8List?>(
                      future: _profileImage?.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: MemoryImage(snapshot.data!),
                          );
                        } else if (_profileImageUrl != null) {
                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(_profileImageUrl!),
                          );
                        } else {
                          return const CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.camera_alt, size: 50),
                          );
                        }
                      },
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedPrefix,
                  decoration: const InputDecoration(
                      labelText: 'คํานําหน้าชื่อ (Prefix)'),
                  items: prefix
                      .map((category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPrefix = value!;
                    });
                  },
                ),
                TextFormField(
                  controller: _firstName,
                  decoration:
                      const InputDecoration(labelText: 'ชื่อ (First Name)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อ';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _lastName,
                  decoration:
                      const InputDecoration(labelText: 'นามสกุล (Last Name)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกนามสกุล';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _username,
                  decoration:
                      const InputDecoration(labelText: 'ชื่อผู้ใช้ (Username)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อผู้ใช้';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneNumber,
                  decoration: const InputDecoration(
                      labelText: 'เบอร์โทรศัพท์ (Phone Number)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกเบอร์โทร';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _birthDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'วันเกิด (BirthDay)',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => pickProductionDate(context),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาเลือกวันเกิด';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
// ดําเนินการเมื่อฟอร์มผ่านการตรวจสอบ
                        _submitForm();
                      }
                    },
                    child: const Text('บันทึก'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
