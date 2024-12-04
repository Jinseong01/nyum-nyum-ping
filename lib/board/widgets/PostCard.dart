import 'package:flutter/material.dart';
import '../class/Post.dart';
import '../PostDetailScreen.dart';

class PostCard extends StatelessWidget {
  final Post post; // 게시글 데이터
  final VoidCallback onEditComplete; // 게시글 수정 완료 시 호출되는 콜백

  const PostCard({
    Key? key,
    required this.post,
    required this.onEditComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // 게시글 상세 화면으로 이동
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
        );

        // 데이터 변경이 확인되면 상위 콜백 호출
        if (result == true) {
          onEditComplete();
        }
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 게시글 제목, 내용, 좋아요 표시
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title, // 제목
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Container(
                    height: 40, // 고정된 높이
                    child: Text(
                      post.reason.length > 40
                          ? '${post.reason.substring(0, 40)}...'
                          : post.reason, // 내용 일부 표시
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.thumb_up,
                          color: Colors.blue, size: 14), // 좋아요 아이콘
                      SizedBox(width: 4),
                      Text(
                        post.likes.toString(), // 좋아요 개수
                        style: TextStyle(fontSize: 13, color: Colors.blue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 게시글에 이미지가 있을 경우 첫 번째 이미지 표시
            if (post.imageUrl.isNotEmpty)
              Container(
                width: 70,
                height: 100,
                margin: EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                  image: DecorationImage(
                    image: NetworkImage(post.imageUrl[0]), // 첫 번째 이미지
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
