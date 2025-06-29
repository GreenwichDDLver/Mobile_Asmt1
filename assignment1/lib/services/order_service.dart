import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';
import '../models/cart_model.dart';
import '../models/MenuItem.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'orders';

  // 获取所有订单
  static Stream<List<OrderModel>> getOrders() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
        });
  }

  // 获取当前订单（非完成状态）
  static Stream<List<OrderModel>> getCurrentOrders() {
    return _firestore
        .collection(_collectionName)
        .where('status', whereIn: ['Preparing', 'Out for Delivery'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
        });
  }

  // 获取订单历史（完成状态）
  static Stream<List<OrderModel>> getOrderHistory() {
    return _firestore
        .collection(_collectionName)
        .where('status', whereIn: ['Completed', 'Cancelled'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
        });
  }

  // 创建新订单
  static Future<String> createOrder({
    required CartModel cart,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required String paymentMethod,
    double? subtotal,
    double? tax,
    double? deliveryFee,
    double? discount,
    double? finalTotal,
  }) async {
    try {
      // 生成订单ID
      String orderId = _generateOrderId();

      // 获取当前时间
      String orderTime = _formatDateTime(DateTime.now());

      // 估算配送时间
      String estimatedTime = '30-45 minutes';

      // 获取餐厅信息
      String shopName = cart.currentRestaurant ?? 'Unknown Restaurant';
      String shopImage = _getShopImage(shopName);

      // 转换购物车项目为订单项目
      List<OrderItem> orderItems =
          cart.items.entries.map((entry) {
            MenuItem menuItem = entry.key;
            int quantity = entry.value;
            return OrderItem(
              name: menuItem.name,
              price: menuItem.price,
              quantity: quantity,
              imagePath: menuItem.imagePath,
            );
          }).toList();

      // 创建订单对象
      OrderModel order = OrderModel(
        id: orderId,
        shopName: shopName,
        shopImage: shopImage,
        items: orderItems,
        totalPrice: cart.totalPrice,
        status: 'Preparing',
        orderTime: orderTime,
        estimatedTime: estimatedTime,
        shopLocation: _getShopLocation(shopName),
        deliveryLocation: _getDefaultDeliveryLocation(),
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
        paymentMethod: paymentMethod,
        canReview: false,
        subtotal: subtotal,
        tax: tax,
        deliveryFee: deliveryFee,
        discount: discount,
        finalTotal: finalTotal,
      );

      // 保存到Firestore
      await _firestore
          .collection(_collectionName)
          .doc(orderId)
          .set(order.toFirestore());

      return orderId;
    } catch (e) {
      throw Exception('创建订单失败: $e');
    }
  }

  // 更新订单状态
  static Future<void> updateOrderStatus(
    String orderId,
    String newStatus,
  ) async {
    try {
      await _firestore.collection(_collectionName).doc(orderId).update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception('更新订单状态失败: $e');
    }
  }

  // 更新骑手信息
  static Future<void> updateRiderInfo(
    String orderId, {
    String? riderName,
    String? riderImage,
    Duration? timeLeft,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (riderName != null) updates['riderName'] = riderName;
      if (riderImage != null) updates['riderImage'] = riderImage;
      if (timeLeft != null) updates['timeLeft'] = timeLeft.inMinutes;

      await _firestore.collection(_collectionName).doc(orderId).update(updates);
    } catch (e) {
      throw Exception('更新骑手信息失败: $e');
    }
  }

  // 删除订单
  static Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection(_collectionName).doc(orderId).delete();
    } catch (e) {
      throw Exception('删除订单失败: $e');
    }
  }

  // 初始化示例订单数据
  static Future<void> initializeSampleOrders() async {
    try {
      // 检查是否已有订单数据
      QuerySnapshot existingOrders =
          await _firestore.collection(_collectionName).limit(1).get();

      if (existingOrders.docs.isNotEmpty) {
        return; // 已有数据，不需要初始化
      }

      // 创建示例订单
      List<Map<String, dynamic>> sampleOrders = [
        {
          'id': 'ORD001',
          'shopName': 'McDonald\'s',
          'shopImage': 'assets/images/mcdmerchant.jpg',
          'items': [
            {
              'name': 'Big Mac',
              'price': 25.0,
              'quantity': 1,
              'imagePath': 'assets/images/menu_food/big.jpg',
            },
            {
              'name': 'French Fries',
              'price': 20.0,
              'quantity': 1,
              'imagePath': 'assets/images/menu_food/French Fries.png',
            },
          ],
          'totalPrice': 45.0,
          'status': 'Out for Delivery',
          'orderTime': '2024-01-20 12:30',
          'estimatedTime': '35 minutes',
          'shopLocation': {'lat': 37.7649, 'lng': -122.4294},
          'deliveryLocation': {'lat': 37.7849, 'lng': -122.4094},
          'customerName': 'John Doe',
          'customerPhone': '+1234567890',
          'customerAddress': '123 Main St, City',
          'paymentMethod': 'Credit Card',
          'canReview': false,
          'riderName': 'John Doe',
          'riderImage': 'assets/images/riderotw.png',
          'timeLeft': 25,
        },
        {
          'id': 'ORD002',
          'shopName': 'Mixue',
          'shopImage': 'assets/images/mixuemerchant.jpg',
          'items': [
            {
              'name': 'Iced Latte',
              'price': 15.0,
              'quantity': 1,
              'imagePath': 'assets/images/menu_food/Iced Latte.jpg',
            },
            {
              'name': 'Apple Pie',
              'price': 12.0,
              'quantity': 1,
              'imagePath': 'assets/images/menu_food/Apple Pie.jpg',
            },
            {
              'name': 'French Fries',
              'price': 5.0,
              'quantity': 1,
              'imagePath': 'assets/images/menu_food/French Fries.png',
            },
          ],
          'totalPrice': 32.0,
          'status': 'Out for Delivery',
          'orderTime': '2024-01-20 11:45',
          'estimatedTime': '20 minutes',
          'shopLocation': {'lat': 37.7549, 'lng': -122.4394},
          'deliveryLocation': {'lat': 37.7849, 'lng': -122.4094},
          'customerName': 'Jane Smith',
          'customerPhone': '+1234567891',
          'customerAddress': '456 Oak Ave, City',
          'paymentMethod': 'Credit Card',
          'canReview': false,
          'riderName': 'Jane Smith',
          'riderImage': 'assets/images/riderotw.png',
          'timeLeft': 15,
        },
        {
          'id': 'ORD003',
          'shopName': 'Local Restaurant',
          'shopImage': 'assets/images/localrestaurantmerchant.jpg',
          'items': [
            {
              'name': 'Pasta',
              'price': 18.0,
              'quantity': 1,
              'imagePath': 'assets/images/menu_food/Pad Thai.jpg',
            },
            {
              'name': 'Garden Salad',
              'price': 10.0,
              'quantity': 1,
              'imagePath': 'assets/images/menu_food/Garden Salad.jpg',
            },
          ],
          'totalPrice': 28.0,
          'status': 'Preparing',
          'orderTime': '2024-01-20 13:15',
          'estimatedTime': '25 minutes',
          'shopLocation': {'lat': 37.7449, 'lng': -122.4494},
          'deliveryLocation': {'lat': 37.7849, 'lng': -122.4094},
          'customerName': 'Mike Johnson',
          'customerPhone': '+1234567892',
          'customerAddress': '789 Pine St, City',
          'paymentMethod': 'Credit Card',
          'canReview': false,
        },
        {
          'id': 'ORD004',
          'shopName': 'McDonald',
          'shopImage': 'assets/images/mcdmerchant.jpg',
          'items': [
            {
              'name': 'Big Mac',
              'price': 15.0,
              'quantity': 1,
              'imagePath': 'assets/images/menu_food/big.jpg',
            },
            {
              'name': 'French Fries',
              'price': 8.0,
              'quantity': 2,
              'imagePath': 'assets/images/menu_food/French Fries.png',
            },
          ],
          'totalPrice': 31.0,
          'status': 'Completed',
          'orderTime': '2024-01-19 18:30',
          'estimatedTime': '30 minutes',
          'shopLocation': {'lat': 37.7349, 'lng': -122.4594},
          'deliveryLocation': {'lat': 37.7849, 'lng': -122.4094},
          'customerName': 'Alice Brown',
          'customerPhone': '+1234567893',
          'customerAddress': '321 Elm St, City',
          'paymentMethod': 'Credit Card',
          'canReview': true,
        },
        {
          'id': 'ORD005',
          'shopName': 'Hang Zhou Flavour',
          'shopImage': 'assets/images/hangzhouflavour.jpg',
          'items': [
            {
              'name': 'Braised Pork',
              'price': 18.0,
              'quantity': 1,
              'imagePath': 'assets/images/menu_food/Braised-Pork.png',
            },
            {
              'name': 'Fried Rice',
              'price': 11.0,
              'quantity': 1,
              'imagePath': 'assets/images/menu_food/fried rice.jpg',
            },
          ],
          'totalPrice': 29.0,
          'status': 'Completed',
          'orderTime': '2024-01-18 19:15',
          'estimatedTime': '35 minutes',
          'shopLocation': {'lat': 37.7249, 'lng': -122.4694},
          'deliveryLocation': {'lat': 37.7849, 'lng': -122.4094},
          'customerName': 'Bob Wilson',
          'customerPhone': '+1234567894',
          'customerAddress': '654 Maple Dr, City',
          'paymentMethod': 'Credit Card',
          'canReview': false,
        },
        {
          'id': 'ORD006',
          'shopName': 'Food By K',
          'shopImage': 'assets/images/defaultmerchant.jpg',
          'items': [
            {
              'name': 'Pad Thai',
              'price': 13.0,
              'quantity': 1,
              'imagePath': 'assets/images/menu_food/Pad Thai.jpg',
            },
            {
              'name': 'Tom Yum',
              'price': 13.0,
              'quantity': 1,
              'imagePath': 'assets/images/menu_food/Tom Yum.jpg',
            },
          ],
          'totalPrice': 26.0,
          'status': 'Cancelled',
          'orderTime': '2024-01-17 12:00',
          'estimatedTime': '25 minutes',
          'shopLocation': {'lat': 37.7149, 'lng': -122.4794},
          'deliveryLocation': {'lat': 37.7849, 'lng': -122.4094},
          'customerName': 'Carol Davis',
          'customerPhone': '+1234567895',
          'customerAddress': '987 Cedar Ln, City',
          'paymentMethod': 'Credit Card',
          'canReview': false,
        },
        {
          'id': 'ORD007',
          'shopName': 'McDonald',
          'shopImage': 'assets/images/mcdmerchant.jpg',
          'items': [
            {
              'name': 'Double Cheeseburger',
              'price': 13.9,
              'quantity': 1,
              'imagePath': 'assets/images/menu_food/Double Cheeseburger.png',
            },
            {
              'name': 'Apple Pie',
              'price': 5.0,
              'quantity': 2,
              'imagePath': 'assets/images/menu_food/Apple Pie.jpg',
            },
            {
              'name': 'Chicken McNuggets',
              'price': 10.0,
              'quantity': 1,
              'imagePath': 'assets/images/menu_food/Chicken McNuggets.png',
            },
          ],
          'totalPrice': 33.9,
          'status': 'Completed',
          'orderTime': '2024-01-16 15:00',
          'estimatedTime': '28 minutes',
          'shopLocation': {'lat': 37.7049, 'lng': -122.4894},
          'deliveryLocation': {'lat': 37.7849, 'lng': -122.4094},
          'customerName': 'David Lee',
          'customerPhone': '+1234567896',
          'customerAddress': '1234 Oak St, City',
          'paymentMethod': 'Credit Card',
          'canReview': true,
        },
      ];

      // 批量添加示例订单
      WriteBatch batch = _firestore.batch();
      for (var orderData in sampleOrders) {
        String orderId = orderData['id'];
        orderData.remove('id'); // 移除id字段，让Firestore自动生成
        orderData['createdAt'] = FieldValue.serverTimestamp();

        DocumentReference docRef = _firestore
            .collection(_collectionName)
            .doc(orderId);
        batch.set(docRef, orderData);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('初始化示例订单失败: $e');
    }
  }

  // 生成订单ID
  static String _generateOrderId() {
    DateTime now = DateTime.now();
    String timestamp = now.millisecondsSinceEpoch.toString();
    String random = (1000 + (now.microsecond % 9000)).toString();
    return 'ORD$timestamp$random';
  }

  // 格式化日期时间
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // 获取餐厅图片
  static String _getShopImage(String shopName) {
    final name = shopName.toLowerCase();
    if (name.contains('local restaurant')) {
      return 'assets/images/localrestaurantmerchant.jpg';
    } else if (name.contains('hang zhou flavor') ||
        name.contains('hangzhou flavour')) {
      return 'assets/images/hangzhouflavour.jpg';
    } else if (name.contains('mcdonald') ||
        name == 'mcd' ||
        name == "mcdonald's") {
      return 'assets/images/mcdmerchant.jpg';
    } else if (name.contains('mixue')) {
      return 'assets/images/mixuemerchant.jpg';
    } else {
      return 'assets/images/defaultmerchant.jpg';
    }
  }

  // 获取餐厅位置
  static Map<String, double> _getShopLocation(String shopName) {
    switch (shopName.toLowerCase()) {
      case 'mcdonald\'s':
        return {'lat': 37.7649, 'lng': -122.4294};
      case 'mixue':
        return {'lat': 37.7549, 'lng': -122.4394};
      default:
        return {'lat': 37.7449, 'lng': -122.4494};
    }
  }

  // 获取默认配送位置
  static Map<String, double> _getDefaultDeliveryLocation() {
    return {'lat': 37.7849, 'lng': -122.4094};
  }

  // 新增：更新订单评价
  static Future<void> updateOrderReview(
    String orderId,
    int rating,
    String text,
  ) async {
    try {
      await _firestore.collection(_collectionName).doc(orderId).update({
        'reviewRating': rating,
        'reviewText': text,
        'reviewTime': _formatDateTime(DateTime.now()),
      });
    } catch (e) {
      throw Exception('评价订单失败: $e');
    }
  }
}
