import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String fname = '';
  String lname = '';
  String email = '';
  String avatar = '';
  String password = '';
  String confirmPassword = '';

  bool isLoading = false;

  Future<void> signup() async {
    final url = Uri.parse("https://api-project-csc452-uxaa.vercel.app/users");

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("รหัสผ่านไม่ตรงกัน")));
      return;
    }
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fname": fname,
          "lname": lname,
          "email": email,
          "password": password,
          "avatar": avatar,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("สมัครสมาชิกสำเร็จ!")),
        );
        Navigator.pop(context); // กลับไปหน้า login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("สมัครไม่สำเร็จ: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("สมัครสมาชิก"),
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
                decoration: InputDecoration(labelText: "ชื่อ"),
                validator: (value) => value!.isEmpty ? "กรุณากรอกชื่อ" : null,
                onChanged: (value) => fname = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "นามสกุล"),
                validator: (value) =>
                    value!.isEmpty ? "กรุณากรอกนามสกุล" : null,
                onChanged: (value) => lname = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "อีเมล"),
                validator: (value) => value!.isEmpty ? "กรุณากรอกอีเมล" : null,
                onChanged: (value) => email = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "อวาตาร์ (URL)"),
                validator: (value) =>
                    value!.isEmpty ? "กรุณากรอก URL อวาตาร์" : null,
                onChanged: (value) => avatar = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "รหัสผ่าน"),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? "กรุณากรอกรหัสผ่าน" : null,
                onChanged: (value) => password = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "ยืนยันรหัสผ่าน"),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? "กรุณายืนยันรหัสผ่าน" : null,
                onChanged: (value) => confirmPassword = value,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          signup();
                        }
                      },
                      child: Text("สมัครสมาชิก"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
