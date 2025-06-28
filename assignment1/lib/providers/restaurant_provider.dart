import 'package:flutter/foundation.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';
import '../utils/data_migration.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantService _restaurantService = RestaurantService();
  
  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  bool _isLoading = false;
  String _error = '';
  bool _isInitialized = false;

  // Getters
  List<Restaurant> get restaurants => _restaurants;
  List<Restaurant> get filteredRestaurants => _filteredRestaurants;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isInitialized => _isInitialized;

  // 初始化数据
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      // 检查是否需要迁移数据
      Map<String, dynamic> migrationStatus = await DataMigration.getMigrationStatus();
      
      if (!migrationStatus['hasData']) {
        print('No data found in Firebase. Starting migration...');
        bool migrationSuccess = await DataMigration.migrateRestaurantData();
        if (!migrationSuccess) {
          throw Exception('Failed to migrate restaurant data');
        }
      }
      
      // 监听商家数据变化
      _restaurantService.getAllRestaurants().listen(
        (restaurants) {
          _restaurants = restaurants;
          _filteredRestaurants = restaurants;
          _setLoading(false);
          _isInitialized = true;
          notifyListeners();
        },
        onError: (error) {
          _setError('Failed to load restaurants: $error');
          _setLoading(false);
        },
      );
      
    } catch (e) {
      _setError('Initialization failed: $e');
      _setLoading(false);
    }
  }

  // 搜索商家
  void searchRestaurants(String query) {
    if (query.isEmpty) {
      _filteredRestaurants = _restaurants;
    } else {
      final lowercaseQuery = query.toLowerCase();
      _filteredRestaurants = _restaurants.where((restaurant) {
        // 搜索餐厅名称
        if (restaurant.name.toLowerCase().contains(lowercaseQuery)) {
          return true;
        }
        
        // 搜索菜品名称
        for (MenuItem item in restaurant.menuItems) {
          if (item.name.toLowerCase().contains(lowercaseQuery) ||
              item.description.toLowerCase().contains(lowercaseQuery)) {
            return true;
          }
        }
        
        // 搜索菜品分类
        for (MenuItem item in restaurant.menuItems) {
          if (item.category.toLowerCase().contains(lowercaseQuery)) {
            return true;
          }
        }
        
        // 搜索餐厅描述信息
        if (restaurant.sales.toLowerCase().contains(lowercaseQuery)) {
          return true;
        }
        
        return false;
      }).toList();
    }
    notifyListeners();
  }

  // 按分类筛选商家
  void filterByCategory(String category) {
    if (category.isEmpty) {
      _filteredRestaurants = _restaurants;
    } else {
      _filteredRestaurants = _restaurants.where((restaurant) {
        return restaurant.menuItems.any((item) => 
          item.category.toLowerCase() == category.toLowerCase()
        );
      }).toList();
    }
    notifyListeners();
  }

  // 获取评分最高的商家
  List<Restaurant> getTopRatedRestaurants({int limit = 5}) {
    List<Restaurant> sorted = List.from(_restaurants);
    sorted.sort((a, b) {
      double scoreA = double.tryParse(a.score) ?? 0;
      double scoreB = double.tryParse(b.score) ?? 0;
      return scoreB.compareTo(scoreA);
    });
    return sorted.take(limit).toList();
  }

  // 添加新商家
  Future<bool> addRestaurant(Restaurant restaurant) async {
    _setLoading(true);
    _clearError();
    
    try {
      String? id = await _restaurantService.addRestaurant(restaurant);
      if (id != null) {
        _setLoading(false);
        return true;
      } else {
        throw Exception('Failed to add restaurant');
      }
    } catch (e) {
      _setError('Failed to add restaurant: $e');
      _setLoading(false);
      return false;
    }
  }

  // 更新商家信息
  Future<bool> updateRestaurant(Restaurant restaurant) async {
    _setLoading(true);
    _clearError();
    
    try {
      bool success = await _restaurantService.updateRestaurant(restaurant);
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Failed to update restaurant: $e');
      _setLoading(false);
      return false;
    }
  }

  // 删除商家
  Future<bool> deleteRestaurant(String id) async {
    _setLoading(true);
    _clearError();
    
    try {
      bool success = await _restaurantService.deleteRestaurant(id);
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Failed to delete restaurant: $e');
      _setLoading(false);
      return false;
    }
  }

  // 根据ID获取商家
  Future<Restaurant?> getRestaurantById(String id) async {
    try {
      return await _restaurantService.getRestaurantById(id);
    } catch (e) {
      _setError('Failed to get restaurant: $e');
      return null;
    }
  }

  // 获取商家统计信息
  Future<Map<String, dynamic>> getStats() async {
    try {
      return await _restaurantService.getRestaurantStats();
    } catch (e) {
      _setError('Failed to get stats: $e');
      return {
        'totalRestaurants': 0,
        'averageScore': 0,
      };
    }
  }

  // 重新迁移数据
  Future<bool> remigrateData() async {
    _setLoading(true);
    _clearError();
    
    try {
      // 清空现有数据
      await DataMigration.clearRestaurantData();
      
      // 重新迁移
      bool success = await DataMigration.migrateRestaurantData();
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Failed to remigrate data: $e');
      _setLoading(false);
      return false;
    }
  }

  // 获取所有分类
  List<String> getAllCategories() {
    Set<String> categories = {};
    for (Restaurant restaurant in _restaurants) {
      for (MenuItem item in restaurant.menuItems) {
        categories.add(item.category);
      }
    }
    return categories.toList()..sort();
  }

  // 获取特定商家的菜单项
  List<MenuItem> getMenuItemsByCategory(String restaurantId, String category) {
    Restaurant? restaurant = _restaurants.firstWhere(
      (r) => r.id == restaurantId,
      orElse: () => Restaurant(
        name: '',
        iconPath: '',
        score: '',
        duration: '',
        fee: '',
        sales: '',
        menuItems: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    return restaurant.menuItems.where((item) => 
      item.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  // 私有方法
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = '';
  }

  // 重置状态
  void reset() {
    _restaurants = [];
    _filteredRestaurants = [];
    _isLoading = false;
    _error = '';
    _isInitialized = false;
    notifyListeners();
  }
} 