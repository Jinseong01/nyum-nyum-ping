import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nyum_nyum_ping/main/restaurant_detail.dart';
import 'package:nyum_nyum_ping/main/widgets//custom_location.dart';
import 'package:nyum_nyum_ping/main/widgets/restaurant.dart';
import 'package:nyum_nyum_ping/main/widgets/book_mark_button.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final CustomLocation customLocation = CustomLocation();
  List<Restaurant> restaurants=[];
  String currentLocationWithAddress="";
  GeoPoint? currentLocation;


  @override
  void initState() {
    super.initState();
    // fetchLocation();
    fetchRestaurants(); // 화면 초기화 시 식당 데이터를 가져옴
    print("초기화");
  }

  Future<void> fetchLocation() async {
    currentLocationWithAddress=await customLocation.fetchCurrentLocationAndAddress();
    setState(() {}); // UI 업데이트
  }

  Future<void> fetchRestaurants() async {
    try {
      currentLocationWithAddress=await customLocation.fetchCurrentLocationAndAddress();
      final position = await customLocation.fetchCurrentLocation();
      if (position == null) {
        print("위치를 가져올 수 없습니다.");
        return;
      }
      setState(() {
        currentLocation = GeoPoint(position.latitude, position.longitude);
      });

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Restaurants')
          .get();

      print("식당 데이터 가져오기 성공");

      // Firestore 데이터를 Restaurant 객체로 변환
      final fetchedRestaurants = snapshot.docs.map((doc) {
        return Restaurant.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      // 3. 거리 계산 및 정렬
      final sortedRestaurants = fetchedRestaurants..sort((a, b) {
        final distanceA = _calculateDistance(
          currentLocation!.latitude,
          currentLocation!.longitude,
          a.location.latitude,
          a.location.longitude,
        );
        final distanceB = _calculateDistance(
          currentLocation!.latitude,
          currentLocation!.longitude,
          b.location.latitude,
          b.location.longitude,
        );
        return distanceA.compareTo(distanceB);
      });

      // 4. 상태 업데이트
      setState(() {
        restaurants = sortedRestaurants;
      });

      print("식당 리스트 가져오기 성공: ${restaurants.length}개 식당");
    } catch (e) {
      print("식당 리스트 가져오기 실패: $e");
    }
  }


  // 거리 계산 함수 (Haversine Formula)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    final distance = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    return distance; // 미터 단위 거리 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          RichText(text: TextSpan(
            children: [
              TextSpan(
                text: " 현재 위치:",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                )
              ),
              TextSpan(
                text: currentLocationWithAddress,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                )
              )
            ]
          )),
          RichText(text: TextSpan(
            children: [
              TextSpan(
                text: currentLocationWithAddress,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text: " 기준으로 식당을 알려드립니다.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                )
              )
            ]
          ))
        ],),
      ),
      body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: restaurants.isEmpty
                ? const Center(child: CircularProgressIndicator(),)
                : ListView.builder(
                    itemCount: restaurants.length,
                    itemBuilder: (context, index){
                      final restaurant=restaurants[index];
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context)=>RestaurantDetail(restaurant: restaurant)
                          ));

                        },
                        child: Container(
                          decoration: BoxDecoration(

                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 이미지
                              Image.network(
                                restaurant.imageUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          restaurant.description.length>15
                                          ? '${restaurant.description.substring(0, 15)}...'
                                          : restaurant.description,
                                          style: TextStyle(
                                            color: Color(0xFFD67151),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                            restaurant.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                            restaurant.address.length>10
                                                ? '${restaurant.address.substring(0, 10)}..'
                                                : restaurant.address
                                        ),
                                        // Icon(
                                        //   Icons.bookmark_border_outlined,
                                        //   color: Colors.blue,
                                        // ),
                                        BookMarkButton(
                                          restaurantName: restaurant.name,
                                          category: restaurant.category,
                                          imageUrl: restaurant.imageUrl,
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                            ],
                          )
                        ),
                      );
                    }
                ),
              ),
            ]

          )
      ),
    );
  }
}
