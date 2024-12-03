import 'package:cloud_firestore/cloud_firestore.dart';

import 'menu.dart';

class Restaurant {
  String name;
  String address;
  int bookMarks;
  String category;
  String description;
  String detail;
  String imageUrl;
  GeoPoint location; // [latitude, longitude]
  List<Menu> menu; // 메뉴 리스트
  String openTime;

  Restaurant({
    required this.name,
    required this.address,
    required this.bookMarks,
    required this.category,
    required this.description,
    required this.detail,
    required this.imageUrl,
    required this.location,
    required this.menu,
    required this.openTime,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json){
    return Restaurant(
        name: json['name'] ?? '',
        address: json['address'] ?? '',
        bookMarks: json['bookMarks'] ?? 0,
        category: json['category'] ?? '',
        description: json['description'] ?? '',
        detail: json['detail'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        location: json['location'] is GeoPoint
            ? json['location'] as GeoPoint
            : GeoPoint(0.0, 0.0),
        menu: json['menu'] != null
          ? (json['menu'] as List).map((menu)=> Menu.fromJson(menu)).toList()
          : [],
        openTime: json['openTime'] ?? '',
    );
  }
}