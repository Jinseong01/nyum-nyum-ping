import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id; // 게시글 ID (Firestore에서 문서 ID)
  final String title; // 게시글 제목
  final String reason; // 게시글 내용
  final String email; // 게시글 작성자의 이메일
  int likes; // 게시글 좋아요 수
  final List<String> imageUrl; // 게시글에 첨부된 이미지 URL 리스트
  final DateTime createdAt; // 게시글 생성 시간
  final List<String> likedBy; // 게시글을 좋아요한 사용자들의 ID 목록
  final QueryDocumentSnapshot?
      documentSnapshot; // Firestore에서 가져온 원본 문서 스냅샷 (옵션)

  Post({
    required this.id,
    required this.title,
    required this.reason,
    required this.email,
    required this.likes,
    required this.imageUrl,
    required this.createdAt,
    required this.likedBy,
    this.documentSnapshot,
  });

  // Firestore 문서 데이터를 Post 객체로 변환
  factory Post.fromFirestore(QueryDocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      reason: data['reason'] ?? '',
      email: data['email'] ?? '',
      likes: data['likes'] ?? 0,
      imageUrl: List<String>.from(data['imageUrl'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      documentSnapshot: doc,
    );
  }

  // Post 객체를 Firestore에 저장 가능한 Map 형식으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'reason': reason,
      'email': email,
      'likes': likes,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'likedBy': likedBy,
    };
  }
}
