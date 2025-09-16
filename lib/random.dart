import 'dart:math';
import 'package:fatfood_project/showmenu.dart';
import 'package:fatfood_project/showrandom.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 233, 64, 58)),
        useMaterial3: true,
      ),
      home: RandomFoodPage(),
    );
  }
}

class RandomFoodPage extends StatefulWidget {
  @override
  State<RandomFoodPage> createState() => _RandomFoodPageState();
}

class _RandomFoodPageState extends State<RandomFoodPage> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref('mainfatfoods');

  List<Map<String, dynamic>> _foodItems = [];
  bool _isLoading = true;
  String selectedFoodUID = "";
  String selectedFoodName = "";
  String selectedFoodImage = "";
  String selectedFoodRecipe = "";
  String selectedFoodVideo = "";

  @override
  void initState() {
    super.initState();
    _fetchFoodData();
  }

  Future<void> _fetchFoodData() async {
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
          _foodItems = fetchedItems;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void selectRandomFood() {
    if (_foodItems.isEmpty) return;

    final randomIndex = Random().nextInt(_foodItems.length);
    setState(() {
      selectedFoodName = _foodItems[randomIndex]['name'] ?? "ไม่มีชื่อ";
      selectedFoodUID = _foodItems[randomIndex]['productid'] ?? "";
      selectedFoodImage = _foodItems[randomIndex]['image'] ?? "";
      selectedFoodRecipe = _foodItems[randomIndex]['description'] ?? "";
      selectedFoodVideo = _foodItems[randomIndex]['video'] ?? "";
    });
  }

  void resetSelection() {
    setState(() {
      selectedFoodName = "";
      selectedFoodUID = "";
      selectedFoodImage = "";
      selectedFoodRecipe = "";
      selectedFoodVideo = "";
    });
  }

  void viewRecipe(BuildContext context) {
    if (selectedFoodRecipe.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => showmenu(
            isMain: true,
            uid: selectedFoodUID,
            text: selectedFoodName,
            recipe: selectedFoodRecipe,
            urlvdo: selectedFoodVideo,
            image: selectedFoodImage,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('วันนี้ทำอะไรกินดี'),
        backgroundColor: Color.fromARGB(255, 233, 64, 58),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      selectedFoodName.isNotEmpty
                          ? "อาหารที่สุ่มได้: $selectedFoodName"
                          : "วันนี้ทำอะไรกินดี!",
                      style: TextStyle(
                        color: Color.fromARGB(255, 186, 35, 35),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
              SizedBox(height: 20),
              selectedFoodImage.isNotEmpty
                  ? Image.network(selectedFoodImage)
                  : Image.asset(
                      'assets/icon/iconapp.png', // เปลี่ยนเป็นชื่อไฟล์ไอคอนที่ต้องการใช้
                      width: 100,
                      height: 100,
                    ),
              SizedBox(height: 20),
              SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 250, 201, 41),
                      foregroundColor: Colors.black),
                  onPressed: _foodItems.isNotEmpty ? selectRandomFood : null,
                  child: Text("สุ่มอาหาร"),
                ),
              ),
              SizedBox(height: 20),
              if (selectedFoodName.isNotEmpty)
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 250, 201, 41),
                        foregroundColor: Colors.black),
                    onPressed: () => viewRecipe(context),
                    child: Text("ดูสูตร & วิดีโอ"),
                  ),
                ),
              SizedBox(height: 20),
              SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 247, 42, 16),
                      foregroundColor: Colors.black),
                  onPressed: resetSelection,
                  child: Text("รีเซ็ต"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
