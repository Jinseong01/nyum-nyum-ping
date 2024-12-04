import 'package:flutter/material.dart';
import 'package:nyum_nyum_ping/bookmark/book_mark.dart';
import 'package:nyum_nyum_ping/main/main_screen.dart';
import 'package:nyum_nyum_ping/map/map_screen.dart';
import 'package:nyum_nyum_ping/mypage/mypage.dart';
import 'package:nyum_nyum_ping/board/BoardScreen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _menuIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: _menuIndex,
          // 여기 배열에 페이지 생성
          children: [
            MainScreen(),
            BoardScreen(),
            MapScreen(),
            const BookMark(),
            const Mypage(),
          ],
        ),
        bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black, width: 1),
              ),
            ),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: Colors.white, // 네비게이션 바 배경 색
                indicatorColor: Colors.blue.shade100, // 선택된 항목 배경 색
              ),
              child: NavigationBar(
                selectedIndex: _menuIndex,
                onDestinationSelected: (idx) {
                  setState(() {
                    _menuIndex = idx;
                  });
                },
                backgroundColor: Colors.white,
                destinations: [
                  NavigationDestination(
                    icon: Icon(
                      Icons.home_outlined,
                    ),
                    label: "홈",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.article_outlined),
                    label: "게시판",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.map_outlined),
                    label: "지도",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.star_outline_rounded),
                    label: "북마크",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    label: "마이페이지",
                  ),
                ],
              ),
            )));
  }
}
