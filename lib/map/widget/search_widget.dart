// search_widget.dart
import 'package:flutter/material.dart';

class SearchWidget extends StatefulWidget {
  final bool isVisible;
  final Function(String) onSearch;
  final Function() onClose;
  final List<String> searchHistory;
  final Function() onClearHistory;

  SearchWidget({
    required this.isVisible,
    required this.onSearch,
    required this.onClose,
    required this.searchHistory,
    required this.onClearHistory,
  });

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return SizedBox.shrink();

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: widget.onClose,
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '검색어를 입력하세요.',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        widget.onSearch(value);
                        _searchController.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearch("");
                  },
                ),
              ],
            ),
            if (widget.searchHistory.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onClearHistory,
                    child: Text(
                      '기록 삭제',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.searchHistory.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(widget.searchHistory[index]),
                    onTap: () {
                      widget.onSearch(widget.searchHistory[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
