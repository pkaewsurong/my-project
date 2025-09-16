import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

//Class stateful เรียกใช้การท างานแบบโต้ตอบ (เรียกใช้ State)
class showrandom extends StatefulWidget {
  final String foodname;
  final String foodrecipe;
  final String foodvideo;

  const showrandom(
      {Key? key,
      required this.foodname,
      required this.foodrecipe,
      required this.foodvideo})
      : super(key: key);
  @override
  State<showrandom> createState() => _MyHomePageState();
}

//class state เขียน Code ภาษา dart เพอื่ รับค่าจากหนา้จอมาคา นวณและส่งคา่่กลบัไปแสดงผล
class _MyHomePageState extends State<showrandom> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  void initState() {
    super.initState();
// Create and store the VideoPlayerController. The VideoPlayerController
// offers several different constructors to play videos from assets, files,
// or the internet.
    _controller = VideoPlayerController.asset(
      widget.foodvideo,
    );
    _initializeVideoPlayerFuture = _controller.initialize();
  }

//หมายเหตุ ถ้าใน code มีฟังก์ชัน dispose แล้วให้เติมเฉพาะ code เพื่อกา จดัค่าเก่าทเี่ ก็บไว้
  @override
  void dispose() {
// Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();
    super.dispose();
  }

  void _intialstate() {
    setState(() {});
  }

  @override
//ส่วนออกแบบหน้าจอ
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("สูตรทำอาหาร"),
        backgroundColor:
            Color.fromARGB(255, 233, 64, 58), // สีพื้นหลังของ AppBar
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ส่วนแสดงชื่อเมนูอาหาร
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.foodname, // แสดงชื่อเมนูอาหารที่ส่งมาจากหน้าก่อน
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(
                        255, 233, 64, 58)), // ขนาดและน้ำหนักของฟอนต์
                textAlign: TextAlign.center,
              ),
            ),
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
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
            // ส่วนแสดงสูตรอาหาร
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.foodrecipe, // แสดงสูตรอาหารที่ส่งมาจากหน้าก่อน
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            // เล่นหรือหยุดวิดีโอตามสถานะ
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
