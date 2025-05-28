import 'package:flutter/material.dart';
import '../widgets/banner_header.dart';
import '../widgets/food_item.dart';
import '../widgets/bottom_cart.dart';
import 'checkout_page.dart'; // 导入checkout页面

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int selectedIndex = 0;

  final categories = ['Best Sales','Noodles', 'Dumpling', 'Rice', 'Porridge', 'Beverage'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Order'),
        backgroundColor: Colors.orange[100],
      ),
      body: Stack(
  children: [
    // 背景图片层（固定在底部居中）
    Positioned(
      bottom: 78,
      left: 110,
      right: 0,
      child: Center(
        child: Image.asset(
          'assets/images/usagi7.png',
          width: 115, // 调整控制图片大小
          fit: BoxFit.contain,
        ),
      ),
    ),

    
    Column(
      children: [
        const BannerHeader(),
        const Divider(),
        Expanded(child: _buildBody()),
        BottomCart(
          onCheckoutPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CheckoutPage()),
            );
          },
        ),
      ],
    ),
  ],
),

    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(8), // 给整体添加内边距，避免溢出
      child: Row(
        children: [
          Container(
            width: 120,
            decoration: BoxDecoration(
              color: Colors.yellow[50],
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ), // 用padding代替margin，避免宽度累加
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _CategoryTile(
                  title: categories[index],
                  selected: selectedIndex == index,
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 8), // 左右间距
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
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
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback? onTap;
  const _CategoryTile({required this.title, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.orangeAccent.withOpacity(0.8) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              selected
                  ? [
                    BoxShadow(
                      color: Colors.orangeAccent.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Colors.white : Colors.orangeAccent,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.orangeAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
