import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class showmenu extends StatefulWidget {
  final String urlvdo;
  final String text;
  final String recipe;
  final String image;
  final String uid;
  final bool isMain;

  showmenu(
      {Key? key,
      required this.urlvdo,
      required this.recipe,
      required this.text,
      required this.image,
      required this.uid,
      required this.isMain})
      : super(key: key);

  @override
  State<showmenu> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<showmenu> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isFavorite = false;
  String? _favoriteKey;
  final DatabaseReference _commentRef = FirebaseDatabase.instance.ref();
  final List<Map<String, dynamic>> _comments = [];
  final Map<String, dynamic> _userProfiles = {};
//ประกาศตัวแปรcommentcontrollerใหเปน TextEditingรับคาการแสดงความคิดเห็น
  final TextEditingController _commentController = TextEditingController();
  final double _userRating = 0.0; //ประกาศตัวแปรเพื่อเกบค็ ่าดาวเริ่มต้น
  double _averageRating = 0.0; //ประกาศตัวแปรเพื่อเกบค็ ่าคะแนนความพึงพอใจเฉลี่ย
  int _ratingCount = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.urlvdo),
    );
    _initializeVideoPlayerFuture = _controller.initialize();
    _checkIfFavorite();
    _fetchComments();
    _fetchUserProfiles();
    _fetchAverageRating();
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
    _fetchComments();
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

  void _checkIfFavorite() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DatabaseReference dbRef =
          FirebaseDatabase.instance.ref('favorites/${user.uid}');
      dbRef.once().then((snapshot) {
        if (snapshot.snapshot.value != null) {
          final Map<dynamic, dynamic> favorites =
              snapshot.snapshot.value as Map<dynamic, dynamic>;
          favorites.forEach((key, value) {
            if (value['name'] == widget.text) {
              setState(() {
                _isFavorite = true;
                _favoriteKey = key;
              });
            }
          });
        }
      });
    }
  }

  void _toggleFavorite() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DatabaseReference dbRef =
          FirebaseDatabase.instance.ref('favorites/${user.uid}');
      if (_isFavorite && _favoriteKey != null) {
        dbRef.child(_favoriteKey!).remove().then((_) {
          setState(() {
            _isFavorite = false;
            _favoriteKey = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ลบเมนูโปรดเรียบร้อย')),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
          );
        });
      } else {
        DatabaseReference newRef = dbRef.push();
        newRef.set({
          'name': widget.text,
          'recipe': widget.recipe,
          'image': widget.image,
          'video': widget.urlvdo,
          'ismain': widget.isMain,
        }).then((_) {
          setState(() {
            _isFavorite = true;
            _favoriteKey = newRef.key;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เพิ่มเมนูโปรดเรียบร้อย')),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
          );
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเข้าสู่ระบบเพื่อใช้งานฟังก์ชันนี้')),
      );
    }
  }

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("สูตรทำอาหาร"),
        backgroundColor: Color.fromARGB(255, 233, 64, 58),
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: _isFavorite ? Colors.white : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ส่วนแสดงชื่อเมนูอาหาร
              Center(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 233, 64, 58),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),

              // ส่วนแสดงวิดีโอ
              Center(
                child: FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),

              // ส่วนแสดงสูตรอาหาร
              Text(
                "สูตรอาหาร",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                widget.recipe,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),

              // ส่วนให้คะแนน
              Text(
                "คะแนนเฉลี่ย: ${_averageRating.toStringAsFixed(1)} ⭐ ($_ratingCount รีวิว)",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),

              const Text(
                "ให้คะแนน:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),

              RatingBar.builder(
                initialRating: _userRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, index) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  _submitRating(rating);
                },
              ),
              const SizedBox(height: 10),

              // ส่วนความคิดเห็น
              const Text(
                "ความคิดเห็น",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),

              Container(
                height: 300, // ปรับขนาดให้พอดีกับหน้าจอ
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _comments.isEmpty
                    ? const Center(child: Text("ยังไม่มีความคิดเห็น"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          final userId = comment['userId'];
                          final profile = _userProfiles[userId] ?? {};

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                                "${profile['firstName'] ?? 'ไม่ทราบชื่อ'} ${profile['lastName'] ?? ''}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(comment['comment']),
                              trailing: Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(
                                    DateTime.parse(comment['timestamp'])),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),

              // 🔹 ฟอร์มเพิ่มความคิดเห็น
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: "แสดงความคิดเห็น...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _addComment,
                    icon: const Icon(Icons.send, size: 20),
                    label: const Text("ส่ง"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
