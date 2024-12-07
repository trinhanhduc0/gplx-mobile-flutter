import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:doan_flutter/ParalysisQuestionPage.dart';
import 'package:doan_flutter/practicequestion.dart';
import 'package:doan_flutter/testpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Hang.dart';
import 'choosetype.dart';
import 'Hang.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        '/chooseType': (context) => ChooseType(),
        '/practiceQuestion': (context) => PracticeQuestion(),
        '/testPage': (context) => TestPage(),
        '/paralysisquestion': (context) => ParalysisQuestion(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SharedPreferences prefs;
  Hang hang = Hang(
      idHang: -1,
      thongTin: "",
      thongTinChiTiet: "",
      diemToiDa: 0,
      diemToiTheu: 0,
      thoiGianThi: 0);

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  void initPrefs() async {
    final hangType = await getType();
    setState(() {
      hang = hangType;
    });
  }

  Future<Hang> getType() async {
    final prefs = await SharedPreferences.getInstance();
    final hangString = prefs.getString("HANG");
    if (hangString == null)
      return const Hang(
          idHang: -1,
          thongTin: "",
          thongTinChiTiet: "thongTinChiTiet",
          diemToiDa: 0,
          diemToiTheu: 0,
          thoiGianThi: 0);

    return Hang.fromJson(jsonDecode(hangString));
  }

  void navigateToChooseType() {
    Navigator.pop(context); // Close the drawer
    Navigator.pushNamed(context, '/chooseType');
  }

  void navigateToPracticeQuestion() {
    Navigator.pop(context); // Close the drawer
    Navigator.pushNamed(context, '/practiceQuestion');
  }

  void navigateToTestPage() {
    Navigator.pop(context); // Close the drawer
    Navigator.pushNamed(context, '/testPage');
  }

  void navigateToParalysisQuestionPage() {
    Navigator.pop(context); // Close the drawer
    Navigator.pushNamed(context, '/paralysisquestion');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.blue,
      ),
      drawer: NavigationDrawer(
        type: hang,
        onChooseTypeTap: navigateToChooseType,
        onPracticeQuestionTap: navigateToPracticeQuestion,
        onTestPageTap: navigateToTestPage,
        onParalysisQuestionTap: navigateToParalysisQuestionPage,
      ),
      body: hang.idHang != -1
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hạng: ${hang.thongTin}",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Thông tin chi tiết:",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    hang.thongTinChiTiet,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Số câu",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "${hang.diemToiTheu.toString()}/${hang.diemToiDa}",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Thời gian thi:",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "${hang.thoiGianThi} phút",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            )
          : (Center(
              child: Text(
                "Chưa chọn hạng",
                style: TextStyle(fontSize: 30),
              ),
            )),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  final VoidCallback onChooseTypeTap;
  final VoidCallback onPracticeQuestionTap;
  final VoidCallback onTestPageTap;
  final VoidCallback onParalysisQuestionTap;
  final Hang type;

  const NavigationDrawer(
      {super.key,
      required this.type,
      required this.onChooseTypeTap,
      required this.onPracticeQuestionTap,
      required this.onTestPageTap,
      required this.onParalysisQuestionTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const ListTile(
            title: Text("GIẤY PHÉP LÁI XE"),
          ),
          ListTile(
            title: Text('Chọn hạng: ' + type.thongTin),
            onTap: onChooseTypeTap,
          ),
          if (type.idHang != -1) ...[
            ListTile(
              title: const Text('Học lý thuyết'),
              onTap: onPracticeQuestionTap,
            ),
            ListTile(
              title: const Text('Thi thử'),
              onTap: onTestPageTap,
            ),
            ListTile(
              title: const Text('Câu điểm liệt'),
              onTap: onParalysisQuestionTap,
            ),
          ],
        ],
      ),
    );
  }
}
