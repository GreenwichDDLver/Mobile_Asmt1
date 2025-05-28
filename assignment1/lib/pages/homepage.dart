import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:assignment1/models/category.dart';
import 'package:assignment1/models/RestaurantList.dart';
import 'package:assignment1/pages/menu_page.dart';
import 'package:assignment1/pages/search_page.dart';
import 'package:assignment1/pages/profile_page.dart'; 
import 'package:assignment1/widgets/cart_panel.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final List<CategoryModel> categories = CategoryModel.getCategories();
  final List<RestaurantListModel> RestaurantList = RestaurantListModel.getRestaurantList();

  final PageController _bannerController = PageController(viewportFraction: 0.85);
  final List<String> bannerImages = [
    "assets/images/banner1.png",
    "assets/images/banner2.png",
    "assets/images/banner3.png",
  ];
  int _currentBannerIndex = 0;

  bool _showCartPanel = false;

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBarFunction(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _searchField(context),
                const SizedBox(height: 20),
                _categorySection(),
                const SizedBox(height: 20),
                _recentActivitiesSection(),
                _bannerSection(),
                _RestaurantListSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),

          // 购物车按钮
          Positioned(
            bottom: 120,
            right: 20,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showCartPanel = !_showCartPanel;
                });
              },
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    "assets/icons/trolley.svg",
                    width: 35,
                    height: 30,
                  ),
                ),
              ),
            ),
          ),

          // 这里替换成调用 CartPanel 组件
          if (_showCartPanel)
            CartPanel(
              onClose: () {
                setState(() {
                  _showCartPanel = false;
                });
              },
            ),
        ],
      ),
    );
  }

//homepage顶部的定位和个人主页进入按钮
  AppBar _appBarFunction() {
    return AppBar(
      backgroundColor: Colors.orange[100],
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.black, size: 20),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              "Shanghai", // 你可以替换为动态定位
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ),

        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                color: Colors.orange[500],
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }


//搜索页面进入
  GestureDetector _searchField(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 10),
            Text(
              "Search",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column _categorySection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
  padding: const EdgeInsets.only(left: 20, right: 20),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          "Category",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Image.asset(
        "assets/images/usagi3.png",
        width: 130,
        height: 90,
      ),
    ],
  ),
),

      const SizedBox(height: 0),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Wrap(
          spacing: 17,
          runSpacing: 10,
          children: List.generate(categories.length, (index) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 20 * 2 - 15 * 3) / 3,
              height: 118,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: categories[index].boxColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 70,
                      width: 80,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          categories[index].iconPath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      categories[index].name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    ],
  );
}

Widget _bannerSection() {
    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: bannerImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 14,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      bannerImages[index],
                      fit: BoxFit.cover,
                      height: 160,
                      width: double.infinity,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(bannerImages.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBannerIndex == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index ? Colors.black : Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
      ],
    );
  }


Column _recentActivitiesSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
  padding: const EdgeInsets.only(left: 20, right: 0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          "Recent Activities",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Image.asset(
        "assets/images/usagi2.png",
        width: 135,
        height: 85,
      ),
    ],
  ),
),

    ],
  );
}

//商家列表
Column _RestaurantListSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
  padding: const EdgeInsets.only(left: 20, right: 4, bottom: 5),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          "Recommended Restaurants",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Image.asset(
        "assets/images/usagi1.png",
        width: 130,
        height: 90,
      ),
    ],
  ),
),

      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: RestaurantList.length,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MenuPage(),
                ),
              );
            },
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),

              child: Row(
                children: [
                  // 左侧图片：加 Padding 实现左边距
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: Image.asset(
                        RestaurantList[index].iconPath,
                        height: 95,
                        width: 95,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            RestaurantList[index].name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                RestaurantList[index].score,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "${RestaurantList[index].duration} | ",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              SvgPicture.asset(
                                "assets/icons/delivery.svg",
                                width: 14,
                                height: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                RestaurantList[index].fee,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ],
  );
}

}

