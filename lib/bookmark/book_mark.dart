import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nyum_nyum_ping/firebase/auth_service.dart';
import 'package:nyum_nyum_ping/main/widgets/restaurant.dart';
import 'package:nyum_nyum_ping/main/restaurant_detail.dart';

class BookMark extends StatefulWidget {
  const BookMark({super.key});

  @override
  State<BookMark> createState() => _BookMarkState();
}

class _BookMarkState extends State<BookMark> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _bookmarks = [];
  bool _isLoading = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    fetchUserBookmarks();
  }

  /// **북마크 데이터 가져오기**
  Future<void> fetchUserBookmarks() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final userDoc = await _authService.firestore
          .collection('BookMarks')
          .doc(user.email)
          .get();

      if (userDoc.exists) {
        final bookmarks = userDoc.data()?['bookMarks'] as List<dynamic>? ?? [];
        final updatedBookmarks = await Future.wait(bookmarks.map((bookmark) async {
          final restaurantDoc = await _authService.firestore
              .collection('Restaurants')
              .doc(bookmark['name'])
              .get();

          if (restaurantDoc.exists) {
            return {
              'name': bookmark['name'],
              'memo': bookmark['memo'],
              'category': restaurantDoc.data()?['category'] ?? '',
              'imageUrl': restaurantDoc.data()?['imageUrl'] ?? '',
              'address': restaurantDoc.data()?['address'] ?? '',
              'description': restaurantDoc.data()?['description'] ?? '',
              'detail': restaurantDoc.data()?['detail'] ?? '',
              'bookMarks': restaurantDoc.data()?['bookMarks'] ?? 0,
              'openTime': restaurantDoc.data()?['openTime'] ?? '',
              'location': restaurantDoc.data()?['location'],
            };
          }
          return null;
        }).toList());

        setState(() {
          _bookmarks = updatedBookmarks.whereType<Map<String, dynamic>>().toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("북마크 데이터를 가져오는 중 오류 발생: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// **메모 수정 기능**
  Future<void> updateMemo(int index, String newMemo) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final userDocRef = _authService.firestore.collection('BookMarks').doc(user.email);
      final bookmarks = List<Map<String, dynamic>>.from(_bookmarks);
      bookmarks[index]['memo'] = newMemo;

      await userDocRef.update({'bookMarks': bookmarks});

      setState(() {
        _bookmarks[index]['memo'] = newMemo;
      });
    } catch (e) {
      print("메모 업데이트 중 오류 발생: $e");
    }
  }

  /// **북마크 삭제 기능**
  Future<void> deleteBookmark(int index) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final userDocRef = _authService.firestore.collection('BookMarks').doc(user.email);
      final updatedBookmarks = List<Map<String, dynamic>>.from(_bookmarks);
      updatedBookmarks.removeAt(index);

      await userDocRef.update({'bookMarks': updatedBookmarks});

      setState(() {
        _bookmarks.removeAt(index);
      });
    } catch (e) {
      print("북마크 삭제 중 오류 발생: $e");
    }
  }

  Future<Restaurant?> fetchRestaurant(String name) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(name)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return Restaurant.fromJson(data);
      }
    } catch (e) {
      print('Error fetching restaurant: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookmarks = _selectedCategory == null
        ? _bookmarks
        : _bookmarks
            .where((bookmark) => bookmark['category'] == _selectedCategory)
            .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCategoryIcon(
                icon: Icons.rice_bowl,
                label: "한식",
                category: "한식",
              ),
              _buildCategoryIcon(
                icon: Icons.ramen_dining,
                label: "중식",
                category: "중식",
              ),
              _buildCategoryIcon(
                icon: Icons.dinner_dining,
                label: "양식",
                category: "양식",
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredBookmarks.isEmpty
              ? const Center(child: Text("해당 카테고리에 북마크가 없습니다."))
              : ListView.builder(
                  itemCount: filteredBookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = filteredBookmarks[index];
                    return RestaurantCard(
                      imageUrl: bookmark['imageUrl'].isNotEmpty
                          ? bookmark['imageUrl']
                          : 'https://via.placeholder.com/150',
                      name: bookmark['name'],
                      onMemoTap: () {
                        final TextEditingController memoController =
                            TextEditingController(text: bookmark['memo']);

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              bookmark['name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextField(
                                controller: memoController,
                                maxLines: 7,
                                style: const TextStyle(fontSize: 14, color: Colors.black),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '메모를 수정하세요',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  updateMemo(index, memoController.text);
                                },
                                child: const Text('저장'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('취소'),
                              ),
                            ],
                          ),
                        );
                      },
                      onBookmarkToggle: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.grey[200],
                            content: const Text(
                              '북마크를 취소하시겠습니까?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            actionsAlignment: MainAxisAlignment.spaceEvenly,
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  deleteBookmark(index);
                                },
                                child: const Text('네'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text('아니오'),
                              ),
                            ],
                          ),
                        );
                      },
                      onImageTap: () async {
                        final restaurant = await fetchRestaurant(bookmark['name']);
                        if (restaurant != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantDetail(restaurant: restaurant),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('가게 정보를 불러오지 못했습니다.')),
                          );
                        }
                      },
                      isBookmarked: true,
                    );
                  },
                ),
    );
  }

  Widget _buildCategoryIcon({required IconData icon, required String label, required String category}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: _selectedCategory == category ? Colors.blue : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _selectedCategory = _selectedCategory == category ? null : category;
            });
          },
        ),
        Text(
          label,
          style: TextStyle(
            color: _selectedCategory == category ? Colors.blue : Colors.black,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final VoidCallback onMemoTap;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onImageTap;
  final bool isBookmarked;

  const RestaurantCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.onMemoTap,
    required this.onBookmarkToggle,
    required this.onImageTap,
    required this.isBookmarked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onImageTap,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: onMemoTap,
                      icon: const Icon(Icons.edit, size: 20),
                    ),
                    IconButton(
                      onPressed: onBookmarkToggle,
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? Colors.blue : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// 북마크 디자인만 수정하면됨 ㅇㅇ 앱바