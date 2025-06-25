import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/MenuItem.dart';
import '../models/RestaurantList.dart';
import '../models/cart_model.dart';
import '../pages/menu_page.dart';

class CategoriesPage extends StatefulWidget {
  final String categoryName;

  const CategoriesPage({super.key, required this.categoryName});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<CategoryMenuItem> categoryItems = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadCategoryData();
  }

  Future<void> loadCategoryData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/restaurants_menu_data.json');
      final List<dynamic> data = json.decode(jsonString);

      List<CategoryMenuItem> items = [];

      for (final restaurantData in data) {
        if (restaurantData == null || restaurantData['menuItems'] == null) continue;

        final restaurantName = restaurantData['name'] ?? 'Unknown Restaurant';
        final restaurantIcon = restaurantData['iconPath'] ?? getImageForRestaurant(restaurantName);
        final score = restaurantData['score'] ?? '0.0';
        final duration = restaurantData['duration'] ?? 'Unknown';
        final fee = restaurantData['fee'] ?? 'Unknown';

        final menuItemsData = restaurantData['menuItems'] as List;
        
        for (final itemData in menuItemsData) {
          if (itemData == null) continue;

          try {
            final menuItem = MenuItem.fromJson(itemData);
            
            // 检查分类是否匹配 (支持模糊匹配)
            if (_categoryMatches(menuItem.category, widget.categoryName)) {
              items.add(CategoryMenuItem(
                menuItem: menuItem,
                restaurantName: restaurantName,
                restaurantIcon: restaurantIcon,
                restaurantScore: score,
                restaurantDuration: duration,
                restaurantFee: fee,
              ));
            }
          } catch (e) {
            print('Error parsing menu item: $e');
          }
        }
      }

      setState(() {
        categoryItems = items;
        isLoading = false;
        errorMessage = null;
      });

      print('Loaded ${items.length} items for category: ${widget.categoryName}');

    } catch (e) {
      print('Error loading category data: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load category data: $e';
      });
    }
  }

  // 分类匹配逻辑 - 支持模糊匹配
  bool _categoryMatches(String itemCategory, String selectedCategory) {
    final item = itemCategory.toLowerCase();
    final selected = selectedCategory.toLowerCase();

    // 直接匹配
    if (item == selected) return true;

    // 模糊匹配逻辑
    switch (selected) {
      case 'rice & noodle':
        return item.contains('rice') || 
               item.contains('noodle') || 
               item.contains('noodles') ||
               item.contains('pasta') ||
               item.contains('ramen');
      
      case 'fast food':
        return item.contains('fast') || 
               item.contains('burger') || 
               item.contains('fries') ||
               item.contains('chicken') ||
               item.contains('sandwich');
      
      case 'steak':
        return item.contains('steak') || 
               item.contains('beef') || 
               item.contains('meat');
      
      case 'salad':
        return item.contains('salad') || 
               item.contains('vegetable');
      
      case 'beverages':
        return item.contains('drink') || 
               item.contains('beverage') || 
               item.contains('coffee') ||
               item.contains('tea') ||
               item.contains('juice') ||
               item.contains('soda');
      
      case 'desserts':
        return item.contains('dessert') || 
               item.contains('cake') || 
               item.contains('ice cream') ||
               item.contains('sweet') ||
               item.contains('pudding');
      
      default:
        return item.contains(selected);
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.orange[100],
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 背景装饰
          Positioned(
            bottom: 50,
            right: 20,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/usagi6.png',
                width: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 主要内容
          if (isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading category items...'),
                ],
              ),
            )
          else if (errorMessage != null)
            Center(
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
                      loadCategoryData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (categoryItems.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No items found in ${widget.categoryName}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                // 分类标题和数量
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${categoryItems.length} items found',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 商品列表
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categoryItems.length,
                    itemBuilder: (context, index) {
                      final item = categoryItems[index];
                      return CategoryFoodItem(
                        categoryMenuItem: item,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuPage(
                                restaurantName: item.restaurantName,
                              ),
                            ),
                          );
                        },
                        onAddToCart: () {
                          final cartModel = Provider.of<CartModel>(context, listen: false);
                          
                          if (!cartModel.canAddFromRestaurant(item.restaurantName)) {
                            _showRestaurantChangeDialog(context, () {
                              cartModel.addItem(item.menuItem, restaurantName: item.restaurantName);
                            });
                          } else {
                            cartModel.addItem(item.menuItem, restaurantName: item.restaurantName);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

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
}

// 分类页面的菜单项模型
class CategoryMenuItem {
  final MenuItem menuItem;
  final String restaurantName;
  final String restaurantIcon;
  final String restaurantScore;
  final String restaurantDuration;
  final String restaurantFee;

  CategoryMenuItem({
    required this.menuItem,
    required this.restaurantName,
    required this.restaurantIcon,
    required this.restaurantScore,
    required this.restaurantDuration,
    required this.restaurantFee,
  });
}

// 分类页面的商品组件
class CategoryFoodItem extends StatelessWidget {
  final CategoryMenuItem categoryMenuItem;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const CategoryFoodItem({
    super.key,
    required this.categoryMenuItem,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        final quantity = cart.getItemQuantity(categoryMenuItem.menuItem);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // 商品图片
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        categoryMenuItem.menuItem.imagePath,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // 商品信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 商品名称
                          Text(
                            categoryMenuItem.menuItem.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          
                          // 商品描述
                          Text(
                            categoryMenuItem.menuItem.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          
                          // 餐厅信息
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.asset(
                                  categoryMenuItem.restaurantIcon,
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 20,
                                      height: 20,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.restaurant,
                                        size: 12,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  categoryMenuItem.restaurantName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    categoryMenuItem.restaurantScore,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          
                          // 价格
                          Text(
                            '\$${categoryMenuItem.menuItem.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // 添加/数量控制按钮
                    Column(
                      children: [
                        if (quantity == 0)
                          // 添加按钮
                          GestureDetector(
                            onTap: (){ 
                              onAddToCart();
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          )
                        else
                          // 数量控制按钮
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 减少按钮
                              GestureDetector(
                                onTap: () {
                                  cart.removeItem(categoryMenuItem.menuItem);
                                },
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                ),
                              ),
                              
                              // 数量显示
                              Container(
                                width: 30,
                                alignment: Alignment.center,
                                child: Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              
                              // 增加按钮
                              GestureDetector(
                                onTap: onAddToCart,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.orangeAccent,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}