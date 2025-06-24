import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/RestaurantList.dart';
import '../models/MenuItem.dart';
import '../models/cart_model.dart';
import '../widgets/banner_header.dart';
import '../widgets/food_item.dart';
import '../widgets/bottom_cart.dart';
import 'checkout_page.dart';

class MenuPage extends StatefulWidget {
  final String restaurantName;

  const MenuPage({super.key, required this.restaurantName});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int selectedIndex = 0;
  List<MenuItem> menuItems = [];
  List<String> categories = [];
  RestaurantListModel? restaurant;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadMenuData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 当页面加载时，设置当前餐厅到购物车模型
    if (widget.restaurantName.isNotEmpty) {
      Provider.of<CartModel>(context, listen: false)
          .setCurrentRestaurant(widget.restaurantName);
    }
  }

  Future<void> loadMenuData() async {
    try {
      print('Loading menu for restaurant: ${widget.restaurantName}');
      
      final jsonString = await rootBundle.loadString('assets/data/restaurants_menu_data.json');
      final List<dynamic> data = json.decode(jsonString);

      final matchedList = data.where((item) => 
        item != null && 
        item['name'] != null && 
        item['name'] == widget.restaurantName
      ).toList();
      
      if (matchedList.isNotEmpty) {
        final matched = matchedList.first;
        print('Found restaurant data: ${matched['name']}');

        // 安全地处理 menuItems
        final menuItemsData = matched['menuItems'];
        if (menuItemsData != null && menuItemsData is List) {
          final loadedItems = menuItemsData
              .where((e) => e != null) // 过滤 null 项
              .map((e) {
                try {
                  return MenuItem.fromJson(e);
                } catch (error) {
                  print('Error parsing menu item: $error');
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<MenuItem>()
              .toList();

          // 安全地获取类别
          final categoriesSet = <String>{};
          for (final item in loadedItems) {
            if (item.category != null && item.category.isNotEmpty) {
              categoriesSet.add(item.category);
            }
          }

          setState(() {
            menuItems = loadedItems;
            categories = categoriesSet.toList();
            selectedIndex = 0; // 重置选中索引
            restaurant = RestaurantListModel(
              name: matched['name'] ?? 'Unknown Restaurant',
              iconPath: matched['iconPath'] ?? getImageForRestaurant(matched['name'] ?? ''),
              score: matched['score'] ?? '0.0',
              duration: matched['duration'] ?? 'Unknown',
              fee: matched['fee'] ?? 'Unknown',
              boxColor: Colors.orangeAccent,
            );
            isLoading = false;
            errorMessage = null;
          });
          
          print('Loaded ${loadedItems.length} menu items with ${categories.length} categories');
        } else {
          throw Exception('No menu items found for ${widget.restaurantName}');
        }
      } else {
        throw Exception('Restaurant ${widget.restaurantName} not found');
      }
    } catch (e) {
      print('Error loading menu data: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load menu: $e';
      });
    }
  }

  String getImageForRestaurant(String name) {
    switch (name) {
      case 'Hang Zhou Flavor':
        return 'assets/images/logo4.jpg';
      case 'Mcdonald':
        return 'assets/images/Mcd.jpg';
      case 'Food By K':
        return 'assets/images/logo1.jpg';
      case 'SuanYu House':
        return 'assets/images/logo2.jpg';
      case 'UKIYO RAMEN':
        return 'assets/images/logo3.jpg';
      default:
        return 'assets/images/placeholder.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 加载中状态
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order'),
          backgroundColor: Colors.orange[100],
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading menu...'),
            ],
          ),
        ),
      );
    }

    // 错误状态
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order'),
          backgroundColor: Colors.orange[100],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  loadMenuData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // 数据为空状态
    if (restaurant == null || categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order'),
          backgroundColor: Colors.orange[100],
        ),
        body: const Center(
          child: Text('No menu available'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Order'),
        backgroundColor: Colors.orange[100],
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 78,
            left: 110,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/usagi7.png',
                width: 115,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Column(
            children: [
              BannerHeader(restaurant: restaurant!, sales: getSalesText(restaurant!.name)),
              const Divider(),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.yellow[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ListView.builder(
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: ListView(
                        children: _getFilteredMenuItems()
                            .map((item) => FoodItem(
                                  imagePath: item.imagePath,
                                  title: item.name,
                                  sub: item.description,
                                  price: item.price,
                                  menuItem: item, // 传递 MenuItem 对象
                                  onAddToCart: () {
                                    final cartModel = Provider.of<CartModel>(context, listen: false);
                                    
                                    // 检查是否可以添加该餐厅的商品
                                    if (!cartModel.canAddFromRestaurant(widget.restaurantName)) {
                                      // 显示警告对话框
                                      _showRestaurantChangeDialog(context, () {
                                        cartModel.addItem(item, restaurantName: widget.restaurantName);
                                      });
                                    } else {
                                      cartModel.addItem(item, restaurantName: widget.restaurantName);
                                    }
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
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

  // 安全地获取过滤后的菜单项
  List<MenuItem> _getFilteredMenuItems() {
    if (categories.isEmpty || selectedIndex >= categories.length) {
      return [];
    }
    
    final selectedCategory = categories[selectedIndex];
    return menuItems
        .where((item) => item.category == selectedCategory)
        .toList();
  }

  // 显示餐厅切换确认对话框
  void _showRestaurantChangeDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Switch Restaurant?'),
          content: const Text(
            'Your cart contains items from another restaurant. '
            'Adding items from this restaurant will clear your current cart. '
            'Do you want to continue?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  String getSalesText(String name) {
    switch (name) {
      case 'Hang Zhou Flavor':
        return 'Monthly sales 2000+';
      case 'Mcdonald':
        return 'Monthly sales 5000+';
      case 'Food By K':
        return 'Monthly sales 1800+';
      case 'SuanYu House':
        return 'Monthly sales 2200+';
      case 'UKIYO RAMEN':
        return 'Monthly sales 1500+';
      default:
        return '';
    }
  }
}

class _CategoryTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback? onTap;

  const _CategoryTile({required this.title, required this.selected, this.onTap});

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
          boxShadow: selected
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
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.orangeAccent,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}