import 'package:flutter/material.dart';
import 'package:nyum_nyum_ping/login/widgets/CommonDialog.dart';
import 'package:nyum_nyum_ping/login/widgets/LoginButton.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible=false;
  final _formKey=GlobalKey<FormState>();
  final TextEditingController _emailController= TextEditingController();
  final TextEditingController _passwordController=TextEditingController();

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CommonDialog(
          title: "",
          content: "입력 정보가 잘못되었습니다.",
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
      )),
    );
  }
}
