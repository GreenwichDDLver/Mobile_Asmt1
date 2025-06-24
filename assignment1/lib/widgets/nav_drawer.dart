import 'package:flutter/material.dart';
import 'package:assignment1/pages/personal_page.dart';
import 'package:assignment1/pages/settings_page.dart';
import 'package:assignment1/pages/help_page.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text(
              "Zhang San",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)
            ),
            accountEmail: const Text(
              "Zhangsan@gmail.com",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)
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
              )
            ),
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

        ],
      ),
    );
  }
}