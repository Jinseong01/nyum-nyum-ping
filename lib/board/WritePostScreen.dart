import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'class/Post.dart'; // 게시글 데이터 모델을 정의한 클래스
import '../firebase/BoardService.dart'; // Firebase와 연동하여 게시글 데이터를 처리하는 서비스 클래스
import '../firebase/auth_service.dart';

class WritePostScreen extends StatefulWidget {
  @override
  _WritePostScreenState createState() => _WritePostScreenState();
}

class _WritePostScreenState extends State<WritePostScreen> {
  // 제목과 내용을 입력받는 TextEditingController
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  final BoardService boardFireBase = BoardService();
  final AuthService authService = AuthService();

  // 선택한 이미지 목록
  List<XFile> images = [];

  // 로딩 상태 및 입력 유효성 확인 상태
  bool _isLoading = false;
  bool _isTitleValid = true;
  bool _isContentValid = true;

  // 갤러리에서 이미지를 선택하는 함수
  Future<void> _getImageFromGallery() async {
    try {
      // 갤러리에서 이미지를 선택
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      // 이미지가 선택되었으면 리스트에 추가
      if (image != null) {
        setState(() {
          if (images.length < 3) {
            // 최대 3개의 이미지만 추가 가능
            images.add(image);
          }
        });
      }
    } catch (e) {
      print('이미지 선택 오류: $e');
    }
  }

  // 선택한 이미지를 Firebase에 업로드하는 함수
  Future<List<String>> _uploadImages() async {
    List<String> uploadedUrls = [];

    for (var image in images) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      try {
        // Firebase에 이미지 업로드 후 URL 가져오기
        String downloadUrl = await boardFireBase.uploadImageToBoards(
          filePath: image.path,
          fileName: fileName,
        );
        uploadedUrls.add(downloadUrl);
      } catch (e) {
        print('이미지 업로드 오류: $e');
      }
    }

    return uploadedUrls; // 업로드된 이미지 URL 반환
  }

  // 게시글을 저장하는 함수
  Future<void> _savePost() async {
    // 제목과 내용의 유효성 검사
    setState(() {
      _isTitleValid = _titleController.text.isNotEmpty;
      _isContentValid = _contentController.text.isNotEmpty;
    });

    // 유효하지 않으면 저장하지 않음
    if (!_isTitleValid || !_isContentValid) {
      return;
    }

    setState(() {
      _isLoading = true; // 로딩 상태 활성화
    });

    try {
      // 이미지 업로드 및 URL 목록 가져오기
      List<String> uploadedImageUrls = await _uploadImages();

      // 로그인된 사용자의 이메일 가져오기
      String? email = authService.currentUser?.email;
      if (email == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      // 새로운 게시글 객체 생성
      Post newPost = Post(
        id: '',
        title: _titleController.text,
        reason: _contentController.text,
        email: email,
        likes: 0,
        imageUrl: uploadedImageUrls,
        createdAt: DateTime.now(),
        likedBy: [],
      );

      // 게시글 저장 및 결과 확인
      String postId = await boardFireBase.createPost(newPost);

      if (postId.isNotEmpty) {
        // 저장 성공 시 이전 화면으로 이동
        Navigator.pop(context, true);
      } else {
        throw Exception('게시글 저장 실패');
      }
    } catch (e) {
      // 오류 발생 시 알림 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 저장 중 오류가 발생했습니다: $e')),
      );
    } finally {
      // 로딩 상태 비활성화
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 이미지 위젯을 생성하는 함수
  Widget _buildImageWidget(XFile image, int index) {
    return Image.file(
      File(image.path),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context), // 뒤로가기 버튼
        ),
        title: Text(''),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2), // 로딩 표시
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: TextButton(
                onPressed: _savePost, // 저장 버튼
                child: Text(
                  '완료',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 입력 필드
            Container(
              margin: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: '제목을 입력하세요',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  ),
                  if (!_isTitleValid)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '제목을 입력해주세요',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            // 내용 입력 필드
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _contentController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: '내용을 입력하세요',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  ),
                  if (!_isContentValid)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '내용을 입력해주세요',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            // 이미지 업로드 그리드
            Container(
              padding: EdgeInsets.all(16),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 3, // 한 행에 보여줄 이미지 개수
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  // 선택된 이미지들
                  ...List.generate(
                    images.length,
                    (index) => Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: _buildImageWidget(images[index], index),
                        ),
                        // 삭제 버튼
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                images.removeAt(index); // 이미지 삭제
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 이미지 추가 버튼
                  if (images.length < 3)
                    GestureDetector(
                      onTap: _getImageFromGallery,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            Icon(Icons.add_circle_outline, color: Colors.grey),
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

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
