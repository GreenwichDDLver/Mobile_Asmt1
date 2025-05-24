import 'package:flutter/material.dart';

class RestaurantDetailPlaceholder extends StatelessWidget {
  final String name;

  const RestaurantDetailPlaceholder({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.yellow[200],
      ),
      body: const Center(
        child: Text(
          '这是商家详情页占位页面',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
