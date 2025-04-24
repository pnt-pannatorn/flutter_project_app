import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project_app/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_project_app/menu_tab.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;

  Future<void> login() async {
    final url =
        Uri.parse("https://api-project-csc452-uxaa.vercel.app/users/login");
    // final String url = dotenv.env['API_URL']! + "/users/login";

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // นำ user ไปเก็บไว้หรือส่งต่อไปหน้า MenuTab
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(data['user']));
        Navigator.pushReplacementNamed(context, "/menuTab",
            arguments: data['user']);
      } else {
        final error = response.body;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("เข้าสู่ระบบล้มเหลว: $error")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
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
        title: Text("เข้าสู่ระบบ"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.teal[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'อีเมล'),
                validator: (value) => value!.isEmpty ? 'กรุณากรอกอีเมล' : null,
                onChanged: (value) => email = value,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'รหัสผ่าน'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'กรุณากรอกรหัสผ่าน' : null,
                onChanged: (value) => password = value,
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          login();
                        }
                      },
                      child: Text("เข้าสู่ระบบ"),
                    ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                child: Text("สมัครสมาชิก"),
              ),
              SizedBox(height: 25),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/resetPassword');
                },
                child: Text("ลืมรหัสผ่าน?"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
