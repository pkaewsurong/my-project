import 'package:flutter/material.dart';

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
      home: profile(),
    );
  }
}

//Class stateful เรียกใช้การท างานแบบโต้ตอบ (เรียกใช้ State)
class profile extends StatefulWidget {
  @override
  State<profile> createState() => _MyHomePageState();
}

//class state เขียน Code ภาษา dart เพอื่รับค่าจากหนา้จอมาคา นวณและส่งคา่่กลบัไปแสดงผล
class _MyHomePageState extends State<profile> {
  void _intialstate() {
    setState(() {});
  }

  @override
  // ส่วนออกแบบหน้าจอ
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เกี่ยวกับ'), // ชื่อ AppBar
        backgroundColor:
            Color.fromARGB(255, 233, 64, 58), // สีพื้นหลังของ AppBar
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white, // เปลี่ยนสีพื้นหลังตามต้องการ
          image: DecorationImage(
            image: AssetImage('assets/bg1.png'),
            fit: BoxFit.cover, // ทำให้ภาพขยายเต็มพื้นที่
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Image.asset(
                'assets/logo.png',
                height: 250,
                fit: BoxFit.cover, // ปรับขนาดรูปภาพให้เหมาะสม
              ),
            ),
            const SizedBox(height: 16), // ระยะห่างด้านล่าง
            Center(
              child: Text(
                'แอปพลิเคชันนี้ออกแบบมาเพื่อช่วยสอนทำอาหารที่เหมาะกับเด็กหอ '
                'โดยมีวิธีการทำอาหารที่เข้าใจง่าย พร้อมคลิปวิดีโอสอนการทำอาหารที่หลากหลาย '
                'มีทั้งอาหารจานหลักและอาหารทานเล่น สำหรับผู้ที่นึกไม่ออกก็สามารถเลือกหัวข้อ '
                '"วันนี้กินอะไรดี?" แอปจะทำการสุ่มอาหารให้คุณได้เลือกทานอย่างสนุกสนาน',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'ความสะดวกสบาย',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'แอปพลิเคชันของเราถูกออกแบบมาอย่างเหมาะสมสำหรับการทำอาหารในหอพัก '
                'โดยนำเสนอสูตรอาหารที่หาซื้อวัตถุดิบได้ง่ายและไม่ใช้เวลาในการทำมากนัก '
                'นอกจากนี้ เรายังจัดเตรียมแหล่งที่สามารถซื้อวัตถุดิบพร้อมพิกัดสำหรับการเลือกซื้อ '
                'อุปกรณ์ต่างๆ ให้คุณสะดวกยิ่งขึ้น อีกทั้งยังมีคลิปวิดีโอสอนทำอาหารที่ชัดเจน '
                'เพื่อให้คุณสามารถทำตามได้อย่างง่ายดายและสนุกสนาน',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'คุณสมบัติของแอป',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'รายละเอียดเกี่ยวกับฟีเจอร์ที่มี เช่น สูตรอาหาร, วิดีโอสอนทำอาหาร, '
                'เทคนิคในการทำอาหาร, สถานที่ในการซื้อวัตถุดิบ, พิกัดซื้ออุปกรณ์ทำอาหาร '
                'และฟีเจอร์การสุ่ม เหมาะสำหรับผู้ที่ไม่แน่ใจว่าจะทำอะไรดี '
                'เรามีฟีเจอร์สุ่มเมนูที่จะช่วยให้คุณค้นพบเมนูใหม่ๆ '
                'หรือเพียงเพื่อความสนุกสนานในชีวิตประจำวัน',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 16), // ระยะห่างด้านล่าง
          ],
        ),
      ),
    );
  }
}
