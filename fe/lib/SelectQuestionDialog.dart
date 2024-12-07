import 'package:doan_flutter/Cau.dart';
import 'package:flutter/material.dart';

import 'Chuong.dart';
import 'apputil.dart';

class MyQuestionListDialog extends StatelessWidget {
  final List<Cau> questions;
  final List<int> choosequestion;
  final List<Chuong> dsChuong;
  final Function(int) onQuestionSelected;

  const MyQuestionListDialog({
    super.key,
    required this.questions,
    required this.choosequestion,
    required this.onQuestionSelected,
    required this.dsChuong,
  });

  @override
  Widget build(BuildContext context) {
    int idChuong = 0;

    return AlertDialog(
      title: const Text('Chọn câu hỏi'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.9,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: List.generate(questions.length, (index) {
              if (questions[index].idChuong != idChuong) {
                idChuong = questions[index].idChuong;
                final chuong = dsChuong.firstWhere(
                    (chuong) => chuong.idChuong == questions[index].idChuong);
                return Column(
                  children: [
                    Align(
                      child: Column(
                        children: [
                          const Divider(color: Colors.black),
                          Text(
                            chuong.thongTinChuong,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          alignment: Alignment.center,
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (states) {
                              if (choosequestion[index] != -1) {
                                return Colors.blue;
                              } else {
                                return Colors.transparent;
                              }
                            },
                          ),
                        ),
                        onPressed: () {
                          onQuestionSelected(index);
                          Navigator.of(context).pop();
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
                    )
                  ],
                );
              }
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                child: ElevatedButton(
                  style: ButtonStyle(
                    alignment: Alignment.center,
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) {
                        if (choosequestion[index] != -1) {
                          return Colors.blue;
                        } else {
                          return Colors.transparent;
                        }
                      },
                    ),
                  ),
                  onPressed: () {
                    onQuestionSelected(index);
                    Navigator.of(context).pop();
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
  }
}
