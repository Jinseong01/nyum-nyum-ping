import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FirebaseFirestore get firestore => _firestore;

  // 현재 로그인된 사용자 가져오기
  User? get currentUser => _auth.currentUser;

  /// **비밀번호 확인 (Re-authentication)**
  Future<bool> verifyPassword(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // 사용자의 이메일과 입력한 비밀번호로 재인증 시도
        final credential = EmailAuthProvider.credential(
          email: user.email!, // 현재 사용자의 이메일
          password: password, // 입력한 비밀번호
        );

        await user.reauthenticateWithCredential(credential);
        return true; // 비밀번호가 일치하면 true 반환
      } else {
        throw FirebaseAuthException(
          code: 'no-user',
          message: '현재 로그인된 사용자가 없습니다.',
        );
      }
    } catch (e) {
      print("비밀번호 확인 실패: $e");
      return false; // 비밀번호가 일치하지 않으면 false 반환
    }
  }

  /// **사용자 데이터 가져오기 (Firestore)**
  Future<Map<String, dynamic>?> getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('User').doc(user.uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    }
    return null;
  }

  /// **더미 데이터로 로그인 (테스트용)**
  Future<void> signInWithTestAccount() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: "gr214777@naver.com", // 테스트 계정 이메일
        password: "wnsgml7481", // 테스트 계정 비밀번호
      );
      print("테스트 계정으로 로그인 성공!");
    } catch (e) {
      print("테스트 계정 로그인 실패: $e");
      rethrow;
    }
  }

  /// **로그아웃**
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// **회원가입 (이메일 & 비밀번호)**
  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String name, String nickname) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Firestore에 사용자 추가 지금은 uid로했은데 email로 해도됨 ㅇㅇ
      await _firestore.collection('User').doc(userCredential.user!.uid).set({
        'email': email,
        'name' : name,
        'nickname': nickname,
      });

      return userCredential.user;
    } catch (e) {
      print("회원가입 실패: $e");
      rethrow;
    }
  }

  /// **비밀번호 변경**
  Future<void> updatePassword(String newPassword) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(newPassword);
      } catch (e) {
        print("비밀번호 변경 실패: $e");
        rethrow;
      }
    } else {
      throw FirebaseAuthException(code: 'no-user', message: '로그인된 사용자가 없습니다.');
    }
  }
}
