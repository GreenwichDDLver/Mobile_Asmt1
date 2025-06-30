import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';

class BottomCart extends StatelessWidget {
  final VoidCallback onCheckoutPressed;
  final VoidCallback onCartPressed;

  const BottomCart({
    super.key, 
    required this.onCheckoutPressed,
    required this.onCartPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        // 如果购物车为空，显示空状态
        if (cart.isEmpty) {
          return Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: const Offset(0, -1),
                  blurRadius: 4,
                )
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onCartPressed,
                  child: const Icon(
                    Icons.shopping_cart_outlined, 
                    size: 28, 
                    color: Colors.grey
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // 购物车有商品时的显示
        return Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: const Offset(0, -1),
                blurRadius: 4,
              )
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onCartPressed,
                child: const Icon(
                  Icons.shopping_cart_outlined, 
                  size: 28, 
                  color: Colors.orange
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cart.totalItems} item${cart.totalItems == 1 ? '' : 's'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Total: \$${cart.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // 显示当前餐厅名称（可选）
              if (cart.currentRestaurant != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cart.currentRestaurant!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: cart.totalItems > 0 ? onCheckoutPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cart.totalItems > 0 
                      ? Colors.orangeAccent 
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}