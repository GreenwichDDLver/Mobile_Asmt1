import 'package:flutter/material.dart';
import 'MenuItem.dart';

class CartModel extends ChangeNotifier {
  final Map<MenuItem, int> _items = {};
  String? _currentRestaurant; // 当前餐厅名称

  // 添加商品到购物车
  void addItem(MenuItem item, {String? restaurantName}) {
    // 如果是不同的餐厅，先清空购物车
    if (restaurantName != null && _currentRestaurant != null && _currentRestaurant != restaurantName) {
      _items.clear();
    }
    
    // 设置当前餐厅
    if (restaurantName != null) {
      _currentRestaurant = restaurantName;
    }
    
    _items.update(item, (quantity) => quantity + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  // 移除商品
  void removeItem(MenuItem item) {
    if (_items.containsKey(item)) {
      if (_items[item]! > 1) {
        _items[item] = _items[item]! - 1;
      } else {
        _items.remove(item);
      }
      
      // 如果购物车为空，清除当前餐厅
      if (_items.isEmpty) {
        _currentRestaurant = null;
      }
      
      notifyListeners();
    }
  }

  // 清空购物车
  void clear() {
    _items.clear();
    _currentRestaurant = null;
    notifyListeners();
  }

  // 设置当前餐厅（用于页面初始化时检查）
  void setCurrentRestaurant(String restaurantName) {
    if (_currentRestaurant != null && _currentRestaurant != restaurantName) {
      // 如果切换到不同餐厅，清空购物车
      _items.clear();
    }
    _currentRestaurant = restaurantName;
    notifyListeners();
  }

  // 检查是否可以添加该餐厅的商品
  bool canAddFromRestaurant(String restaurantName) {
    return _currentRestaurant == null || _currentRestaurant == restaurantName;
  }

  // Getters
  Map<MenuItem, int> get items => Map.unmodifiable(_items);
  String? get currentRestaurant => _currentRestaurant;

  double get totalPrice {
    return _items.entries
        .map((e) => e.key.price * e.value)
        .fold(0.0, (sum, element) => sum + element);
  }

  int get totalItems {
    return _items.values.fold(0, (sum, quantity) => sum + quantity);
  }

  // 检查购物车是否为空
  bool get isEmpty => _items.isEmpty;

  // 获取特定商品的数量
  int getItemQuantity(MenuItem item) {
    return _items[item] ?? 0;
  }
}