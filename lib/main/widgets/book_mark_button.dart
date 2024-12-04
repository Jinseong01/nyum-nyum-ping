import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookMarkButton extends StatefulWidget {
  final String restaurantName;
  final String imageUrl;
  final String category;
  final double? size;
  final void Function(bool isBookmarked)? onBookmarkChanged; // 콜백 함수 추가


  const BookMarkButton({
    super.key,
    required this.restaurantName,
    required this.imageUrl,
    required this.category,
    this.size,
    this.onBookmarkChanged, // 콜백 함수 초기화
  });

  @override
  State<BookMarkButton> createState() => _BookMarkButtonState();
}

class _BookMarkButtonState extends State<BookMarkButton> {
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    checkBookmarkStatus();
  }

  Future<void> checkBookmarkStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final docRef = FirebaseFirestore.instance
          .collection('BookMarks')
          .doc(user.email);

      final snapshot = await docRef.get();
      if (snapshot.exists) {
        final bookmarks = snapshot.data()?['bookMarks'] as List<dynamic>? ?? [];
        setState(() {
          isBookmarked = bookmarks.any((bookmark) =>
          (bookmark as Map<String, dynamic>)['name'] == widget.restaurantName);
        });
      }
    } catch (e) {
      print("북마크 상태 확인 중 오류 발생: $e");
    }
  }

  Future<void> toggleBookmark() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final userDocRef = FirebaseFirestore.instance.collection('BookMarks').doc(user.email);
    final restaurantDocRef =
    FirebaseFirestore.instance.collection('Restaurants').doc(widget.restaurantName);

    final bookmarkData = {
      'name': widget.restaurantName,
      'category': widget.category,
      'imageUrl': widget.imageUrl,
      'memo': "",
    };

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userDocRef);
        final restaurantSnapshot = await transaction.get(restaurantDocRef);

        if (!restaurantSnapshot.exists) {
          throw Exception("레스토랑 데이터가 존재하지 않습니다.");
        }

        int currentBookmarkCount = restaurantSnapshot.data()?['bookMarks'] ?? 0;

        if (isBookmarked) {
          // 북마크 제거
          if (userSnapshot.exists) {
            final bookmarks = userSnapshot.data()?['bookMarks'] as List<dynamic>? ?? [];
            final updatedBookmarks = bookmarks.where((bookmark) {
              final mapBookmark = bookmark as Map<String, dynamic>;
              return mapBookmark['name'] != widget.restaurantName;
            }).toList();

            transaction.update(userDocRef, {'bookMarks': updatedBookmarks});
          }

          // 레스토랑 북마크 수 감소
          transaction.update(restaurantDocRef, {
            'bookMarks': FieldValue.increment(-1),
          });
        } else {
          // 북마크 추가
          transaction.set(userDocRef, {
            'bookMarks': FieldValue.arrayUnion([bookmarkData]),
          }, SetOptions(merge: true));

          // 레스토랑 북마크 수 증가
          transaction.update(restaurantDocRef, {
            'bookMarks': FieldValue.increment(1),
          });
        }
      });

      // UI 업데이트
      setState(() {
        isBookmarked = !isBookmarked;
      });

      // 콜백 호출 (상태 변경 알림)
      if (widget.onBookmarkChanged != null) {
        widget.onBookmarkChanged!(isBookmarked);
      }
    } catch (e) {
      print("북마크 업데이트 중 오류 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleBookmark,
      child: Icon(
        isBookmarked ? Icons.bookmark : Icons.bookmark_border_outlined,
        color: Colors.blue,
        size: widget.size ?? 24.0, // 기본 크기 24.0 설정
      ),
    );
  }
}


