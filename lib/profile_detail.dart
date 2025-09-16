import 'package:fatfood_project/profile_setup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'favorite.dart';

class ProfileDetailWidget extends StatefulWidget {
  final String uid;
  const ProfileDetailWidget({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfileDetailWidgetState createState() => _ProfileDetailWidgetState();
}

class _ProfileDetailWidgetState extends State<ProfileDetailWidget> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  String? _profileImageUrl;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final snapshot = await _dbRef.child('usersfatfood/${widget.uid}').get();
      if (snapshot.exists) {
        setState(() {
          _profileData = Map<String, dynamic>.from(snapshot.value as Map);
          _profileImageUrl = _profileData?['profileImage'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'โปรไฟล์',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor:
            Color.fromARGB(255, 233, 64, 58), // 🔴 สีแดงเข้มที่ต้องการ
        elevation: 0,
      ),
      body: Stack(
        children: [
          _profileData == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.amber,
                          backgroundImage: _profileImageUrl != null &&
                                  _profileImageUrl!.isNotEmpty
                              ? NetworkImage(_profileImageUrl!)
                              : AssetImage('assets/default_profile.png')
                                  as ImageProvider,
                        ),
                        SizedBox(height: 12),
                        Text(
                          '${_profileData?['prefix']} ${_profileData?['firstName']} ${_profileData?['lastName']}',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepOrange,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '@${_profileData?['username']}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 16),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          color: Colors.orange[100],
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                _buildProfileDetail(
                                  icon: Icons.phone,
                                  title: 'เบอร์โทร',
                                  value: _profileData?['phoneNumber'] ?? 'N/A',
                                ),
                                Divider(color: Colors.deepOrange),
                                _buildProfileDetail(
                                  icon: Icons.cake,
                                  title: 'วันเกิด',
                                  value: _profileData?['birthDate'] ?? 'N/A',
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          icon: Icon(Icons.edit, color: Colors.white),
                          label: Text(
                            'แก้ไขโปรไฟล์',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Profilesetup()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: Icon(
                Icons.favorite,
                color: Colors.deepOrange,
                size: 36,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritePage(
                      uid: widget.uid,
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

  Widget _buildProfileDetail(
      {required IconData icon, required String title, required String value}) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepOrange),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
      ),
    );
  }
}
