import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/order_service.dart';

class FirebaseTest {
  static Future<bool> testConnection() async {
    try {
      // 测试Firestore连接
      await FirebaseFirestore.instance.collection('test').limit(1).get();
      return true;
    } catch (e) {
      print('Firebase连接测试失败: $e');
      return false;
    }
  }

  static Future<void> testOrderService() async {
    try {
      print('开始测试订单服务...');

      // 测试初始化示例订单
      await OrderService.initializeSampleOrders();
      print('示例订单初始化成功');

      // 测试获取订单流
      final ordersStream = OrderService.getOrders();
      await for (final orders in ordersStream.take(1)) {
        print('获取到 ${orders.length} 个订单');
        for (final order in orders) {
          print(
            '订单ID: ${order.id}, 餐厅: ${order.shopName}, 状态: ${order.status}',
          );
        }
      }

      print('订单服务测试完成');
    } catch (e) {
      print('订单服务测试失败: $e');
    }
  }
}
