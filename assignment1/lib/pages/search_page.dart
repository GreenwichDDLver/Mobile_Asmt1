import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/restaurant_provider.dart';
import '../models/restaurant.dart';
import '../utils/search_suggestions.dart';
import 'menu_page.dart';

class SearchPage extends StatefulWidget {
  final String? userId;
  
  const SearchPage({Key? key, this.userId}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<String> _searchHistory = [];
  List<String> _searchSuggestions = [];
  bool _isSearching = false;
  bool _isLoadingHistory = true;
  String _currentQuery = '';

  // Get user ID
  String get _getUserId => widget.userId ?? 'default_user';

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    // Initialize Firebase data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().initialize();
    });
  }

  // Load search history from Firebase
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
          _searchHistory = historyList.reversed.take(10).toList();
          _isLoadingHistory = false;
        });
      } else {
        await _createEmptyHistoryDocument();
        setState(() {
          _searchHistory = [];
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      print('Failed to load search history: $e');
      setState(() {
        _searchHistory = [];
        _isLoadingHistory = false;
      });
    }
  }

  // Create empty history document
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
      print('Failed to create history document: $e');
    }
  }

  // Save search history to Firebase
  Future<void> _saveSearchToHistory(String query) async {
    if (query.trim().isEmpty) return;

    try {
      _searchHistory.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
      _searchHistory.insert(0, query);
      
      if (_searchHistory.length > 20) {
        _searchHistory = _searchHistory.take(20).toList();
      }

      await _firestore
          .collection('users')
          .doc(_getUserId)
          .collection('search_history')
          .doc('history')
          .set({
        'searches': _searchHistory,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {});
      
    } catch (e) {
      print('Failed to save search history: $e');
      setState(() {
        _searchHistory.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 20) {
          _searchHistory = _searchHistory.take(20).toList();
        }
      });
    }
  }

  // Clear search history
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Search history cleared'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Failed to clear search history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to clear search history, please try again'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Remove single search history item
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
      print('Failed to remove search history item: $e');
    }
  }

  // Perform search
  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _currentQuery = query.trim();
      _searchSuggestions.clear();
    });

    // Save to search history
    _saveSearchToHistory(query);

    // Use Provider for search
    final provider = context.read<RestaurantProvider>();
    provider.searchRestaurants(query);

    // Delay to show loading state
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  // Real-time search
  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _currentQuery = '';
        _searchSuggestions.clear();
      });
      return;
    }

    setState(() {
      _currentQuery = query.trim();
      _searchSuggestions = SearchSuggestions.getSuggestions(query);
    });

    // Use Provider for real-time search
    final provider = context.read<RestaurantProvider>();
    provider.searchRestaurants(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange[100],
        elevation: 0,
        title: Container(
          height: 40,
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search restaurants or dishes...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchSuggestions.clear();
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
            onChanged: _onSearchChanged,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _performSearch(_searchController.text),
            child: const Text('Search', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, child) {
          // If there's a search query, show search results
          if (_currentQuery.isNotEmpty) {
            if (_isSearching) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Searching...'),
                  ],
                ),
              );
            }

            final results = provider.filteredRestaurants;
            
            if (results.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No results found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try different keywords',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Show search suggestions
                    if (_searchSuggestions.isNotEmpty) ...[
                      const Text(
                        'Search suggestions:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _searchSuggestions.map((suggestion) {
                          return GestureDetector(
                            onTap: () {
                              _searchController.text = suggestion;
                              _performSearch(suggestion);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                suggestion,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              );
            }

            return _buildSearchResults(results);
          }

          // Otherwise show search suggestions
          return _buildSearchSuggestions();
        },
      ),
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Search Record'),
                          content: Text('Are you sure you want to delete "$history"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _removeSearchHistoryItem(history);
                              },
                              child: const Text('Delete'),
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
            children: SearchSuggestions.hotSearches.map((hot) {
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
          const SizedBox(height: 24),
          const Text(
            'Search Tips',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: SearchSuggestions.getSearchTips().map((tip) => 
                _buildSearchTip(tip['icon']!, tip['title']!, tip['description']!)
              ).toList(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Example Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SearchSuggestions.getExampleSearches().map((example) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = example;
                  _performSearch(example);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    example,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTip(String icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<Restaurant> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Found ${results.length} results',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final restaurant = results[index];
              return _buildRestaurantCard(restaurant);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
              builder: (context) => MenuPage(restaurantName: restaurant.name),
                ),
              );
            },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Restaurant image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  restaurant.iconPath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              // Restaurant information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.yellow[600],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.score,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          restaurant.sales,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.duration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.delivery_dining,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.fee,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Menu items: ${restaurant.menuItems.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}