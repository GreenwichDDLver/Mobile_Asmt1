import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant.dart';

class RestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'restaurants';

  // 获取所有商家
  Stream<List<Restaurant>> getAllRestaurants() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Restaurant.fromFirestore(doc)).toList();
    });
  }

  // 根据ID获取商家
  Future<Restaurant?> getRestaurantById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Restaurant.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting restaurant: $e');
      return null;
    }
  }

  // 添加新商家
  Future<String?> addRestaurant(Restaurant restaurant) async {
    try {
      DocumentReference docRef = await _firestore.collection(_collection).add(
        restaurant.toFirestore(),
      );
      return docRef.id;
    } catch (e) {
      print('Error adding restaurant: $e');
      return null;
    }
  }

  // 更新商家信息
  Future<bool> updateRestaurant(Restaurant restaurant) async {
    try {
      if (restaurant.id == null) return false;
      
      await _firestore.collection(_collection).doc(restaurant.id).update(
        restaurant.copyWith(updatedAt: DateTime.now()).toFirestore(),
      );
      return true;
    } catch (e) {
      print('Error updating restaurant: $e');
      return false;
    }
  }

  // 删除商家（软删除）
  Future<bool> deleteRestaurant(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error deleting restaurant: $e');
      return false;
    }
  }

  // 永久删除商家
  Future<bool> permanentlyDeleteRestaurant(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error permanently deleting restaurant: $e');
      return false;
    }
  }

  // 搜索商家
  Stream<List<Restaurant>> searchRestaurants(String query) {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + '\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Restaurant.fromFirestore(doc)).toList();
    });
  }

  // 根据分类筛选商家
  Stream<List<Restaurant>> getRestaurantsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .where('menuItems', arrayContains: {'category': category})
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Restaurant.fromFirestore(doc)).toList();
    });
  }

  // 获取评分最高的商家
  Stream<List<Restaurant>> getTopRatedRestaurants({int limit = 5}) {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Restaurant.fromFirestore(doc)).toList();
    });
  }

  // 批量添加商家（用于数据迁移）
  Future<void> batchAddRestaurants(List<Restaurant> restaurants) async {
    WriteBatch batch = _firestore.batch();
    
    for (Restaurant restaurant in restaurants) {
      DocumentReference docRef = _firestore.collection(_collection).doc();
      batch.set(docRef, restaurant.toFirestore());
    }
    
    await batch.commit();
  }

  // 检查商家是否存在
  Future<bool> restaurantExists(String name) async {
    QuerySnapshot snapshot = await _firestore
        .collection(_collection)
        .where('name', isEqualTo: name)
        .where('isActive', isEqualTo: true)
        .get();
    
    return snapshot.docs.isNotEmpty;
  }

  // 获取商家统计信息
  Future<Map<String, dynamic>> getRestaurantStats() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();
      
      int totalRestaurants = snapshot.docs.length;
      double averageScore = 0;
      
      if (totalRestaurants > 0) {
        double totalScore = 0;
        for (DocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          totalScore += double.tryParse(data['score'] ?? '0') ?? 0;
        }
        averageScore = totalScore / totalRestaurants;
      }
      
      return {
        'totalRestaurants': totalRestaurants,
        'averageScore': averageScore,
      };
    } catch (e) {
      print('Error getting restaurant stats: $e');
      return {
        'totalRestaurants': 0,
        'averageScore': 0,
      };
    }
  }
} 