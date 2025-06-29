import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _currentOrders = [];
  List<OrderModel> _orderHistory = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get currentOrders => _currentOrders;
  List<OrderModel> get orderHistory => _orderHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 初始化订单数据
  Future<void> initializeOrders() async {
    _setLoading(true);
    try {
      // 初始化示例订单数据
      await OrderService.initializeSampleOrders();
      _setError(null);
    } catch (e) {
      _setError('初始化订单失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 创建新订单
  Future<String?> createOrder({
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required String paymentMethod,
    required double totalPrice,
    required String shopName,
    required List<Map<String, dynamic>> items,
  }) async {
    _setLoading(true);
    try {
      // 这里需要重构OrderService.createOrder方法以接受更简单的参数
      // 暂时返回一个模拟订单ID
      String orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
      _setError(null);
      return orderId;
    } catch (e) {
      _setError('创建订单失败: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // 更新订单状态
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await OrderService.updateOrderStatus(orderId, newStatus);
      _setError(null);
      return true;
    } catch (e) {
      _setError('更新订单状态失败: $e');
      return false;
    }
  }

  // 删除订单
  Future<bool> deleteOrder(String orderId) async {
    try {
      await OrderService.deleteOrder(orderId);
      _setError(null);
      return true;
    } catch (e) {
      _setError('删除订单失败: $e');
      return false;
    }
  }

  // 获取当前订单流
  Stream<List<OrderModel>> getCurrentOrdersStream() {
    return OrderService.getCurrentOrders();
  }

  // 获取订单历史流
  Stream<List<OrderModel>> getOrderHistoryStream() {
    return OrderService.getOrderHistory();
  }

  // 获取所有订单流
  Stream<List<OrderModel>> getAllOrdersStream() {
    return OrderService.getOrders();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
