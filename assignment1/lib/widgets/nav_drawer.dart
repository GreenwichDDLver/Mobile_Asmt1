import 'package:flutter/material.dart';
import 'package:assignment1/pages/personal_page.dart';
import 'package:assignment1/pages/settings_page.dart';
import 'package:assignment1/pages/help_page.dart';
import 'package:assignment1/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/account_manager.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  Future<Map<String, String?>> _getUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    String? username = 'Unknown';
    String? email = user?.email ?? 'No email';
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        username = doc.data()!['username'] ?? 'Unknown';
      }
    }
    return {
      'username': username,
      'email': email,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<Map<String, String?>> (
            future: _getUserInfo(),
            builder: (context, snapshot) {
              String username = 'User';
              String email = '';
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                username = snapshot.data!['username'] ?? 'User';
                email = snapshot.data!['email'] ?? '';
              }
              return UserAccountsDrawerHeader(
                accountName: Text(
                  username,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                accountEmail: Text(
                  email,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                currentAccountPicture: ClipOval(
                  child: Image.asset(
                    "assets/images/UserImage.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/personBackground.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          ListTile(
            onTap: (){
              Navigator.pop(context);
              Navigator.push(context,
                MaterialPageRoute(builder:(context) => const PersonalHomePage()));
            },
            title: const Text(
              "Profile",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            leading: const Icon(
              Icons.person,
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SettingsPage()));
            },
            title: const Text(
              "Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            leading: const Icon(
              Icons.settings,
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HelpPage()));
            },
            title: const Text(
              "Help",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            leading: const Icon(
              Icons.help,
            ),
          ),
          ListTile(
            onTap: () async {
              bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                final FirebaseAuth auth = FirebaseAuth.instance;
                if (auth.currentUser != null) {
                  await auth.signOut();
                }
                await AccountManager.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            title: const Text(
              "Sign Out",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}