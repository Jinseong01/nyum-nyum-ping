import 'dart:io';

import '../board/class/Post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BoardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FirebaseFirestore get firestore => _firestore;

  // 최근 7일간 작성된 게시글 가져오기
  // Firestore에서 'createdAt' 필드가 7일 이내인 게시글을 최신순으로 가져옴
  Future<List<Post>> getRecentPosts() async {
    try {
      final DateTime oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

      QuerySnapshot querySnapshot = await _firestore
          .collection("Boards")
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo))
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    } catch (e) {
      print('최근 게시글 로딩 오류 : $e');
      return [];
    }
  }

  // 특정 게시글 가져오기
  // 주어진 postId를 기반으로 Firestore에서 게시글을 조회하여 반환
  Future<Post?> getPostById(String postId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await _firestore.collection("Boards").doc(postId).get();

      if (docSnapshot.exists) {
        return Post(
          id: docSnapshot.id,
          title: docSnapshot.data()?['title'] ?? '',
          reason: docSnapshot.data()?['reason'] ?? '',
          email: docSnapshot.data()?['email'] ?? '',
          likes: docSnapshot.data()?['likes'] ?? 0,
          imageUrl: List<String>.from(docSnapshot.data()?['imageUrl'] ?? []),
          createdAt:
              (docSnapshot.data()?['createdAt'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
          likedBy: List<String>.from(docSnapshot.data()?['likedBy'] ?? []),
        );
      } else {
        print('$postId 번 게시글 없음');
        return null;
      }
    } catch (e) {
      print('게시글 로딩 오류 : $e');
      return null;
    }
  }

  // 게시글 데이터 다시 로드
  Future<Post> reloadPost(String postId) async {
    try {
      final post = await getPostById(postId);
      if (post == null) {
        throw Exception('$postId 번 게시글 없음');
      }
      return post;
    } catch (e) {
      print('게시글 재로딩 오류 : $e');
      throw e;
    }
  }

  // 페이징 처리된 게시글 가져오기
  Future<List<Post>> getPaginatedPosts({
    int limit = 10,
    QueryDocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection("Boards")
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => Post.fromFirestore(doc as QueryDocumentSnapshot))
          .toList();
    } catch (e) {
      print('페이징 오류 : $e');
      return [];
    }
  }

  // 게시글 생성 메서드
  Future<String> createPost(Post post) async {
    try {
      DocumentReference docRef =
          await _firestore.collection("Boards").add(post.toFirestore());
      return docRef.id;
    } catch (e) {
      print('게시글 생성 오류 : $e');
      return '';
    }
  }

  // 이미지 업로드
  Future<String> uploadImageToBoards({
    required String filePath,
    required String fileName,
  }) async {
    try {
      Reference ref = _storage.ref().child('Boards/$fileName');

      File file = File(filePath);
      UploadTask uploadTask = ref.putFile(file);

      await uploadTask;
      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('이미지 업로드 오류 : $e');
      throw e;
    }
  }

  // 게시글 업데이트
  Future<bool> updatePost(String postId, Post post) async {
    try {
      await _firestore
          .collection("Boards")
          .doc(postId)
          .update(post.toFirestore());
      return true;
    } catch (e) {
      print('게시글 업데이트 오류 : $e');
      return false;
    }
  }

  // 게시글 및 이미지 삭제
  Future<bool> deletePostAndImages(
      String postId, List<String>? imageUrls) async {
    try {
      await _firestore.collection("Boards").doc(postId).delete();

      if (imageUrls != null && imageUrls.isNotEmpty) {
        for (String imageUrl in imageUrls) {
          try {
            final Reference storageRef = _storage.refFromURL(imageUrl);
            await storageRef.delete();
          } catch (e) {
            print('게시글(이미지) 삭제 오류 : $e');
          }
        }
      }

      return true;
    } catch (e) {
      print('게시글 삭제 오류 : $e');
      return false;
    }
  }

  // 이미지 삭제
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
    } catch (e) {
      print('이미지 삭제 오류 : $e');
      throw e;
    }
  }
}
