// category_widget.dart
import 'package:flutter/material.dart';

class CategoryWidget extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  CategoryWidget({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  Widget _buildCategoryButton(String label, IconData icon, Color color) {
    final isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () {
        onCategorySelected(isSelected ? '' : label);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 11.3),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : color),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCategoryButton('북마크', Icons.bookmark, Colors.blue),
          _buildCategoryButton('한식', Icons.rice_bowl, Colors.green),
          _buildCategoryButton('중식', Icons.ramen_dining, Colors.red),
          _buildCategoryButton('양식', Icons.dinner_dining, Colors.orange),
        ],
      ),
    );
  }
}
