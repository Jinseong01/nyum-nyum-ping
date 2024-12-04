import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'class/Post.dart';
import '../firebase/BoardService.dart';

class EditPostScreen extends StatefulWidget {
  final Post post; // 수정할 게시글 데이터를 전달받음

  const EditPostScreen({Key? key, required this.post}) : super(key: key);

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final BoardService _boardFireBase = BoardService(); // Firebase 관련 클래스 인스턴스
  final _titleController = TextEditingController(); // 제목 입력 컨트롤러
  final _contentController = TextEditingController(); // 내용 입력 컨트롤러
  final ImagePicker _picker = ImagePicker(); // 이미지 선택 도구
  List<XFile> images = []; // 추가할 이미지 파일 리스트
  List<String> imageUrls = []; // 기존 이미지 URL 리스트
  List<String> deletedImageUrls = []; // 삭제할 이미지 URL 리스트
  bool _isTitleValid = true; // 제목 입력 유효성 플래그
  bool _isContentValid = true; // 내용 입력 유효성 플래그
  bool _isLoading = false; // 로딩 상태 플래그

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.post.title; // 초기 제목 설정
    _contentController.text = widget.post.reason; // 초기 내용 설정
    imageUrls = List.from(widget.post.imageUrl); // 초기 이미지 URL 설정
  }

  // 갤러리에서 이미지 가져오기
  Future<void> _getImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null && images.length + imageUrls.length < 3) {
        setState(() {
          images.add(image); // 선택한 이미지 추가
        });
      }
    } catch (e) {
      print('이미지 선택 오류: $e');
    }
  }

  // 게시글 저장
  Future<void> _savePost() async {
    // 제목과 내용의 유효성 검사
    setState(() {
      _isTitleValid = _titleController.text.isNotEmpty;
      _isContentValid = _contentController.text.isNotEmpty;
    });

    if (!_isTitleValid || !_isContentValid) {
      return;
    }

    setState(() {
      _isLoading = true; // 로딩 상태 시작
    });

    try {
      List<String> uploadedImageUrls = [];
      // 새로 추가된 이미지 업로드
      for (var image in images) {
        String imageUrl = await _boardFireBase.uploadImageToBoards(
          filePath: image.path,
          fileName: DateTime.now().millisecondsSinceEpoch.toString(),
        );
        uploadedImageUrls.add(imageUrl);
      }

      // 삭제된 이미지 제거
      for (String deletedUrl in deletedImageUrls) {
        try {
          await _boardFireBase.deleteImage(deletedUrl);
        } catch (e) {
          print('이미지 삭제 실패: $e');
        }
      }

      final updatedImageUrls = [
        ...imageUrls,
        ...uploadedImageUrls
      ]; // 업데이트된 이미지 리스트

      // 수정된 게시글 데이터 생성
      final updatedPost = Post(
        id: widget.post.id,
        title: _titleController.text,
        reason: _contentController.text,
        email: widget.post.email,
        likes: widget.post.likes,
        imageUrl: updatedImageUrls,
        createdAt: widget.post.createdAt,
        likedBy: widget.post.likedBy,
      );

      // Firestore에 게시글 업데이트
      await _boardFireBase.updatePost(updatedPost.id, updatedPost);
      Navigator.pop(context, true); // 수정 완료 후 이전 화면으로 복귀
    } catch (e) {
      print('게시글 수정 오류: $e');
    } finally {
      setState(() {
        _isLoading = false; // 로딩 상태 종료
      });
    }
  }

  // 선택된 이미지를 표시하는 위젯 생성
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
      backgroundColor: Colors.white, // 배경색 설정
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context, false), // 뒤로가기 버튼
        ),
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
            TextButton(
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
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 입력 영역
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
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  if (!_isTitleValid)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '제목을 입력해주세요', // 제목 유효성 검사 메시지
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            // 내용 입력 영역
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
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  if (!_isContentValid)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '내용을 입력해주세요', // 내용 유효성 검사 메시지
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            // 이미지 선택 영역
            Container(
              padding: EdgeInsets.all(16),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  // 기존 이미지 리스트 표시
                  ...List.generate(
                    imageUrls.length,
                    (index) => Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.network(
                            imageUrls[index], // 기존 이미지
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        // 이미지 삭제 버튼
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                deletedImageUrls.add(imageUrls[index]);
                                imageUrls.removeAt(index);
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
                  // 새로 추가된 이미지 리스트 표시
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
                        // 추가된 이미지 삭제 버튼
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                images.removeAt(index);
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
                  if (images.length + imageUrls.length < 3)
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
