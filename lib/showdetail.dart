//โครงสร้างของหน้าจอที่ต้องแสดงผลจากการรับค่ามาจากอีกหน้าหนึ่ง ต้องใช้StatefulWidget
// Class StatefulWidget สําหรับแสดงผลหน้ารายละเอียดแบบรับค่ามาจากอีกหน้าหนึ่ง
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart'; // ใช้แปลงวันที่ให้เป็นรูปแบบที่อ่านง่าย

class ShowDetail extends StatefulWidget {
  static const String routeName = '/showdetail';
//ส่วนสําหรับรับค่ามาจากอีกหน้าหนึ่ง
  final String uid;
  final String title;
  final String description;
  final String type;
  final String? imageUrl;
// รับค่าจากหน้า shart.dart มาหน้า showdetail โดยต้องเรียกใช้ผาน่ Widget
  const ShowDetail({
    required this.uid,
    required this.title,
    required this.description,
    required this.type,
    this.imageUrl,
    super.key,
  });

  @override
  State<ShowDetail> createState() => _ShowDetailState();
}

class _ShowDetailState extends State<ShowDetail> {
//เขียนcode ภาษาdart
//ประกาศตัวแปรที่เปนตัวแทนการเรียกใช firebasedatabase และ firebaseauth
  final DatabaseReference _commentRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
//ประกาศตัวแปรเก็บคาcomment
  final List<Map<String, dynamic>> _comments = [];
  final Map<String, dynamic> _userProfiles = {};
//ประกาศตัวแปรcommentcontrollerใหเปน TextEditingรับคาการแสดงความคิดเห็น
  final TextEditingController _commentController = TextEditingController();
// สร้างฟังก์ชันเพื่อดึงข้อมูลโปรไฟล์ของผู้ใช้ทั้งหมดจาก Firebaseเพื่อใช้เกบและแสดงผลวใ่ครแสดงความคิดเห็น
  void _fetchUserProfiles() {
    _commentRef.child("usersfatfood").onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        _userProfiles.clear();
        data.forEach((userId, profile) {
          _userProfiles[userId] = {
            'firstName': profile['firstName'],
            'lastName': profile['lastName'],
            'profileImage': profile['profileImage'],
          };
        });
      }
      setState(() {});
    });
  }

// สร้างฟังกชันบันทึกความคิดเห็น ์
  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;
    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("กรุณาเข้าสู่ระบบก่อนแสดงความคิดเห็น")));
      return;
    }
    String userId = user.uid;
    String comment = _commentController.text.trim();
    String timestamp = DateTime.now().toIso8601String();
    await _commentRef.child("commentsfatfood/${widget.uid}").push().set({
      'userId': userId,
      'comment': comment,
      'timestamp': timestamp,
    });
    _commentController.clear();
  }

// สร้างฟังกชัน์ ดึงความคิดเห็นจาก Firebaseมาแสดงผล
  void _fetchComments() {
    _commentRef.child("commentsfatfood/${widget.uid}").onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        _comments.clear();
        data.forEach((key, value) {
          _comments.add({
            'id': key,
            'userId': value['userId'],
            'comment': value['comment'],
            'timestamp': value['timestamp'],
          });
        });
        _comments.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      }
      setState(() {});
    });
  }

  //ฟังกชันกาหนดค่าเริ่มต้น
  @override
  void initState() {
    super.initState();
    _fetchComments();
    _fetchUserProfiles();
    _fetchAverageRating();
  }

//2.1 ประกาศตัวแปรเพื่อเกบค็ ่าดาว คะแนนความพึงพอใจและจํานวนคนที่ให้ดาว
  final double _userRating = 0.0; //ประกาศตัวแปรเพื่อเกบค็ ่าดาวเริ่มต้น
  double _averageRating = 0.0; //ประกาศตัวแปรเพื่อเกบค็ ่าคะแนนความพึงพอใจเฉลี่ย
  int _ratingCount = 0; //ประกาศตัวแปรเพื่อนับจํานวนคนที่ให้ดาว
