import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordChangePage extends StatefulWidget {
  const PasswordChangePage({super.key});

  @override
  State<PasswordChangePage> createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _newPasswordController = TextEditingController();
  String? _errorMessage;

  // 비밀번호 규칙 검증 함수
  bool isPasswordValid(String password) {
    final hasMinLength = password.length >= 8;
    final hasLetters = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(password);
    return hasMinLength && hasLetters && hasNumbers;
  }

  // 비밀번호 변경 로직
  Future<void> updatePassword() async {
    final newPassword = _newPasswordController.text.trim();

    if (!isPasswordValid(newPassword)) {
      setState(() {
        _errorMessage = "비밀번호는 8자리 이상, 영문과 숫자를 포함해야 합니다.";
      });
      return;
    }

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // 새 비밀번호 업데이트
        await user.updatePassword(newPassword);
        setState(() {
          _errorMessage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("비밀번호가 성공적으로 변경되었습니다.")),
        );
        Navigator.pop(context); // 이전 페이지로 돌아가기
      }
    } catch (e) {
      print("비밀번호 변경 오류: $e");
      setState(() {
        _errorMessage = "비밀번호 변경 중 오류가 발생했습니다.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 현재 비밀번호
                  const Text(
                    "현재 비밀번호",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[400], // 배경색 설정
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: TextEditingController(text: "********"),
                      readOnly: true, // 읽기 전용
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey, // 글자색 설정
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  // 새로운 비밀번호
                  const Text(
                    "새로운 비밀번호",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "영어+숫자 8글자 이상",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  // 오류 메시지
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  const SizedBox(height: 20),
                  // 변경 버튼
                  Center(
                    child: ElevatedButton(
                      onPressed: updatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "변경",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
