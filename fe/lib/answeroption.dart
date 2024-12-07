import 'package:flutter/material.dart';

class AnswerOption extends StatelessWidget {
  final bool isChosen;
  final bool isCorrect;
  final String answer;
  final VoidCallback onTap;

  const AnswerOption({
    required this.isChosen,
    required this.isCorrect,
    required this.answer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        margin: EdgeInsets.symmetric(vertical: 5.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isChosen
              ? (isCorrect ? Colors.blue : Colors.red)
              : Colors.black54,
          border: Border.all(
            color:
                isChosen ? (isCorrect ? Colors.blue : Colors.red) : Colors.grey,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Text(
          answer,
          style: const TextStyle(fontSize: 18.0, color: Colors.white),
        ),
      ),
    );
  }
}
