import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BannerHeader extends StatelessWidget {
  const BannerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/images/shop.jpg', width: 110, height: 110),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hangzhou flavor',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                // 评分和配送时间一行
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Color.fromARGB(255, 255, 232, 26)),
                    const SizedBox(width: 4),
                    const Text(
                      '4.9',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(width: 20),
                    SvgPicture.asset(
                      "assets/icons/delivery.svg",
                      width: 14,
                      height: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '40min',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 月销单独一行
                const Text(
                  'Monthly sales 2000+',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.star_border),
        ],
      ),
    );
  }
}
