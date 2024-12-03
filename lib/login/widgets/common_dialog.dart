import 'package:flutter/material.dart';

class CommonDialog extends StatelessWidget {

  final String title; // 다이얼로그 제목
  final String content; // 다이얼로그 내용
  final VoidCallback onConfirm; // 확인 버튼 눌렀을 때 동작

  const CommonDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8, // 다이얼로그 너비 설정
        child: Text(
          content,
          textAlign: TextAlign.center, // 내용 중앙 정렬
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: onConfirm, // 확인 버튼 동작 전달
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text("확인"),
        ),
      ],
    );
  }
}

