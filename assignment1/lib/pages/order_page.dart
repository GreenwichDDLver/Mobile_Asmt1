import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:assignment1/pages/contact_page.dart';
import 'package:assignment1/pages/checkout_page.dart';
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

  // Sample rider locations (you would get these from your backend)
  final Map<String, Map<String, dynamic>> _riderLocations = {
    'ORD001': {
      'lat': 37.7749,
      'lng': -122.4194,
      'riderName': 'John Doe',
      'riderImage': 'assets/images/riderotw.png',
      'timeLeft': Duration(minutes: 25),
    },
    'ORD002': {
      'lat': 37.7849,
      'lng': -122.4094,
      'riderName': 'Jane Smith',
      'riderImage': 'assets/images/riderotw.png',
      'timeLeft': Duration(minutes: 15),
    },
    'ORD003': {
      'lat': 37.7649,
      'lng': -122.4294,
      'riderName': 'Mike Johnson',
      'riderImage': 'assets/images/riderotw.png',
      'timeLeft': Duration(minutes: 12),
    },
  };

  final List<Map<String, dynamic>> _currentOrders = [
    {
      'id': 'ORD001',
      'shopName': 'McDonald\'s',
      'shopImage': 'assets/images/mcdmerchant.jpg',
      'items': ['Big Mac', 'Fries'],
      'totalPrice': 45.0,
      'status': 'Out for Delivery',
      'orderTime': '2024-01-20 12:30',
      'estimatedTime': '35 minutes',
      'shopLocation': {'lat': 37.7649, 'lng': -122.4294},
      'deliveryLocation': {'lat': 37.7849, 'lng': -122.4094},
    },
    {
      'id': 'ORD002',
      'shopName': 'Mixue',
      'shopImage': 'assets/images/mixuemerchant.jpg',
      'items': ['Ice Cream', 'Bubble Tea', 'Snack'],
      'totalPrice': 32.0,
      'status': 'Out for Delivery',
      'orderTime': '2024-01-20 11:45',
      'estimatedTime': '20 minutes',
      'shopLocation': {'lat': 37.7549, 'lng': -122.4394},
      'deliveryLocation': {'lat': 37.7849, 'lng': -122.4094},
    },
    {
      'id': 'ORD003',
      'shopName': 'Local Restaurant',
      'shopImage': 'assets/images/mcdmerchant.jpg',
      'items': ['Pasta', 'Salad'],
      'totalPrice': 28.0,
      'status': 'Preparing',
      'orderTime': '2024-01-20 13:15',
      'estimatedTime': '25 minutes',
      'shopLocation': {'lat': 37.7449, 'lng': -122.4494},
      'deliveryLocation': {'lat': 37.7849, 'lng': -122.4094},
    },
  ];

  final List<Map<String, dynamic>> _orderHistory = [
    {
      'id': 'ORD004',
      'shopName': 'Shop C',
      'items': ['Food5', 'Food6'],
      'totalPrice': 28.0,
      'status': 'Completed',
      'orderTime': '2024-01-19 18:30',
      'canReview': true,
    },
    {
      'id': 'ORD005',
      'shopName': 'Shop D',
      'items': ['Food7', 'Food8'],
      'totalPrice': 55.0,
      'status': 'Completed',
      'orderTime': '2024-01-18 19:15',
      'canReview': false,
    },
    {
      'id': 'ORD006',
      'shopName': 'Shop E',
      'items': ['Food9', 'Food10'],
      'totalPrice': 22.0,
      'status': 'Cancelled',
      'orderTime': '2024-01-17 12:00',
      'canReview': false,
    },
  ];

  // User's delivery location (this would typically come from user profile)
  final LatLng _userLocation = const LatLng(37.7849, -122.4094);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _mapController = MapController();
    _startLocationUpdates();
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

  List<Map<String, dynamic>> get _outForDeliveryOrders {
    return _currentOrders
        .where((order) => order['status'] == 'Out for Delivery')
        .toList();
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
          padding: const EdgeInsets.only(
            top: 40,
            left: 16,
            right: 16,
          ),
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
    return SingleChildScrollView(
      child: Column(
        children: [
          if (_outForDeliveryOrders.isNotEmpty) _buildInteractiveMap(),
          _buildCurrentOrders(),
        ],
      ),
    );
  }

  Widget _buildInteractiveMap() {
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
                  polylines: _buildRoutePolylines(),
                ),
                MarkerLayer(
                  markers: _buildMapMarkers(),
                ),
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
                        _mapController.move(_mapController.camera.center, zoom + 1);
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
                        _mapController.move(_mapController.camera.center, zoom - 1);
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
                      'Active Deliveries',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ..._outForDeliveryOrders.map((order) {
                      final riderInfo = _riderLocations[order['id']]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${order['shopName']}: ${riderInfo['timeLeft'].inMinutes}min',
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
                    _buildLegendItem(Colors.blue, 'Shops'),
                    const SizedBox(width: 8),
                    _buildLegendItem(Colors.orange, 'Riders'),
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
                  'Live Tracking - ${_outForDeliveryOrders.length} Active',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMapMarkers() {
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
                  child: const Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 20,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    // Add shop markers
    for (var order in _outForDeliveryOrders) {
      final shopLocation = order['shopLocation'];
      markers.add(
        Marker(
          point: LatLng(shopLocation['lat'], shopLocation['lng']),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 3),
              color: Colors.white,
            ),
            child: ClipOval(
              child: Image.asset(
                order['shopImage'] ?? 'assets/images/mcdmerchant.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.blue,
                    child: const Icon(
                      Icons.store,
                      color: Colors.white,
                      size: 20,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    }

    // Add rider markers
    for (var order in _outForDeliveryOrders) {
      final riderInfo = _riderLocations[order['id']]!;
      markers.add(
        Marker(
          point: LatLng(riderInfo['lat'], riderInfo['lng']),
          width: 60,
          height: 80,
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
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
                          Icons.motorcycle,
                          color: Colors.white,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${riderInfo['timeLeft'].inMinutes}min',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return markers;
  }

  List<Polyline> _buildRoutePolylines() {
    List<Polyline> polylines = [];

    for (var order in _outForDeliveryOrders) {
      final riderInfo = _riderLocations[order['id']]!;
      final shopLocation = order['shopLocation'];
      
      // Route from shop to rider
      polylines.add(
        Polyline(
          points: [
            LatLng(shopLocation['lat'], shopLocation['lng']),
            LatLng(riderInfo['lat'], riderInfo['lng']),
          ],
          color: Colors.orange.withOpacity(0.5),
          strokeWidth: 3.0,
          pattern: StrokePattern.dashed(segments: [10, 5]),
        ),
      );

      // Route from rider to user
      polylines.add(
        Polyline(
          points: [
            LatLng(riderInfo['lat'], riderInfo['lng']),
            _userLocation,
          ],
          color: Colors.orange,
          strokeWidth: 3.0,
        ),
      );
    }

    return polylines;
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildCurrentOrders() {
    if (_currentOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No current orders',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _currentOrders.length,
      itemBuilder: (context, index) {
        final order = _currentOrders[index];
        return Card(
          color: const Color.fromARGB(255, 255, 249, 226),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order['shopName'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order['status']),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        order['status'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  order['items'].join(', '),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order ID: ${order['id']}'),
                    Text(
                      '\$${order['totalPrice']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order Time: ${order['orderTime']}'),
                    if (_riderLocations.containsKey(order['id']))
                      Text(
                        'Time Left: ${_riderLocations[order['id']]!['timeLeft'].inMinutes} min',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.phone, color: Colors.green),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Do you want to call the rider?'),
                            content: const Text('Do you want to call the rider?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('You are calling the rider...'),
                                    ),
                                  );
                                },
                                child: const Text('Call'),
                              ),
                            ],
                          ),
                        );
                      },
                      tooltip: 'Call Rider',
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF8C00),
                            side: const BorderSide(color: Color(0xFFFF8C00)),
                          ),
                          onPressed: () {
                            _showOrderDetail(order);
                          },
                          child: const Text('View Details'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA500),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            _showContactOptions(order);
                          },
                          child: const Text('Contact'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'preparing':
        return Colors.blue;
      case 'out for delivery':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildOrderHistory() {
    if (_orderHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No order history',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orderHistory.length,
      itemBuilder: (context, index) {
        final order = _orderHistory[index];
        return Card(
          color: const Color.fromARGB(255, 255, 249, 226),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order['shopName'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: order['status'] == 'Completed'
                            ? Colors.green[100]
                            : Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order['status'],
                        style: TextStyle(
                          color: order['status'] == 'Completed'
                              ? Colors.green[800]
                              : Colors.red[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  order['items'].join(', '),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order ID: ${order['id']}'),
                    Text(
                      '\$${order['totalPrice']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Order Time: ${order['orderTime']}'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF8C00),
                        side: const BorderSide(color: Color(0xFFFF8C00)),
                      ),
                      onPressed: () {
                        _showOrderDetail(order);
                      },
                      child: const Text('View Details'),
                    ),
                    const SizedBox(width: 8),
                    if (order['canReview'])
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA500),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          _writeReview(order);
                        },
                        child: const Text('Write Review'),
                      )
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA500),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          _reorderFood(order);
                        },
                        child: const Text('Order Again'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOrderDetail(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Order Details - ${order['id']}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shop: ${order['shopName']}'),
                const SizedBox(height: 8),
                Text('Items: ${order['items'].join(', ')}'),
                const SizedBox(height: 8),
                Text('Total: \$${order['totalPrice']}'),
                const SizedBox(height: 8),
                Text('Order Time: ${order['orderTime']}'),
                if (_riderLocations.containsKey(order['id'])) ...[
                  const SizedBox(height: 8),
                  Text('Rider: ${_riderLocations[order['id']]!['riderName']}'),
                  Text(
                    'Time Left: ${_riderLocations[order['id']]!['timeLeft'].inMinutes} minutes',
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showContactOptions(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Contact Options'),
            content: const Text('Who do you want to contact?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToContactPage(order, contactType: 'rider');
                },
                child: const Text('Contact Rider'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToContactPage(order, contactType: 'merchant');
                },
                child: const Text('Contact Merchant'),
              ),
            ],
          ),
    );
  }

  void _navigateToContactPage(
  Map<String, dynamic> order, {
  required String contactType,
}) {
  String contactName;
  String contactAvatar;
  
  if (contactType == 'rider') {
    // Check if rider information exists for this order
    final riderInfo = _riderLocations[order['id']];
    if (riderInfo != null) {
      contactName = riderInfo['riderName'] ?? 'Unknown Rider';
      contactAvatar = 'assets/images/rider1.jpg';
    } else {
      // Fallback if no rider info is available
      contactName = 'Delivery Rider';
      contactAvatar = 'assets/images/rider1.jpg';
    }
  } else {
    contactName = order['shopName'] ?? 'Unknown Shop';
    contactAvatar = order['shopImage'] ?? 'assets/images/mcdmerchant.jpg';
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ContactPage(
        contactName: contactName,
        contactAvatar: contactAvatar,
      ),
    ),
  );
}

  void _contactDelivery(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contacting rider for order ${order['id']}')),
    );
  }

  void _writeReview(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Writing review for order ${order['id']}')),
    );
  }

  void _reorderFood(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CheckoutPage()),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer?.cancel();
    super.dispose();
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
  
  void cubicTo(double dx, double dy, double dx2, double dy2, double dx3, double dy3) {}
  
  void moveTo(double dx, double dy) {}
}
