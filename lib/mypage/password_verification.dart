import 'package:flutter/material.dart';
import 'package:nyum_nyum_ping/firebase/AuthService.dart'; // AuthService import

class PasswordVerificationPage extends StatefulWidget {
  final VoidCallback onVerified;

  const PasswordVerificationPage({super.key, required this.onVerified});

  @override
  State<PasswordVerificationPage> createState() =>
      _PasswordVerificationPageState();
}

class _PasswordVerificationPageState extends State<PasswordVerificationPage> {
  final AuthService _authService = AuthService(); // AuthService 인스턴스 생성
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true; // 비밀번호 숨김 여부
  String? _errorMessage; // 오류 메시지

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context); // 뒤로가기 버튼 동작
              },
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
          ),
          const SizedBox(height: 70), // AppBar 아래 여백
          const Text(
            "비밀번호 입력",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 100), // "비밀번호 입력" 아래 여백
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: "비밀번호를 입력해주세요",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText; // 비밀번호 표시 토글
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 오류 메시지 출력 영역
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      final inputPassword = _passwordController.text;
              
                      // AuthService를 통해 비밀번호 검증
                      bool isVerified =
                          await _authService.verifyPassword(inputPassword);
                      if (isVerified) {
                        widget.onVerified(); // 검증 성공 시 콜백 실행
                      } else {
                        setState(() {
                          _errorMessage = "비밀번호가 일치하지 않습니다.";
                        });
                      }
                    },
                    child: const Text(
                      "확인",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
