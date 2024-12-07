import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:doan_flutter/Cau.dart';
import 'package:path_provider/path_provider.dart';
import 'Chuong.dart';
import 'Hang.dart';
import 'package:http/http.dart' as http;

class AppUtil {
  static String localhost = "https://10.0.2.2:7054";
  static const String _path = "dataquestion.json";
// Hàm để ghi dữ liệu vào tệp JSON trong bộ nhớ cục bộ
  static Future<void> writeToFile(String jsonString) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/dataquestion.json');
    await file.writeAsString(jsonString);
  }

  static String getPath() {
    return _path;
  }

  static String getHost() {
    return localhost;
  }

  static Future<void> deleteFileQuestions() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$_path';
    if (await fileExist(path: filePath)) {
      File(filePath).deleteSync();
    }
  }

  static Future<bool> fileExist({String path = _path}) async {
    bool fileExists = await File(path).exists();
    return fileExists;
  }

  static Future<List<Hang>> fetchHangs() async {
    final response = await http.get(Uri.parse('$localhost/api/Cauhoi/hang'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Hang.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Hangs');
    }
  }

  static Future<List<Chuong>> fetchChuongs() async {
    final response = await http.get(Uri.parse('$localhost/api/Cauhoi/chuong'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Chuong.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Hangs');
    }
  }

  static Future<List<Cau>> getTest(int id) async {
    final response =
        await http.get(Uri.parse("$localhost/api/Cauhoi/thi?id=$id"));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Cau.fromJson(json)).toList();
    }
    return <Cau>[];
  }

  static loadTest(int id) {}
}