//2.2 สร้างฟังกชันเพื่อเก ์ ็บค่าคะแนนความพึงพอใจที่ผู้ใช้แต่ละคนให้ในแต่ละรายการลงในตาราง rating
//บันทึกคะแนนความพึงพอใจลง Realtime Databaseในตารางชื่อ ratingชื่อนักศึกษา
  Future<void> _submitRating(double rating) async {
    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("กรุณาเข้าสู่ระบบก่อนให้คะแนน")));
      return;
    }
    String userId = user.uid;
    //เก็บคะแนนความพึงพอใจกบวันเวลาให้คะแนน ั
    await _commentRef.child("ratingfatfood/${widget.uid}/$userId").set({
      'rating': rating,
      'timestamp': DateTime.now().toIso8601String(),
    });
    _fetchAverageRating(); // อัปเดตค่าเฉลี่ยหลังจากให้คะแนน
  }

  void _fetchAverageRating() {
    _commentRef.child("ratingfatfood/${widget.uid}").onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        double totalRating =
            0.0; //ประกาศตัวแปรคะแนนทั้งหมดให้มีค่าเริ่มต้นเป็ นศุนย์
        int count = 0; //ประกาศตัวแปรสําหรับนับจํานวนผู้ใช้ที่เข้ามาให้คะแนน
        //วนรอบเพื่ออ่านคาคะแนนทั ่ ้งหมดมาบวกรวมกนไว้ ั
        data.forEach((userId, ratingData) {
          totalRating += (ratingData['rating'] as num).toDouble();
          count++;
        });
        //ตรวจสอบวามีคนมาให้คะแนนก ่ ี่คนถ้ามีมากกวา่ 0ให้เอาคะแนนทั้งหมดหารด้วยจํานวนคนที่มาให้คะแนนเก็บในตัวแปรaverage
        _averageRating = count > 0 ? totalRating / count : 0.0;
        _ratingCount = count;
      } else {
        _averageRating = 0.0;
        _ratingCount = 0;
      }
      setState(() {});
    });
  }

//ส่วนสําหรับการออกแบบหน้าจอ
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("...")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
              Center(
                child: Image.network(widget.imageUrl!,
                    height: 200, fit: BoxFit.cover),
              )
            else
              const Center(
                child: Icon(Icons.image, size: 100, color: Colors.grey),
              ),
            const SizedBox(height: 16),
            Text("UID: ${widget.uid}",
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("ชื่อ: ${widget.title}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("ประเภท: ${widget.type}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("รายละเอียด: ${widget.description}",
                style: const TextStyle(fontSize: 16)),

            //ควรวางต่อจากการแสดงรายละเอียดข้อมูลก่อนการแสดงความคิดเห็น
//เพิ่ม Text แสดงค่าเฉลี่ยคะแนน
            Text(
                "คะแนนเฉลี่ย: ${_averageRating.toStringAsFixed(1)} ⭐ ($_ratingCount รีวิว)",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//เพิ่ม Widget Rating Bar เพื่อให้ผู้ใช้ให้คะแนนความพึงพอใจ
// ส่วนให้ผู้ใช้ให้คะแนน
            const Text("ให้คะแนน:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            RatingBar.builder(
              initialRating: _userRating, // คาคะแนนเริ่มตน
              minRating: 1, // คาคะแนนต่ำสุดที่เลือกได
              direction: Axis.horizontal, //วางดาวแบบแนวนอน
              allowHalfRating: true, //ยอมให้คะแนนแบบครึ่งดวงได้
              itemCount: 5, //จํานวนดาวทั้งหมด 5 ดวง
              itemPadding:
                  const EdgeInsets.symmetric(horizontal: 4.0), //ระยะห่างดาว
              itemBuilder: (context, index) =>
                  const Icon(Icons.star, color: Colors.amber), //รูปดาว
              onRatingUpdate: (rating) {
                _submitRating(
                    rating); //เมื่อกดให้คะแนนที่ดาวให้เรียกใช้ฟังก์ชันบันทึกคะแนน
              },
            ),

            //เพิ่มส่วนแสดงความคิดเห็น
// ส่วนการแสดงความคิดเห็น
            const Text("ความคิดเห็น",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: _comments.isEmpty
                  ? const Center(child: Text("ยังไม่มีความคิดเห็น"))
                  : ListView.builder(
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        final userId = comment['userId'];
                        final profile = _userProfiles[userId] ?? {};
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundImage:
                                  profile['profileImage'] != null &&
                                          profile['profileImage'].isNotEmpty
                                      ? NetworkImage(profile['profileImage'])
                                      : const AssetImage(
                                              'assets/default_profile.png')
                                          as ImageProvider,
                            ),
                            title: Text(
                              "${profile['firstName'] ?? 'ไม่ทราบชื่อ'}${profile['lastName'] ?? ''}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(comment['comment']),
                            trailing: Text(
                              DateFormat('dd/MM/yyyyHH:mm')
                                  .format(DateTime.parse(comment['timestamp'])),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    ),
            ),
// 🔹🔹 ฟอร์มเพิ่มความคิดเห็น
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "แสดงความคิดเห็น...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addComment,
                  child: const Text("ส่ง"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
