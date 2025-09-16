import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:flutter/services.dart';

//Class stateful เรียกใช้การท างานแบบโต้ตอบ (เรียกใช้ State)
class showcoordinates extends StatefulWidget {
  final String url; // ประกาศตัวแปร url เพือรั ่ บค่าลิงค์มาจากหน้า gridview
  showcoordinates({Key? key, required this.url})
      : super(key: key); // อ้างอิงค่าทีส่งมา

  @override
  State<showcoordinates> createState() => _MyHomePageState();
}

//class state เขียน Code ภาษา dart เพอื่รับค่าจากหนา้จอมาคา นวณและส่งคา่่กลบัไปแสดงผล
class _MyHomePageState extends State<showcoordinates> {
  late WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(Uri.parse(widget.url)); // Use the passed URL toload content
  }

  void _intialstate() {
    setState(() {});
  }

  @override
//ส่วนออกแบบหนา้จอ
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 233, 64, 58),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
