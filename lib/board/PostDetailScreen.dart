import 'package:flutter/material.dart';

import 'class/Post.dart';
import 'widgets/SelfLikeDialog.dart';
import 'widgets/AlreadyLikeDialog.dart';
import 'widgets/DeleteConfirmDialog.dart';
import 'EditPostScreen.dart';
import '../firebase/BoardService.dart';
import '../firebase//auth_service.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Post _post; // 현재 게시글 데이터
  bool _isLiked = false; // 좋아요 여부
  bool _isDataChanged = false; // 게시글 데이터 변경 여부
  final BoardService _boardFireBase = BoardService(); // 게시판 서비스 객체
  final AuthService _authService = AuthService(); // 인증 서비스 객체

  @override
  void initState() {
    super.initState();
    _post = widget.post; // 전달받은 게시글 데이터 초기화

    // 현재 사용자 이메일로 좋아요 상태 초기화
    final String? currentUserEmail = _authService.currentUser?.email;
    if (currentUserEmail != null) {
      _isLiked = _post.likedBy.contains(currentUserEmail);
    }
  }

  // 본인의 글을 추천하려고 할 때 표시하는 다이얼로그
  void _showSelfLikeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SelfLikeDialog(),
    );
  }

  // 이미 좋아요를 누른 글을 추천하려고 할 때 표시하는 다이얼로그
  void _showAlreadyLikedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const AlreadyLikeDialog(),
    );
  }

  // 삭제 확인 다이얼로그를 표시
  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => DeleteConfirmDialog(
        onConfirm: _deletePost, // 삭제 동작을 수행하는 함수 전달
      ),
    );
  }

  // 좋아요 버튼 클릭 시 호출
  Future<void> _toggleLike() async {
    final String? currentUserEmail = _authService.currentUser?.email;

    if (currentUserEmail == null) {
      // 로그인이 필요할 경우 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    // 본인의 글을 추천하려고 할 경우 다이얼로그 표시
    if (_post.email == currentUserEmail) {
      _showSelfLikeDialog(context);
      return;
    }

    // 이미 좋아요를 누른 경우 다이얼로그 표시
    if (_post.likedBy.contains(currentUserEmail)) {
      _showAlreadyLikedDialog(context);
      return;
    }

    // 좋아요 추가
    try {
      setState(() {
        _post.likedBy.add(currentUserEmail);
        _post.likes++;
        _isLiked = true;
      });

      // Firebase에 좋아요 상태 업데이트
      await _boardFireBase.updatePost(_post.id, _post);
      _isDataChanged = true; // 데이터가 변경됨을 표시
    } catch (e) {
      print('Error updating likes: $e');
      // 에러 발생 시 상태 복원
      setState(() {
        _post.likedBy.remove(currentUserEmail);
        _post.likes--;
        _isLiked = false;
      });
    }
  }

  // 게시글 삭제 처리
  Future<void> _deletePost() async {
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      // 게시글 삭제 API 호출
      bool isDeleted = await _boardFireBase.deletePostAndImages(
        _post.id,
        _post.imageUrl.isEmpty ? null : _post.imageUrl,
      );

      if (isDeleted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        Navigator.of(context).pop(true); // 화면 종료
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글이 삭제되었습니다.')),
        );
      } else {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글 삭제 중 오류가 발생했습니다.')),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 삭제 중 오류가 발생했습니다.')),
      );
    }
  }

  // 게시글 데이터 다시 로드
  Future<void> _reloadPostData() async {
    try {
      final reloadedPost = await _boardFireBase.reloadPost(_post.id);
      setState(() {
        _post = reloadedPost;

        // 좋아요 상태 다시 초기화
        final String? currentUserEmail = _authService.currentUser?.email;
        if (currentUserEmail != null) {
          _isLiked = _post.likedBy.contains(currentUserEmail);
        }
      });
    } catch (e) {
      print('Error reloading post data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 데이터를 불러오는 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserEmail = _authService.currentUser?.email;
    final bool isOwner =
        currentUserEmail == _post.email; // 현재 사용자가 게시글 소유자인지 확인

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_isDataChanged); // 데이터 변경 상태 반환
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context, _isDataChanged),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: isOwner
              ? [
                  PopupMenuButton<String>(
                    color: Colors.white,
                    onSelected: (String value) async {
                      if (value == 'edit') {
                        // 게시글 수정 화면으로 이동
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPostScreen(post: _post),
                          ),
                        );

                        if (result == true) {
                          await _reloadPostData(); // 데이터 다시 로드
                          setState(() {
                            _isDataChanged = true;
                          });
                        }
                      } else if (value == 'delete') {
                        // 삭제 확인 다이얼로그 표시
                        _showDeleteConfirmDialog(context);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Text(
                          '수정하기',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(
                          '삭제하기',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                    icon: Icon(Icons.more_vert, color: Colors.black),
                  ),
                ]
              : [],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Divider(height: 1, color: Colors.grey[200]),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _post.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _post.reason,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (_post.imageUrl.isNotEmpty) ...[
                      SizedBox(height: 16),
                      Container(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _post.imageUrl.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Image.network(
                                _post.imageUrl[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: _toggleLike,
                      child: Row(
                        children: [
                          Icon(
                            _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            color: Colors.blue,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            _post.likes.toString(),
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
