import 'package:fatfood_project/maincourse.dart';
import 'package:fatfood_project/random.dart';
import 'package:fatfood_project/services/auth_service.dart';
import 'package:fatfood_project/signin_widget.dart';
import 'package:flutter/material.dart';
import 'appetizer.dart';
// import 'maincourse.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'quickmode.dart';

//Method หลักทีRun
void main() {
  runApp(MyApp());
}

//Class state less สั่งแสดงผลหนา้จอ
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
      home: home(),
    );
  }
}

//Class stateful เรียกใช้การท างานแบบโต้ตอบ (เรียกใช้ State)
class home extends StatefulWidget {
  @override
  State<home> createState() => _MyHomePageState();
}

//class state เขียน Code ภาษา dart เพอื่รับค่าจากหนา้จอมาคา นวณและส่งคา่่กลบัไปแสดงผล
class _MyHomePageState extends State<home> {
  final AuthService _auth = AuthService();
  void _intialstate() {
    setState(() {});
  }

  @override
//ส่วนออกแบบหนา้จอ
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg4.png'), // พื้นหลัง
          fit: BoxFit.cover, // ทำให้ภาพขยายเต็มพื้นที่
        ),
      ),
      child: Center(
//ส่วนออกแบบหนา้จอ
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
                width: 300, height: 300, child: Image.asset('assets/logo.png')),
            SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 255, 255),
                      foregroundColor: const Color.fromARGB(255, 5, 5, 5)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            maincourse(), //ชื่อหน้าจอที่ต้องการเปิด
                      ),
                    );
                  },
                  child: Text('อาหารจานหลัก')),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 255, 255),
                      foregroundColor: const Color.fromARGB(255, 5, 5, 5)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            appetizer(), //ชื่อหน้าจอที่ต้องการเปิด
                      ),
                    );
                  },
                  child: Text('อาหารทานเล่น')),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 255, 255),
                      foregroundColor: const Color.fromARGB(255, 5, 5, 5)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RandomFoodPage(), //ชื่อหน้าจอที่ต้องการเปิด
                      ),
                    );
                  },
                  child: Text('วันนี้ทำอะไรกินดี')),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 255, 255),
                      foregroundColor: const Color.fromARGB(255, 5, 5, 5)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            QuickModeScreen(), //ชื่อหน้าจอที่ต้องการเปิด
                      ),
                    );
                  },
                  child: Text('Tasty in time')),
            ),
            SizedBox(
              height: 20,
            ),
            _auth.currentUser == null
                ? SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 247, 42, 16),
                            foregroundColor:
                                Color.fromARGB(255, 255, 255, 255)),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SignInPage(), //ชื่อหน้าจอที่ต้องการเปิด
                            ),
                          );
                          setState(() {});
                        },
                        child: Text('เข้าสู่ระบบ')),
                  )
                : SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 247, 42, 16),
                            foregroundColor:
                                Color.fromARGB(255, 255, 255, 255)),
                        onPressed: () async {
                          await _auth.signOut(context);
                          setState(() {});
                        },
                        child: Text('ออกจากระบบ')),
                  ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 247, 42, 16),
                      foregroundColor: Color.fromARGB(255, 255, 255, 255)),
                  onPressed: () {
                    SystemNavigator.pop();
                    exit(0);
                  },
                  child: Text('ออก')),
            ),
          ],
        ),
      ),
    ));
  }
}
