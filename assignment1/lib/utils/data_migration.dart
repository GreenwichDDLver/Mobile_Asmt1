import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataMigration {
  static final RestaurantService _restaurantService = RestaurantService();

  // 从JSON文件加载数据并迁移到Firebase
  static Future<bool> migrateRestaurantData() async {
    try {
      // 读取JSON文件
      String jsonString = await rootBundle.loadString('assets/data/restaurants_menu_data.json');
      List<dynamic> jsonData = json.decode(jsonString);
      
      // 转换为Restaurant对象列表
      List<Restaurant> restaurants = [];
      DateTime now = DateTime.now();
      
      for (Map<String, dynamic> restaurantData in jsonData) {
        List<MenuItem> menuItems = [];
        
        // 转换菜单项
        for (Map<String, dynamic> itemData in restaurantData['menuItems']) {
          menuItems.add(MenuItem(
            name: itemData['name'] ?? '',
            description: itemData['description'] ?? '',
            price: (itemData['price'] is int) 
                ? (itemData['price'] as int).toDouble() 
                : (itemData['price'] as double?) ?? 0.0,
            category: itemData['category'] ?? '',
            imagePath: itemData['imagePath'] ?? '',
          ));
        }
        
        // 创建Restaurant对象
        Restaurant restaurant = Restaurant(
          name: restaurantData['name'] ?? '',
          iconPath: restaurantData['iconPath'] ?? '',
          score: restaurantData['score'] ?? '',
          duration: restaurantData['duration'] ?? '',
          fee: restaurantData['fee'] ?? '',
          sales: restaurantData['sales'] ?? '',
          menuItems: menuItems,
          createdAt: now,
          updatedAt: now,
          isActive: true,
        );
        
        restaurants.add(restaurant);
      }
      
      // 检查是否已经存在数据
      bool hasExistingData = await _checkExistingData();
      if (hasExistingData) {
        print('Restaurant data already exists in Firebase. Skipping migration.');
        return true;
      }
      
      // 批量添加到Firebase
      await _restaurantService.batchAddRestaurants(restaurants);
      
      print('Successfully migrated ${restaurants.length} restaurants to Firebase');
      return true;
      
    } catch (e) {
      print('Error migrating restaurant data: $e');
      return false;
    }
  }

  // 检查是否已经存在数据
  static Future<bool> _checkExistingData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking existing data: $e');
      return false;
    }
  }

  // 清空Firebase中的商家数据
  static Future<bool> clearRestaurantData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .get();
      
      WriteBatch batch = FirebaseFirestore.instance.batch();
      
      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('Successfully cleared all restaurant data from Firebase');
      return true;
      
    } catch (e) {
      print('Error clearing restaurant data: $e');
      return false;
    }
  }

  // 获取迁移状态
  static Future<Map<String, dynamic>> getMigrationStatus() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .get();
      
      return {
        'hasData': snapshot.docs.isNotEmpty,
        'count': snapshot.docs.length,
        'lastUpdated': snapshot.docs.isNotEmpty 
            ? (snapshot.docs.first.data() as Map<String, dynamic>)['updatedAt']
            : null,
      };
    } catch (e) {
      print('Error getting migration status: $e');
      return {
        'hasData': false,
        'count': 0,
        'lastUpdated': null,
      };
    }
  }
} 