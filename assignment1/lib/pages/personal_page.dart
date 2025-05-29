import 'package:flutter/material.dart';

class PersonalHomePage extends StatefulWidget {
  const PersonalHomePage({super.key});

  @override
  State<PersonalHomePage> createState() => _PersonalHomePageState();
}

class _PersonalHomePageState extends State<PersonalHomePage> with TickerProviderStateMixin {
  final String _userName = 'Zhang San';

  // Coupon data
  final List<Map<String, dynamic>> _unusedCoupons = [
    {
      'title': '20% Off First Order',
      'discount': '20%',
      'expiry': '2024-12-31',
      'code': 'FIRST20',
    },
    {
      'title': 'Free Delivery',
      'discount': 'Free',
      'expiry': '2024-11-30',
      'code': 'FREEDEL',
    },
    {
      'title': '\$10 Off \$50+',
      'discount': '\$10',
      'expiry': '2024-12-15',
      'code': 'SAVE10',
    },
  ];

  final List<Map<String, dynamic>> _usedCoupons = [
    {
      'title': '15% Off Any Order',
      'discount': '15%',
      'usedDate': '2024-10-15',
      'code': 'SAVE15',
    },
    {
      'title': 'Buy 1 Get 1 Free',
      'discount': 'BOGO',
      'usedDate': '2024-10-10',
      'code': 'BOGO1',
    },
  ];

  final List<Map<String, dynamic>> _expiredCoupons = [
    {
      'title': '25% Off Weekend',
      'discount': '25%',
      'expiry': '2024-09-30',
      'code': 'WEEK25',
    },
    {
      'title': 'Student Discount',
      'discount': '30%',
      'expiry': '2024-08-31',
      'code': 'STUDENT',
    },
  ];

