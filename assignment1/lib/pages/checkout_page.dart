import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../models/MenuItem.dart';
import '../models/RestaurantList.dart'; 

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _promoCodeController = TextEditingController();
  
  String _selectedPaymentMethod = 'Credit Card';
  double _promoDiscount = 0.0;
  bool _isPromoApplied = false;
  
  // 费用常量
  static const double _taxRate = 0.08; // 8% 税率

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  double _getDeliveryFee(String? restaurantName) {
    if (restaurantName == null) return 0.0;
    
    // 从RestaurantListModel获取配送费
    final restaurants = RestaurantListModel.getRestaurantList();
    final restaurant = restaurants.firstWhere(
      (r) => r.name == restaurantName,
      orElse: () => RestaurantListModel(
        name: '',
        iconPath: '',
        score: '',
        duration: '',
        fee: '\$0.00',
        boxColor: Colors.grey,
      ),
    );
    
    // 解析fee字符串，去掉$符号并转换为double
    final feeString = restaurant.fee.replaceAll('\$', '');
    return double.tryParse(feeString) ?? 0.0;
  }

  void _applyPromoCode() {
    final code = _promoCodeController.text.trim().toUpperCase();
    setState(() {
      switch (code) {
        case 'SAVE10':
          _promoDiscount = 0.10; // 10% 折扣
          _isPromoApplied = true;
          _showSnackBar('Promo code applied! 10% discount', Colors.green);
          break;
        case 'WELCOME':
          _promoDiscount = 0.15; // 15% 折扣
          _isPromoApplied = true;
          _showSnackBar('Welcome discount applied! 15% off', Colors.green);
          break;
        case 'FIRST5':
          _promoDiscount = 5.0; // 固定5元折扣
          _isPromoApplied = true;
          _showSnackBar('First order discount applied! \$5 off', Colors.green);
          break;
        default:
          _promoDiscount = 0.0;
          _isPromoApplied = false;
          _showSnackBar('Invalid promo code', Colors.red);
      }
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmOrder() {
    if (_formKey.currentState?.validate() ?? false) {
      // 这里可以添加实际的订单提交逻辑
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Order Confirmed!'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 64),
                SizedBox(height: 16),
                Text('Your order has been placed successfully!'),
                Text('Estimated delivery: 30-45 minutes'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // 清空购物车
                  Provider.of<CartModel>(context, listen: false).clear();
                  // 返回到主页面
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.orange[100],
        elevation: 0,
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final subtotal = cart.totalPrice;
          final tax = subtotal * _taxRate;
          final deliveryFee = _getDeliveryFee(cart.currentRestaurant);
          final discount = _isPromoApplied 
              ? (_promoDiscount < 1 ? subtotal * _promoDiscount : _promoDiscount)
              : 0.0;
          final total = subtotal + tax + deliveryFee - discount;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 餐厅信息
                  if (cart.currentRestaurant != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order from',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.restaurant, color: Colors.orange),
                              const SizedBox(width: 12),
                              Text(
                                cart.currentRestaurant!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // 订单详情
                  _buildSectionCard(
                    title: 'Order Summary',
                    child: Column(
                      children: cart.items.entries.map((entry) {
                        final item = entry.key;
                        final quantity = entry.value;
                        return _buildOrderItem(item, quantity);
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 用户信息
                  _buildSectionCard(
                    title: 'Delivery Information',
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Delivery Address',
                            prefixIcon: Icon(Icons.location_on),
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your delivery address';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 配送方式
                  _buildSectionCard(
                    title: 'Payment Method',
                    child: Column(
                      children: [
                        _buildRadioOption(
                          'Credit Card',
                          'Pay with credit/debit card',
                          _selectedPaymentMethod,
                          (value) => setState(() => _selectedPaymentMethod = value!),
                        ),
                        _buildRadioOption(
                          'PayPal',
                          'Pay with PayPal account',
                          _selectedPaymentMethod,
                          (value) => setState(() => _selectedPaymentMethod = value!),
                        ),
                        _buildRadioOption(
                          'Cash on Delivery',
                          'Pay when food arrives',
                          _selectedPaymentMethod,
                          (value) => setState(() => _selectedPaymentMethod = value!),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 优惠码
                  _buildSectionCard(
                    title: 'Promo Code',
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _promoCodeController,
                            decoration: const InputDecoration(
                              hintText: 'Enter promo code',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _applyPromoCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 费用明细
                  _buildSectionCard(
                    title: 'Order Total',
                    child: Column(
                      children: [
                        _buildPriceRow('Subtotal', subtotal),
                        _buildPriceRow('Tax (8%)', tax),
                        _buildPriceRow('Delivery Fee', deliveryFee),
                        if (_isPromoApplied)
                          _buildPriceRow('Discount', -discount, color: Colors.green),
                        const Divider(thickness: 2),
                        _buildPriceRow('Total', total, isTotal: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 确认订单按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Confirm Order - \$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      color: Colors.yellow[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(MenuItem item, int quantity) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.imagePath,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${item.price.toStringAsFixed(2)} × $quantity',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${(item.price * quantity).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String value, String subtitle, String groupValue, void Function(String?) onChanged) {
    return RadioListTile<String>(
      title: Text(value),
      subtitle: Text(subtitle),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Colors.orangeAccent,
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color ?? (isTotal ? Colors.orangeAccent : null),
            ),
          ),
        ],
      ),
    );
  }
}