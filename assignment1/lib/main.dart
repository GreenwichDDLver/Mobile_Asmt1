import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:assignment1/pages/homepage.dart';
import 'package:assignment1/pages/order_page.dart';
import 'package:assignment1/pages/message_page.dart';
import 'package:assignment1/pages/splash_page.dart';
import 'package:assignment1/pages/categories_page.dart';
import 'package:assignment1/models/cart_model.dart';
import 'package:assignment1/providers/restaurant_provider.dart';
import 'pages/login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const SplashPage(), // Start with splash screen
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 1; // Start with HomePage (middle button)

  // List of pages corresponding to bottom navigation tabs
  final List<Widget> _pages = [
    const OrderPage(), // Left button
    const HomePage(), // Middle button
    const MessagePage(), // Right button
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Order',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange[700],
        onTap: _onItemTapped,
      ),
    );
  }
}