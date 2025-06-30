import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/order_service.dart';

class FirebaseTest {
  static Future<bool> testConnection() async {
    try {
      // 测试Firestore连接
      await FirebaseFirestore.instance.collection('test').limit(1).get();
      return true;
    } catch (e) {
      print('Firebase connection test failed: $e');
      return false;
    }
  }

  static Future<void> testOrderService() async {
    try {
      print('Start testing the order service...');

      // 测试初始化示例订单
      await OrderService.initializeSampleOrders();
      print('Sample order initialization successful');

      // 测试获取订单流
      final ordersStream = OrderService.getOrders();
      await for (final orders in ordersStream.take(1)) {
        print('Get ${orders.length} orders');
        for (final order in orders) {
          print(
            'OrderID: ${order.id}, Restaurant: ${order.shopName}, Status: ${order.status}',
          );
        }
      }

      print('Order service test completed');
    } catch (e) {
      print('Order service test failed: $e');
    }
  }
}
