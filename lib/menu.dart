import 'package:fatfood_project/profile_detail.dart';
import 'package:fatfood_project/profile_setup.dart';
import 'package:fatfood_project/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'coordinates.dart';
import 'profile.dart';
import 'search.dart';
import 'package:flutter/services.dart';

//Method หลักทีRun
void main() {
  runApp(MyApp());
}

//Class state less สั่งแสดงผลหน้าจอ
class MyApp extends StatelessWidget {
  const MyApp({super.key});
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '...',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 233, 64, 58)),
        useMaterial3: true,
      ),
      home: menu(),
    );
  }
}

//Class stateful เรียกใช้การทำงานแบบโต้ตอบ (เรียกใช้ State)
class menu extends StatefulWidget {
  @override
  State<menu> createState() => _MyHomePageState();
}

//class state เขียน Code ภาษา dart เพื่อรับค่าจากหน้าจอมาคำนวณและส่งค่ากลับไปแสดงผล
class _MyHomePageState extends State<menu> {
  final AuthService _auth = AuthService();
  final User? user = FirebaseAuth.instance.currentUser;
  //ประกาศตวัแปรเก็บลำ
  //ดับของหนา้จอ
  int _currentIndex = 0;
// สร้างตวัแปรอาร์เรยเ์พื่อเก็บ รายการของหนา้จอที่ตอ้งการสลับไปเมื่อเลือกแต่ละแทบ็
  List<Widget> _screens = [];
// สร้างฟังกช์ นั ที่ใชส้ลบั หนา้จอเมื่อผใู้ชเ้ลือกแทบ็
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _screens = [
      home(),
      Coordinates(),
      search(),
      // profile(),
      ProfileDetailWidget(
        uid: user?.uid ?? '',
      )
    ];
    super.initState();
  }

  @override
//ส่วนออกแบบหน้าจอ
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(), // ทำให้เลื่อนลื่นไหล
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height, // ทำให้เนื้อหาขยายเต็มจอ
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      _screens[_currentIndex], // แสดงหน้าจอที่ถูกเลือก
                      Positioned(
                        top: 20,
                        right: 20,
                        child: IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('จบการทํางาน'),
                                  content:
                                      Text('ท่านต้องการจบการทํางานใช่หรือไม่'),
                                  actions: [
                                    TextButton(
                                      child: Text('ใช่'),
                                      onPressed: () {
                                        SystemNavigator.pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('ไม่'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.exit_to_app),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data; // ดึง user จาก snapshot
          return BottomNavigationBar(
            backgroundColor: Color.fromARGB(255, 233, 64, 58),
            selectedItemColor: Color.fromARGB(235, 255, 17, 12),
            unselectedItemColor: Color.fromARGB(255, 250, 201, 41),
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าแรก'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_basket), label: 'พิกัดซื้ออุปกรณ์'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.food_bank_sharp), label: 'แหล่งวัตถุดิบ'),
              if (user != null)
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'โปรไฟล์'),
            ],
          );
        },
      ),
    );
  }
}
