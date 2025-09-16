import 'package:fatfood_project/services/auth_service.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  static const String routeName = '/login';
  const SignInPage({super.key});
  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เข้าสู่ระบบ FATFOOD'),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 233, 64, 58), // สีส้มเข้ม
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bgsign.png'), // เปลี่ยนพาธรูปพื้นหลัง
            fit: BoxFit.cover, // ปรับขนาดให้เต็มหน้าจอ
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // โลโก้อยู่ตรงกลาง
                  Center(
                    child: Image.asset(
                      'assets/logo.png', // เปลี่ยนพาธโลโก้ตามที่คุณใช้
                      height: 120, // ปรับขนาดโลโก้
                    ),
                  ),
                  const SizedBox(
                      height: 24), // เว้นระยะห่างระหว่างโลโก้กับฟอร์ม
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'อีเมล',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white
                          .withOpacity(0.8), // ทำให้ช่องกรอกดูชัดขึ้น
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _email = value.trim();
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'รหัสผ่าน',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _password = value.trim();
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Color.fromARGB(255, 255, 255, 255), // สีปุ่มส้ม
                            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _setLoading(true);
                              try {
                                await _auth.signInWithEmailAndPassword(
                                    _email, _password, context);
                                Navigator.pop(context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Login failed: $e'),
                                  ),
                                );
                              } finally {
                                _setLoading(false);
                              }
                            }
                          },
                          child: const Text('เข้าสู่ระบบ'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(
                                255, 233, 64, 58), // สีปุ่มเหลือง
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _setLoading(true);
                              try {
                                await _auth.registerWithEmailAndPassword(
                                    _email, _password, context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Sign up failed: $e'),
                                  ),
                                );
                              } finally {
                                _setLoading(false);
                              }
                            }
                          },
                          child: const Text('สมัครสมาชิก'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () async {
                      await _auth.resetPassword(_email, context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'ลิงก์รีเซ็ตรหัสผ่านถูกส่งไปยังอีเมล์ของท่าน'),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(
                          255, 255, 255, 255), // สีปุ่มลืมรหัสผ่าน
                    ),
                    child: const Text('ลืมรหัสผ่าน?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
