import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nyum_nyum_ping/main/widgets/photo_review_slider.dart';
import 'package:nyum_nyum_ping/main/widgets/restaurant.dart';
import 'package:nyum_nyum_ping/main/widgets/custom_fab_location.dart';
import 'package:permission_handler/permission_handler.dart';

import '../login/widgets/common_dialog.dart';
import 'main_screen.dart';

class RestaurantDetail extends StatefulWidget {
  final Restaurant restaurant;
  const RestaurantDetail({super.key, required this.restaurant});

  @override
  State<RestaurantDetail> createState() => _RestaurantDetailState();
}

class _RestaurantDetailState extends State<RestaurantDetail> {
  PageController pageController = PageController();
  int bannerIndex = 0;
  late Future<bool> isBookmarkedFuture; // 북마크 상태를 저장하는 Future

  List<String> images = []; // 이미지를 저장할 리스트
  bool isLoading = true; // 로딩 상태 관리
  // late Future<int> bookmarkCount;

  @override
  void initState() {
    super.initState();
    isBookmarkedFuture = checkBookmarkStatus(); // 북마크 상태 확인
    // bookmarkCount=fetchRestaurantBookmarkCount();
    fetchImages(); // Firestore에서 데이터 가져오기
  }

  void _showDialog(String content) {
    showDialog(
      context: context,
      builder: (context) {
        return CommonDialog(
          title: "",
          content: content,
          onConfirm: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
        );
      },
    );
  }

  void fetchImages() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Reviews')
          .doc(widget.restaurant.name)
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

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // 안드로이드 13 이상
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();

