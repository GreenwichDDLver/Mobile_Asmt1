import 'package:flutter/material.dart';
import 'package:assignment1/pages/checkout_page.dart';

class CartPanel extends StatelessWidget {
  final VoidCallback onClose;

  const CartPanel({super.key, required this.onClose});

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
          child: Stack(
            children: [
              // 背景图片层（底部居中）
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/images/usagi6.png',
                    width: 135, // 控制图片宽度
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.orange, size: 18),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                  const Divider(),

                  // Items Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
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

                  // 示例商品
                  _buildProductItem(
                    'assets/images/hamberger.png',
                    'Brand',
                    'Burger',
                    'Delicious beef burger',
                    '01',
                    '\$10.99',
                    Colors.red.shade100,
                  ),
                  const SizedBox(height: 12),
                  _buildProductItem(
                    'assets/images/chickencorns.jpg',
                    'Brand',
                    'chicken corns',
                    'Crispy chicken corns',
                    '02',
                    '\$8.99',
                    Colors.yellow.shade100,
                  ),
                  const SizedBox(height: 16),

                  // Order Summary
                  _buildSummaryRow('Subtotal (3)', '\$19.98'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Shipping total', 'Free'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Taxes', '\$2.00'),
                  const Divider(height: 32),
                  _buildSummaryRow('Total', '\$21.98', isTotal: true),
                  const Spacer(),

                  // Go to Check Out 按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CheckoutPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: const Text(
                        "Go to Check Out",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(String imagePath, String brand, String name, String description, String quantity, String price, Color bgColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$name ($quantity)', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(description, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
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
