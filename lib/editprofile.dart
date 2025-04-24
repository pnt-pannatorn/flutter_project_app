import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController fnameController = TextEditingController();
  TextEditingController lnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      setState(() {
        userData = jsonDecode(userString);
        fnameController.text = userData!['fname'];
        lnameController.text = userData!['lname'];
        emailController.text = userData!['email'];
      });
    }
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString == null) return;

    final user = jsonDecode(userString);
    final id = user['id'];

    final url =
        Uri.parse('https://api-project-csc452-uxaa.vercel.app/users/update');

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'id': id,
          'fname': fnameController.text.trim(),
          'lname': lnameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final updatedUser = {
          'id': id,
          'fname': fnameController.text.trim(),
          'lname': lnameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
          'avatar': user['avatar'],
        };
        await prefs.setString('user', jsonEncode(updatedUser));

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('อัปเดตโปรไฟล์สำเร็จ!')),
        );
        Navigator.pop(context, true); // กลับไปหน้า profile
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('อัปเดตไม่สำเร็จ: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("แก้ไขโปรไฟล์"),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.teal[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: fnameController,
                decoration: InputDecoration(labelText: "ชื่อ"),
                validator: (value) => value!.isEmpty ? "กรุณากรอกชื่อ" : null,
              ),
              TextFormField(
                controller: lnameController,
                decoration: InputDecoration(labelText: "นามสกุล"),
                validator: (value) =>
                    value!.isEmpty ? "กรุณากรอกนามสกุล" : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "อีเมล"),
                validator: (value) => value!.isEmpty ? "กรุณากรอกอีเมล" : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "รหัสผ่านใหม่"),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? "กรุณากรอกรหัสผ่านใหม่" : null,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text("อัปเดตโปรไฟล์",
                          style: TextStyle(color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
