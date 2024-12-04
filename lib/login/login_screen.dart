import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nyum_nyum_ping/HomeScreen.dart';
import 'package:nyum_nyum_ping/login/widgets/common_dialog.dart';
import 'package:nyum_nyum_ping/login/widgets/login_button.dart';
import 'package:nyum_nyum_ping/main/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible=true;
  final _formKey=GlobalKey<FormState>();
  final TextEditingController _emailController= TextEditingController();
  final TextEditingController _passwordController=TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return CommonDialog(
          title: "",
          content: message,
          onConfirm: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
        );
      },
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      try {
        // Firebase Authentication으로 로그인
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // 로그인 성공 시
        print("로그인 성공: ${userCredential.user?.email}");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Homescreen()),
              (Route<dynamic> route) => false,
        );
      } catch (e) {
        // FirebaseAuthException 처리
        String errorMessage = '로그인에 실패했습니다.';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              errorMessage = '등록되지 않은 이메일입니다.';
              break;
            case 'wrong-password':
              errorMessage = '비밀번호가 올바르지 않습니다.';
              break;
            case 'invalid-email':
              errorMessage = '유효하지 않은 이메일 형식입니다.';
              break;
            case 'network-request-failed':
              errorMessage = '네트워크 연결 상태를 확인해주세요.';
              break;
            default:
              errorMessage = e.message ?? errorMessage;
          }
        }
        _showErrorDialog("입력 정보가 잘못되었습니다.");
      }
    } else {
      _showErrorDialog("입력 정보가 잘못되었습니다");
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
            crossAxisAlignment: CrossAxisAlignment.start  ,
            children: [
              // 냠냠핑 사용해보셨나요?
              SizedBox(height: 16,),
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
                        text: '사용해보셨나요?',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
              ),
              SizedBox(height: 28,),
              Form(
                key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(" E-MAIL"),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: '이메일을 입력해주세요.',
                          hintText: '이메일을 입력해주세요',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이메일을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 48,),
          
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
                              onPressed: (){
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off
                              )
                          )
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력해주세요';
                          }
                          return null;
                        },
                      ),
          
                      // 로그인 버튼
                      SizedBox(height: 284,),
                      Center(
                        child: LoginButton(
                          title: "로그인",
                            onPressed: _login,
                        ),
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
