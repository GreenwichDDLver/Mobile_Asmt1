import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';

class BottomCart extends StatelessWidget {
  const BottomCart({super.key});

  @override
  Widget build(BuildContext context) {
    final total = context.watch<CartModel>().totalPrice;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.shopping_cart, color: Colors.orange),
          const SizedBox(width: 10),
          Text('¥${total.toStringAsFixed(2)}'),
          const Spacer(),
          ElevatedButton(
            onPressed: total == 0
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Checked out ¥${total.toStringAsFixed(2)}')),
                    );
                    context.read<CartModel>().clear();
                  },
            child: const Text('CHECK'),
          ),
        ],
      ),
    );
  }
}
