import 'package:flutter/material.dart';
import 'package:nyum_nyum_ping/login/widgets/CommonDialog.dart';
import 'package:nyum_nyum_ping/login/widgets/LoginButton.dart';

import 'LoginScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isPasswordVisible=false;
  final _formKey=GlobalKey<FormState>();
  final TextEditingController _emailController= TextEditingController();
  final TextEditingController _passwordController=TextEditingController();
  final TextEditingController _nameController= TextEditingController();
  final TextEditingController _nicknameController=TextEditingController();

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CommonDialog(
          title: "",
          content: "사용 가능한 닉네임입니다.",
          onConfirm: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
        );
      },
    );
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                SizedBox(height: 28,),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이메일 필드
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
                      SizedBox(height: 32,),

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
                      SizedBox(height: 32,),

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
                            return '이름을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 32,),

                      // 닉네임
                      Text(" 닉네임"),
                      TextFormField(
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
                            return '닉네임을 입력해주세요';
                          }
                          return null;
                        },
                      ),

                      // 로그인 버튼
                      SizedBox(height: 150,),
                      Center(
                        child: LoginButton(
                            onPressed: (){
                              if (_formKey.currentState?.validate() ?? false) {
                                print("로그인 성공");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context)=>LoginScreen(),
                                    )
                                );
                              } else {
                                _showErrorDialog();
                              }
                            }
                        ),
                      ),


                    ],
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}
