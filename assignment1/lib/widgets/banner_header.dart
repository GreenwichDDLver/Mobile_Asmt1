import 'package:flutter/material.dart';
import '../models/RestaurantList.dart';

class BannerHeader extends StatelessWidget {
  final RestaurantListModel restaurant;
  final String sales;

  const BannerHeader({super.key, required this.restaurant, required this.sales});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.orange[50],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              restaurant.iconPath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orangeAccent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${restaurant.score}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.timer, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.duration,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.monetization_on, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.fee,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  sales,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
