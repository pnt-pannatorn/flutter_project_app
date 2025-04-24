import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final String apiUrl =
      "https://api-project-csc452-uxaa.vercel.app/airquality/history";
  final List<String> deviceIds = ['ทั้งหมด', 'ESP8266-001', 'ESP8266-002'];

  String selectedDevice = 'ทั้งหมด';
  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;

  Future<List<dynamic>> fetchHistory() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load history data");
      }
    } catch (e) {
      print("Error fetching history data: $e");
      return [];
    }
  }

  String formatTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp).toLocal();
    return DateFormat('HH:mm dd-MM-yyyy').format(dateTime);
  }

  _clearFilters() {
    setState(() {
      selectedDevice = 'ทั้งหมด';
      startDate = null;
      startTime = null;
      endDate = null;
      endTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // DateTime? startDateTime = mergeDateAndTime(startDate, startTime);
    // DateTime? endDateTime = mergeDateAndTime(endDate, endTime);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          children: [
            Text(
              "ข้อมูลย้อนหลัง",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(width: 40),
            DropdownButton<String>(
              value: selectedDevice,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              dropdownColor: Colors.teal,
              underline: SizedBox(),
              onChanged: (value) {
                setState(() {
                  selectedDevice = value!;
                });
              },
              items: deviceIds.map((String id) {
                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(
                    id,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              onPressed: _clearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.refresh, color: Colors.teal, size: 18),
              label: const Text("Clear", style: TextStyle(color: Colors.teal)),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.teal[200],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilterChip(
                  label: Text(startDate == null
                      ? "เลือกวันเริ่มต้น"
                      : DateFormat('dd-MM-yyyy').format(startDate!)),
                  onSelected: (_) async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => startDate = picked);
                  },
                ),
                FilterChip(
                  label: Text(endDate == null
                      ? "เลือกวันสิ้นสุด"
                      : DateFormat('dd-MM-yyyy').format(endDate!)),
                  onSelected: (_) async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => endDate = picked);
                  },
                ),
                FilterChip(
                  label: Text(startTime == null
                      ? "เวลาเริ่ม"
                      : startTime!.format(context)),
                  onSelected: (_) async {
                    if (startDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("กรุณาเลือกวันก่อนเลือกเวลา")),
                      );
                      return;
                    }
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: startTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) setState(() => startTime = picked);
                  },
                ),
                FilterChip(
                  label: Text(endTime == null
                      ? "เวลาสิ้นสุด"
                      : endTime!.format(context)),
                  onSelected: (_) async {
                    if (startDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("กรุณาเลือกวันก่อนเลือกเวลา")),
                      );
                      return;
                    }
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: endTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) setState(() => endTime = picked);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(child: Text("ไม่มีข้อมูลย้อนหลัง"));
                } else {
                  List filteredData = snapshot.data!.where((item) {
                    DateTime itemTime =
                        DateTime.parse(item['timestamp']).toLocal();

                    // เช็ก device ก่อน
                    if (selectedDevice != 'ทั้งหมด' &&
                        item['device_id'] != selectedDevice) {
                      return false;
                    }

                    // ถ้าเลือกเวลา ต้องเลือกวันด้วย
                    if ((startTime != null || endTime != null) &&
                        (startDate == null || endDate == null)) {
                      return false;
                    }

                    // เช็กช่วงวันที่
                    if (startDate != null &&
                        itemTime.isBefore(DateTime(startDate!.year,
                            startDate!.month, startDate!.day))) {
                      return false;
                    }
                    if (endDate != null &&
                        itemTime.isAfter(DateTime(endDate!.year, endDate!.month,
                            endDate!.day, 23, 59, 59))) {
                      return false;
                    }

                    // เช็กช่วงเวลา (เช็กเฉพาะเวลา ไม่สนวันที่)
                    if (startTime != null && endTime != null) {
                      TimeOfDay itemTod = TimeOfDay(
                          hour: itemTime.hour, minute: itemTime.minute);

                      // เปลี่ยน startTime, endTime เป็นนาทีเพื่อเทียบง่ายๆ
                      int itemMinutes = itemTod.hour * 60 + itemTod.minute;
                      int startMinutes =
                          startTime!.hour * 60 + startTime!.minute;
                      int endMinutes = endTime!.hour * 60 + endTime!.minute;

                      if (itemMinutes < startMinutes ||
                          itemMinutes > endMinutes) {
                        return false;
                      }
                    }

                    return true;
                  }).toList();

                  if (filteredData.isEmpty) {
                    return const Center(child: Text("ไม่พบข้อมูลตามตัวกรอง"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      var data = filteredData[index];
                      return Card(
                        color: Colors.teal[50],
                        elevation: 3,
                        margin: EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "🕒 เวลา: ${formatTimestamp(data['timestamp'])}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.thermostat, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text("อุณหภูมิ: ${data['temperature']} °C",
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.cloud, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text("PM2.5: ${data['pm2_5']} µg/m³",
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.water_drop,
                                      color: Colors.blueAccent),
                                  SizedBox(width: 8),
                                  Text("ความชื้น: ${data['humidity']} %",
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.device_hub, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text("อุปกรณ์: ${data['device_id']}",
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
