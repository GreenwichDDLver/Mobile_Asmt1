import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:assignment1/pages/contact_page.dart';
import 'package:assignment1/pages/checkout_page.dart';
import 'package:assignment1/services/order_service.dart';
import 'package:assignment1/models/order.dart';
import 'dart:async';
import 'dart:ui';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _timer;
  late MapController _mapController;

  // 骑手位置信息
  final Map<String, Map<String, dynamic>> _riderLocations = {};

  // 用户配送位置
  final LatLng _userLocation = const LatLng(37.7849, -122.4094);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _mapController = MapController();
    _startLocationUpdates();
    _initializeSampleOrders();
  }

  // 初始化示例订单数据
  void _initializeSampleOrders() async {
    try {
      await OrderService.initializeSampleOrders();
    } catch (e) {
      print('Failed to initialize sample order: $e');
    }
  }

  void _startLocationUpdates() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {
        for (String orderId in _riderLocations.keys) {
          _riderLocations[orderId]!['lat'] += 0.001;
          _riderLocations[orderId]!['lng'] += 0.001;

          Duration currentTime = _riderLocations[orderId]!['timeLeft'];
          if (currentTime.inMinutes > 0) {
            _riderLocations[orderId]!['timeLeft'] = Duration(
              minutes: currentTime.inMinutes - 1,
            );
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.orange[100],
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Current Orders'), Tab(text: 'Order History')],
        ),
        flexibleSpace: Container(
          padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildPatternImage('assets/images/pattern1.png', small: true),
              _buildPatternImage('assets/images/pattern2.png', small: false),
              _buildPatternImage('assets/images/pattern3.png', small: true),
              _buildPatternImage('assets/images/pattern4.png', small: false),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildCurrentOrdersWithMap(), _buildOrderHistory()],
      ),
    );
  }

  Widget _buildPatternImage(String assetPath, {required bool small}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Opacity(
        opacity: 0.50,
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          height: small ? 50 : 80,
        ),
      ),
    );
  }

  Widget _buildCurrentOrdersWithMap() {
    return StreamBuilder<List<OrderModel>>(
      stream: OrderService.getCurrentOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Failed to load order: ${snapshot.error}'));
        }

        List<OrderModel> currentOrders = snapshot.data ?? [];
        List<OrderModel> outForDeliveryOrders =
            currentOrders
                .where((order) => order.status == 'Out for Delivery')
                .toList();

        // 更新骑手位置信息
        _updateRiderLocations(outForDeliveryOrders);

        return SingleChildScrollView(
          child: Column(
            children: [
              if (outForDeliveryOrders.isNotEmpty)
                _buildInteractiveMap(outForDeliveryOrders),
              _buildCurrentOrders(currentOrders),
            ],
          ),
        );
      },
    );
  }

  void _updateRiderLocations(List<OrderModel> outForDeliveryOrders) {
    for (var order in outForDeliveryOrders) {
      if (!_riderLocations.containsKey(order.id)) {
        _riderLocations[order.id] = {
          'lat': order.shopLocation['lat'] ?? 37.7649,
          'lng': order.shopLocation['lng'] ?? -122.4294,
          'riderName': order.riderName ?? 'Unknown Rider',
          'riderImage': order.riderImage ?? 'assets/images/riderotw.png',
          'timeLeft': order.timeLeft ?? Duration(minutes: 25),
        };
      }
    }
  }

  Widget _buildInteractiveMap(List<OrderModel> outForDeliveryOrders) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userLocation,
                initialZoom: 13.0,
                minZoom: 10.0,
                maxZoom: 18.0,
                onTap: (tapPosition, point) {
                  // Handle map tap if needed
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                PolylineLayer(
                  polylines: _buildRoutePolylines(outForDeliveryOrders),
                ),
                MarkerLayer(markers: _buildMapMarkers(outForDeliveryOrders)),
              ],
            ),
            // Zoom controls
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: "zoomIn",
                    mini: true,
                    onPressed: () {
                      final zoom = _mapController.camera.zoom;
                      if (zoom < 18.0) {
                        _mapController.move(
                          _mapController.camera.center,
                          zoom + 1,
                        );
                      }
                    },
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: "zoomOut",
                    mini: true,
                    onPressed: () {
                      final zoom = _mapController.camera.zoom;
                      if (zoom > 10.0) {
                        _mapController.move(
                          _mapController.camera.center,
                          zoom - 1,
                        );
                      }
                    },
                    child: const Icon(Icons.remove),
                  ),
                ],
              ),
            ),
            // Active deliveries info
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '活跃配送',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...outForDeliveryOrders.map((order) {
                      final riderInfo = _riderLocations[order.id]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${order.shopName}: ${riderInfo['timeLeft'].inMinutes}分钟',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            // Legend
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendItem(Colors.blue, 'Restaurant'),
                    const SizedBox(width: 8),
                    _buildLegendItem(Colors.orange, 'Rider'),
                    const SizedBox(width: 8),
                    _buildLegendItem(Colors.green, 'You'),
                  ],
                ),
              ),
            ),
            // Live tracking indicator
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '实时追踪 - ${outForDeliveryOrders.length} 个活跃订单',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMapMarkers(List<OrderModel> outForDeliveryOrders) {
    List<Marker> markers = [];

    // Add user location marker
    markers.add(
      Marker(
        point: _userLocation,
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green, width: 3),
            color: Colors.white,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/UserImage.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.green,
                  child: const Icon(Icons.home, color: Colors.white, size: 20),
                );
              },
            ),
          ),
        ),
      ),
    );

    // Add shop markers
    for (var order in outForDeliveryOrders) {
      final shopLat = order.shopLocation['lat'] ?? 37.7649;
      final shopLng = order.shopLocation['lng'] ?? -122.4294;

      markers.add(
        Marker(
          point: LatLng(shopLat, shopLng),
          width: 30,
          height: 30,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 2),
              color: Colors.white,
            ),
            child: const Icon(Icons.store, color: Colors.blue, size: 16),
          ),
        ),
      );
    }

    // Add rider markers
    for (var order in outForDeliveryOrders) {
      if (_riderLocations.containsKey(order.id)) {
        final riderInfo = _riderLocations[order.id]!;
        markers.add(
          Marker(
            point: LatLng(riderInfo['lat'], riderInfo['lng']),
            width: 35,
            height: 35,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange, width: 2),
                color: Colors.white,
              ),
              child: ClipOval(
                child: Image.asset(
                  riderInfo['riderImage'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.orange,
                      child: const Icon(
                        Icons.delivery_dining,
                        color: Colors.white,
                        size: 18,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      }
    }

    return markers;
  }

  List<Polyline> _buildRoutePolylines(List<OrderModel> outForDeliveryOrders) {
    List<Polyline> polylines = [];

    for (var order in outForDeliveryOrders) {
      if (_riderLocations.containsKey(order.id)) {
        final riderInfo = _riderLocations[order.id]!;
        final shopLat = order.shopLocation['lat'] ?? 37.7649;
        final shopLng = order.shopLocation['lng'] ?? -122.4294;

        polylines.add(
          Polyline(
            points: [
              LatLng(shopLat, shopLng),
              LatLng(riderInfo['lat'], riderInfo['lng']),
              _userLocation,
            ],
            strokeWidth: 3,
            color: Colors.orange.withOpacity(0.7),
          ),
        );
      }
    }

    return polylines;
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildCurrentOrders(List<OrderModel> currentOrders) {
    if (currentOrders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No current orders exist',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currentOrders.length,
      itemBuilder: (context, index) {
        final order = currentOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderHistory() {
    return StreamBuilder<List<OrderModel>>(
      stream: OrderService.getOrderHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Failed to load order history: ${snapshot.error}'));
        }

        List<OrderModel> orderHistory = snapshot.data ?? [];

        if (orderHistory.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No order history exist',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: orderHistory.length,
          itemBuilder: (context, index) {
            final order = orderHistory[index];
            return _buildOrderCard(order);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 订单头部
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    order.shopImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[200],
                        child: const Icon(Icons.store, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.shopName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order Number: ${order.id}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.orderTime,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 历史订单显示删除按钮
                if (order.status == 'Completed' || order.status == 'Cancelled')
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete order',
                    onPressed: () => _showDeleteOrderDialog(order),
                  ),
              ],
            ),
          ),

          // 订单项目
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...order.items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.asset(
                                item.imagePath,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.fastfood,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Quantity: ${item.quantity}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),

                const Divider(),
                // 费用明细
                if (order.subtotal != null)
                  _buildOrderPriceRow('Subtotal of goods', order.subtotal!),
                if (order.tax != null) _buildOrderPriceRow('Taxes', order.tax!),
                if (order.deliveryFee != null)
                  _buildOrderPriceRow('Delivery Fee', order.deliveryFee!),
                if (order.discount != null && order.discount != 0)
                  _buildOrderPriceRow(
                    'Discount',
                    -order.discount!,
                    color: Colors.green,
                  ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${(order.finalTotal ?? order.totalPrice).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),

                if (order.status == 'Out for Delivery' &&
                    order.timeLeft != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Expected ${order.timeLeft!.inMinutes} delivered',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 订单操作按钮
          if (order.status == 'Completed')
            Container(
              padding: const EdgeInsets.all(16),
              child:
                  order.reviewRating == null
                      ? Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _showReviewDialog(order);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Review order'),
                            ),
                          ),
                        ],
                      )
                      : _buildOrderReview(order),
            ),
        ],
      ),
    );
  }

  void _showDeleteOrderDialog(OrderModel order) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete order'),
            content: const Text('Do you want to permanently delete this order? This operation cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await OrderService.deleteOrder(order.id);
                  setState(() {}); // 刷新页面
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showReviewDialog(OrderModel order) {
    int _selectedRating = 5;
    TextEditingController _reviewController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('评价订单'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                    ),
                    onPressed: () {
                      _selectedRating = index + 1;
                      (context as Element).markNeedsBuild();
                    },
                  );
                }),
              ),
              TextField(
                controller: _reviewController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Rating',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancle'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await OrderService.updateOrderReview(
                  order.id,
                  _selectedRating,
                  _reviewController.text.trim(),
                );
                setState(() {});
              },
              child: const Text('Submit', style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderReview(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < (order.reviewRating ?? 0)
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.orange,
                size: 18,
              );
            }),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.reviewText != null && order.reviewText!.isNotEmpty)
                  Text(order.reviewText!, style: const TextStyle(fontSize: 14)),
                if (order.reviewTime != null)
                  Text(
                    order.reviewTime!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Preparing':
        return Colors.blue;
      case 'Out for Delivery':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Preparing':
        return 'Preparing';
      case 'Out for Delivery':
        return 'Delivering';
      case 'Completed':
        return 'Completed';
      case 'Cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Widget _buildOrderPriceRow(String label, double amount, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              color: color ?? Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painters for the map
class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.withOpacity(0.1)
          ..strokeWidth = 1;

    for (int i = 0; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }

    for (int i = 0; i < size.height; i += 30) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }

    final streetPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..strokeWidth = 2;

    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      streetPaint,
    );

    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.7),
      streetPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height),
      streetPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      streetPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class RoutePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;

  RoutePainter({
    required this.start,
    required this.end,
    this.color = Colors.orange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(start.dx, start.dy);

    final controlPoint1 = Offset(
      start.dx + (end.dx - start.dx) * 0.3,
      start.dy,
    );
    final controlPoint2 = Offset(start.dx + (end.dx - start.dx) * 0.7, end.dy);

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      end.dx,
      end.dy,
    );

    const dashWidth = 5.0;
    const dashSpace = 5.0;
    double distance = 0.0;
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        final extractPath = pathMetric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

extension on Path<LatLng> {
  computeMetrics() {}

  void cubicTo(
    double dx,
    double dy,
    double dx2,
    double dy2,
    double dx3,
    double dy3,
  ) {}

  void moveTo(double dx, double dy) {}
}
