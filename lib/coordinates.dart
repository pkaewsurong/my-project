import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '...',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 250, 201, 41)),
        useMaterial3: true,
      ),
      home: Coordinates(),
    );
  }
}

class Coordinates extends StatefulWidget {
  @override
  State<Coordinates> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Coordinates> {
  final ScrollController _scrollController =
      ScrollController(); // ตัวควบคุมการเลื่อน
  Timer? _autoScrollTimer; // ตัวจับเวลา สำหรับเลื่อนอัตโนมัติ

  void _startAutoScroll() {
    const duration = Duration(seconds: 2); // กำหนดระยะเวลาในการเลื่อน
    _autoScrollTimer = Timer.periodic(duration, (timer) {
      if (_scrollController.hasClients) {
        double maxScroll =
            _scrollController.position.maxScrollExtent; // ระยะการเลื่อนสูงสุด
        double currentScroll = _scrollController.offset; // ตำแหน่งปัจจุบัน
        double scrollIncrement = 100.0; // ระยะทางที่เลื่อนในแต่ละครั้ง
        if (currentScroll + scrollIncrement >= maxScroll) {
          // ถ้าถึงจุดสุดท้าย ให้เลื่อนกลับไปที่จุดเริ่มต้น
          _scrollController.animateTo(0,
              duration: Duration(seconds: 1), curve: Curves.easeInOut);
        } else {
          // ถ้ายังไม่ถึงจุดสุดท้าย ให้เลื่อนไปข้างหน้า
          _scrollController.animateTo(currentScroll + scrollIncrement,
              duration: Duration(seconds: 1), curve: Curves.easeInOut);
        }
      }
    });
  }

  void dispose() {
    _autoScrollTimer?.cancel(); // ยกเลิกตัวจับเวลาเมื่อไม่ใช้แล้ว
    _scrollController.dispose(); // ปลดปล่อยตัวควบคุมการเลื่อน
    super.dispose();
  }

  void initState() {
    super.initState();
    _startAutoScroll(); // เริ่มการเลื่อนอัตโนมัติ
  }

  final List<Map<String, String>> items = [
    {
      'text': 'Bettergarden ',
      'image': 'assets/1.png',
      'url': 'https://th.shp.ee/r9TuKg3',
    },
    {
      'text': 'thebestshop.22',
      'image': 'assets/2.png',
      'url': 'https://th.shp.ee/5d7KesG',
    },
    {
      'text': 'T.Electric',
      'image': 'assets/3.png',
      'url': 'https://th.shp.ee/y8shB4x',
    },
    {
      'text': 'Simplus official shop',
      'image': 'assets/4.png',
      'url': 'https://th.shp.ee/p58PAcp',
    },
    {
      'text': 'Sudyod Shop',
      'image': 'assets/5.png',
      'url': 'https://th.shp.ee/ti8fFZb',
    },
    {
      'text': 'yod_siam',
      'image': 'assets/6.png',
      'url': 'https://shorturl.asia/JUxsZ',
    },
    {
      'text': 'Kitchencraft 999',
      'image': 'assets/7.png',
      'url': 'https://s.lazada.co.th/s.q9hGa',
    },
    {
      'text': 'Gemini Mall',
      'image': 'assets/8.png',
      'url': 'https://s.lazada.co.th/s.q9STA',
    },
    {
      'text': 'Sunshine88',
      'image': 'assets/9.png',
      'url': 'https://shorturl.asia/4JtTh',
    },
    {
      'text': 'INSSA Life Official Store',
      'image': 'assets/10.png',
      'url': 'https://s.lazada.co.th/s.qBnum',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('พิกัดซื้ออุปกรณ์ทำอาหาร'), // ชื่อแอปใน AppBar
        backgroundColor:
            Color.fromARGB(255, 233, 64, 58), // สีพื้นหลังของ AppBar
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // จำนวนคอลัมน์ใน Grid
          crossAxisSpacing: 10.0, // ระยะห่างระหว่างคอลัมน์
          mainAxisSpacing: 10.0, // ระยะห่างระหว่างแถว
          childAspectRatio: 1 / 1, // สัดส่วนของเด็กใน Grid
        ),
        itemCount: items.length, // จำนวนรายการใน Grid
        itemBuilder: (context, index) {
          final item = items[index]; // นำข้อมูลรายการมาใช้
          return GestureDetector(
            onTap: () async {
              final url = item['url']!; // ดึง URL จากรายการ
              if (await canLaunch(url)) {
                // ตรวจสอบว่าสามารถเปิด URL ได้หรือไม่
                await launch(url); // เปิด URL ในเบราว์เซอร์
              } else {
                throw 'ไม่สามารถเปิด $url'; // ถ้าไม่สามารถเปิดให้แสดงข้อผิดพลาด
              }
            },
            child: Card(
              elevation: 4, // ระดับการยกของการ์ด
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // จัดตำแหน่งแนวตั้งให้กลาง
                children: [
                  Image.asset(
                    item['image']!, // แสดงรูปภาพจาก assets
                    height: 150,
                    width: 150,
                    fit: BoxFit.contain, // จัดการกับขนาดภาพ
                  ),
                  SizedBox(height: 10),
                  Text(
                    item['text']!, // แสดงข้อความ
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
