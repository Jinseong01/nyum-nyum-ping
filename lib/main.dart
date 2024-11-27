import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase/AuthService.dart';
import 'login/FirstScreen.dart';
import 'package:nyum_nyum_ping/HomeScreen.dart';
import 'firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 테스트 계정으로 강제 로그인
  final AuthService authService = AuthService();
  await authService.signInWithTestAccount();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return const MaterialApp(
      title: "nyum nyum ping",

      home: 
      Homescreen(),
    );
  }
}
