import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'menu_page.dart';
import 'package:firebase_core/firebase_core.dart';

class SearchPage extends StatefulWidget {
  final String? userId; // 添加用户ID参数，用于区分不同用户的搜索历史
  
  const SearchPage({Key? key, this.userId}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<String> _searchHistory = [];
  List<String> _hotSearches = ['Suanyu House', 'Food by K', 'Hangzhou Flavor'];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingHistory = true;

  // 获取用户ID，如果没有提供则使用默认用户
  String get _getUserId => widget.userId ?? 'default_user';

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  // 从Firebase加载搜索历史
  Future<void> _loadSearchHistory() async {
    try {
      setState(() {
        _isLoadingHistory = true;
      });

      final doc = await _firestore
          .collection('users')
          .doc(_getUserId)
          .collection('search_history')
          .doc('history')
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final historyList = List<String>.from(data['searches'] ?? []);
        
        setState(() {
          _searchHistory = historyList.reversed.take(10).toList(); // 只保留最近10条记录
          _isLoadingHistory = false;
        });
      } else {
        // 如果没有历史记录，创建空的文档
        await _createEmptyHistoryDocument();
        setState(() {
          _searchHistory = [];
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      print('加载搜索历史失败: $e');
      setState(() {
        _searchHistory = [];
        _isLoadingHistory = false;
      });
    }
  }

  // 创建空的历史记录文档
  Future<void> _createEmptyHistoryDocument() async {
    try {
      await _firestore
          .collection('users')
          .doc(_getUserId)
          .collection('search_history')
          .doc('history')
          .set({
        'searches': [],
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('创建历史记录文档失败: $e');
    }
  }

  // 保存搜索历史到Firebase
  Future<void> _saveSearchToHistory(String query) async {
    if (query.trim().isEmpty) return;

    try {
      // 先从本地历史中移除重复项
      _searchHistory.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
      
      // 添加新的搜索词到开头
      _searchHistory.insert(0, query);
      
      // 只保留最近20条记录
      if (_searchHistory.length > 20) {
        _searchHistory = _searchHistory.take(20).toList();
      }

      // 保存到Firebase
      await _firestore
          .collection('users')
          .doc(_getUserId)
          .collection('search_history')
          .doc('history')
          .set({
        'searches': _searchHistory,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 更新UI
      setState(() {});
      
    } catch (e) {
      print('保存搜索历史失败: $e');
      // 即使保存失败，也更新本地状态
      setState(() {
        _searchHistory.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 20) {
          _searchHistory = _searchHistory.take(20).toList();
        }
      });
    }
  }

  // 清空搜索历史
  Future<void> _clearSearchHistory() async {
    try {
      await _firestore
          .collection('users')
          .doc(_getUserId)
          .collection('search_history')
          .doc('history')
          .update({
        'searches': [],
        'updated_at': FieldValue.serverTimestamp(),
      });

      setState(() {
        _searchHistory.clear();
      });

      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('搜索历史已清空'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('清空搜索历史失败: $e');
      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('清空搜索历史失败，请重试'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // 删除单个搜索历史项
  Future<void> _removeSearchHistoryItem(String query) async {
    try {
      _searchHistory.removeWhere((item) => item == query);

      await _firestore
          .collection('users')
          .doc(_getUserId)
          .collection('search_history')
          .doc('history')
          .update({
        'searches': _searchHistory,
        'updated_at': FieldValue.serverTimestamp(),
      });

      setState(() {});
    } catch (e) {
      print('删除搜索历史项失败: $e');
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;

    // 保存到搜索历史
    _saveSearchToHistory(query);

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
            'image': Icons.fastfood,
            'rating': 4.2,
          },
          {
            'name': 'Result Restaurant 3',
            'image': Icons.fastfood,
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
            'image': Icons.fastfood,
            'rating': 4.2,
          },
          {
            'name': 'Result Restaurant 3',
            'image': Icons.fastfood,
            'rating': 4.8,
          },
        ];
      }
      _isSearching = false;
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
          if (_isLoadingHistory) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            ),
          ] else if (_searchHistory.isNotEmpty) ...[
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
                  onLongPress: () {
                    // 长按删除单个历史记录
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('删除搜索记录'),
                          content: Text('确定要删除 "$history" 吗？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _removeSearchHistoryItem(history);
                              },
                              child: const Text('删除'),
                            ),
                          ],
                        );
                      },
                    );
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(history),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.history,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 14,
                        color: Colors.orange[800],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hot,
                        style: TextStyle(color: Colors.orange[800]),
                      ),
                    ],
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
                ? Image.asset(item['image'], fit: BoxFit.cover)
                : Icon(item['image'], size: 40),
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
                MaterialPageRoute(
                  builder: (context) => MenuPage(restaurantName: item['name']),
                ),
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