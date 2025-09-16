import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'showmenu.dart';

class FavoritePage extends StatefulWidget {
  final String uid; // เพิ่มพารามิเตอร์ uid

  const FavoritePage({Key? key, required this.uid}) : super(key: key);
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final _auth = FirebaseAuth.instance;
  final DatabaseReference _favoritesRef =
      FirebaseDatabase.instance.ref('favorites');
  List<Map<String, dynamic>> favoriteItems = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseReference userFavRef = _favoritesRef.child(user.uid);
      DatabaseEvent event = await userFavRef.once();

      Map<dynamic, dynamic>? data =
          event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          favoriteItems = data.entries.map((entry) {
            return {
              'id': entry.key,
              'name': entry.value['name'],
              'recipe': entry.value['recipe'],
              'image': entry.value['image'],
              'video': entry.value['video'],
              'ismain': entry.value['ismain'],
            };
          }).toList();
          log('favoriteItems: $favoriteItems');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("เมนูที่บันทึกไว้"),
        backgroundColor: Color.fromARGB(255, 233, 64, 58),
      ),
      body: favoriteItems.isEmpty
          ? Center(child: Text("ไม่มีเมนูที่บันทึกไว้"))
          : GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final item = favoriteItems[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => showmenu(
                          isMain: item['ismain'],
                          uid: item['productid'],
                          urlvdo: item['video'],
                          text: item['name'],
                          recipe: item['recipe'],
                          image: item['image'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(10)),
                            child: Image.network(
                              item['image'],
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item['name'],
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
