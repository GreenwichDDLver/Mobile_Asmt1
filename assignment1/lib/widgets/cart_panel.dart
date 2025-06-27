import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assignment1/pages/checkout_page.dart';
import 'package:assignment1/models/cart_model.dart';
import 'package:assignment1/models/MenuItem.dart'; // 添加MenuItem导入
// 添加这个导入
import 'package:assignment1/models/RestaurantList.dart'; // 根据你的实际路径调整

class CartPanel extends StatelessWidget {
  final VoidCallback onClose;

  const CartPanel({super.key, required this.onClose});

  // 从 RestaurantListModel 获取配送费字符串
  String _getDeliveryFeeString(String? restaurantName) {
    if (restaurantName == null) return 'Free';

    final restaurants = RestaurantListModel.getRestaurantList();
    final restaurant = restaurants.firstWhere(
      (r) => r.name == restaurantName,
      orElse:
          () => RestaurantListModel(
            name: '',
            iconPath: '',
            score: '',
            duration: '',
            fee: '\$2.99',
            boxColor: Colors.grey,
          ),
    );
    return restaurant.fee;
  }

  // 从 RestaurantListModel 获取配送费数值
  double _getDeliveryFeeValue(String? restaurantName) {
    if (restaurantName == null) return 0.0;

    final restaurants = RestaurantListModel.getRestaurantList();
    final restaurant = restaurants.firstWhere(
      (r) => r.name == restaurantName,
      orElse:
          () => RestaurantListModel(
            name: '',
            iconPath: '',
            score: '',
            duration: '',
            fee: '\$2.99',
            boxColor: Colors.grey,
          ),
    );

    final feeString = restaurant.fee.replaceAll('\$', '');
    return double.tryParse(feeString) ?? 2.99;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 120,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          height: 460,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Consumer<CartModel>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  // 背景图片层（底部居中）
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.asset(
                        'assets/images/usagi6.png',
                        width: 135,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // 前景内容层
                  Column(
                    children: [
                      // 标题 + 关闭按钮
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Your Cart",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.orange,
                              size: 18,
                            ),
                            onPressed: onClose,
                          ),
                        ],
                      ),
                      const Divider(),

                      // 显示当前餐厅名称
                      if (cart.currentRestaurant != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.restaurant,
                                color: Colors.orange[600],
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cart.currentRestaurant!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Items Header
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ITEMS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(width: 80),
                              Text(
                                'PRICE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 购物车商品列表或空状态
                      Expanded(
                        child:
                            cart.isEmpty
                                ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Your cart is empty',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      // 动态生成购物车商品列表
                                      ...cart.items.entries.map((entry) {
                                        final item = entry.key;
                                        final quantity = entry.value;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: _buildProductItem(
                                            item.imagePath,
                                            item.name,
                                            item.description ?? '',
                                            quantity.toString().padLeft(2, '0'),
                                            '\$${(item.price * quantity).toStringAsFixed(2)}',
                                            Colors.orange.shade50,
                                          ),
                                        );
                                      }).toList(),

                                      const SizedBox(height: 16),

                                      // Order Summary
                                      _buildSummaryRow(
                                        'Subtotal (${cart.totalItems})',
                                        '\$${cart.totalPrice.toStringAsFixed(2)}',
                                      ),
                                      const SizedBox(height: 8),
                                      _buildSummaryRow(
                                        'Shipping total',
                                        _getDeliveryFeeString(
                                          cart.currentRestaurant,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildSummaryRow(
                                        'Taxes',
                                        '\$${(cart.totalPrice * 0.08).toStringAsFixed(2)}',
                                      ),
                                      const Divider(height: 32),
                                      _buildSummaryRow(
                                        'Total',
                                        '\$${(cart.totalPrice * 1.08 + _getDeliveryFeeValue(cart.currentRestaurant)).toStringAsFixed(2)}',
                                        isTotal: true,
                                      ),
                                    ],
                                  ),
                                ),
                      ),

                      const SizedBox(height: 16),

                      // Go to Check Out 按钮
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              cart.isEmpty
                                  ? null
                                  : () {
                                    onClose(); // 先关闭面板
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const CheckoutPage(),
                                      ),
                                    );
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                cart.isEmpty
                                    ? Colors.grey
                                    : Colors.orange.withOpacity(0.9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            cart.isEmpty ? "Cart is Empty" : "Go to Check Out",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(
    String imagePath,
    String name,
    String description,
    String quantity,
    String price,
    Color bgColor,
  ) {
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        // 找到对应的MenuItem
        final item = cart.items.keys.firstWhere(
          (item) => item.name == name && item.imagePath == imagePath,
          orElse:
              () => MenuItem(
                name: name,
                price: 0.0,
                description: description,
                imagePath: imagePath,
                category: '',
              ),
        );

        final currentQuantity = cart.getItemQuantity(item);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$name (×$quantity)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                // 减选按钮
                GestureDetector(
                  onTap: () {
                    cart.removeItem(item);
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[300]!, width: 1),
                    ),
                    child: const Icon(
                      Icons.remove,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 14 : 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 14 : 12,
          ),
        ),
      ],
    );
  }
}
