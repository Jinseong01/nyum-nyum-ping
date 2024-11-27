import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NicknameChangePage extends StatefulWidget {
  const NicknameChangePage({super.key});

  @override
  State<NicknameChangePage> createState() => _NicknameChangePageState();
}

class _NicknameChangePageState extends State<NicknameChangePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nicknameController = TextEditingController();
  String? _errorMessage;
  String currentNickname = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchCurrentNickname();
  }

  Future<void> fetchCurrentNickname() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('User').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            currentNickname =
                (userDoc.data() as Map<String, dynamic>)['nickname'] ?? "Unknown";
          });
        }
      }
    } catch (e) {
      print("닉네임 불러오기 오류: $e");
    }
  }

  Future<void> updateNickname() async {
    final newNickname = _nicknameController.text.trim();
    if (newNickname.isEmpty) {
      setState(() {
        _errorMessage = "닉네임을 입력해주세요.";
      });
      return;
    }
    if (newNickname.length > 10) {
      setState(() {
        _errorMessage = "닉네임 양식이 일치하지 않습니다.";
      });
      return;
    }
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('User').doc(user.uid).update({
          'nickname': newNickname,
        });
        setState(() {
          _errorMessage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("닉네임이 성공적으로 변경되었습니다.")),
        );
        Navigator.pop(context); // 이전 화면으로 돌아가기
      }
    } catch (e) {
      print("닉네임 변경 실패: $e");
      setState(() {
        _errorMessage = "닉네임 변경 중 오류가 발생했습니다.";
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
                  const Text(
                    "현재 닉네임",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: TextEditingController(text: currentNickname),
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  const Text(
                    "새로운 닉네임",
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
                      controller: _nicknameController,
                      decoration: InputDecoration(
                        hintText: "10글자 이내",
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
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: updateNickname,
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
