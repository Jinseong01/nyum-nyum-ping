import 'package:flutter/material.dart';

class CustomFABLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    final double fabX = geometry.scaffoldSize.width - geometry.floatingActionButtonSize.width - 16; // 오른쪽 여백
    final double fabY = geometry.scaffoldSize.height - geometry.floatingActionButtonSize.height - 100; // 아래 여백 (100으로 설정)
    return Offset(fabX, fabY);
  }
}