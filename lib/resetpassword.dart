import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String newPassword = '';
  bool isLoading = false;

  Future<void> resetPassword() async {
    final url = Uri.parse("https://api-project-csc452-uxaa.vercel.app/users/reset-password");

    setState(() => isLoading = true);

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "newPassword": newPassword}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("รีเซ็ตรหัสผ่านสำเร็จ")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("รีเซ็ตรหัสผ่านไม่สำเร็จ")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("รีเซ็ตรหัสผ่าน"),
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
                decoration: InputDecoration(labelText: 'รหัสผ่านใหม่'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'รหัสต้องมีอย่างน้อย 6 ตัว' : null,
                onChanged: (value) => newPassword = value,
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          resetPassword();
                        }
                      },
                      child: Text("รีเซ็ตรหัสผ่าน"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}