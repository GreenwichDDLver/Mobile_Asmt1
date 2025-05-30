import 'package:flutter/material.dart';
import 'menu_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchHistory = [];
  List<String> _hotSearches = ['Suanyu House', 'Food by K', 'Hangzhou Flavor'];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchHistory = ['mcdonald'];
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      if (query == 'Hangzhou Flavor') {
        _searchResults = [
          {
            'name': 'Hangzhou Flavor',
            'image': 'assets/images/shop.jpg',
            'rating': 4.5,
          },
          {
            'name': 'Result Restaurant 2',
            'image': Icons.fastfood,  // 使用通用食物图标
            'rating': 4.2,
          },
          {
            'name': 'Result Restaurant 3',
            'image': Icons.fastfood,  // 使用通用食物图标
            'rating': 4.8,
          },
        ];
      } else {
        _searchResults = [
          {
            'name': 'Result Restaurant 1',
            'image': 'assets/images/shop.jpg',
            'rating': 4.5,
          },
          {
            'name': 'Result Restaurant 2',
            'image': Icons.fastfood,  // 使用通用食物图标
            'rating': 4.2,
          },
          {
            'name': 'Result Restaurant 3',
            'image': Icons.fastfood,  // 使用通用食物图标
            'rating': 4.8,
          },
        ];
      }
      _isSearching = false;
    });
  }

  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.orange[100],
        elevation: 0,
        title: Container(
          height: 40,
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search products or stores',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults.clear();
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.orange[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onSubmitted: _performSearch,
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _performSearch(_searchController.text),
            child: const Text('Search', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
      body: _searchResults.isNotEmpty
          ? _buildSearchResults()
          : _buildSearchSuggestions(),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Search History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _clearSearchHistory,
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchHistory.map((history) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = history;
                    _performSearch(history);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(history),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          const Text(
            'Popular Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _hotSearches.map((hot) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = hot;
                  _performSearch(hot);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    hot,
                    style: TextStyle(color: Colors.orange[800]),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return Card(
          color: Colors.orange[50],
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: item['image'] is String
                ? Image.asset(item['image'], fit: BoxFit.cover)  // 对于图片路径
                : Icon(item['image'], size: 40),  // 调整图标大小
            title: Text(item['name']),
            subtitle: Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 16),
                Text(' ${item['rating']}'),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MenuPage()), 
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
