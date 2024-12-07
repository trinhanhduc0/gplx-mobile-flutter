import 'dart:convert';

import 'package:doan_flutter/apputil.dart';
import 'package:doan_flutter/main.dart';
import 'package:doan_flutter/practicequestion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Hang.dart'; // Import for making API requests (if needed)

// Assuming you have a function to fetch Hang data (replace with your actual logic)
Future<List<Hang>> fetchHangs() async {
  final response = await AppUtil.fetchHangs();
  return response;
}

class ChooseType extends StatelessWidget {
  const ChooseType({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn hạng"),
      ),
      body: FutureBuilder<List<Hang>>(
        future: fetchHangs(), // Call your data fetching function
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final hangs = snapshot.data!;
            return ListView.builder(
              itemCount: hangs.length,
              itemBuilder: (context, index) {
                final hang = hangs[index];
                return HangCard(
                  hang: hang,
                  onTap: () =>
                      navigateToHangDetails(context, hang), // Handle tap
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // Display a loading indicator while data is being fetched
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class HangCard extends StatelessWidget {
  final Hang hang;
  final VoidCallback onTap;

  const HangCard({super.key, required this.hang, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showConfirmationDialog(
          context, hang.thongTin), // Show confirmation dialog when tapped
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hang.thongTin, // Display the relevant field for "rank" or "hạng"
                style: const TextStyle(
                    fontSize: 25.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                hang.thongTinChiTiet,
                style: TextStyle(fontSize: 20),
              ), // Display additional details if needed
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String hang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Bạn có chắc chắn muốn chọn hạng $hang không?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onTap();
            },
            child: const Text('Có'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Không'),
          ),
        ],
      ),
    );
  }
}

void navigateToHangDetails(BuildContext context, Hang hang) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String data = prefs.getString("HANG") ?? "";
  final Hang h;
  if (data != "") {
    h = Hang.fromJson(jsonDecode(data));
  } else {
    h = Hang(
        idHang: -1,
        thongTin: "thongTin",
        thongTinChiTiet: "thongTinChiTiet",
        diemToiDa: 0,
        diemToiTheu: 0,
        thoiGianThi: 0);
  }
  if (hang.idHang != h.idHang) {
    await prefs.setString("HANG", jsonEncode(hang.toJson()));
    AppUtil.deleteFileQuestions();
    prefs.remove("CHOOSES");
  }
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const MyHomePage(title: "GPLX")),
    (Route<dynamic> route) => false, // Remove all remaining routes
  );
}

// ... rest of your code (including Hang class definition)
