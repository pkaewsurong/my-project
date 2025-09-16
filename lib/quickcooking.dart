import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class QuickCookingScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;
  QuickCookingScreen({required this.recipe});

  @override
  _QuickCookingScreenState createState() => _QuickCookingScreenState();
}

class _QuickCookingScreenState extends State<QuickCookingScreen> {
  Timer? timer;
  int remainingTime = 0;
  bool isTimerRunning = false;
  bool isCookingFinished = false;
  int rating = 0;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    // Check if recipe is already in favorites
    checkFavoriteStatus();
  }

  void checkFavoriteStatus() async {
    // This would normally check a database or shared preferences
    // For demo purposes, just set to false
    setState(() => isFavorite = false);
  }

  List<String> getSimplifiedSteps() {
    String stepsText = widget.recipe['steps'] ?? '';
    List<String> allSteps =
        stepsText.split('\n').where((step) => step.trim().isNotEmpty).toList();

    // Simplify to 2-3 steps as per requirements
    if (allSteps.length <= 3) {
      return allSteps;
    } else {
      // Combine steps if there are too many
      return [
        allSteps.first,
        allSteps.length > 2 ? '${allSteps.length - 2} ขั้นตอนสำคัญอื่นๆ' : '',
        allSteps.last,
      ].where((step) => step.isNotEmpty).toList();
    }
  }

  void startTimer() {
    // Use actual recipe time instead of fixed 5 minutes
    int cookingTimeMinutes =
        int.tryParse(widget.recipe['time'].toString()) ?? 5;
    setState(() {
      remainingTime = cookingTimeMinutes * 60;
      isTimerRunning = true;
    });

    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() => remainingTime--);
      } else {
        timer.cancel();
        setState(() => isTimerRunning = false);
        // Show notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เวลาทำอาหารหมดแล้ว!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void saveRating() async {
    // This would normally save to Firebase
    setState(() => isCookingFinished = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('บันทึกคะแนน $rating ดาวเรียบร้อย')),
    );
  }

  void toggleFavorite() async {
    // This would normally toggle in Firebase
    setState(() => isFavorite = !isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            isFavorite ? 'เพิ่มในรายการโปรดแล้ว' : 'ลบออกจากรายการโปรดแล้ว'),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> steps = getSimplifiedSteps();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe['name'] ?? 'ทำอาหารด่วน'),
        backgroundColor: Color.fromARGB(255, 250, 201, 41),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'เวลาทำอาหาร: ${widget.recipe['time']} นาที',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    if (isTimerRunning)
                      Column(
                        children: [
                          CircularProgressIndicator(
                            value: remainingTime /
                                (int.parse(widget.recipe['time'].toString()) *
                                    60),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 250, 201, 41),
                            ),
                            backgroundColor: Colors.grey.shade200,
                          ),
                          SizedBox(height: 16),
                          Text(
                            formatTime(remainingTime),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(isTimerRunning ? Icons.pause : Icons.timer),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isTimerRunning
                              ? Colors.red
                              : Color.fromARGB(255, 250, 201, 41),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: isTimerRunning
                            ? () {
                                timer?.cancel();
                                setState(() => isTimerRunning = false);
                              }
                            : startTimer,
                        label: Text(
                          isTimerRunning ? 'หยุดเวลา' : 'ตั้งเวลาทำอาหาร',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'ขั้นตอนทำอาหาร:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 250, 201, 41),
                        child: Text('${index + 1}'),
                      ),
                      title: Text(steps[index]),
                    ),
                  );
                },
              ),
            ),
            if (!isCookingFinished)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.check_circle),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    setState(() => isCookingFinished = true);
                  },
                  label: Text(
                    'เสร็จแล้ว',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (isCookingFinished)
              Card(
                margin: EdgeInsets.symmetric(vertical: 16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ให้คะแนนเมนูนี้',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() => rating = index + 1);
                            },
                          );
                        }),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 250, 201, 41),
                              ),
                              onPressed: saveRating,
                              child: Text('บันทึกคะแนน'),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Text('กลับหน้าหลัก'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
