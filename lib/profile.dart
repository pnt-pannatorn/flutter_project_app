import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      setState(() {
        userData = jsonDecode(userString);
      });
    }
  }

  Future<void> _verify() async {
    String enteredPassword = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยืนยันรหัสผ่าน"),
        content: TextField(
          obscureText: true,
          decoration: const InputDecoration(hintText: "กรอกรหัสผ่านของคุณ"),
          onChanged: (value) => enteredPassword = value,
        ),
        actions: [
          TextButton(
            child: const Text("ยกเลิก"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("ยืนยัน"),
            onPressed: () async {
              if (enteredPassword == userData!['password']) {
                Navigator.pop(context); // ปิด Dialog ก่อน

                // รอผลลัพธ์จากหน้า editProfile กลับมา
                final result =
                    await Navigator.pushNamed(context, '/editProfile');

                if (result == true) {
                  // ถ้าแก้ไขสำเร็จ โหลดข้อมูลใหม่เลย
                  await _loadUserData();
                }
              } else {
                Navigator.pop(context); // ปิด Dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("รหัสผ่านไม่ถูกต้อง")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("confirm delete"),
        content: const Text(
            "Are you sure you want to delete this account? This action cannot be undone."),
        actions: [
          TextButton(
            child: const Text("cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("delete"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final userId = userData!['id'];
        final response = await http.delete(
          Uri.parse("https://api-project-csc452-uxaa.vercel.app/users/$userId"),
        );

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("error deleting account")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final avatarUrl = userData!['avatar'] ??
        'https://cdn-icons-png.flaticon.com/512/149/149071.png';

    return Scaffold(
      appBar: AppBar(
        title: const Text("บัญชีของฉัน"),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.teal[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(avatarUrl),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text("${userData!['fname']} ${userData!['lname']}"),
                    subtitle: const Text("ชื่อผู้ใช้"),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(userData!['email']),
                    subtitle: const Text("อีเมล"),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: Text(userData!['id'].toString()),
                    subtitle: const Text("รหัสผู้ใช้"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _verify,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text("Edit profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  )),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text("Sign out",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  )),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _deleteAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text("delete account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
