import 'package:flutter/material.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shipping Section
                  _buildInfoRow(
                    'SHIPPING',
                    'Add shipping address',
                    showArrow: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),

                  // Delivery Section
                  _buildInfoRow(
                    'DELIVERY',
                    'Free\nStandard | 3-4 days',
                    showArrow: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),

                  // Payment Section
                  _buildInfoRow(
                    'PAYMENT',
                    'Visa *1234',
                    showArrow: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),

                  // Promos Section
                  _buildInfoRow(
                    'PROMOS',
                    'Apply promo code',
                    showArrow: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),

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
                          Text(
                            'DESCRIPTION',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
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

                  // Product Items
                  _buildProductItem(
                    'assets/images/hamberger.png', // 你需要添加图片资源
                    'Brand',
                    'Product name',
                    'Description',
                    '01',
                    '\$10.99',
                    Colors.red.shade100,
                  ),
                  const SizedBox(height: 16),

                  _buildProductItem(
                    'assets/images/chickencorns.jpg', // 你需要添加图片资源
                    'Brand',
                    'Product name',
                    'Description',
                    '01',
                    '\$8.99',
                    Colors.yellow.shade100,
                  ),
                  const SizedBox(height: 24),

                  // Order Summary
                  _buildSummaryRow('Subtotal (2)', '\$19.98'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Shipping total', 'Free'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Taxes', '\$2.00'),
                  const Divider(height: 32),
                  _buildSummaryRow('Total', '\$21.98', isTotal: true),
                ],
              ),
            ),
          ),

          // Place Order Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Handle place order
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order placed successfully!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Place order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String title,
    String subtitle, {
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color:
                    subtitle.contains('Add') || subtitle.contains('Apply')
                        ? Colors.grey.shade500
                        : Colors.black87,
                height: 1.3,
              ),
            ),
          ),
          if (showArrow)
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade400,
            ),
        ],
      ),
    );
  }

  Widget _buildProductItem(
    String imagePath,
    String brand,
    String productName,
    String description,
    String quantity,
    String price,
    Color backgroundColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.image,
            color: Colors.grey,
            size: 30,
          ), // 替换为实际图片: Image.asset(imagePath, fit: BoxFit.cover)
        ),
        const SizedBox(width: 12),

        // Product Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                brand,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                productName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                'Quantity: $quantity',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        // Price
        Text(
          price,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
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
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
