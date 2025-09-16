import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'profile_setup.dart';

//Method หลักทีRun
Future<void> main() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: "AIzaSyDm59AWhqozbbz9UP44XGC5OgBxWsIu2MQ",
      authDomain: "testfirebase-435dd.firebaseapp.com",
      databaseURL: "https://testfirebase-435dd.firebaseio.com",
      projectId: "testfirebase-435dd",
      storageBucket: "testfirebase-435dd.appspot.com",
      messagingSenderId: "311200022907",
      appId: "1:311200022907:web:bec948b7cee0acbfe93dde",
      measurementId: "G-9SQPR9K40G",
    ));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

//Class state less สั่งแสดงผลหน้าจอ
class MyApp extends StatelessWidget {
  const MyApp({super.key});
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'fatfood',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 233, 64, 58)),
        useMaterial3: true,
      ),
      home: MyHomePage(),
      routes: {
        Profilesetup.routeName: (context) => const Profilesetup(), // ✅ เพิ่ม route ที่หายไป
      },
    );
  }
}

//Class stateful เรียกใช้การท างานแบบโต้ตอบ (เรียกใช้ State)
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//class state เขียน Code ภาษา dart เพื่อ รับค่าจากหน้าจอมาคา นวณและส่งคา่ กลับไปแสดงผล
class _MyHomePageState extends State<MyHomePage> {
  void _startAnimation() async {
// ทําการหน่วงเวลาเป็นระยะเวลา 7 วินาที
    await Future.delayed(Duration(seconds: 3));

// หลังจากการหน่วงเวลาเสร็จแล้วจะทําการเปลี่ยนไปยังหน้าหลัก
    Navigator.pushReplacement(
      context,
//home หมายถึงหน้าจอ ที่จะให้ไปแสดงผลหลังจากแสดง animate เสร็จ
      MaterialPageRoute(builder: (context) => menu()),
    );
  }

  void initState() {
    super.initState();
    _startAnimation();
  }

  void _intialstate() {
    setState(() {});
  }

  @override
//ส่วนออกแบบหน้าจอ
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg.png'), // พื้นหลัง
              fit: BoxFit.cover, // ทำให้ภาพขยายเต็มพื้นที่
            ),
          ),
          child: Center(
//ส่วนออกแบบหนา้จอ
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/logo.png', // เปลี่ยนชื่อไฟล์ตามที่ดาวน์โหลดมา
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'WELCOME',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
