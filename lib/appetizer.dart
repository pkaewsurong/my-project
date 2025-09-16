import 'package:fatfood_project/showmenu.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'showmenu.dart';

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
      home: appetizer(),
    );
  }
}

//Class stateful เรียกใช้การท างานแบบโต้ตอบ (เรียกใช้ State)
class appetizer extends StatefulWidget {
  @override
  State<appetizer> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<appetizer> {
  late DatabaseReference _database;
  List<Map<String, dynamic>> items = [];
//ประกาศตัวแปร ScrollController สําหรับควบคุมการเลื่อน
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer; // Timer สําหรับการเลื่อนอัตโนมัต
  String description1 = '''
// \t\t\t\t  วิธีทำ ทอดมันหมู  ทำง่าย อร่อยแบบเพลิดเพลินใจ

//    ส่วนผสม ทอดมันหมู
// \t\t\t\t•	หมูบด 500 กรัม
// \t\t\t\t•	กระเทียม 3 กลีบ
// \t\t\t\t•	พริกไทยป่น 1 ช้อนชา
// \t\t\t\t•	ผงกะหรี่ 1 ช้อนชา
// \t\t\t\t•	น้ำตาลทราย 1 ช้อนชา
// \t\t\t\t•	น้ำปลา 2 ช้อนโต๊ะ
// \t\t\t\t•	แป้งมัน 2 ช้อนโต๊ะ
// \t\t\t\t•	ใบมะกรูดซอย 1 ใบ
// \t\t\t\t•	น้ำมันพืชสำหรับทอด

 
// วิธีทำ ทอดมันหมู
// \t\t\t\t1.โขลกกระเทียมและพริกไทยให้ละเอียด
// \t\t\t\t2.ผสมหมูบดกับเครื่องที่โขลก ใส่ผงกะหรี่ น้ำตาล น้ำปลา และแป้งมัน ผสมให้เข้ากัน
// \t\t\t\t3.ใส่ใบมะกรูดซอยลงไป
// \t\t\t\t4.ปั้นเป็นก้อนกลมแล้วกดให้แบน
// \t\t\t\t5.ทอดในน้ำมันร้อนจนกรอบและสีสวย 
// ''';

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
    //   'ทอดมันหมู',
    //   description1,
    //   'assets/p11.png',
    //   'assets/video/p11.mp4',
    // );
    // addFood(
    //   'ปีกไก่ทอดน้ำปลา',
    //   description2,
    //   'assets/p12.png',
    //   'assets/video/p12.mp4',
    // );
    // addFood(
    //   'ข้าวเกรียบปากหม้อ',
    //   description3,
    //   'assets/p13.png',
    //   'assets/video/p13.mp4',
    // );
    // addFood(
    //   'ลาบหมูทอด',
    //   description4,
    //   'assets/p14.png',
    //   "assets/video/p14.mp4",
    // );
    // addFood(
    //   'หมูสะเต๊ะ',
    //   description5,
    //   "assets/p15.png",
    //   "assets/video/p15.mp4",
    // );
    // addFood(
    //   'ขนมจีบ',
    //   description6,
    //   "assets/p16.png",
    //   "assets/video/p16.mp4",
    // );
    // addFood(
    //   'ทอดมันกุ้ง',
    //   description7,
    //   "assets/p17.png",
    //   "assets/video/p17.mp4",
    // );
    // addFood(
    //   'หอยจ๊อ',
    //   description8,
    //   "assets/p18.png",
    //   "assets/video/p18.mp4",
    // );
    // addFood(
    //   'เกี๊ยวทอด',
    //   description9,
    //   "assets/p19.png",
    //   "assets/video/p19.mp4",
    // );
    // addFood(
    //   'ปอเปี๊ยะทอด',
    //   description10,
    //   "assets/p20.png",
    //   "assets/video/p20.mp4",
    // );
    _database = FirebaseDatabase.instance.ref('appetizerfatfoods');
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
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref('appetizerfatfoods');
    try {
      DatabaseReference newFoodRef = dbRef.push();
      String newProductID = newFoodRef.key!;
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
        title: Text('อาหารทานเล่น'), // ชื่อ AppBar
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
                    isMain: false,
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
