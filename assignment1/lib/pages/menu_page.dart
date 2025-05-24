import 'package:flutter/material.dart';
import '../widgets/banner_header.dart';
import '../widgets/food_item.dart';
import '../widgets/bottom_cart.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E5), 
      appBar: AppBar(title: const Text('Order')),
      body: Column(
        children: [
          const BannerHeader(),
          const Divider(),
          Expanded(child: _buildBody()),
          const BottomCart(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Row(
      children: [
        Container(
          width: 100,
          color: Colors.yellow[200],
          child: ListView(
            children: const [
              ListTile(title: Text('Best Sell')),
              ListTile(title: Text('Double Set')),
              ListTile(title: Text('Steamed Dumpling')),
              ListTile(title: Text('Porridge')),
              ListTile(title: Text('Beverage')),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: const [
              FoodItem(
                imagePath: 'assets/images/item1.jpg',
                title: 'Steam Dumpling',
                sub: 'Monthly sales 1000+ The Best Seller',
                price: 12,
              ),
              FoodItem(
                imagePath: 'assets/images/item2.jpg',
                title: 'Dumpling',
                sub: 'Monthly sales 300+ Public Recommend',
                price: 13,
              ),
              FoodItem(
                imagePath: 'assets/images/item3.jpg',
                title: 'Steam Bread',
                sub: 'Monthly sales 200+ Recommend',
                price: 13,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
