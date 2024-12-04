import 'package:flutter/material.dart';

class AlreadyLikeDialog extends StatelessWidget {
  const AlreadyLikeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // 둥근 모서리
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 다이얼로그 크기 내용에 맞춤
          children: [
            Text(
              '이 글은 이미 추천하셨습니다.\n더 이상 추천할 수 없습니다.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24), // 텍스트와 버튼 사이 간격
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // 버튼 배경색
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24), // 둥근 버튼
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              onPressed: () => Navigator.pop(context), // 다이얼로그 닫기
              child: Text(
                '확인',
                style: TextStyle(
                  color: Colors.white, // 버튼 텍스트 색상
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
