import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _currentOrders = [
    {
      'id': 'ORD001',
      'shopName': 'Shop A',
      'items': ['Food1', 'Food2'],
      'totalPrice': 45.0,
      'status': 'Status A',
      'orderTime': '2024-01-20 12:30',
      'estimatedTime': '35 minutes',
    },
    {
      'id': 'ORD002',
      'shopName': 'Shop B',
      'items': ['Food3', 'Food4', 'Drink1'],
      'totalPrice': 32.0,
      'status': 'Status B',
      'orderTime': '2024-01-20 11:45',
      'estimatedTime': '20 minutes',
    },
  ];

  final List<Map<String, dynamic>> _orderHistory = [
    {
      'id': 'ORD003',
      'shopName': 'Shop C',
      'items': ['Food5', 'Food6'],
      'totalPrice': 28.0,
      'status': 'Completed',
      'orderTime': '2024-01-19 18:30',
      'canReview': true,
    },
    {
      'id': 'ORD004',
      'shopName': 'Shop D',
      'items': ['Food7', 'Food8'],
      'totalPrice': 55.0,
      'status': 'Completed',
      'orderTime': '2024-01-18 19:15',
      'canReview': false,
    },
    {
      'id': 'ORD005',
      'shopName': 'Shop E',
      'items': ['Food9', 'Food10'],
      'totalPrice': 22.0,
      'status': 'Cancelled',
      'orderTime': '2024-01-17 12:00',
      'canReview': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildCurrentOrders(), _buildOrderHistory()],
      ),
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
                    Text(
                      order['status'],
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
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
                    Text('ETA: ${order['estimatedTime']}'),
                  ],
                ),
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA500),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        _contactDelivery(order);
                      },
                      child: const Text('Contact Rider'),
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
                        color:
                            order['status'] == 'Completed'
                                ? Colors.green[100]
                                : Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order['status'],
                        style: TextStyle(
                          color:
                              order['status'] == 'Completed'
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reordering from ${order['shopName']}')),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
