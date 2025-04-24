import 'package:flutter/material.dart';
import 'package:flutter_project_app/airquality.dart';
import 'package:flutter_project_app/history.dart';
import 'package:flutter_project_app/profile.dart';

class TabMenu extends StatefulWidget {
  const TabMenu({super.key});
  @override
  State<TabMenu> createState() => _TabMenuState();
}

class _TabMenuState extends State<TabMenu> {
  int currentIndex = 0;
  final screens = [AirQualityPage(), HistoryPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.teal,
        onTap: (index) => setState(() => currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
