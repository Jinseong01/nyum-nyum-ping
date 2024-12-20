import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed; // 버튼 클릭 시 실행될 함수
  final String title;

  const LoginButton({
    super.key,
    required this.onPressed,
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(
            horizontal: 25, vertical: 12), // 버튼 크기
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // 버튼 테두리 둥글게
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
