import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:math';

class QuickModeScreen extends StatefulWidget {
  @override
  _QuickModeScreenState createState() => _QuickModeScreenState();
}

class _QuickModeScreenState extends State<QuickModeScreen> {
  String selectedCategory = 'maincourse';
  TextEditingController timeController = TextEditingController();
  TextEditingController timeController1 = TextEditingController();
  TextEditingController timeController2 = TextEditingController();
  List<Map<String, dynamic>> menuList = [];
  List<Map<String, dynamic>> allRecipes = [];
  List<Map<String, dynamic>> filteredRecipes = [];
  bool isLoading = true;
  int selectedTimeFilter = 0;
  late DatabaseReference _database;
  late DatabaseReference _databaseAppetizer;

  @override
  void initState() {
    super.initState();
    _database = FirebaseDatabase.instance.ref('mainfatfoods');
    _databaseAppetizer = FirebaseDatabase.instance.ref('appetizerfatfoods');
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    // จำลองการดึงข้อมูลจาก Firebase
    // ในกรณีจริงคุณจะใช้ FirebaseDatabase.instance.reference().child('recipes').get()

    // ตัวอย่างข้อมูลเมนู
    final dummyMainRecipes = await _fetchMainData();
    final dummyAppetizerRecipes = await _fetchAppetizerData();

    setState(() {
      allRecipes.addAll(dummyMainRecipes);
      allRecipes.addAll(dummyAppetizerRecipes);
      filteredRecipes = List.from(allRecipes);
      isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchMainData() async {
    try {
      final snapshot = await _database.get();
      if (snapshot.exists) {
        Map<String, dynamic> data =
            Map<String, dynamic>.from(snapshot.value as Map);

        List<Map<String, dynamic>> fetchedItems = [];
        data.forEach((key, value) {
          fetchedItems.add(Map<String, dynamic>.from(value));
        });
        return fetchedItems;
      }
      return [];
    } catch (e) {
      print("Error fetching data: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAppetizerData() async {
    try {
      final snapshot = await _databaseAppetizer.get();
      if (snapshot.exists) {
        Map<String, dynamic> data =
            Map<String, dynamic>.from(snapshot.value as Map);

        List<Map<String, dynamic>> fetchedItems = [];
        data.forEach((key, value) {
          fetchedItems.add(Map<String, dynamic>.from(value));
        });
        return fetchedItems;
      }
      return [];
    } catch (e) {
      print("Error fetching data: $e");
      return [];
    }
  }

  void findQuickMenu() async {
    int? inputTime1 = int.tryParse(timeController1.text);
    int? inputTime2 = int.tryParse(timeController2.text);

    if (inputTime1 == null || inputTime2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกเวลาทั้งสองช่อง')),
      );
      return;
    }

    // คำนวณค่าเฉลี่ยเวลา
    int avgTime = ((inputTime1 + inputTime2) / 2).round();

    if (avgTime < 5 || avgTime > 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ค่าเฉลี่ยเวลาต้องอยู่ระหว่าง 5 - 15 นาที')),
      );
      return;
    }

    // กรองเมนูที่เวลาอยู่ในช่วง (avgTime - 2) ถึง (avgTime + 2)
    List<Map<String, dynamic>> filteredList = allRecipes.where((recipe) {
      int recipeTime = (recipe['time'] ?? 0) as int;
      return (recipeTime >= avgTime - 2 && recipeTime <= avgTime + 2);
    }).toList();

    setState(() {
      menuList = filteredList;
    });

    if (menuList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่พบเมนูที่เหมาะสม')),
      );
    }
  }

  void filterRecipesByTime(int minutes) {
    setState(() {
      selectedTimeFilter = minutes;

      if (minutes == 0) {
        // แสดงทั้งหมด
        filteredRecipes = List.from(allRecipes);
      } else {
        // กรองตามเวลาที่เลือก
        filteredRecipes =
            allRecipes.where((recipe) => recipe['time'] == minutes).toList();
      }
    });
  }

  void filterRecipesByTime2() {
    int minTime = int.tryParse(timeController1.text) ?? 0;
    int maxTime = int.tryParse(timeController2.text) ??
        9999; // ตั้งค่ามากสุดเป็นค่าใหญ่เพื่อครอบคลุมทุกกรณี

    setState(() {
      filteredRecipes = allRecipes.where((recipe) {
        int recipeTime = (recipe['time'] ?? 0) as int;
        return recipeTime >= minTime && recipeTime <= maxTime;
      }).toList();
    });
  }

  Widget _buildTimeFilterChip(int minutes, String label) {
    final isSelected = selectedTimeFilter == minutes;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => filterRecipesByTime(minutes),
      backgroundColor: Colors.grey.shade200,
      selectedColor: Color.fromARGB(255, 255, 196, 0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasty in time'),
        backgroundColor: Color.fromARGB(255, 233, 64, 58),
        // backgroundColor: Color.fromARGB(255, 233, 64, 58),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'เลือกเวลาทำอาหาร:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // _buildTimeFilterChip(0, 'ทั้งหมด'),
                      // SizedBox(width: 8),
                      // _buildTimeFilterChip(5, '5 นาที'),
                      // SizedBox(width: 8),
                      // _buildTimeFilterChip(10, '10 นาที'),
                      // SizedBox(width: 8),
                      // _buildTimeFilterChip(15, '15 นาที'),
                      // const SizedBox(width: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTimeInput(
                              timeController1, 'ช่วงเริ่มต้น (นาที)'),
                          const SizedBox(width: 8),
                          Text('ถึง',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          _buildTimeInput(
                              timeController2, 'ช่วงสิ้นสุด (นาที)'),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => filterRecipesByTime2(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 233, 64, 58),
                              foregroundColor:
                                  Colors.white, // สีตัวอักษรเป็นสีขาว
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('ค้นหาเมนู',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    menuList.isNotEmpty
                        ? 'เมนูที่ค้นพบ'
                        : selectedTimeFilter == 0
                            ? 'เมนูทั้งหมด'
                            : 'เมนูที่ใช้เวลา ${selectedTimeFilter} นาที',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: menuList.isNotEmpty
                      ? GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: menuList.length,
                          padding: EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final recipe = menuList[index];
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 255, 196, 0),
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.restaurant,
                                        size: 30,
                                        color: Color.fromARGB(255, 255, 196, 0),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        Text(
                                          recipe['name'] ?? '',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 4),
                                        Text('${recipe['time'] ?? 0} นาที'),
                                        SizedBox(height: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(
                                                255, 233, 64, 58),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    QuickCookingScreen(
                                                        recipe: recipe),
                                              ),
                                            );
                                          },
                                          child: Text('เริ่มทำเลย'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : filteredRecipes.isEmpty
                          ? Center(
                              child: Text(
                                'ไม่พบเมนูที่ใช้เวลา ${timeController1.text} ถึง ${timeController2.text} นาที',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredRecipes.length,
                              padding: EdgeInsets.all(16),
                              itemBuilder: (context, index) {
                                final recipe = filteredRecipes[index];
                                return Card(
                                  margin: EdgeInsets.only(bottom: 16),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              QuickCookingScreen(
                                                  recipe: recipe),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(
                                              8.0), // เพิ่มระยะห่างรอบรูป

                                          child: recipe['image'] != null
                                              ? Image.network(recipe['image'])
                                              : Placeholder(),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      recipe['name'] ?? '',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Color.fromARGB(
                                                          255, 255, 196, 0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Text(
                                                      '${recipe['time'] ?? 0} นาที',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                '',
                                                // 'วัตถุดิบ: ${(recipe['ingredients'] as String).split(',').length} อย่าง',
                                                style: TextStyle(
                                                  color: const Color.fromARGB(
                                                      255, 255, 255, 255),
                                                ),
                                              ),
                                              SizedBox(height: 16),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton.icon(
                                                  icon: Icon(
                                                      Icons.restaurant_menu),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 233, 64, 58),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 12),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            QuickCookingScreen(
                                                                recipe: recipe),
                                                      ),
                                                    );
                                                  },
                                                  label: Text('เริ่มทำอาหาร'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }

  Widget _buildTimeInput(TextEditingController controller, String label) {
    return Container(
      width: 120,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Color.fromARGB(255, 255, 196, 0),
          ), // สีตัวหนังสือ
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromARGB(255, 255, 196, 0), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromARGB(255, 255, 196, 0), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

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
  bool isPaused = false;
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
    String stepsText = widget.recipe['description'] ?? '';
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

  void resumeTimer() {
    // Use actual recipe time instead of fixed 5 minutes

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
        backgroundColor: Color.fromARGB(255, 233, 64, 58),
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
                      'เวลาทำอาหาร: ${widget.recipe['time'] ?? 0} นาที',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    if (isTimerRunning || isPaused)
                      Column(
                        children: [
                          CircularProgressIndicator(
                            value: remainingTime /
                                ((widget.recipe['time'] ?? 0) * 60),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(255, 255, 196, 0)),
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
                    if (!isTimerRunning && !isPaused)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.timer),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 233, 64, 58),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: startTimer,
                          label: Text(
                            'ตั้งเวลาทำอาหาร',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(isPaused
                                  ? Icons.play_arrow
                                  : Icons.pause), // เปลี่ยนไอคอน
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isPaused ? Colors.green : Colors.red,
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                if (isPaused) {
                                  resumeTimer();
                                  setState(() {
                                    isPaused = false;
                                    isTimerRunning = true;
                                  });
                                } else {
                                  timer?.cancel();
                                  setState(() {
                                    isPaused = true;
                                    isTimerRunning = false;
                                  });
                                }
                              },
                              label: Text(
                                isPaused
                                    ? 'เริ่มต่อ'
                                    : 'หยุดเวลา', // เปลี่ยนข้อความปุ่ม
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.refresh),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                timer?.cancel();
                                setState(() {
                                  remainingTime =
                                      (widget.recipe['time'] ?? 0) * 60;
                                  isTimerRunning = false;
                                  isPaused = false; // รีเซ็ตค่าหยุดชั่วคราว
                                });
                              },
                              label: Text(
                                'รีเซ็ต',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
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
                  icon: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 233, 64, 58),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    setState(() => isCookingFinished = true);
                  },
                  label: Text(
                    'เสร็จแล้ว',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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
