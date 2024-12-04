import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class PhotoReviewSlider extends StatefulWidget {
  final String restaurantName;
  final VoidCallback? onImagesUpdated; // 이미지 업데이트 시 호출할 콜백
  const PhotoReviewSlider({
    super.key,
    required this.restaurantName,
    this.onImagesUpdated, // 콜백 초기화
  });

  @override
  State<PhotoReviewSlider> createState() => _PhotoReviewSliderState();
}

class _PhotoReviewSliderState extends State<PhotoReviewSlider> {
  List<String> images = []; // 이미지를 저장할 리스트
  bool isLoading = true; // 로딩 상태 관리

  @override
  void initState() {
    super.initState();
    print("initState 호출");
    fetchImages(); // Firestore에서 데이터 가져오기
  }

  void fetchImages() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Reviews')
          .doc(widget.restaurantName)
          .get();

      if (doc.exists) {
        print("fetchImages 도중 doc 존재");
        final data = doc.data();
        if (data != null && data['reviews'] != null) {
          final List<dynamic> reviews = data['reviews'];

          // Firebase Storage에서 URL 변환
          final List<String> imageUrls = [];
          for (var review in reviews) {
            if (review['imageUrl'] != null) {
              final List<dynamic> gsPaths = review['imageUrl'];
              for (var path in gsPaths) {
                String downloadUrl = await FirebaseStorage.instance
                    .refFromURL(path)
                    .getDownloadURL();
                imageUrls.add(downloadUrl);
              }
            }
          }

          setState(() {
            print("데이터가 존재하기 때문에 setState");
            images = imageUrls;
            isLoading = false;
            print("데이터가 존재하기 때문에 setState ${images}");
          });

          // 콜백 호출
          if (widget.onImagesUpdated != null) {
            widget.onImagesUpdated!();
          }

          return; // 성공적으로 데이터를 가져오면 함수 종료
        }else{
          setState(() {
            print("데이터가 존재하지 않음 setState");
            isLoading = false; // 데이터가 없는 경우에도 로딩 상태 종료
          });
        }
      }else{
        setState(() {
          print("doc이 존재하지 않음 setState");
          isLoading = false; // 데이터가 없는 경우에도 로딩 상태 종료
        });
      }
    } catch (e) {
      print("Error fetching images: $e");
    }
    setState(() {
      isLoading = false; // 실패 시에도 로딩 상태 종료
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFEEF5FF),
      height: 180,
      child: isLoading
        ? Center(child: CircularProgressIndicator(),)
        : ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          itemBuilder: (context, index){
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: 150,
                height: 130,
                color: Color(0xFFEEF5FF),
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                )
              ),
            );
          }
      )
      ,
    );
  }
}