        if (statuses.values.every((status) => status.isGranted)) {
          return true;
        } else {
          print("미디어 권한이 거부되었습니다.");
          openAppSettings();
          return false;
        }
      } else {
        // 안드로이드 13 미만
        PermissionStatus status = await Permission.storage.status;

        if (status.isGranted) {
          return true;
        } else if (status.isDenied) {
          status = await Permission.storage.request();
          if (status.isGranted) {
            return true;
          } else {
            print("스토리지 권한이 거부되었습니다.");
            return false;
          }
        } else if (status.isPermanentlyDenied) {
          print("스토리지 권한이 영구적으로 거부되었습니다.");
          openAppSettings();
          return false;
        }
      }
    } else if (Platform.isIOS) {
      // iOS에서는 기본적으로 권한 허용 (필요 시 추가 로직 작성)
      return true;
    }

    // 지원하지 않는 플랫폼
    throw UnsupportedError("Unsupported platform for permission request");
  }



  Future<bool> checkBookmarkStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final docRef = FirebaseFirestore.instance
          .collection('BookMarks')
          .doc(user.email);

      final snapshot = await docRef.get();
      if (snapshot.exists) {
        final bookmarks = snapshot.data()?['bookMarks'] as List<dynamic>? ?? [];
        // 북마크 상태 확인
        return bookmarks.any((bookmark) =>
        (bookmark as Map<String, dynamic>)['name'] == widget.restaurant.name);
      }
    } catch (e) {
      print("북마크 상태 확인 중 오류 발생: $e");
    }
    return false;
  }

  Future<int> fetchRestaurantBookmarkCount() async {
    try {
      // Firestore에서 해당 식당 문서 가져오기
      final docRef = FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(widget.restaurant.name);

      final snapshot = await docRef.get();

      if (snapshot.exists) {
        // bookMarks 필드 값 가져오기
        final bookmarkCount = snapshot.data()?['bookMarks'] as int? ?? 0;
        print("북마크 수: $bookmarkCount");
        return bookmarkCount;
      } else {
        print("식당 문서가 존재하지 않습니다.");
      }
    } catch (e) {
      print("북마크 수 가져오는 중 오류 발생: $e");
    }

    return 0; // 오류 발생 시 기본값 반환
  }

  Future<void> toggleBookmark(bool isBookmarked) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final userDocRef = FirebaseFirestore.instance.collection('BookMarks').doc(user.email);
    final restaurantDocRef = FirebaseFirestore.instance.collection('Restaurants').doc(widget.restaurant.name);

    final bookmarkData = {
      'name': widget.restaurant.name,
      'category': widget.restaurant.category,
      'imageUrl': widget.restaurant.imageUrl,
      'memo': "",
    };

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userDocRef);
        final restaurantSnapshot = await transaction.get(restaurantDocRef);

        if (!restaurantSnapshot.exists) {
          throw Exception("해당 레스토랑이 존재하지 않습니다.");
        }

        int currentBookmarkCount = restaurantSnapshot.data()?['bookMarks'] ?? 0;

        if (isBookmarked) {
          // 북마크 제거
          if (userSnapshot.exists) {
            final bookmarks = userSnapshot.data()?['bookMarks'] as List<dynamic>? ?? [];
            final updatedBookmarks = bookmarks.where((bookmark) {
              final mapBookmark = bookmark as Map<String, dynamic>;
              return mapBookmark['name'] != widget.restaurant.name;
            }).toList();

            transaction.update(userDocRef, {'bookMarks': updatedBookmarks});
          }

          // bookmarkCount 감소
          transaction.update(restaurantDocRef, {
            'bookMarks': FieldValue.increment(-1),
          });
        } else {
          // 북마크 추가
          transaction.set(userDocRef, {
            'bookMarks': FieldValue.arrayUnion([bookmarkData]),
          }, SetOptions(merge: true));

          // bookmarkCount 증가
          transaction.update(restaurantDocRef, {
            'bookMarks': FieldValue.increment(1),
          });
        }
      });

      // UI 상태와 Firestore 데이터 동기화
      setState(() {
        isBookmarkedFuture = checkBookmarkStatus(); // FutureBuilder 업데이트
        widget.restaurant.bookMarks += isBookmarked ? -1 : 1; // 북마크 수 동기화
      });
    } catch (e) {
      print("북마크 업데이트 중 오류 발생: $e");
    }
  }

  Future<void> uploadPhotoReview() async {
    final picker = ImagePicker();

    try {
      // 1. 현재 로그인된 사용자 가져오기
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        print("사용자가 로그인되어 있지 않거나 이메일이 없습니다.");
        return;
      }
      final String userEmail = user.email!;
      print("현재 로그인된 사용자 이메일: $userEmail");

      // 2. 이미지 선택
      final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage == null) {
        print("이미지 선택 취소됨");
        return;
      }
      print("이미지 선택 성공: ${pickedImage.path}");

      // 3. Firebase Storage에 업로드
      File imageFile = File(pickedImage.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('Reviews/${widget.restaurant.name}/$fileName');

      // 업로드 작업 시작
      UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() => {});

      // 업로드 URL 가져오기
      String downloadUrl = await storageSnapshot.ref.getDownloadURL();
      print("Firebase Storage 업로드 성공: $downloadUrl");

      // 4. Firestore에서 기존 reviews 배열 가져오기
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('Reviews')
          .doc(widget.restaurant.name);

      final docSnapshot = await docRef.get();
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>? ?? {};

      List<dynamic> reviews = data['reviews'] ?? [];

      // 기존 리뷰 중 email이 동일한 데이터 찾기
      Map<String, dynamic>? existingReview = reviews.firstWhere(
            (review) => review['email'] == userEmail,
        orElse: () => null,
      );

      if (existingReview != null) {
        // 5. 기존 리뷰가 있으면 imageUrl 배열에 새 URL 추가
        List<dynamic> imageUrls = existingReview['imageUrl'] ?? [];
        imageUrls.add(downloadUrl);
        existingReview['imageUrl'] = imageUrls;
      } else {
        // 6. 기존 리뷰가 없으면 새 리뷰 추가
        reviews.add({
          'email': userEmail,
          'imageUrl': [downloadUrl],
        });
      }

      // 7. Firestore에 업데이트
      await docRef.update({'reviews': reviews});

      print("Firestore 데이터베이스에 URL 저장 성공: $downloadUrl");
      _showDialog("포토리뷰가 등록되었습니다.");
      // 이미지 업데이트 콜백 실행

      fetchImages();

    } catch (e) {
      print("이미지 업로드 중 오류 발생: $e");
      _showDialog("에러 발생으로 다시 시도해주세요.");
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isBookmarkedFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // 로딩 중 상태 표시
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back)),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        bool isBookmarked = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  // Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()), // MainScreen으로 이동
                  );
                },
                icon: Icon(Icons.arrow_back)),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 가게 이미지 컨테이너
                  Image.network(
                    widget.restaurant.imageUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                  // 식당 정보
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.restaurant.description,
                          style: TextStyle(
                            color: Color(0xFFD67151),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.restaurant.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(height: 2),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(widget.restaurant.address),
                                Text(widget.restaurant.openTime),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(widget.restaurant.detail),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // 대표메뉴
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "대표메뉴",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // 대표메뉴 컨테이너
                  Container(
                    color: Color(0xFFEEF5FF),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: PageView.builder(
                              controller: pageController,
                              itemCount: widget.restaurant.menu.length,
                              onPageChanged: (idx) {
                                setState(() {
                                  bannerIndex = idx;
                                });
                              },
                              itemBuilder: (context, index) {
                                final menuItem = widget.restaurant.menu[index];
                                return Row(
                                  children: [
                                    // TODO: 이미지 로딩 중 indicator 추가
                                    Image.network(
                                      menuItem.imageUrl,
                                      height: 180,
                                      width: 180,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            menuItem.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                            ),
                                          ),
                                          Text(
                                            "${menuItem.price}원",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            menuItem.description,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 24),
                          DotsIndicator(
                            dotsCount: widget.restaurant.menu.length,
                            position: bannerIndex,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  // 포토리뷰 안내 텍스트
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "다른 사용자들의\n",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '포토리뷰',
                                style: TextStyle(
                                  color: Color(0xFFD67151),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 포토리뷰 등록하기
                        GestureDetector(
                          onTap: uploadPhotoReview,
                          child: Text(
                            "포토리뷰\n등록하기",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
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
          ),
                  SizedBox(height: 200,)
                ],
              ),
            ),
          ),
          floatingActionButton: SizedBox(
            width: 120,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () => toggleBookmark(isBookmarked),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border_outlined,
                    color: Colors.blue,
                    size: 48,
                  ),
                  // TODO: 북마크 수 업데이트 기능 추가
                  Text(
                    widget.restaurant.bookMarks.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(width: 8), // 위치 조절
                ],
              ),
            ),
          ),
          floatingActionButtonLocation: CustomFABLocation(),
        );
      },
      );
  }
}

