import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

import 'showmenu.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'showdetail.dart';

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
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 190, 51, 47)),
        useMaterial3: true,
      ),
      home: maincourse(),
    );
  }
}

//Class stateful เรียกใช้การท างานแบบโต้ตอบ (เรียกใช้ State)
class maincourse extends StatefulWidget {
  @override
  State<maincourse> createState() => _MyHomePageState();
}

//class state เขียน Code ภาษา dart เพอื่รับค่าจากหนา้จอมาคา นวณและส่งคา่่กลบัไปแสดงผล
class _MyHomePageState extends State<maincourse> {
//ประกาศตัวแปร ScrollController สําหรับควบคุมการเลื่อน
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer; // Timer สําหรับการเลื่อนอัตโนมัต
  late DatabaseReference _database;
  List<Map<String, dynamic>> items = [];

// สร้างฟังก์ชัน startAutoscroll ให้Gridview เลื่อน Auto
  void _startAutoScroll() {
    const duration = Duration(seconds: 2); // กําหนดเวลาช่วงระหว่างการเลื่อน
    _autoScrollTimer = Timer.periodic(duration, (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.offset;
        double scrollIncrement = 100.0; // ระยะทางที่เลื่อนแต่ละครั้ง
        if (currentScroll + scrollIncrement >= maxScroll) {
// เลื่อนกลับไปจุดเริ่มต้นถ้าถึงจุดสุดท้ายแล้ว
          _scrollController.animateTo(0,
              duration: Duration(seconds: 1), curve: Curves.easeInOut);
        } else {
// เลื่อนไปข้างหน้า
          _scrollController.animateTo(currentScroll + scrollIncrement,
              duration: Duration(seconds: 1), curve: Curves.easeInOut);
        }
      }
    });
  }

// สร้างฟังก์ชัน dispose ให้ยกเลิก timer เมื่อเลิกใช้งาน
  void dispose() {
    _autoScrollTimer?.cancel(); // ยกเลิก Timer เมื่อเลิกใช้งาน
    _scrollController.dispose();
    super.dispose();
  }

// สร้างฟังก์ชัน initState ที่จะทํางานทันทีเมื่อ app run โดยเรียกใช้ฟังก์ชัน startAutoScroll
  void initState() {
    super.initState();
// เริ่มการเลื่อนอัตโนมัติ
    // addFood(
    //   'ซุปมักกะโรนีแฮมเส้น',
    //   'description20',
    //   "assets/mn4.png",
    //   "assets/video/mn4.mp4",
    // );
    // addFood(
    //   'น้ำพริกปลาทู',
    //   description2,
    //   "assets/mn20.png",
    //   "assets/video/mn20.mp4",
    // );
    // addFood(
    //   'ยำปลาดุกฟู',
    //   description3,
    //   "assets/mn17.png",
    //   "assets/video/mn17.mp4",
    // );
    // addFood(
    //   'ผัดมาม่าขี้เมา',
    //   description4,
    //   "assets/mn18.png",
    //   "assets/video/mn18.mp4",
    // );
    _database = FirebaseDatabase.instance.ref('mainfatfoods');
    _fetchData();
    _startAutoScroll();
  }

  Future<void> _fetchData() async {
    try {
      final snapshot = await _database.get();
      if (snapshot.exists) {
        Map<String, dynamic> data =
            Map<String, dynamic>.from(snapshot.value as Map);

        List<Map<String, dynamic>> fetchedItems = [];
        data.forEach((key, value) {
          fetchedItems.add(Map<String, dynamic>.from(value));
        });
        setState(() {
          items = fetchedItems;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> addFood(String name, String description, String imageAsset,
      String videoAsset) async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('mainfatfoods');
    try {
      DatabaseReference newFoodRef = dbRef.push();
      // DatabaseReference productRef = dbRef.push();
      String newProductID = newFoodRef.key!;
      // String productID = productRef.key!;
      String imageUrl =
          await uploadFileToStorage(imageAsset, 'images/$newProductID.jpg');
      String videoUrl =
          await uploadFileToStorage(videoAsset, 'videos/$newProductID.mp4');
      await dbRef.child(newProductID).set({
        'productid': newProductID,
        'name': name,
        'description': description,
        'image': imageUrl,
        'like': {},
        'video': videoUrl
      });
    } catch (e) {
      print('ERROR : $e');
    }
  }

  Future<String> uploadFileToStorage(
      String assetPath, String storagePath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      final uploadTask = storageRef.putData(bytes);

      await uploadTask.whenComplete(() {});

      final String downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("Error uploading file: $e");
      return '';
    }
  }

  @override
//ส่วนออกแบบหนา้จอ
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('อาหารจานหลัก'), // ชื่อ AppBar
        backgroundColor:
            Color.fromARGB(255, 233, 64, 58), // สีพื้นหลังของ AppBar
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // แสดง 2 คอลัมน์ต่อแถว
          crossAxisSpacing: 10.0, // ระยะห่างระหวางคอลัมน์ ่
          mainAxisSpacing: 10.0, // ระยะห่างระหวางแถว ่
          childAspectRatio:
              1 / 1, // สัดส่วน กว้าง : สูง (1:1 = สี่เหลี่ยมจตุรัส)
        ),
        itemCount: items.length, // จํานวนรายการใน GridView
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
// รอใส่ code Navigator.push() เพื่อไปยังหน้า webviewscreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      //ชื่อหน้าเว็บที่จะไปเปิดพร้อมตัวแปรที่ส่งไปด้วย
                      showmenu(
                    isMain: true,
                    uid: item['productid'] ?? '',
                    urlvdo: item['video'] ?? '',
                    text: item['name'] ?? '',
                    recipe: item['description'] ?? '',
                    image: item['image'] ?? '',
                  ),
                ),
              );
            },
            child: Card(
//elevation ระดับการยกของการ์ดจากพื้นหลัง โดย จะรับค่าเป็ นตัวเลข
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // เพิ่มระยะห่างรอบรูป

                      child: item['image'] != null
                          ? Image.network(item['image'])
                          : Placeholder(),
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0), // เพิ่มระยะห่างซ้ายขวา
                    child: Text(
                      item['name'] ?? '', // แสดงข้อความ
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // ทำให้ข้อความเด่นขึ้น
                      ),
                      textAlign: TextAlign.center, // จัดข้อความกลาง
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
