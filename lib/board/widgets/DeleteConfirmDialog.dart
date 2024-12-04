import 'package:flutter/material.dart';

class DeleteConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm; // "네" 버튼의 콜백 함수

  const DeleteConfirmDialog({Key? key, required this.onConfirm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // 둥근 모서리
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 다이얼로그 크기를 내용에 맞춤
          children: [
            // 메시지 텍스트
            Text(
              '정말로 삭제하시겠습니까?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24), // 메시지와 버튼 사이 간격

            // "네"와 "아니오" 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 버튼들을 가운데 배치
              children: [
                // "네" 버튼
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // 버튼 배경색
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24), // 둥근 버튼
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // 다이얼로그 닫기
                      onConfirm(); // 확인 버튼 콜백 호출
                    },
                    child: Text(
                      '네',
                      style: TextStyle(
                        color: Colors.white, // 텍스트 색상
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16), // 버튼 간격

                // "아니오" 버튼
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // 버튼 배경색
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24), // 둥근 버튼
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pop(), // 다이얼로그 닫기
                    child: Text(
                      '아니오',
                      style: TextStyle(
                        color: Colors.white, // 텍스트 색상
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
