import 'package:flutter/material.dart';

import './class/Post.dart';
import 'widgets/PostCard.dart';
import 'widgets/ScrollButton.dart';
import 'WritePostScreen.dart';
import '../firebase/BoardService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BoardScreen extends StatefulWidget {
  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final BoardService _boardFireBase = BoardService(); // Firebase 관련 클래스 인스턴스
  List<Post> _posts = []; // 게시글 리스트
  List<Post> _topPosts = []; // 좋아요 상위 게시글 리스트
  bool _isLoading = false; // 로딩 상태 플래그
  bool _isDataChanged = false; // 데이터 변경 여부 플래그
  QueryDocumentSnapshot? _lastDocument; // 페이징을 위한 마지막 문서 스냅샷
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러

  @override
  void initState() {
    super.initState();
    _fetchPosts(); // 초기 게시글 로드
    _scrollController.addListener(_scrollListener); // 스크롤 리스너 추가
  }

  // 스크롤 이벤트 리스너: 스크롤 위치가 특정 위치에 도달하면 추가 게시글 로드
  void _scrollListener() {
    if (_scrollController.position.extentAfter < 500 && !_isLoading) {
      _loadMorePosts();
    }
  }

  // 게시글 불러오기 (초기 로드 및 추가 로드 공통 처리)
  Future<void> _loadPosts({bool isInitialLoad = false}) async {
    if (_isLoading || (!isInitialLoad && _lastDocument == null)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Firestore에서 게시글 불러오기
      List<Post> posts = await _boardFireBase.getPaginatedPosts(
        startAfter: isInitialLoad ? null : _lastDocument,
      );

      if (isInitialLoad) {
        // 초기 로드시 좋아요 상위 게시글 가져오기
        List<Post> topPosts = await _boardFireBase.getRecentPosts();
        topPosts.sort((a, b) => b.likes.compareTo(a.likes));

        setState(() {
          _posts = posts; // 게시글 업데이트
          _topPosts = topPosts.take(3).toList(); // 상위 게시글 3개만 업데이트
        });
      } else {
        setState(() {
          _posts.addAll(posts); // 추가 게시글 업데이트
        });
      }

      // 마지막 문서 스냅샷 업데이트
      _lastDocument = posts.isNotEmpty ? posts.last.documentSnapshot : null;
      _isDataChanged = true; // 데이터 변경 플래그 설정
    } catch (e) {
      print('Error loading posts: $e');
    } finally {
      setState(() {
        _isLoading = false; // 로딩 상태 해제
      });
    }
  }

  // 초기 게시글 로드
  Future<void> _fetchPosts() => _loadPosts(isInitialLoad: true);

  // 추가 게시글 로드
  Future<void> _loadMorePosts() => _loadPosts(isInitialLoad: false);

  // 로딩 상태 표시 위젯
  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 데이터 변경 시 게시글 새로고침
        if (_isDataChanged) {
          await _fetchPosts();
          _isDataChanged = false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // 좋아요 상위 게시글 표시 위젯
            ScrollButtons(topPosts: _topPosts),
            // 게시글 목록
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchPosts, // 새로고침 시 호출
                child: ListView.separated(
                  controller: _scrollController, // 스크롤 컨트롤러 추가
                  itemCount:
                      _posts.length + (_isLoading ? 1 : 0), // 로딩 상태 표시 포함
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey[300]), // 구분선
                  itemBuilder: (context, index) {
                    if (index < _posts.length) {
                      return PostCard(
                        post: _posts[index], // 게시글 표시
                        onEditComplete: _fetchPosts, // 게시글 수정 완료 후 새로고침
                      );
                    } else {
                      return _buildLoadingIndicator(); // 로딩 상태 표시
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        // 게시글 작성 버튼
        floatingActionButton: GestureDetector(
          onTap: () async {
            // 게시글 작성 화면으로 이동
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WritePostScreen()),
            );

            // 게시글 작성 완료 시 데이터 갱신
            if (result == true) {
              await _fetchPosts();
            }
          },
          child: Container(
            width: 120,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '게시글 쓰기',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
