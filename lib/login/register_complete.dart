import 'package:flutter/material.dart';
import 'package:nyum_nyum_ping/login/LoginScreen.dart';
import 'package:nyum_nyum_ping/login/RegisterScreen.dart';
import 'package:nyum_nyum_ping/login/widgets/LoginButton.dart';

class RegisterComplete extends StatefulWidget {
  const RegisterComplete({super.key});

  @override
  State<RegisterComplete> createState() => _RegisterCompleteState();
}

class _RegisterCompleteState extends State<RegisterComplete> {
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
                  'assets/images/login/register.png',
                  width: 150,
                  height: 150,
                ),
                SizedBox(
                  height: 12,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "회원가입\n",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '완료',
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
                  height: 200,
                ),
                LoginButton(
                    title: "로그인하기",
                    onPressed: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context)=>LoginScreen(),
                          )
                      );
                    }
                ),
              ],
            ),
          )),
    );
  }
}

