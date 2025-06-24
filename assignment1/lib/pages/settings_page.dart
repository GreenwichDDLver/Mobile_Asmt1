import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _merchantNotifications = true;
  bool _deliveryNotifications = true;
  bool _orderStatusNotifications = true;
  bool _promotionalNotifications = false;
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English',
    'Bahasa Malaysia',
    'Chinese (Simplified)',
    'Tamil',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Notifications'),
          _buildNotificationCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('Language & Region'),
          _buildLanguageCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('Privacy'),
          _buildPrivacyCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('Account'),
          _buildAccountCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSwitchTile(
              'Merchant Messages',
              'Receive messages from restaurants and stores',
              _merchantNotifications,
              (value) {
                setState(() {
                  _merchantNotifications = value;
                });
                _showSnackBar('Merchant notifications ${value ? 'enabled' : 'disabled'}');
              },
            ),
            const Divider(),
            _buildSwitchTile(
              'Delivery Updates',
              'Get notified about delivery status changes',
              _deliveryNotifications,
              (value) {
                setState(() {
                  _deliveryNotifications = value;
                });
                _showSnackBar('Delivery notifications ${value ? 'enabled' : 'disabled'}');
              },
            ),
            const Divider(),
            _buildSwitchTile(
              'Order Status',
              'Notifications about order confirmation and preparation',
              _orderStatusNotifications,
              (value) {
                setState(() {
                  _orderStatusNotifications = value;
                });
                _showSnackBar('Order status notifications ${value ? 'enabled' : 'disabled'}');
              },
            ),
            const Divider(),
            _buildSwitchTile(
              'Promotions & Offers',
              'Receive promotional messages and special offers',
              _promotionalNotifications,
              (value) {
                setState(() {
                  _promotionalNotifications = value;
                });
                _showSnackBar('Promotional notifications ${value ? 'enabled' : 'disabled'}');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard() {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.language, color: Colors.orange),
        title: const Text('App Language'),
        subtitle: Text(_selectedLanguage),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _showLanguageDialog(),
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.orange),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showSnackBar('Opening Privacy Policy...'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.orange),
            title: const Text('Data & Security'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showSnackBar('Opening Data & Security settings...'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.orange),
            title: const Text('Location Permissions'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showSnackBar('Opening Location settings...'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person, color: Colors.orange),
            title: const Text('Profile Settings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showSnackBar('Opening Profile settings...'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.payment, color: Colors.orange),
            title: const Text('Payment Methods'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showSnackBar('Opening Payment settings...'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () => _showSignOutDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.orange,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                return RadioListTile<String>(
                  title: Text(_languages[index]),
                  value: _languages[index],
                  groupValue: _selectedLanguage,
                  activeColor: Colors.orange,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                    Navigator.of(context).pop();
                    _showSnackBar('Language changed to $_selectedLanguage');
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out of your account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSnackBar('Signed out successfully');
              },
              child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}