import 'package:assignment1/widgets/nav_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:assignment1/models/category.dart';
import 'package:assignment1/models/RestaurantList.dart';
import 'package:assignment1/pages/menu_page.dart';
import 'package:assignment1/pages/search_page.dart';
import 'package:assignment1/pages/personal_page.dart';
import 'package:assignment1/widgets/cart_panel.dart';
import 'package:assignment1/widgets/homepage_banner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<CategoryModel> categories = CategoryModel.getCategories();
  final List<RestaurantListModel> RestaurantList =
      RestaurantListModel.getRestaurantList();

  final PageController _bannerController = PageController(
    viewportFraction: 0.85,
  );
  final List<String> bannerImages = [
    "assets/images/banner1.png",
    "assets/images/banner2.png",
    "assets/images/banner3.png",
  ];
  int _currentBannerIndex = 0;

  bool _showCartPanel = false;

  // Video player controller
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  // 当前选中的城市
  String _selectedCity = "KuaLumpur";

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() async {
    _videoController = VideoPlayerController.asset(
      'assets/videos/background.mp4',
    );
    await _videoController.initialize();
    _videoController.setLooping(true);
    _videoController.setVolume(0.0); // 静音
    _videoController.play();
    setState(() {
      _isVideoInitialized = true;
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _appBarFunction(),
      extendBodyBehindAppBar: true,

      drawer: const NavDrawer(),

      body: Stack(
        children: [
          // 视频背景
          if (_isVideoInitialized)
            Positioned.fill(
              child: Opacity(
                opacity: 0.2,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              ),
            ),

          // 视频未加载时的背景颜色
          if (!_isVideoInitialized) Container(color: Colors.white),

          // 主要内容
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100), // 给透明appbar留空隙
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

          // 购物车面板
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

  // 修改后的appbar，地点可点击选择城市
  AppBar _appBarFunction() {
    return AppBar(
      backgroundColor: Colors.orange[100]?.withOpacity(0.9),
      elevation: 0,
      centerTitle: false,
      title: GestureDetector(
        onTap: _showCitySelectionDialog,
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.black, size: 20),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                _selectedCity,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.black),
          ],
        ),
      ),
      /*
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PersonalHomePage(),
                ),
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
              child: Icon(Icons.person, color: Colors.orange[500], size: 22),
            ),
          ),
        ),
      ],
      */
    );
  }

  // 弹出城市选择对话框
  void _showCitySelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final cities = [
          "KuaLumpur",
          "Penang",
          "Johor Bahru",
          "Ipoh",
          "Melaka",
          "Kota Kinabalu",
          "Kuching",
          "George Town",
        ];

        return SimpleDialog(
          title: const Text("Select a city"),
          children:
              cities.map((city) {
                return SimpleDialogOption(
                  onPressed: () {
                    setState(() {
                      _selectedCity = city;
                    });
                    Navigator.pop(context);
                  },
                  child: Text(city),
                );
              }).toList(),
        );
      },
    );
  }

  // 搜索栏
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
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Row(
          children: const [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 10),
            Text("Search", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // 分类区
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange[100]?.withOpacity(0.9),
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
              Image.asset("assets/images/usagi3.png", width: 130, height: 90),
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
                width:
                    (MediaQuery.of(context).size.width - 20 * 2 - 15 * 3) / 3,
                height: 118,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: categories[index].boxColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 70,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
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

  // 最近活动标题
  Column _recentActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange[100]?.withOpacity(0.9),
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
              Image.asset("assets/images/usagi2.png", width: 135, height: 85),
            ],
          ),
        ),
      ],
    );
  }

  // banner区
  Widget _bannerSection() {
    final bannerDescriptions = [
      '''
Enjoy a delightful pasta day! 🍝

✨ Special Offers:
- Get a 50% discount on your second pasta dish.
- Collect exclusive pasta coupons valid for this week only.

📅 Limited-time offer. Grab it while it lasts!
''',
      '''
🔥 Big Weekend Deal! 🛍️

🎁 Up to 35% OFF on selected menu items.

💡 Use Code: WEEKEND35 at checkout
📌 Valid on orders over \$15.
🕒 Only available from Friday to Sunday!

Don't miss your chance to save big this weekend!
''',
      '''
🍕 Pizza Time Deal! Just \$3.99

Indulge in our cheesy pizza offer:
- Classic Margherita, only \$3.99!
- No hidden fees. No extra charges.

📅 Available daily from 2 PM to 6 PM.
''',
    ];

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
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => BannerPanel(
                          imagePath: bannerImages[index],
                          description: bannerDescriptions[index],
                          onClose: () => Navigator.of(context).pop(),
                        ),
                  );
                },
                child: Padding(
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
                color:
                    _currentBannerIndex == index
                        ? Colors.black
                        : Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // 推荐商家列表
  Column _RestaurantListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 25, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange[100]?.withOpacity(0.9),
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
              Image.asset("assets/images/usagi1.png", width: 130, height: 90),
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
                  MaterialPageRoute(builder: (context) => const MenuPage()),
                );
              },
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
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
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
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
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[600],
                      ),
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