  // Payment methods
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'type': 'Visa',
      'number': '••1234',
      'isDefault': true,
      'icon': Icons.credit_card,
    },
    {
      'type': 'GrabPay',
      'balance': 'RM0',
      'isSetup': false,
      'icon': Icons.account_balance_wallet,
    },
  ];

  // Quick access items
  final List<Map<String, dynamic>> _quickAccessItems = [
    {
      'title': 'My Orders',
      'subtitle': 'View your order history',
      'icon': Icons.receipt_long,
      'action': 'orders',
    },
    {
      'title': 'My Coupons',
      'subtitle': '6 unused coupons available',
      'icon': Icons.local_offer,
      'action': 'coupons',
      'badge': '6',
    },
    {
      'title': 'Favorites',
      'subtitle': 'Your favorite restaurants',
      'icon': Icons.favorite_outline,
      'action': 'favorites',
    },
    {
      'title': 'Manage Addresses',
      'subtitle': 'Delivery addresses',
      'icon': Icons.location_on_outlined,
      'action': 'addresses',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header with gradient background
            _buildHeader(),
            
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Member benefits and Track progress buttons
                    _buildMembershipButtons(),
                    
                    const SizedBox(height: 20),
                    
                    // Dashboard/Activity tabs
                    _buildTabSection(),
                    
                    const SizedBox(height: 20),
                    
                    // Payment methods section
                    _buildPaymentMethodsSection(),
                    
                    const SizedBox(height: 20),
                    
                    // Additional options
                    _buildAdditionalOptionsSection(),
                    
                    const SizedBox(height: 20),

                    // Coupons Section
                    _buildCouponsSection(),

                    const SizedBox(height: 20),
                    
                    // For more value section
                    _buildMoreValueSection(),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange[300]!,
            Colors.orange[400]!,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top row with back button and profile button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                GestureDetector(
                  onTap: () => _navigateToDetailedProfile(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Profile info
            Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange[600],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      'assets/images/UserImage.jpg',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(width: 15),
                
                // Name
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildMembershipButton(
              'Member\'s benefits',
              Icons.card_giftcard,
              Colors.pink[100]!,
              Colors.pink[700]!,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMembershipButton(
              'Track progress',
              Icons.trending_up,
              Colors.amber[100]!,
              Colors.amber[700]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipButton(String title, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.green[600]!, width: 3),
              ),
            ),
            child: Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.green[600],
              ),
            ),
          ),
          const SizedBox(width: 30),
          Text(
            'Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Visa card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue[900],
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'VISA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Default',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Visa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '••1234',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // GrabPay card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple[400]!,
                    Colors.grey[800]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'GX',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'GX Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Set up now',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.local_offer,
            title: 'My Coupons',
            subtitle: '${_unusedCoupons.length} unused coupons available',
            onTap: () => _showCouponsDialog(),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_unusedCoupons.length}',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalOptionsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildOptionCard(
              'Create Family Account',
              Icons.family_restroom,
              Colors.blue[50]!,
              Colors.blue[600]!,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildOptionCard(
              'Business Centre',
              Icons.business_center,
              Colors.orange[50]!,
              Colors.orange[600]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.orange[50],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.orange[700], size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      trailing:
          trailing ??
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildOptionCard(String title, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: iconColor),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreValueSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'For more value',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildValueItem(
            'Partner loyalty programmes',
            null,
            Icons.arrow_forward_ios,
            () {},
          ),
          _buildDivider(),
          _buildValueItem(
            'Subscriptions',
            null,
            Icons.arrow_forward_ios,
            () {},
          ),
          _buildDivider(),
          _buildValueItem(
            'Challenges',
            null,
            Icons.arrow_forward_ios,
            () {},
          ),
          _buildDivider(),
          _buildValueItem(
            'Settings',
            null,
            Icons.arrow_forward_ios,
            () => _showSettingsDialog(),
          ),
          _buildDivider(),
          _buildValueItem(
            'Help Center',
            null,
            Icons.arrow_forward_ios,
            () {},
          ),
          _buildDivider(),
          _buildValueItem(
            'Language',
            'English',
            Icons.arrow_forward_ios,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem(String title, String? subtitle, IconData trailingIcon, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null ? Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ) : null,
      trailing: Icon(trailingIcon, size: 16, color: Colors.grey[400]),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 20,
      endIndent: 20,
    );
  }

  void _navigateToDetailedProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DetailedProfilePage(),
      ),
    );
  }

  void _showCouponsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => DefaultTabController(
            length: 3,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text('My Coupons'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: Colors.orange[700],
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.orange[700],
                      tabs: const [
                        Tab(text: 'Unused'),
                        Tab(text: 'Used'),
                        Tab(text: 'Expired'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildCouponList(_unusedCoupons, 'unused'),
                          _buildCouponList(_usedCoupons, 'used'),
                          _buildCouponList(_expiredCoupons, 'expired'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildCouponList(List<Map<String, dynamic>> coupons, String type) {
    return ListView.builder(
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        final coupon = coupons[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                type == 'unused'
                    ? Colors.green[50]
                    : type == 'used'
                    ? Colors.blue[50]
                    : Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  type == 'unused'
                      ? Colors.green[200]!
                      : type == 'used'
                      ? Colors.blue[200]!
                      : Colors.red[200]!,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coupon['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Discount: ${coupon['discount']}'),
              Text('Code: ${coupon['code']}'),
              if (type == 'unused')
                Text('Expires: ${coupon['expiry']}')
              else if (type == 'used')
                Text('Used: ${coupon['usedDate']}')
              else
                Text('Expired: ${coupon['expiry']}'),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Notifications'),
            SizedBox(height: 8),
            Text('• Privacy & Security'),
            SizedBox(height: 8),
            Text('• Payment Methods'),
            SizedBox(height: 8),
            Text('• Account Settings'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Detailed Profile Page (similar to Grab's second profile screen)
class DetailedProfilePage extends StatefulWidget {
  const DetailedProfilePage({super.key});

  @override
  State<DetailedProfilePage> createState() => _DetailedProfilePageState();
}

class _DetailedProfilePageState extends State<DetailedProfilePage> {
  String _userName = 'Zhang San.';
  String _userEmail = 'Zhangsan@email.com';
  String _deliveryAddress = '123 Main Street, Shanghai, China';
  
  final List<Map<String, dynamic>> _favoriteRestaurants = [
    {
      'name': '4Fingers Crispy Chicken - Kota...',
      'image': 'assets/images/logo-4fingers.jpg',
      'rating': 4.5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header with green gradient
            _buildProfileHeader(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    
                    // Stats row
                    _buildStatsRow(),
                    
                    const SizedBox(height: 30),
                    
                    // Edit profile button
                    _buildEditProfileButton(),
                    
                    const SizedBox(height: 30),
                    
                    // Favorite restaurants section
                    _buildFavoriteRestaurantsSection(),
                    
                    const SizedBox(height: 30),
                    
                    // Reviews section
                    _buildReviewsSection(),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green[400]!,
            Colors.green[600]!,
          ],
        ),
      ),
      child: Column(
        children: [
          // Top row with back button, share and settings
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () => _showEditProfileDialog(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Profile info
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange[600],
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      'assets/images/UserImage.jpg',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Name
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('0', 'likes'),
          _buildStatItem('0', 'followers'),
          _buildStatItem('0', 'followings'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showEditProfileDialog(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text(
            'Edit profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteRestaurantsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Favourite restaurants',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.grey[600]),
            ],
          ),
          
          const SizedBox(height: 15),
          
          // Restaurant card
          Container(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.orange[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/restaurant1.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 40,
                              color: Colors.orange[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _favoriteRestaurants[0]['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Reviews illustration
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.rate_review,
                  size: 60,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 15),
                const Text(
                  'Your food adventures can inspire others',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Write reviews and guide others to delicious discoveries!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Start your food adventure',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    TextEditingController nameController = TextEditingController(text: _userName);
    TextEditingController emailController = TextEditingController(text: _userEmail);
    TextEditingController addressController = TextEditingController(text: _deliveryAddress);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _userName = nameController.text;
                _userEmail = emailController.text;
                _deliveryAddress = addressController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}