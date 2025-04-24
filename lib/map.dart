// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;

// class MapPage extends StatefulWidget {
//   const MapPage({super.key});

//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   final String apiUrl = "https://api-project-csc452-uxaa.vercel.app/airquality";
//   late GoogleMapController mapController;
//   Set<Marker> markers = {};

//   Future<void> fetchDeviceLocations() async {
//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       if (response.statusCode == 200) {
//         List<dynamic> data = jsonDecode(response.body);

//         // ล้าง Marker ก่อนเพื่ออัปเดต
//         markers.clear();

//         for (var device in data) {
//           // double latitude = device['latitude'];
//           // double longitude = device['longitude'];
//           double latitude = 100.523186; // ค่าเริ่มต้น (กรุงเทพ)
//           double longitude = 13.736717; // ค่าเริ่มต้น (กรุงเทพ)
//           String deviceId = device['device_id'];

//           markers.add(
//             Marker(
//               markerId: MarkerId(deviceId),
//               position: LatLng(latitude, longitude),
//               infoWindow: InfoWindow(
//                 title: "อุปกรณ์: $deviceId",
//                 snippet: "PM2.5: ${device['pm2_5']} µg/m³",
//               ),
//             ),
//           );
//         }

//         setState(() {}); // อัปเดต UI
//       } else {
//         throw Exception("Failed to load device locations");
//       }
//     } catch (e) {
//       print("Error fetching locations: $e");
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchDeviceLocations();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("แผนที่อุปกรณ์")),
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: LatLng(13.736717, 100.523186), // ค่าเริ่มต้น (กรุงเทพ)
//           zoom: 10,
//         ),
//         markers: markers,
//         onMapCreated: (GoogleMapController controller) {
//           mapController = controller;
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: fetchDeviceLocations, // รีเฟรชตำแหน่งอุปกรณ์
//         child: Icon(Icons.refresh),
//       ),
//     );
//   }
// }