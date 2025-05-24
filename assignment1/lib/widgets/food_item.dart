import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';

class FoodItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final String sub;
  final double price;

  const FoodItem({
    super.key,
    required this.imagePath,
    required this.title,
    required this.sub,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.yellow[50], // 设置淡黄色背景
      margin: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12), 
            child: Image.asset(
              imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(sub, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 5),
                Text('¥$price', style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.orange),
            onPressed: () {
              Provider.of<CartModel>(context, listen: false)
                  .addItem(title, price);
            },
          )
        ],
      ),
    );
  }
}
