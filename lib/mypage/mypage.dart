import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage 가져오기
import 'package:nyum_nyum_ping/login/first_screen.dart'; // FirstScreen 가져오기
import 'password_verification.dart';
import 'nickname_change.dart';
import 'password_change.dart';

class Mypage extends StatefulWidget {
  const Mypage({super.key});

  @override
  State<Mypage> createState() => _MypageState();
}

class _MypageState extends State<Mypage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **사용자 데이터 실시간 스트림**
  Stream<DocumentSnapshot> getUserStream() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('User').doc(user.email).snapshots();
    } else {
      throw Exception("로그인된 사용자가 없습니다.");
    }
  }

  /// **회원탈퇴 로직**
Future<void> deleteUserAccount() async {
  try {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("로그인된 사용자가 없습니다.");
    }

    final userEmail = user.email;
    if (userEmail == null) {
      throw Exception("사용자의 이메일을 찾을 수 없습니다.");
    }
 
    // **Firestore 데이터 삭제**
    // 3. Reviews 삭제
    print("Reviews 데이터 삭제 시작...");
    final reviewsQuerySnapshot = await _firestore.collection('Reviews').get();
    for (var doc in reviewsQuerySnapshot.docs) {
      if (doc.data().containsKey('reviews')) {
        List<dynamic> reviews = doc['reviews'] ?? [];
        reviews.removeWhere((review) => review['email'] == userEmail);
        await doc.reference.update({'reviews': reviews});
      } else {
        print("문서에 'reviews' 필드가 없습니다: ${doc.id}");
      }
    }
    print("Reviews 데이터 삭제 완료!");

    // 1. BookMarks 삭제
    print("BookMarks 삭제 시작...");
    await _firestore.collection('BookMarks').doc(userEmail).delete();
    print("BookMarks 삭제 완료!");

    // 2. Boards 삭제
    print("Boards 데이터 삭제 시작...");
    final boardsQuerySnapshot = await _firestore
        .collection('Boards')
        .where('email', isEqualTo: userEmail)
        .get();

    for (var doc in boardsQuerySnapshot.docs) {
      // Storage에서 이미지 삭제
      if (doc.data().containsKey('imageUrl')) {
        List<dynamic> imageUrls = doc['imageUrl'] != null ? List.from(doc['imageUrl']) : [];
        await _deleteImagesFromStorage(imageUrls);
      }
      // 문서 삭제
      await doc.reference.delete();
    }
    print("Boards 데이터 삭제 완료!");

    

    // 4. User 문서 삭제
    print("User 문서 삭제 시작...");
    await _firestore.collection('User').doc(userEmail).delete();
    print("User 문서 삭제 완료!");

    // **Firebase Authentication 계정 삭제**
    print("Firebase Authentication 계정 삭제 시작...");
    await user.delete();
    print("Firebase Authentication 계정 삭제 완료!");

    // **회원탈퇴 후 화면 이동**
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const FirstScreen()),
      (route) => false, // 모든 스택 제거
    );
  } catch (e) {
    print("회원탈퇴 중 오류 발생: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("회원탈퇴 중 오류가 발생했습니다: $e")),
    );
  }
}

/// **Storage 이미지 삭제 함수**
Future<void> _deleteImagesFromStorage(List<dynamic> imageUrls) async {
  final storage = FirebaseStorage.instance;
  for (var url in imageUrls) {
    if (url.isNotEmpty) {
      try {
        await storage.refFromURL(url).delete();
        print("이미지 삭제 성공: $url");
      } catch (e) {
        print('이미지 삭제 실패: $e');
      }
    }
  }
}


  /// **로그아웃 로직**
  Future<void> logout() async {
    try {
      await _auth.signOut(); // Firebase Auth 로그아웃

      // FirstScreen으로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const FirstScreen()),
        (route) => false, // 모든 스택 제거
      );
    } catch (e) {
      print("로그아웃 중 오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그아웃 중 오류가 발생했습니다: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 70), // AppBar 위에 여백 추가
          AppBar(
            title: StreamBuilder<DocumentSnapshot>(
              stream: getUserStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading...');
                }
                if (snapshot.hasData && snapshot.data!.exists) {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  return Text(
                    data['nickname'] ?? '닉네임 없음',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  );
                } else {
                  return const Text('사용자 없음');
                }
              },
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0.5,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "계정",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: const Text(
                      "닉네임 변경",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PasswordVerificationPage(
                            onVerified: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NicknameChangePage(),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text(
                      "비밀번호 변경",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PasswordVerificationPage(
                            onVerified: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PasswordChangePage(),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text(
                      "로그아웃",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: logout, // 로그아웃 로직 연결
                  ),
                  const SizedBox(height: 300), // 회원탈퇴 섹션 위에 여백 추가
                  ListTile(
                    title: Text(
                      "회원탈퇴",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.grey[200],
                          content: const Text(
                            '회원탈퇴를 진행하시겠습니까?',
                            style: TextStyle(
                              fontSize: 14, // 텍스트 크기
                              fontWeight: FontWeight.bold, // 텍스트 굵게
                            ),
                            textAlign: TextAlign.center, // 텍스트 가운데 정렬
                          ),
                          actionsAlignment: MainAxisAlignment.spaceEvenly,
                          actions: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                deleteUserAccount(); // 회원탈퇴 로직 실행
                              },
                              child: const Text(
                                '네',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                '아니오',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
