import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AirQualityPage extends StatefulWidget {
  const AirQualityPage({super.key});
  @override
  State<AirQualityPage> createState() => _AirQualityPageState();
}

class _AirQualityPageState extends State<AirQualityPage> {
  final String baseUrl =
      "https://api-project-csc452-uxaa.vercel.app/airquality/history";

  final List<String> deviceIds = [
    "ESP8266-001",
    "ESP8266-002",
    // "ESP01"
  ];

  Future<Map<String, List<dynamic>>> fetchAllAirQuality() async {
    Map<String, List<dynamic>> allData = {};

    for (String id in deviceIds) {
      try {
        final response = await http.get(Uri.parse("$baseUrl/$id"));
        if (response.statusCode == 200) {
          allData[id] = jsonDecode(response.body);
        } else {
          allData[id] = []; // ใส่ข้อมูลว่างถ้าดึงไม่ได้
        }
      } catch (e) {
        allData[id] = [];
      }
    }

    return allData;
  }

  late Future<Map<String, List<dynamic>>> _airDataFuture;

  @override
  void initState() {
    super.initState();
    _airDataFuture = fetchAllAirQuality();
  }

  Future<void> _refreshData() async {
    setState(() {
      _airDataFuture = fetchAllAirQuality();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[200],
      appBar: AppBar(
        title: const Text("คุณภาพอากาศล่าสุด"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<Map<String, List<dynamic>>>(
          future: _airDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator()); // แสดง loader อันเดียว
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล"));
            }

            final dataMap = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: dataMap.entries.map((entry) {
                final deviceId = entry.key;
                final dataList = entry.value;

                if (dataList.isEmpty) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                          child: Text("ไม่มีข้อมูลสำหรับอุปกรณ์ $deviceId")),
                    ),
                  );
                }

                final latestData = dataList[0];

                return Card(
                  color: Colors.teal[50],
                  elevation: 5,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 24),
                            const SizedBox(width: 8),
                            Text("ข้อมูลล่าสุด ณ ${latestData['timestamp']}",
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.device_hub, size: 24),
                            const SizedBox(width: 8),
                            Text("จากอุปกรณ์ $deviceId",
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.thermostat,
                                size: 24, color: Colors.redAccent),
                            const SizedBox(width: 8),
                            Text("อุณหภูมิ: ${latestData['temperature']} °C",
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.water_drop,
                                size: 24, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text("ความชื้น: ${latestData['humidity']} %",
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.masks,
                                size: 24, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text("PM 2.5: ${latestData['pm2_5']} µg/m³",
                                style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
