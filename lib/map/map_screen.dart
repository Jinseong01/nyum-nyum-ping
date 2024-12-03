import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng _currentPosition = const LatLng(37.5665, 126.9780); // 서울시청 기본 좌표
  String _selectedFilter = ""; // 현재 선택된 필터

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // 초기 사용자 위치 가져오기
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치 서비스를 활성화해주세요.')),
      );
      return;
    }

    // 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 권한이 필요합니다.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치 권한이 영구적으로 거부되었습니다.')),
      );
      return;
    }

    // 현재 위치 가져오기
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _currentPosition, zoom: 15),
    ));
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      // 필터에 따라 마커나 데이터를 갱신할 로직을 추가
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도 화면
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
          ),
          // 검색창과 필터 버튼
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // 검색창
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: '검색어를 입력하세요...',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (query) {
                            // 검색 로직 추가
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          // 검색 버튼 클릭 시 동작
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // 필터 버튼들
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterButton("북마크", Icons.bookmark, "bookmark"),
                      _buildFilterButton("한식", Icons.rice_bowl, "korean"),
                      _buildFilterButton("중식", Icons.ramen_dining, "chinese"),
                      _buildFilterButton("양식", Icons.dinner_dining, "western"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // 지도 화면 탭
        onTap: (index) {
          // 네비게이션 동작 추가
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "홈",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: "게시판",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "지도",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: "즐겨찾기",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "마이페이지",
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, IconData icon, String filterKey) {
    return GestureDetector(
      onTap: () {
        _applyFilter(filterKey);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedFilter == filterKey ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedFilter == filterKey ? Colors.blue : Colors.grey,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: _selectedFilter == filterKey ? Colors.white : Colors.black),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: _selectedFilter == filterKey ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
