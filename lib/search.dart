import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
      home: search(),
    );
  }
}

//Class stateful เรียกใช้การท างานแบบโต้ตอบ (เรียกใช้ State)
class search extends StatefulWidget {
  @override
  State<search> createState() => _MyHomePageState();
}

//class state เขียน Code ภาษา dart เพอื่รับค่าจากหนา้จอมาคา นวณและส่งคา่่กลบัไปแสดงผล
class _MyHomePageState extends State<search> {
  // ฟังกชันเปิ ด ์ Google Maps
  void _launchMap(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  List<Map<String, dynamic>> places = [
    {
      'name': 'Lotus go fresh คลองหก (ซอยพร)',
      'description': '''
- สินค้าอุปโภคบริโภค
- อาหารสด เนื้อสัตว์ หมูชิ้น หมูสับ ไก่ กุ้ง มีสำหรับทำเองและสำเร็จรูป(แบบแช่แข็ง) ไข่ อื่นๆอีกมากมาย
- เครื่องปรุงต่างๆ เช่น ซอส ผงปรุงรสสำเร็จรูปพะโล้,ต้มยำ,แกงส้ม,ผัดกะเพรา อื่นๆ
- ผักสดสำเร็จรูปพร้อมปรุง
- อาหารแห้ง
 ''',
      'time': 'เปิด 24 ชั่วโมง',
      'imagelist': 'assets/map1.png',
      'lat': 14.036366682731124,
      'lng': 100.73303799325424
    },
    {
      'name': 'ร้านตี๋ใหญ่ - ผักสด หมูสด ไก่สด และของชำ',
      'description': '''
- ของสด เนื้อสัตว์ สำเร็จรูป(แบบแช่แข็ง) ไข่ อื่นๆ
- ผักสด
- ของชำ
''',
      'time': '5:30 - 21:00 น.',
      'imagelist': 'assets/map2.png',
      'lat': 14.042364888727777,
      'lng': 100.73904559324052
    },
    {
      'name': 'ร้านหมูรำพึง คลองหก',
      'description': '''
- ของสด เนื้อสัตว์ สำเร็จรูป(แบบแช่แข็ง) ไข่ อื่นๆ
- ผักสด
- น้ำจิ้มต่างๆ
- ซอสปรุงรส
''',
      'time': '6:00 - 21:00 น.',
      'imagelist': 'assets/map3.png',
      'lat': 14.04066047269314,
      'lng': 100.73711673887104
    },
    {
      'name': 'หมูคู่เรา Freshmart',
      'description': '''
- สินค้าอุปโภคบริโภค
- ของสด เนื้อสัตว์ สำเร็จรูป(แบบแช่แข็ง) ปลา ไข่ อื่นๆ เป็นแบบตักระบุราคาได้ เอากี่ขีดหรือเอาเป็นแช่แข็ง
- ผักสด
- น้ำจิ้มต่างๆ
- ซอสปรุงรส
- ผงปรุงรสสำเร็จรูป
- วุ้นเส้น,เส้นบะหมี่,เส้นมาม่า
''',
      'time': '6:00 - 22:00 น.',
      'imagelist': 'assets/map4.png',
      'lat': 14.037067039691182,
      'lng': 100.73245697790955
    },
    {
      'name': 'เกษรไก่สด',
      'description': '''
- สินค้าอุปโภคบริโภค
- ของสด เนื้อสัตว์ สำเร็จรูป(แบบแช่แข็ง) ปลา ไข่ อื่นๆ 
- ผักสด
- น้ำจิ้มต่างๆ
- ซอสปรุงรส
- ผงปรุงรสสำเร็จรูป
- วุ้นเส้น,เส้นบะหมี่,เส้นมาม่า
''',
      'time': '6:00 - 22:00 น.',
      'imagelist': 'assets/map5.png',
      'lat': 14.038645941164885,
      'lng': 100.73253270984223
    },
    {
      'name': 'ร้านหมูกินผัก',
      'description': '''
- สินค้าอุปโภคบริโภค
- ของสด เนื้อสัตว์ สำเร็จรูป(แบบแช่แข็ง) ปลา ไข่ อื่นๆ 
- ผักสด
- น้ำจิ้มสุกี้
- ซอสปรุงรส
''',
      'time': '6:00 - 23:00 น.',
      'imagelist': 'assets/map6.png',
      'lat': 14.03843021075899,
      'lng': 100.73644946799953
    },
    {
      'name': 'ตลาดเหรียญทอง',
      'description': '''
- สินค้าอุปโภคบริโภค
- ของสด เนื้อสัตว์ ปลา ไข่ อาหารสำเร็จรูป อื่นๆ 
- ผักสด
- น้ำจิ้มสุกี้
- ซอสปรุงรส
''',
      'time': '16:00 - 21:00 น.',
      'imagelist': 'assets/map7.png',
      'lat': 14.036683502604653,
      'lng': 100.73224487685336
    },
    {
      'name': 'Big C คลองหก',
      'description': '''
- สินค้าอุปโภคบริโภค
- อาหารสด เนื้อสัตว์ หมูชิ้น หมูสับ ไก่ กุ้ง ไข่ อาหารสำเร็จรูป อื่นๆอีกมากมาย
- เครื่องปรุงต่างๆ เช่น ซอส ผงปรุงรสสำเร็จรูปพะโล้,ต้มยำ,แกงส้ม,ผัดกะเพรา อื่นๆ
- ผักสดสำเร็จรูปพร้อมปรุง
- วุ้นเส้น,เส้นบะหมี่,เส้นมาม่า
- อาหารแห้ง
''',
      'time': '9:00 - 22:00 น.',
      'imagelist': 'assets/map8.png',
      'lat': 14.027381122670043,
      'lng': 100.74347011150388
    },
    {
      'name': 'ตลาดการเคหะคลอง 6',
      'description': '''
- สินค้าอุปโภคบริโภค
- ของสด เนื้อสัตว์ ปลา ไข่ อาหารสำเร็จรูป อื่นๆ 
- ผักสด
- น้ำจิ้มต่างๆ
- ซอสปรุงรส
''',
      'time': '04:00 - 19:00 น.',
      'imagelist': 'assets/map9.png',
      'lat': 14.029637870810664,
      'lng': 100.72947241163817
    },
    {
      'name': 'ร้านพันธ์ชัย ผักสด บ้านพฤกษา',
      'description': '''
- สินค้าอุปโภคบริโภค
- ของสด เนื้อสัตว์ สำเร็จรูป(แบบแช่แข็ง) กุ้ง ปลา ไข่ อื่นๆ 
- ผักสด
- น้ำจิ้มต่างๆ
- ซอสปรุงรส
- ผงปรุงรสสำเร็จรูป
- วุ้นเส้น,เส้นบะหมี่,เส้นมาม่า
''',
      'time': '06:00 - 23:00 น.',
      'imagelist': 'assets/map10.png',
      'lat': 14.048498454975,
      'lng': 100.73445960674576
    },
  ];

  //1) ประกาศตัวแปรสำหรับรับคาคำคนหา
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredPlaces = [];
//2) สรางฟงกชันคนหา
  void filterPlaces() {
    setState(() {
      _filteredPlaces = places
          .where((place) => place['name']
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

//3) กำหนดใหฟงกชันคนหาและตัวแปรคนหาทำทันทีเมื่อ app
  void initState() {
    super.initState();
    _filteredPlaces = places;
    _searchController.addListener(() {
      filterPlaces();
    });
  }

  void _intialstate() {
    setState(() {});
  }

  @override
//ส่วนออกแบบหนา้จอ
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ค้นหาสถานที่'),
        backgroundColor: Color.fromARGB(255, 233, 64, 58),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'พิมพ์เพื่อค้นหา...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _filteredPlaces.length,
        itemBuilder: (context, index) {
          final place = _filteredPlaces[index];
          return Card(
            color: Color.fromARGB(255, 238, 201, 81), // สีพื้นหลังของ Card
            elevation: 2.0, // ความนูน
            shape: RoundedRectangleBorder(
// ความโค้งของมุม
              borderRadius: BorderRadius.circular(5),
            ),
            child: ListTile(
              title: Row(
                children: [
                  SizedBox(
                      width: 70,
                      height: 70,
                      child: Image.asset(place['imagelist'])),
                  SizedBox(width: 8), // เพิ่มระยะห่างระหวางรูปภาพและข้อความ ่
                  Text(
                    place['name'],
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 16),
                  ),
                ],
              ),
              onTap: () {
                //เมื่อกดที่ listview แล้วให้ขึ้นรายละเอียดตางหรือไปหน้าอื่น ๆ เขียน ่ code ที่ส่วนนี้
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('รายละเอียดเพิ่มเติม'),
                      content: SingleChildScrollView(
                        // เพิ่ม SingleChildScrollView ที่นี่
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 300,
                              height: 300,
                              child: Image.asset(place['imagelist']),
                            ),
                            Text(
                              'ชื่อสถานที่ : ' + place['name'],
                              style: TextStyle(
                                  color: Color.fromARGB(255, 190, 51, 47),
                                  fontSize: 18),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'รายละเอียด',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 18),
                            ),
                            Text(
                              place['description'],
                              style: TextStyle(
                                  color: Color.fromARGB(255, 250, 201, 41),
                                  fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'เวลาเปิด-ปิด',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 18),
                            ),
                            Text(
                              place['time'],
                              style: TextStyle(
                                  color: Color.fromARGB(255, 250, 201, 41),
                                  fontSize: 16),
                            ),
                            SizedBox(height: 5),
                          ],
                        ),
                      ), //อยากแสดงอะไรเอามาแสดงได้เลย
                      actions: [
                        TextButton(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: Image.asset('assets/map.png'),
                            ),
                            onPressed: () {
                              _launchMap(place['lat'], place['lng']);
                            }),
                        TextButton(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: Image.asset('assets/close.png'),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); //คำสั่งปิด alert
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
