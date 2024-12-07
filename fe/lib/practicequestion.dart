import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:doan_flutter/apputil.dart';
import 'package:doan_flutter/testpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Cau.dart';
import 'Chuong.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';

import 'Hang.dart';
import 'SelectQuestionDialog.dart';
import 'choosetype.dart';

class PracticeQuestionState extends State<PracticeQuestion> {
  int _total = 0;
  int _received = 0;
  late http.StreamedResponse _response;
  final List<int> _bytes = [];

  List<Cau> questions = [];
  List<int> choosequestion = [];
  int? selectedHang;
  int currentQuestionIndex = 0; // Index of the current question being displayed
  bool autoNext = false;
  int wrongQuestion = 0;
  List<Chuong> dsChuong = [];
  @override
  initState() {
    super.initState();
    checkSelectedHang();
  }

  Future<void> showQuestionListDialog() async {
    int? selectedQuestion;
    int idChuong = 0;
    await showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn câu hỏi'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.9,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(8.0), // Add padding here
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: List.generate(questions.length, (index) {
                  if (questions[index].idChuong != idChuong) {
                    idChuong = questions[index].idChuong;
                    final chuong = dsChuong.firstWhere((chuong) =>
                        chuong.idChuong == questions[index].idChuong);
                    return Align(
                        child: Column(
                      children: [
                        const Divider(color: Colors.black),
                        Text(chuong.thongTinChuong,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ));
                  }
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        alignment: Alignment.center,
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>((states) {
                          // Kiểm tra xem câu hỏi có được chọn hay không
                          if (choosequestion[index] != -1) {
                            // Nếu câu hỏi đã được chọn, trả về màu xanh
                            return Colors.blue;
                          } else {
                            // Nếu câu hỏi chưa được chọn, trả về màu trong suốt
                            return Colors.transparent;
                          }
                        }),
                      ),
                      onPressed: () {
                        setState(() {
                          currentQuestionIndex = index;
                          Navigator.of(context).pop();
                        });
                      },
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 18,
                          color: choosequestion[index] != -1
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
          ],
        );
      },
      animationType: DialogTransitionType.fade,
      curve: Curves.easeIn,
      duration: Duration(milliseconds: 400),
    );
    // Hiển thị câu hỏi đã chọn
  }

  Future<void> checkSelectedHang() async {
    final prefs = await SharedPreferences.getInstance();
    final hangString = prefs.getString('HANG') ?? "";

    final selectedHangId = Hang.fromJson(jsonDecode(hangString)).idHang ?? -1;
    List<Chuong> lsChuong = await AppUtil.fetchChuongs();

    setState(() {
      dsChuong = lsChuong;
      selectedHang = selectedHangId;
    });
    if (selectedHangId != -1) {
      await fetchQuestions(selectedHangId);
      final listChooses = prefs.getString('CHOOSES');
      if (listChooses == null) {
        choosequestion = List<int>.filled(questions.length, -1);
        prefs.setString("CHOOSES", jsonEncode(choosequestion));
      } else {
        final List<dynamic> decodedList = jsonDecode(listChooses);
        choosequestion = decodedList.map<int>((item) => item as int).toList();
      }
    }
  }

  void nextQuestion() {
    setState(() {
      currentQuestionIndex = (currentQuestionIndex + 1) % questions.length;
    });
  }

  void previousQuestion() {
    setState(() {
      currentQuestionIndex =
          (currentQuestionIndex - 1 + questions.length) % questions.length;
    });
  }

  Future<void> fetchQuestions(int id) async {
    List<Cau> list = await loadFileQuestions(id);
    setState(() {
      questions = list;
      currentQuestionIndex = 0;
    });
  }

  Future<List<Cau>> loadFileQuestions(int id) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/dataquestion.json';
    if (await AppUtil.fileExist(path: filePath)) {
      print("LOCAL");
      String jsonString = await File(filePath).readAsString();
      List<dynamic> jsonResponse = json.decode(jsonString);
      List<Cau> dscau = jsonResponse.map((e) => Cau.fromJson(e)).toList();
      print(dscau.length);
      return dscau;
    } else {
      print("NETWORK");
      await fetchQuestion();
    }
    return <Cau>[];
  }

  Future<void> fetchQuestion() async {
    _response = await http.Client().send(http.Request(
        'POST', Uri.parse('${AppUtil.localhost}/api/Cauhoi/$selectedHang')));
    final response = await http.post(
        Uri.parse('${AppUtil.localhost}/api/Cauhoi/length?id=$selectedHang'));
    if (response.statusCode == 200) {
      print(response.body);
      _total = int.parse(response.body);
    }

    _response.stream.listen((value) {
      setState(() {
        _bytes.addAll(value);
        _received += value.length;
        print('${_received / 1024} / ${_total / 1024}');
      });
    }).onDone(() async {
      final file = File(
          '${(await getApplicationDocumentsDirectory()).path}/${AppUtil.getPath()}');
      await file.writeAsBytes(_bytes);
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        Iterable list = jsonDecode(utf8.decode(_bytes));
        questions = list.map((e) => Cau.fromJson(e)).toList();
        choosequestion = List<int>.filled(questions.length, -1);
        prefs.setString("CHOOSES", jsonEncode(choosequestion));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: (questions.isEmpty
          ? FloatingActionButton.extended(
              label: Text('${_received ~/ 1024}/${_total ~/ 1024} KB'),
              icon: const Icon(Icons.file_download),
              onPressed: () {},
            )
          : null),
      appBar: AppBar(
        title: Text('Lý thuyết'),
        actions: [
          TextButton.icon(
              icon: Icon(Icons.next_plan),
              label: autoNext ? Text("Bật") : Text("Tắt"),
              onPressed: () {
                setState(() {
                  autoNext = !autoNext;
                });
              }),
        ],
      ),
      body: questions.isEmpty
          ? const Center(
              child: Text(
                'Dữ liệu đang được tải trong vòng vài phút \n Vui lòng kết nối internet',
                style: TextStyle(fontSize: 18),
              ), // Include _received here
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        //onPressed: showQuestionListDialog,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return MyQuestionListDialog(
                                questions: questions,
                                choosequestion: choosequestion,
                                dsChuong: dsChuong,
                                onQuestionSelected: (index) {
                                  setState(() {
                                    currentQuestionIndex = index;
                                  });
                                },
                              );
                            },
                          );
                        },
                        child: Text(
                            'Danh sách câu hỏi'), // Thêm nút hiển thị danh sách câu hỏi
                      ),
                      const SizedBox(
                        width: 20,
                        height: 20,
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('Tự động chuyển câu hỏi'),
                          const SizedBox(
                            width: 5,
                          ),
                          Switch(
                            value: autoNext,
                            onChanged: (value) {
                              setState(() {
                                autoNext = value;
                              });
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            currentQuestionIndex =
                                (currentQuestionIndex - 1) % questions.length;
                          });
                        },
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Colors.blue), // Màu chữ của nút
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.hovered)) {
                                return Colors.blue
                                    .withOpacity(0.2); // Màu nền khi hover
                              }
                              return Colors.blue;
                            },
                          ),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              // Độ cong của góc nút
                              side: BorderSide(
                                  color: Colors.blue), // Viền của nút
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          // Padding cho chữ trong nút
                          child: Text('Prev Question'),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(10)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            currentQuestionIndex =
                                (currentQuestionIndex + 1) % questions.length;
                          });
                        },
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Colors.blue), // Màu chữ của nút
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.hovered)) {
                                return Colors.blue
                                    .withOpacity(0.2); // Màu nền khi hover
                              }
                              return Colors.blue;
                            },
                          ),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              // Độ cong của góc nút
                              side: const BorderSide(
                                  color: Colors.blue), // Viền của nút
                            ),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          // Padding cho chữ trong nút
                          child: Text('Next Question'),
                        ),
                      ),
                    ],
                  ),
                  // Display the question text
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      questions.isNotEmpty
                          ? "Câu " +
                              (currentQuestionIndex + 1).toString() +
                              ": " +
                              questions[currentQuestionIndex].ttcaus.cauhoi
                          : '',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: questions[currentQuestionIndex].ttcaus.diemliet
                              ? Colors.red
                              : Colors.black),
                    ),
                  ),
                  // Display the question image, if available,
                  if (questions.isNotEmpty &&
                      questions[currentQuestionIndex]
                          .ttcaus
                          .hinhcauhoi
                          .isNotEmpty)
                    Image.memory(
                      base64Decode(
                          questions[currentQuestionIndex].ttcaus.hinhcauhoi),
                      width: 400, // Set the desired width
                      height: 400, // Set the desired height
                    ),
                  if (choosequestion[currentQuestionIndex] != -1 &&
                      questions[currentQuestionIndex].ttcaus.goiy != "")
                    SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.9, // Giới hạn chiều rộng của Container
                      child: Center(
                        child: Text(
                          "Gợi ý: " +
                              questions[currentQuestionIndex].ttcaus.goiy,
                          textAlign: TextAlign.center, // Căn giữa văn bản
                        ),
                      ),
                    ),
                  // Display options (answers)
                  if (questions.isNotEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: questions[currentQuestionIndex]
                            .dapans
                            .map((dapan) => GestureDetector(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    // Chiếm 90% chiều ngang
                                    margin: EdgeInsets.symmetric(vertical: 5.0),
                                    padding: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: choosequestion[
                                                  currentQuestionIndex] !=
                                              -1
                                          ? (choosequestion[currentQuestionIndex] ==
                                                          dapan.iddapan &&
                                                      dapan.dapandung == true ||
                                                  dapan.dapandung == true
                                              ? Colors.blue
                                              : (choosequestion[
                                                          currentQuestionIndex] ==
                                                      dapan.iddapan
                                                  ? Colors.red
                                                  : Colors.black54))
                                          : Colors.black54,
                                      border: Border.all(
                                        color: choosequestion[
                                                    currentQuestionIndex] !=
                                                -1
                                            ? (choosequestion[currentQuestionIndex] ==
                                                            dapan.iddapan &&
                                                        dapan.dapandung ==
                                                            true ||
                                                    dapan.dapandung == true
                                                ? Colors.blue
                                                : (choosequestion[
                                                            currentQuestionIndex] ==
                                                        dapan.iddapan
                                                    ? Colors.red
                                                    : Colors.grey))
                                            : Colors.grey,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Text(
                                      dapan.dapan1,
                                      style: const TextStyle(
                                          fontSize: 18.0, color: Colors.white),
                                    ),
                                  ),
                                  onTap: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    setState(() {
                                      choosequestion[currentQuestionIndex] =
                                          dapan.iddapan;
                                      prefs.setString("CHOOSES",
                                          jsonEncode(choosequestion));
                                      if (autoNext) {
                                        nextQuestion();
                                      }
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  SizedBox(
                    height: 100,
                  )
                  // Button to navigate to the next question
                ],
              ),
            ),
    );
  }
}

class PracticeQuestion extends StatefulWidget {
  const PracticeQuestion({super.key});

  @override
  PracticeQuestionState createState() => PracticeQuestionState();
}
