import 'package:flutter/material.dart';
import 'package:nyum_nyum_ping/login/LoginScreen.dart';
import 'package:nyum_nyum_ping/login/widgets/LoginButton.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 130,),
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ),
            SizedBox(
              height: 20,
            ),
            const Text(
              '냠냠핑', // 환영 메시지
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w200,
                  color: Colors.blue),
            ),
            SizedBox(
              height: 200,
            ),
            LoginButton(
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context)=>LoginScreen(),
                      )
                  );
                }
            ),
            TextButton(
              onPressed: () {
                // 회원가입 로직 추가
                print('회원가입 클릭됨');
              },
              child: const Text(
                '회원가입하기',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey, // 텍스트 색상 회색으로 설정
                  decoration: TextDecoration.underline, // 밑줄 추가
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}