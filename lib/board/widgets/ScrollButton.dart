import 'package:flutter/material.dart';

import '../class/Post.dart';
import '../PostDetailScreen.dart';
import '../../firebase/BoardService.dart';

class ScrollButtons extends StatelessWidget {
  final List<Post> topPosts; // 좋아요가 많은 상위 게시글 리스트

  const ScrollButtons({
    Key? key,
    required this.topPosts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (topPosts.isEmpty) {
      // 게시글이 없을 경우 로딩 표시
      return Container(
        height: 45,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade600, width: 1), // 하단 경계선
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // 가로 스크롤
        itemCount: topPosts.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // 게시글 상세 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(post: topPosts[index]),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20), // 둥근 모서리
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.thumb_up_outlined, // 좋아요 아이콘
                    size: 14,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 4),
                  Text(
                    topPosts[index].likes.toString(), // 좋아요 수
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    topPosts[index].title, // 게시글 제목
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // 텍스트 잘림 처리
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
