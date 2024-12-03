import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nyum_nyum_ping/firebase/AuthService.dart';
import 'package:nyum_nyum_ping/login/FirstScreen.dart';
import 'package:nyum_nyum_ping/login/widgets/CommonDialog.dart';
import 'package:nyum_nyum_ping/login/widgets/LoginButton.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'LoginScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Firebase Authentication 인스턴스
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();


  void _showDialog(String content) {
    showDialog(
      context: context,
      builder: (context) {
        return CommonDialog(
          title: "",
          content: content,
          onConfirm: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
        );
      },
    );
  }

  // 이메일 중복 체크
  Future<void> _checkEmailDuplicate() async {
    try {
      final querySnapshot = await _firestore
          .collection('User')
          .where('email', isEqualTo: _emailController.text.trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _showDialog("중복된 이메일입니다.");
      } else {
        _showDialog("사용 가능한 이메일입니다.");
      }
    } catch (e) {
      print("이메일 중복 체크 오류: $e");
    }
  }

  // 닉네임 중복 체크
  Future<void> _checkNicknameDuplicate() async {
    try {
      final querySnapshot = await _firestore
          .collection('User')
          .where('nickname', isEqualTo: _nicknameController.text.trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _showDialog("중복된 닉네임입니다.");
      } else {
        _showDialog("사용 가능한 닉네임입니다.");
      }
    } catch (e) {
      print("닉네임 중복 체크 오류: $e");
    }
  }

  // 사용자 생성 함수
  Future<void> _registerUser() async {
    try {
      // Firebase Auth 사용자 생성
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Firestore에 사용자 정보 저장
      await _firestore.collection('User').doc(userCredential.user?.email).set({
        'email': _emailController.text.trim(),
        'name': _nameController.text.trim(),
        'nickname': _nicknameController.text.trim()
      });

      // 성공 메시지 출력
      print("회원가입 및 Firestore 저장 성공: ${userCredential.user?.email}");


      // 회원가입 성공 시 로그인 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FirstScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // 에러 처리
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = '이미 사용 중인 이메일입니다.';
      } else if (e.code == 'weak-password') {
        errorMessage = '비밀번호가 너무 약합니다.';
      } else {
        errorMessage = '회원가입 중 오류가 발생했습니다.';
      }

      // 에러 다이얼로그 표시
      showDialog(
        context: context,
        builder: (context) => CommonDialog(
          title: '회원가입 실패',
          content: errorMessage,
          onConfirm: () => Navigator.of(context).pop(),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 이전 화면으로 돌아가기
          },
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 16,
              ),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "냠냠핑\n",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '사용이 처음이신가요?',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 28,
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이메일 필드
                    Text(" E-MAIL"),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: '이메일을 입력해주세요.',
                              hintText: '이메일을 입력해주세요',
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '이메일을 입력하지 않았습니다';
                              }
                              // 이메일 형식 정규식
                              final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                              if (!emailRegex.hasMatch(value)) {
                                return '이메일 양식이 맞지 않습니다';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        ElevatedButton(
                          onPressed: _checkEmailDuplicate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrangeAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "중복 체크",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 32,
                    ),
          
                    // 비밀번호
                    Text(" PW"),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isPasswordVisible,
                      decoration: InputDecoration(
                          labelText: '비밀번호를 입력해주세요.',
                          hintText: '비밀번호를 입력해주세요',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Icon(_isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력하지 않았습니다.';
                        }
                        // 영어+숫자+8글자 이상 검사
                        final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
                        if (!passwordRegex.hasMatch(value)) {
                          return '비밀번호는 영어와 숫자를 포함해 8글자 이상이어야 합니다.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 32,
                    ),
          
                    // 이름
                    Text(" 이름"),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '이름을 입력해주세요.',
                        hintText: '이름을 입력해주세요',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이름을 입력하지 않았습니다';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 32,
                    ),
          
                    // 닉네임
                    Text(" 닉네임"),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nicknameController,
                            decoration: InputDecoration(
                              labelText: '닉네임을 입력해주세요.',
                              hintText: '닉네임을 입력해주세요',
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '닉네임을 입력하지 않았습니다';
                              }
                              if (value.length > 10) {
                                return '닉네임은 10자 이내로 입력해주세요.';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        ElevatedButton(
                          onPressed: _checkNicknameDuplicate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrangeAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "중복 체크",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
          
                    // 로그인 버튼
                    SizedBox(
                      height: 60,
                    ),
                    Center(
                      child: LoginButton(
                        title: "회원가입",
                          onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _registerUser();
                        } else {
                          _showDialog("회원가입에 실패하였습니다");
                        }
                      }),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}
