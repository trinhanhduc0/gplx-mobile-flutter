import 'dart:async';
import 'dart:convert';
import 'package:doan_flutter/apputil.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Cau.dart';
import 'Hang.dart';

class TestPageState extends State<TestPage> {
  List<Cau> questions = [];
  List<int> choosequestion = [];
  int? selectedHang;
  int currentQuestionIndex = 0; // Index of the current question being displayed
  bool autoNext = false;
  bool endTest = false;
  int correctQuestions = 0;
  int _timerSeconds = 0;
  late Hang h;
  @override
  initState() {
    super.initState();
    checkSelectedHang();
    //startTimer();
  }

  Future<void> showQuestionListDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn câu hỏi'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(8.0), // Add padding here
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: List.generate(questions.length, (index) {
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
                      child: Text('${index + 1}'),
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
    );
    // Hiển thị câu hỏi đã chọn
  }

  Future<void> checkSelectedHang() async {
    final prefs = await SharedPreferences.getInstance();
    final hangString = prefs.getString('HANG') ?? "";
    int selectedHangId = -1; // Default value
    try {
      h = Hang.fromJson(jsonDecode(hangString));
      selectedHangId = h.idHang;
      _timerSeconds = h.thoiGianThi * 60;
    } catch (e) {
      print("Error parsing selected hang ID: $e");
    }
    List<Cau> list = await AppUtil.getTest(selectedHangId);
    setState(() {
      questions = list;
      choosequestion = List<int>.filled(questions.length, -1);
    });
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

  void getMark() {
    for (int i = 0; i < choosequestion.length; i++) {
      // Lấy danh sách các đáp án đúng của câu hỏi hiện tại
      var dapAnDung = questions[i].dapans.where((e) => e.dapandung == true);
      // Kiểm tra xem danh sách có chứa id đáp án được chọn không
      if (dapAnDung.isNotEmpty &&
          dapAnDung.first.iddapan == choosequestion[i]) {
        ++correctQuestions;
      } else if (questions[i].ttcaus.diemliet == true) {
        correctQuestions = -1;
        break;
      }
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn kết thúc bài làm không?'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                correctQuestions = 0;
                endTest = true;
                getMark();
              });
              Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPLX'),
        actions: [
          if (endTest != true)
            TextButton.icon(
                icon: const Icon(Icons.ad_units_sharp),
                label: const Text("KẾT QUẢ"),
                onPressed: () {
                  _showConfirmationDialog(context);
                }),
        ],
      ),
      body: questions.isEmpty
          ? const Center(
              child: Text(
                'Dữ liệu đang được tải. Vui lòng mở internet',
                style: TextStyle(fontSize: 18),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (endTest)
                    if (correctQuestions < 0)
                      const Text(
                        "Bạn đã làm sai câu điểm liệt",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )
                    else if (correctQuestions >= h.diemToiTheu)
                      Text(
                        "Kết quả thi: $correctQuestions/${questions.length}\nBạn đã đậu phần thi lý thuyết",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )
                    else
                      Text(
                        "Kết quả thi: ${correctQuestions}/${questions.length}\nBạn trượt phần thi lý thuyết",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),

                  if (!endTest)
                    TimerDisplay(
                      initialSeconds: _timerSeconds,
                      onTimerFinish: () {
                        setState(() {
                          endTest = true;
                          getMark();
                        });
                      },
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
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: showQuestionListDialog,
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
                          Text('Tự động chuyển câu hỏi'),
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  // Display options (answers)
                  if (questions.isNotEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: questions[currentQuestionIndex]
                            .dapans
                            .map((dapan) => GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      choosequestion[currentQuestionIndex] =
                                          dapan.iddapan;
                                      if (autoNext) {
                                        nextQuestion();
                                      }
                                    });
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    // Chiếm 90% chiều ngang
                                    margin: EdgeInsets.symmetric(vertical: 5.0),
                                    padding: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: endTest == true
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
                                                    : Colors.black))
                                            : (choosequestion[
                                                        currentQuestionIndex] ==
                                                    dapan.iddapan
                                                ? Colors.blue
                                                : Colors.black),
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Text(
                                      dapan.dapan1,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: endTest == true
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
                                                    : Colors.black))
                                            : (choosequestion[
                                                        currentQuestionIndex] ==
                                                    dapan.iddapan
                                                ? Colors.blue
                                                : Colors.black),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  // Button to navigate to the next question
                ],
              ),
            ),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  TestPageState createState() => TestPageState();
}

class TimerDisplay extends StatefulWidget {
  const TimerDisplay(
      {super.key, required this.initialSeconds, required this.onTimerFinish});

  final int initialSeconds;
  final Function() onTimerFinish;
  @override
  _TimerDisplayState createState() => _TimerDisplayState(
      timerSeconds: initialSeconds, onTimerFinish: onTimerFinish);
}

class _TimerDisplayState extends State<TimerDisplay> {
  late Timer _timer;
  int timerSeconds;
  Function() onTimerFinish;

  _TimerDisplayState({required this.timerSeconds, required this.onTimerFinish});

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void didUpdateWidget(covariant TimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSeconds != widget.initialSeconds) {
      setState(() {
        timerSeconds = widget.initialSeconds;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (timer) {
      setState(() {
        if (timerSeconds <= 0) {
          timer.cancel(); // Hủy đếm ngược khi hết thời gian
          // Gọi hàm callback khi thời gian kết thúc
          widget.onTimerFinish();
        } else {
          timerSeconds--;
        }
      });
    });
  }

  String _formatTime(int seconds) {
    // Chuyển đổi thời gian sang định dạng phút:giây
    final minutes = (seconds / 60).truncate();
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatTime(timerSeconds),
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
